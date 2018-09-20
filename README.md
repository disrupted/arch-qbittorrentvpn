**Application**

[qBittorrent](https://github.com/qbittorrent/qBittorrent)
[autodl-irssi](https://github.com/autodl-community/autodl-irssi)
[OpenVPN](https://openvpn.net)
[Privoxy](http://www.privoxy.org)

**Description**

The qBittorrent project aims to provide an open-source software alternative to µTorrent that runs and provides the same features on all major platforms (Linux, macOS, Windows, OS/2, FreeBSD). It is based on the Qt toolkit and libtorrent-rasterbar library.

**Build notes**

Latest stable qBittorrent-nox release from Arch Linux.
Latest stable OpenVPN release from Arch Linux repo.
Latest stable Privoxy release from Arch Linux repo.

**Usage**
```
docker run -d \
    --cap-add=NET_ADMIN \
    -p 8080:8080 \
    --name=<container name> \
    -v <path for data files>:/data \
    -v <path for config files>:/config \
    -v /etc/localtime:/etc/localtime:ro \
    -e VPN_ENABLED=<yes|no> \
    -e VPN_USER=<vpn username> \
    -e VPN_PASS=<vpn password> \
    -e VPN_PROV=<pia|airvpn|custom> \
    -e VPN_OPTIONS=<additional openvpn cli options> \
    -e STRICT_PORT_FORWARD=<yes|no> \
    -e ENABLE_PRIVOXY=<yes|no> \
    -e ENABLE_FLOOD=<yes|no|both> \
    -e ENABLE_AUTODL_IRSSI=<yes|no> \
    -e LAN_NETWORK=<lan ipv4 network>/<cidr notation> \
    -e NAME_SERVERS=<name server ip(s)> \
    -e DEBUG=<true|false> \
    -e PHP_TZ=<php timezone> \
    -e UMASK=<umask for created files> \
    -e PUID=<uid for user> \
    -e PGID=<gid for user> \
    binhex/arch-qbittorrentvpn
```
&nbsp;
Please replace all user variables in the above command defined by <> with the correct values.

**Access qBittorrent (web ui)**

`http://<host ip>:8080/`

Username:- admin
Password:- adminadmin

**Access Privoxy**

`http://<host ip>:8118`

**PIA example**
```
docker run -d \
    --cap-add=NET_ADMIN \
    -p 8080:8080 \
    --name=qbittorrentvpn \
    -v /root/docker/data:/data \
    -v /root/docker/config:/config \
    -v /etc/localtime:/etc/localtime:ro \
    -e VPN_ENABLED=yes \
    -e VPN_USER=myusername \
    -e VPN_PASS=mypassword \
    -e VPN_PROV=pia \
    -e STRICT_PORT_FORWARD=yes \
    -e ENABLE_PRIVOXY=yes \
    -e ENABLE_FLOOD=yes \
    -e ENABLE_AUTODL_IRSSI=yes \
    -e LAN_NETWORK=192.168.1.0/24 \
    -e NAME_SERVERS=8.8.8.8,8.8.4.4 \
    -e DEBUG=true \
    -e PHP_TZ=UTC \
    -e UMASK=002 \
    -e PUID=0 \
    -e PGID=0 \
    binhex/arch-qbittorrentvpn
```
&nbsp;
**AirVPN provider**

AirVPN users will need to generate a unique OpenVPN configuration file by using the following link https://airvpn.org/generator/

1. Please select Linux and then choose the country you want to connect to
2. Save the ovpn file to somewhere safe
3. Start the qbittorrentvpn docker to create the folder structure
4. Stop qbittorrentvpn docker and copy the saved ovpn file to the /config/openvpn/ folder on the host
5. Start qbittorrentvpn docker
6. Check supervisor.log to make sure you are connected to the tunnel

AirVPN users will also need to create a port forward by using the following link https://airvpn.org/ports/ and clicking Add. This port will need to be specified in the qBittorrent configuration file located at /config/qBittorrent/config/qBittorrent.conf with the option `port_range = <start incoming port>-<end incoming port>` and `port_random = no`.

qBittorrent example config
```
port_range = 49400-49400
port_random = no
```
&nbsp;
**AirVPN example**
```
docker run -d \
    --cap-add=NET_ADMIN \
    -p 9080:9080 \
    -p 9443:9443 \
    -p 8118:8118 \
    -p 3000:3000 \
    --name=qbittorrentvpn \
    -v /root/docker/data:/data \
    -v /root/docker/config:/config \
    -v /etc/localtime:/etc/localtime:ro \
    -e VPN_ENABLED=yes \
    -e VPN_PROV=airvpn \
    -e ENABLE_PRIVOXY=yes \
    -e ENABLE_FLOOD=yes \
    -e ENABLE_AUTODL_IRSSI=yes \
    -e LAN_NETWORK=192.168.1.0/24 \
    -e NAME_SERVERS=209.222.18.222,37.235.1.174,8.8.8.8,209.222.18.218,37.235.1.177,8.8.4.4 \
    -e DEBUG=false \
    -e PHP_TZ=UTC \
    -e UMASK=000 \
    -e PUID=0 \
    -e PGID=0 \
    binhex/arch-qbittorrentvpn
```
&nbsp;
**Notes**

Please note this Docker image does not include the required OpenVPN configuration file and certificates. These will typically be downloaded from your VPN providers website (look for OpenVPN configuration files), and generally are zipped.

PIA users - The URL to download the OpenVPN configuration files and certs is:-

https://www.privateinternetaccess.com/openvpn/openvpn.zip

Once you have downloaded the zip (normally a zip as they contain multiple ovpn files) then extract it to /config/openvpn/ folder (if that folder doesn't exist then start and stop the docker container to force the creation of the folder).

If there are multiple ovpn files then please delete the ones you don't want to use (normally filename follows location of the endpoint) leaving just a single ovpn file and the certificates referenced in the ovpn file (certificates will normally have a crt and/or pem extension).

User ID (PUID) and Group ID (PGID) can be found by issuing the following command for the user you want to run the container as:-

`id <username>`

If you want to create an additional user account for ruTorrent webui then please execute the following on the host:-

`docker exec -it <container name> /home/nobody/createuser.sh <username to create>`

If you want to delete a user account (or change the password for an account) then please execute the following on the host:-

`docker exec -it <container name> /home/nobody/deluser.sh <username to delete>`

If you do not define the PHP timezone you may see issues with the ruTorrent Scheduler plugin, please make sure you set the PHP timezone by specifying this using the environment variable PHP_TZ. Valid timezone values can be found here, http://php.net/manual/en/timezones.php
___
If you appreciate my work, then please consider buying me a beer  :D

[![PayPal donation](https://www.paypal.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=MM5E27UX6AUU4)

[Support forum](http://lime-technology.com/forum/index.php?topic=47832.0)
