#!/usr/bin/env bash
set -euo pipefail

REPO="slyber-app/slyber-inspector"
BIN_NAME="slyber_test"
INSTALL_DIR="/usr/local/bin"
LISTEN_ADDR="${LISTEN_ADDR:-0.0.0.0:8095}"
VERSION="${VERSION:-latest}"

echo "==> Installing Slyber Inspector..."

OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

case "${OS}" in
  linux|darwin) ;;
  *)
    echo "[ERROR] Unsupported operating system: ${OS}"
    exit 1
    ;;
esac

case "${ARCH}" in
  x86_64|amd64) ARCH="amd64" ;;
  aarch64|arm64) ARCH="arm64" ;;
  *)
    echo "[ERROR] Unsupported architecture: ${ARCH}"
    exit 1
    ;;
esac

ARTIFACT="${BIN_NAME}-${OS}-${ARCH}"

if [ "${VERSION}" = "latest" ]; then
  BASE_URL="https://github.com/${REPO}/releases/latest/download"
else
  BASE_URL="https://github.com/${REPO}/releases/download/${VERSION}"
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

echo "==> Downloading ${ARTIFACT} and SHA256SUMS..."
curl -fsSL "${BASE_URL}/${ARTIFACT}" -o "${TMP_DIR}/${ARTIFACT}"
curl -fsSL "${BASE_URL}/SHA256SUMS" -o "${TMP_DIR}/SHA256SUMS"

echo "==> Verifying SHA256 checksum..."
(
  cd "${TMP_DIR}"
  EXPECTED="$(grep " ${ARTIFACT}\$" SHA256SUMS | awk '{print $1}')"
  if [ -z "${EXPECTED}" ]; then
    echo "[ERROR] Checksum entry for ${ARTIFACT} not found in SHA256SUMS"
    exit 1
  fi
  if command -v sha256sum >/dev/null 2>&1; then
    ACTUAL="$(sha256sum "${ARTIFACT}" | awk '{print $1}')"
  else
    ACTUAL="$(shasum -a 256 "${ARTIFACT}" | awk '{print $1}')"
  fi
  if [ "${EXPECTED}" != "${ACTUAL}" ]; then
    echo "[ERROR] SHA256 mismatch: expected ${EXPECTED}, got ${ACTUAL}"
    exit 1
  fi
)
echo "[OK] Checksum verified."

chmod +x "${TMP_DIR}/${ARTIFACT}"
mv "${TMP_DIR}/${ARTIFACT}" "${INSTALL_DIR}/${BIN_NAME}"

INSTALLED_VER="$("${INSTALL_DIR}/${BIN_NAME}" --version)"
echo "[OK] Installed ${INSTALLED_VER} to ${INSTALL_DIR}/${BIN_NAME}"

if [ "${OS}" = "linux" ] && command -v systemctl >/dev/null 2>&1 && [ "$(id -u)" -eq 0 ]; then
  if ! id -u slyber_test >/dev/null 2>&1; then
    useradd --system --no-create-home --shell /usr/sbin/nologin slyber_test || true
  fi

  cat >/etc/systemd/system/slyber_test.service <<EOF
[Unit]
Description=Slyber Inspector (WebRTC & TURN Visual Verification Suite)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=slyber_test
Group=slyber_test
Environment="LISTEN_ADDR=${LISTEN_ADDR}"
ExecStart=${INSTALL_DIR}/${BIN_NAME} -addr ${LISTEN_ADDR}
Restart=always
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  systemctl enable --now slyber_test
  echo "[OK] systemd service slyber_test started on http://${LISTEN_ADDR}"
else
  echo "==> Run 'slyber_test -addr 127.0.0.1:8095' to start the visual test suite."
fi