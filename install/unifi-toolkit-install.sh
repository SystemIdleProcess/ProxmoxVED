#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: SystemIdleProcess
# License: MIT | https://github.com/community-scripts/ProxmoxVED/raw/main/LICENSE
# Source: https://github.com/Crosstalk-Solutions/unifi-toolkit

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_warn "WARNING: This script will run an external installer from a third-party source (https://www.kasmweb.com/)."
msg_warn "The following code is NOT maintained or audited by our repository."
msg_warn "If you have any doubts or concerns, please review the installer code before proceeding:"
msg_custom "${TAB3}${GATEWAY}${BGN}${CL}" "\e[1;34m" "→  https://raw.githubusercontent.com/Crosstalk-Solutions/unifi-toolkit/refs/heads/main/setup.sh"
echo
read -r -p "${TAB3}Do you want to continue? [y/N]: " CONFIRM
if [[ ! "$CONFIRM" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  msg_error "Aborted by user. No changes have been made."
  exit 10
fi

PYTHON_VERSION="312" setup_uv
fetch_and_deploy_gh_tag "unifi-toolkit" "Crosstalk-Solutions/unifi-toolkit"

msg_info "Setup Unifi-Toolkit"
cd /opt/unifi-toolkit
$STD bash setup.sh
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
msg_ok "Setup Unifi-Toolkit"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/unifi-toolkit.service
[Unit]
Description=Unifi-Toolkit Service
After=network-online.target

[Service]
Type=simple
WorkingDirectory=/opt/unifi-toolkit
ExecStart=/opt/unifi-toolkit/run.py
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now unifi-toolkit
msg_ok "Created Service"

motd_ssh
customize
cleanup_lxc
