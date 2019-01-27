#!/bin/bash

INSTALL_PACKAGES=""
INSTALL_PACKAGES="$INSTALL_PACKAGES firewalld"
INSTALL_PACKAGES="$INSTALL_PACKAGES openconnect"
INSTALL_PACKAGES="$INSTALL_PACKAGES dante-server"


# Disable auto start service at apt install
install -o root -g root -m 755 <(printf '#!/bin/sh\nexit 101') /usr/sbin/policy-rc.d

apt-get update

missing_packages=""
for pkg in $INSTALL_PACKAGES ; do
 dpkg -s "$pkg" >& /dev/null || missing_packages="$missing_packages $pkg"
done

apt-get install --no-install-recommends -y $missing_packages

systemctl start firewalld.service
systemctl enable firewalld.service

firewall-cmd --new-zone=vpn --permanent
firewall-cmd --zone=vpn --add-masquerade --permanent
# ip_forward는 자동 활성화
firewall-cmd --zone=vpn --add-interface=tun+ --permanent

firewall-cmd  --zone=public --add-port=1080/tcp --permanent  # SOCKS

firewall-cmd --reload

cp /etc/danted.conf{,.bak}
cat > /etc/danted.conf <<EOF
logoutput: stderr

user.privileged: proxy
user.unprivileged: nobody
#user.libwrap: libwrap

internal.protocol: ipv4
internal: enp0s8
external: enp0s3
socksmethod: none

client pass {
  from: 0.0.0.0/0 port 1-65535 to: 0.0.0.0/0
  clientmethod: none
  log: connect error
}

socks pass {
  from: 0.0.0.0/0 port 1-65535 to: 0.0.0.0/0
  clientmethod: none
  log: connect error
}
EOF

systemctl start danted.service
systemctl enable danted.service

