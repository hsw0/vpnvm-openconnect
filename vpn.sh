#!/bin/bash

set -eu -o pipefail

usage() {
 echo "Usage: $0 vpn.example.com" >&2
 return 1
}

vpn_login() {
 local host="$1"
 local auth_cookie='-'

 local auth_info=$(openconnect --timestamp --authenticate "$host")

 local key value
 while IFS='=' read -r key value ; do
  [[ "${key}" == "COOKIE" ]] && auth_cookie="${value:1:-1}"
 done <<< "$auth_info"

 echo "$auth_cookie"

 return 0
}

vpn_connect() {
 local host="$1"
 local auth_cookie="$2"

 set +e

 <<< "$auth_cookie" sudo openconnect \
  --timestamp \
  --setuid=nobody \
  --force-dpd=17 \
  --reconnect-timeout=1 \
  --pfs \
  --cookie-on-stdin \
  --non-inter \
  "$host" 2>&1 | tee -a /dev/stderr | \
  while read -r ; do
    [[ "${REPLY-}" == *\ Unauthorized* ]] && return 2
  done

  return $?
}

main() {
 if [[ $# != 1 ]]; then
  usage
  return 1
 fi

 local host="$1"
 local auth_cookie

 echo "[*] Connecting to $host"
 auth_cookie=$(vpn_login "$host")

 echo "[+] Logged in."

 local attempts=1 max_attempts=30
 while (( attempts <= 30 )) ; do
  echo "[*] $(date '+%F %T') Trying to connect.. ($attempts/$max_attempts)"

  vpn_connect "$host" "$auth_cookie" && break
  local rc=$?
  echo "[-] Connect failed: $rc" >&2

  (( $rc == 2 )) && return $rc

  attempts=$((attempts + 1))
  sleep 5
 done
}

main "$@"
exit $?

