#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVED/main/misc/build.func)
# Copyright (c) 2021-2026 community-scripts ORG
# Author: SystemIdleProcess
# License: MIT | https://github.com/community-scripts/ProxmoxVED/raw/main/LICENSE
# Source: https://github.com/Crosstalk-Solutions/unifi-toolkit

APP="Unifi Toolkit"
var_tags="${var_tags:-network}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-2048}"
var_disk="${var_disk:-2}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources

  if [[ ! -d "/opt/unifi-toolkit" ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi
  if check_for_gh_tag "unifi-toolkit" "Crosstalk-Solutions/unifi-toolkit"; then
    msg_info "Stopping Service"
    systemctl stop unifi-toolkit
    msg_ok "Stopped Service"

    PYTHON_VERSION="312" setup_uv
    cd /opt/unifi-toolkit
    source venv/bin/activate
    fetch_and_deploy_gh_tag "unifi-toolkit" "Crosstalk-Solutions/unifi-toolkit"
    msg_info "Updating Unifi-Toolkit"
    $STD uv pip install -r requirements.txt --python /opt/unifi-toolkit/venv/bin/python3
    alembic upgrade head
    msg_ok "Updated Unifi-Toolkit"

    msg_info "Starting Service"
    systemctl start unifi-toolkit
    msg_ok "Started Service"
    msg_ok "Updated successfully!"
  fi
  exit
}

start
build_container
description

msg_ok "Completed successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8000${CL}"
