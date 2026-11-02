# Slyber Test Server

Unified visual testing, stream inspection, and load verification environment for **Slyber** real time communication infrastructure modules.

Designed as a standalone, zero dependency static Go binary with an embedded web interface to test, benchmark, and inspect media and signaling workloads across the Slyber ecosystem:

* **Slyber TURN Server** - Peer to peer WebRTC media relay verification, dynamic credential provisioning (`secret` HMAC-SHA1 and `redis` MD5 key modes), live key revocation, and real time stream telemetry.
* **Slyber SFU Server** *(upcoming)* - Multi party selective forwarding simulation, simulcast layer switching, and bandwidth estimation analysis.
* **Slyber Signaling Server** *(upcoming)* - High concurrency WebSocket room orchestration, presence state inspection, and session negotiation benchmarks.

## Documentation

* [Slyber Documentation](https://slyber.com/docs) - General architecture, ecosystem overview, and deployment guides.
* [Slyber TURN Server Documentation](https://slyber.com/docs/slyber-turn-server) - Full configuration reference, authentication modes, and production setup for Slyber TURN Server.

---

## 1. Quick Start via Docker

Run the visual test environment in a single command:

    sudo docker run -d \
      --name slyber_test \
      --restart unless-stopped \
      -p 8095:8095 \
      ghcr.io/slyber-app/slyber-test-server:latest

Open `http://127.0.0.1:8095` (or `http://<SERVER_IP>:8095`) in your browser.

Verify container health and version:

    sudo docker exec slyber_test slyber_test --version
    curl -s http://127.0.0.1:8095/api/health

---

## 2. Docker Compose Deployment

Download `docker-compose.yml` and start the service:

    curl -fsSLO https://raw.githubusercontent.com/slyber-app/slyber-test-server/main/docker-compose.yml
    sudo docker compose up -d

---

## 3. One-Command Native Installation (Linux & macOS)

Install the static binary (`linux-amd64`, `linux-arm64`, `darwin-arm64`, or `darwin-amd64`), verify its SHA256 checksum, and automatically configure the `systemd` service on Linux:

    curl -fsSL https://raw.githubusercontent.com/slyber-app/slyber-test-server/main/install.sh | sudo bash

Manage the background service on Linux:

    sudo systemctl status slyber_test
    sudo journalctl -u slyber_test -f
    sudo systemctl restart slyber_test

Run manually on macOS or Linux without systemd:

    slyber_test -addr 127.0.0.1:8095

---

## 4. Manual Binary Installation

Download the prebuilt static binary for your platform from the latest release:

Linux (x86_64 / amd64):

    curl -fsSL https://github.com/slyber-app/slyber-test-server/releases/latest/download/slyber_test-linux-amd64 -o slyber_test
    chmod +x slyber_test
    ./slyber_test -addr 0.0.0.0:8095

Linux (ARM64 / aarch64):

    curl -fsSL https://github.com/slyber-app/slyber-test-server/releases/latest/download/slyber_test-linux-arm64 -o slyber_test
    chmod +x slyber_test
    ./slyber_test -addr 0.0.0.0:8095

macOS (Apple Silicon M1/M2/M3/M4):

    curl -fsSL https://github.com/slyber-app/slyber-test-server/releases/latest/download/slyber_test-darwin-arm64 -o slyber_test
    chmod +x slyber_test
    ./slyber_test -addr 127.0.0.1:8095

---

## 5. Configuration & CLI Flags

Command-line flags:

* `-addr` - TCP address and port for the web interface and signaling hub (default: `0.0.0.0:8095`).
* `--version` - Print binary version and exit.

Environment variables:

* `LISTEN_ADDR` - Listen address override (e.g., `127.0.0.1:8095` or `0.0.0.0:8095`).
* `PORT` - Port override when `LISTEN_ADDR` is not set (default: `8095`).

---

## 6. Key Capabilities

* **Unified Multi Module Workspace:** Switch seamlessly between Slyber infrastructure modules (`Slyber TURN Server`, `Slyber SFU Server`, and `Slyber Signaling Server`) from a single interface.
* **Multi Pair WebRTC Relay Grid:** Spawn any number of concurrent peer to peer pairs in a structured row layout (`Peer 1` on the left, `Peer 2` on the right) with configurable `iceTransportPolicy` (`relay` or `all`).
* **Distinct Media Selection:** Upload multiple local video files or generate synthetic audio/video streams; each pair automatically selects two different video sources so paired peers never stream identical files.
* **Persistent Browser State:** All server parameters, credentials, and uploaded video blobs are automatically saved in browser `localStorage` and `IndexedDB` across reloads.
* **Dual Authentication Provisioning:**
  * `secret` mode: Local stateless `HMAC-SHA1` credential generation or remote HTTP `/api/turn-credentials` API fetching.
  * `redis` mode: Direct `SET turn/realm/<realm>/user/<username>/key <md5> EX <ttl>` provisioning (RFC 5389 long term key format) and one click mid call key revocation (`DEL`).
* **Selective Audio Routing:** All video elements start muted by default; toggle live relayed audio on any individual peer at any time.
* **Live Stream Telemetry:** Real time per peer bitrate (`kbps`), cumulative relayed megabytes (`mb`), `RTT` latency (`ms`), and allocated `relay IP:port` badges.

---

## License

Licensed under the Apache License, Version 2.0. See [Slyber Documentation](https://slyber.com/docs) for more details.