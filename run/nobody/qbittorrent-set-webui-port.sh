#!/bin/bash
CONF_FILE="/config/qBittorrent/config/qBittorrent.conf"

# Set qBitTorrent WebUI port
echo "[info] qBittorrent WebUI port: ${1}" | ts '%Y-%m-%d %H:%M:%.S'

# Is the webui port already set correctly?
if ! grep -q -m 1 "WebUI\\\Port=${1}" "${CONF_FILE}"; then
  # Is the webui port config option in the file?
  if grep -q -m 1 'WebUI\\\Port' "${CONF_FILE}"; then
    # Get line number of WebUI Port
    LINE_NUM=$(grep -Fn -m 1 'WebUI\Port' "${CONF_FILE}" | cut -d: -f 1)
    sed -i "${LINE_NUM}s@.*@WebUI\\\Port=${1}\n@" "${CONF_FILE}"
    echo "[info] Modified existing WebUI Port in qBittorrent config." | ts '%Y-%m-%d %H:%M:%.S'
  else
    echo "WebUI\Port=${1}" >> "${CONF_FILE}"
    echo "[info] Added WebUI Port to qBittorrent config." | ts '%Y-%m-%d %H:%M:%.S'
  fi
fi
