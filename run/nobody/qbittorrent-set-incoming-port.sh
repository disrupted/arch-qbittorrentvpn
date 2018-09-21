#!/bin/bash
CONF_FILE="/config/qBittorrent/config/qBittorrent.conf"

# Set qBitTorrent incoming port
echo "[info] qBittorrent incoming port: ${1}" | ts '%Y-%m-%d %H:%M:%.S'

# Is the incoming port set correctly?
if ! grep -q -m 1 "Connection\\\PortRangeMin=${1}" "${CONF_FILE}"; then
  # Is incoming port config option in the file?
  if grep -q -m 1 'Connection\\\PortRangeMin' "${CONF_FILE}"; then
    # Get line number of Incoming
    LINE_NUM=$(grep -Fn -m 1 'Connection\PortRangeMin' "${CONF_FILE}" | cut -d: -f 1)
    sed -i "${LINE_NUM}s@.*@Connection\\\PortRangeMin=${1}@" "${CONF_FILE}"
    echo "[info] Modified existing PortRangeMin in qBittorrent config." | ts '%Y-%m-%d %H:%M:%.S'
  else
    echo "Connection\PortRangeMin=${1}" >> "${CONF_FILE}"
    echo "[info] Added PortRangeMin to qBittorrent config." | ts '%Y-%m-%d %H:%M:%.S'
  fi
fi
