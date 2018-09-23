# VPN Box

VPN Client in vagrant box.

전사 정책으로 모든 트래픽을 VPN을 통해 전송하게 한 경우 여러가지 문제점이 생길 수 있다.
비 업무 트래픽도 무조건 VPN을 타고 나가게 되어 개인 프라이버시 침해 소지도 있고 동영상 시청이나 다운로드 등 대용량 트래픽 사용시 개인은 성능 저하, 회사는 과다 비용 유발로 서로에게 피해를 줄 수 있다.

VPN 클라이언트나 정책을 임의 수정하는 대신 클라이언트를 VM 내에서 구동하고 개인 PC에서 VM을 라우터로 사용하여 선택적으로 트래픽을 보내도록 하여 해결(?)

## Usage

### VPN 접속

```bash
localhost $ vagrant up
localhost $ vagrant ssh
vagrant@vpnbox:~$ /vagrant/vpn.sh vpn.company.com
```

### 브라우저 설정

1. `example-wpad.js` 를 참고하여 회사 도메인으로 수정 후 적절한 파일명으로 지정한다
2. 브라우저의 프록시 설정에서 자동 프록시 설정 URL을 `file://` Scheme로 지정한다
   ex) `file:///Users/me/work/vpnbox/company.wpad.js`

이후 company.wpad.js 에 지정한 도메인은 vpn vm의 socks 서버를 통해 나간다.

SOCKS 호스트를 지정시 모든 브라우징 트래픽을 나가게 설정할 수 있다. 도메인이 너무 많고 브라우저 프로필을 여러개 사용할 경우 유용할 수 있다.

### 라우팅 설정

SSH나 socks를 지정하기 어려운 경우 등

```bash
$ sudo route add CIDR 192.168.213.200
$ sudo route add 192.0.2.123/24 192.168.213.200
```

## 설치

1. Install Vagrant
    * [Download](https://www.vagrantup.com/downloads.html)
    * or, `brew cask install vagrant`
2. Install VirtualBox
    * [Download](https://www.virtualbox.org/wiki/Downloads)
    * or, `brew cask install virtualbox`

