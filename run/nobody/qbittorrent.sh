#!/bin/bash

# if config file doesnt exist then copy stock config file
if [[ ! -f /config/qBittorrent/config/qBittorrent.conf ]]; then

	echo "[info] qBittorrent config file doesn't exist, copying default..."
	mkdir -p /config/qBittorrent/config/
	cp /home/nobody/qBittorrent.conf /config/qBittorrent/config/

else
	echo "[info] qBittorrent config file already exists, skipping copy"
fi

# if pid file exists then remove (generated from previous run)
rm -f /config/qbittorrent-nox.pid

# if vpn set to "no" then don't run openvpn
if [[ "${VPN_ENABLED}" == "no" ]]; then

	echo "[info] VPN not enabled, skipping VPN tunnel local ip/port checks"

	qbittorrent_ip="0.0.0.0"

	# set listen interface ip address for qBittorrent using python script
	/home/nobody/qbittorrent-set-ip.sh "${qbittorrent_ip}"

	# run qBittorrent daemon (daemonized, non-blocking)
	echo "[info] Attempting to start qBittorrent..."
	/usr/bin/qbittorrent-nox -d --profile=/config

	# run cat to prevent script exit
	cat
else
	echo "[info] VPN is enabled, checking VPN tunnel local ip is valid"

	# set triggers to first run
	qbittorrent_running="false"
	ip_change="false"
	port_change="false"

	# set default values for port and ip
	qbittorrent_port="${INCOMING_PORT}"
	qbittorrent_ip="0.0.0.0"

	# while loop to check ip and port
	while true; do

		# run script to check ip is valid for tunnel device (will block until valid)
		source /home/nobody/getvpnip.sh

		# if vpn_ip is not blank then run, otherwise log warning
		if [[ ! -z "${vpn_ip}" ]]; then

			# check if qBittorrent is running, if not then skip reconfigure for port/ip
			if ! pgrep -x qbittorrent-nox > /dev/null; then

				echo "[info] qBittorrent not running"

				# mark as qBittorrent not running
				qbittorrent_running="false"

			else

				# if qbittorrent is running, then reconfigure port/ip
				qbittorrent_running="true"

			fi

			# if current bind interface ip is different to tunnel local ip then re-configure qBittorrent
			if [[ "${qbittorrent_ip}" != "${vpn_ip}" ]]; then

				echo "[info] qBittorrent listening interface IP $qbittorrent_ip and VPN provider IP ${vpn_ip} different, marking for reconfigure"

				# mark as reload required due to mismatch
				ip_change="true"

			fi

			if [[ "${VPN_PROV}" == "pia" ]]; then

				# run scripts to identify vpn port
				source /home/nobody/getvpnport.sh

				# if vpn port is not an integer then dont change port
				if [[ ! "${VPN_INCOMING_PORT}" =~ ^-?[0-9]+$ ]]; then

					# set vpn port to current qBittorrent port, as we currently cannot detect incoming port (line saturated, or issues with pia)
					VPN_INCOMING_PORT="${qbittorrent_port}"

					# ignore port change as we cannot detect new port
					port_change="false"

				else

					if [[ "${qbittorrent_running}" == "true" ]]; then

						# run netcat to identify if port still open, use exit code
						nc_exitcode=$(/usr/bin/nc -z -w 3 "${qbittorrent_ip}" "${qbittorrent_port}")

						if [[ "${nc_exitcode}" -ne 0 ]]; then

							echo "[info] qBittorrent incoming port closed, marking for reconfigure"

							# mark as reconfigure required due to mismatch
							port_change="true"

						elif [[ "${qbittorrent_port}" != "${VPN_INCOMING_PORT}" ]]; then

							echo "[info] qBittorrent incoming port ${qbittorrent_port} and VPN incoming port ${VPN_INCOMING_PORT} different, marking for reconfigure"

							# mark as reconfigure required due to mismatch
							port_change="true"

						fi

					fi

				fi

			fi

			if [[ "${qbittorrent_running}" == "true" ]]; then

				if [[ "${VPN_PROV}" == "pia" ]]; then

					# reconfigure qBittorrent with new port
					if [[ "${port_change}" == "true" ]]; then

						echo "[info] Reconfiguring qBittorrent due to port change..."

						# set incoming port
						/home/nobody/qbittorrent-set-incoming-port.sh "${INCOMING_PORT}"

						echo "[info] qBittorrent reconfigured for port change"

					fi

				fi

				# reconfigure qBittorrent with new ip
				if [[ "${ip_change}" == "true" ]]; then

					echo "[info] Reconfiguring qBittorrent due to ip change..."

					# set listen interface to tunnel local ip using command line
					/home/nobody/qbittorrent-set-ip.sh ${vpn_ip}

					echo "[info] qBittorrent reconfigured for ip change"

				fi

			else

				echo "[info] Attempting to start qBittorrent..."

				# if pid file exists then remove (generated from previous run)
				rm -f /config/qbittorrent-nox.pid

				# set listen interface ip address for qBittorrent using python script
				/home/nobody/qbittorrent-set-ip.sh ${vpn_ip}

				# run qBittorrent daemon (daemonized, non-blocking)
				/usr/bin/qbittorrent-nox -d --profile=/config

				if [[ "${VPN_PROV}" == "pia" || -n "${VPN_INCOMING_PORT}" ]]; then

					# wait for qBittorrent process to start (listen for port)
					while [[ $(netstat -lnt | awk '$6 == "LISTEN" && $4 ~ ".${INCOMING_PORT}"') == "" ]]; do
						sleep 0.1
					done

					# set incoming port
					/home/nobody/qbittorrent-set-incoming-port.sh "${INCOMING_PORT}"
				fi

				echo "[info] qBittorrent started"

			fi

			# set qBittorrent ip and port to current vpn ip and port (used when checking for changes on next run)
			qbittorrent_ip="${vpn_ip}"
			qbittorrent_port="${VPN_INCOMING_PORT}"

			# reset triggers to negative values
			qbittorrent_running="false"
			ip_change="false"
			port_change="false"

			if [[ "${DEBUG}" == "true" ]]; then

				echo "[debug] VPN incoming port is ${VPN_INCOMING_PORT}"
				echo "[debug] VPN IP is ${vpn_ip}"
				echo "[debug] qBittorrent incoming port is ${qbittorrent_port}"
				echo "[debug] qBittorrent IP is ${qbittorrent_ip}"

			fi

		else

			echo "[warn] VPN IP not detected, VPN tunnel maybe down"

		fi

		sleep 30s

	done

fi
