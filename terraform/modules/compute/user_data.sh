#!/bin/bash
set -Eeuo pipefail

LOG_FILE="/var/log/pelumi-setup.log"
APP_DIR="/opt/pelumi-test"
SERVICE_FILE="/etc/systemd/system/pelumi-test.service"

exec > >(tee -a "$LOG_FILE") 2>&1

log() {
  printf '[%s] %s\n' "$(date --iso-8601=seconds)" "$*"
}

on_error() {
  local exit_code=$?
  log "ERROR: startup failed at line ${BASH_LINENO[0]} (exit ${exit_code})."
  exit "$exit_code"
}
trap on_error ERR

log "Starting pelumi-test instance setup."
log "Installing Python 3 with dnf."
dnf install -y python3

log "Creating the application directory and page."
install -d -o root -g root -m 0755 "$APP_DIR"
cat > "$APP_DIR/index.html" <<'HTML'
<!doctype html>
<html lang="en">
  <head><meta charset="utf-8"><title>AWS Three-Tier Architecture</title></head>
  <body><h1>AWS Three-Tier Architecture</h1><p>EC2 web test application is running.</p></body>
</html>
HTML
chmod 0644 "$APP_DIR/index.html"

log "Writing the pelumi-test systemd service."
cat > "$SERVICE_FILE" <<'UNIT'
[Unit]
Description=Pelumi EC2 Test Web Application
After=network.target

[Service]
Type=simple
User=nobody
Group=nobody
AmbientCapabilities=CAP_NET_BIND_SERVICE
WorkingDirectory=/opt/pelumi-test
ExecStart=/usr/bin/python3 -m http.server 80 --directory /opt/pelumi-test
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
UNIT
chmod 0644 "$SERVICE_FILE"

log "Reloading systemd and enabling the web service."
systemctl daemon-reload
systemctl enable --now pelumi-test.service

log "pelumi-test setup completed successfully."
