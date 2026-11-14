# Slyber Inspector

[![Docs](https://img.shields.io/badge/docs-official-blue.svg)](https://slyber.com/docs/slyber-inspector/slyber-inspector-overview)
[![Website](https://img.shields.io/badge/website-slyber.com-success.svg)](https://slyber.com/slyber-inspector)

Unified visual testing, stream inspection, and load verification environment for **Slyber** real-time communication infrastructure modules.

Designed as a standalone, zero-dependency static Go binary with an embedded web interface to test, benchmark, and inspect media and signaling workloads across the Slyber ecosystem:

- **Slyber TURN Server**: Peer-to-peer WebRTC media relay verification, dynamic credential provisioning (`secret` HMAC-SHA1 and `redis` MD5 key modes), live key revocation, ICE Restart testing, and real-time stream telemetry.
- **Slyber SFU Server**: Interactive multi-party Pion WebRTC v4 selective forwarding simulation across 5 live scenarios — Group Call (Conference & Last-N), 1v1 Roulette Fast Swap, Webinar (Simulcast/SVC Auto-BWE), Full-Duplex AI Voice Pipe (Simple Synth & Multi-Bot Gemini Live with RFC 6464 VAD Barge-In), and a 6-point Gateway & Security Audit suite.
- **Slyber Signaling Server** *(upcoming)*: High-concurrency WebSocket room orchestration, presence state inspection, and session negotiation benchmarks.

## Documentation

- [Slyber Documentation](https://slyber.com/docs) - General architecture, ecosystem overview, and deployment guides.
- [Slyber TURN Server Documentation](https://slyber.com/docs/slyber-turn-server) - Full configuration reference, authentication modes, and production setup for Slyber TURN Server.
- [Slyber SFU Server Documentation](https://slyber.com/docs/slyber-sfu-server) - Architecture guide, Pion single-port mux setup, signaling protocol, SFrame E2EE, and AI Voice Pipe reference.

---

## 1. Quick Start via Docker

Run the visual test environment in a single command:

```bash
sudo docker run -d \
  --name slyber_test \
  --restart unless-stopped \
  -p 8095:8095 \
  ghcr.io/slyber-app/slyber-inspector:latest
```

Open `http://127.0.0.1:8095` (or `http://<SERVER_IP>:8095`) in your browser.

Verify container health and version:

```bash
sudo docker exec slyber_test slyber_test --version
curl -s http://127.0.0.1:8095/api/health
```

---

## 2. Docker Compose Deployment

Download `docker-compose.yml` and start the service:

```bash
curl -fsSLO https://raw.githubusercontent.com/slyber-app/slyber-inspector/main/docker-compose.yml
sudo docker compose up -d
```

---

## 3. One-Command Native Installation (Linux & macOS)

Install the static binary (`linux-amd64`, `linux-arm64`, `darwin-arm64`, or `darwin-amd64`), verify its SHA256 checksum, and automatically configure the `systemd` service on Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/slyber-app/slyber-inspector/main/install.sh | sudo bash
```

Manage the background service on Linux:

```bash
sudo systemctl status slyber_test
sudo journalctl -u slyber_test -f
sudo systemctl restart slyber_test
```

Run manually on macOS or Linux without systemd:

```bash
slyber_test -addr 127.0.0.1:8095
```

---

## 4. Manual Binary Installation

Download the prebuilt static binary for your platform from the latest release:

Linux (x86_64 / amd64):

```bash
curl -fsSL https://github.com/slyber-app/slyber-inspector/releases/latest/download/slyber_test-linux-amd64 -o slyber_test
chmod +x slyber_test
./slyber_test -addr 0.0.0.0:8095
```

Linux (ARM64 / aarch64):

```bash
curl -fsSL https://github.com/slyber-app/slyber-inspector/releases/latest/download/slyber_test-linux-arm64 -o slyber_test
chmod +x slyber_test
./slyber_test -addr 0.0.0.0:8095
```

macOS (Apple Silicon M1/M2/M3/M4):

```bash
curl -fsSL https://github.com/slyber-app/slyber-inspector/releases/latest/download/slyber_test-darwin-arm64 -o slyber_test
chmod +x slyber_test
./slyber_test -addr 127.0.0.1:8095
```

---

## 5. Configuration & CLI Flags

Command-line flags:

- `-addr`: TCP address and port for the web interface and signaling hub (default: `0.0.0.0:8095`).
- `--version`: Print binary version and exit.

Environment variables:

- `LISTEN_ADDR`: Listen address override (e.g., `127.0.0.1:8095` or `0.0.0.0:8095`).
- `PORT`: Port override when `LISTEN_ADDR` is not set (default: `8095`).

---

## 6. Key Capabilities

### Shared Platform & TURN Server Module
- **Unified Multi-Module Workspace**: Switch seamlessly between `Slyber TURN Server`, `Slyber SFU Server`, and `Slyber Signaling Server` from a single interface with a shared media pool.
- **Multi-Pair WebRTC Relay Grid**: Spawn up to 50 concurrent peer-to-peer pairs in a structured row layout (`Peer 1` on the left, `Peer 2` on the right) with configurable `iceTransportPolicy` (`relay` or `all`) and one-click `Ice restart` testing.
- **Persistent Browser Media Pool**: Upload local MP4/WebM video files (saved in browser `IndexedDB`) or generate 4 synthetic Canvas + Web Audio streams (`220–520 Hz`); all settings persist in `localStorage`.
- **TURN Auth & Redis Management**: Supports stateless `HMAC-SHA1` (`secret`) and `RFC 5389 MD5` (`redis`) modes with instant mid-call key revocation (`DEL`).

### Slyber SFU Server Testing Module
- **Pion WebRTC v4 Single-Port Transport**: Connects over `ICE-TCP` (RFC 4571) or `UDP` to port `4443` with full DTLS 1.2 + SRTP encryption, `JWT` (HS256), `Redis`, and `Secret` (HMAC-SHA1) authentication, and optional `SFrame` E2EE validation.
- **Scenario 1 — Group Call (Conference & Last-N)**: Simulates 4 concurrent publishers on a composite GPU canvas with RFC 6464 active speaker switching, dynamic `Last-N` video pausing (`1`, `2`, or `4` active cameras), and per-publisher Redis token revocation.
- **Scenario 2 — 1v1 Roulette Fast Swap**: Keeps 3 candidate peers warmed up on SFU ingress and measures sub-millisecond `roulette_swap` switching without SDP renegotiation or output RTP sequence gaps.
- **Scenario 3 — Webinar & Simulcast/SVC Tiers**: Streams 3 simultaneous quality layers (`s2` 1080p, `s1` 480p, `s0` 180p) to 3 independent viewers with interactive network throttlers (`Auto-BWE` TWCC/GCC simulation or manual layer overrides).
- **Scenario 4 — Full-Duplex AI Voice Pipe & VAD Barge-In**: Tests `/ai/ws` both in Simple Synth mode and in Multiplexed Multi-Bot Gemini Live mode (up to 6 ordered AI agents with custom voices, languages, roles, drag-and-drop speaking order, token usage counters, live transcript, and real microphone RFC 6464 VAD barge-in interruption).
- **Scenario 5 — Gateways & 6-Point RFC Security Audit**: Executes live protocol verification against `/whip/` & `/whep/` endpoints, `/moq/` (`moqt-draft-22`) relay packaging, `/ai/` Opus injection, and a 6-point security audit covering STUN HMAC, DTLS 1.2 ECDHE, Unified Plan SDP BUNDLE separation, SFrame E2EE MLS key ratcheting, Cascade Pipe SSRF filters, and `/inspector/stats` telemetry.

## 7. Uninstallation

### Linux (systemd service & binary)

Run the one line uninstaller to stop the service and remove `/usr/local/bin/slyber_test`:

```bash
curl -fsSL https://raw.githubusercontent.com/slyber-app/slyber-inspector/main/uninstall.sh | sudo bash
```

To also remove the `slyber_test` system user:

```bash
curl -fsSL https://raw.githubusercontent.com/slyber-app/slyber-inspector/main/uninstall.sh | sudo env PURGE_DATA=true bash
```

### Docker

Stop and remove the running container and local image:

```bash
sudo docker rm -f slyber_test
sudo docker rmi ghcr.io/slyber-app/slyber-inspector:latest
```

---

## License

Licensed under the Apache License, Version 2.0. See [Slyber Documentation](https://slyber.com/docs) for more details.