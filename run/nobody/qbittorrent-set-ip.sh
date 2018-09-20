#!/bin/bash
CONF_FILE="/config/qBittorrent/config/qBittorrent.conf"

# Set qBitTorrent Connection Interface
echo "[info] qBittorrent Interface: ${1}" | ts '%Y-%m-%d %H:%M:%.S'

# Is the Connection Interface already set correctly?
if ! grep -q -m 1 "Connection\\\Interface=${1}" "${CONF_FILE}"; then
  # Is the Connection Interface config option in the file?
  if grep -q -m 1 'Connection\\\Interface' "${CONF_FILE}"; then
    # Get line number of Connection Interface
    LINE_NUM=$(grep -Fn -m 1 'Connection\Interface' "${CONF_FILE}" | cut -d: -f 1)
    sed -i "${LINE_NUM}s@.*@Connection\\\Interface=${1}\n@" "${CONF_FILE}"
    echo "[info] Modified existing Connection Interface in qBittorrent config." | ts '%Y-%m-%d %H:%M:%.S'
  else
    echo "Connection\Interface=${1}" >> "${CONF_FILE}"
    echo "[info] Added Connection Interface to qBittorrent config." | ts '%Y-%m-%d %H:%M:%.S'
  fi
fi
