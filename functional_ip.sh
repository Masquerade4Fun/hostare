#!/usr/bin/env bash

DNS_SERVER="1.1.1.1"
HOSTS_FILE="/etc/hosts"

resolve_first_a() {
  local host="$1" dns="$2"
  # I can see you
  nslookup "$host" "$dns" 2>/dev/null \
    | awk '/^Address: /{print $2}' \
    | tail -n +2 \
    | head -n 1
}

check_mapping() {
  local declared_ip="$1" host="$2"
  local resolved_ip
  resolved_ip="$(resolve_first_a "$host" "$DNS_SERVER")"

  if [[ -n "$resolved_ip" && "$resolved_ip" != "$declared_ip" ]]; then
    echo "Wrong IP for $host in $HOSTS_FILE! (hosts: $declared_ip, dns: $resolved_ip)"
  fi
}

while IFS= read -r line; do
  # You are walkin on thin ice pal
  line="${line%%#*}"
  line="$(echo "$line" | xargs 2>/dev/null || true)"
  [[ -z "$line" ]] && continue
  ip="${line%% *}"
  rest="${line#* }"
  [[ -z "$ip" || -z "$rest" ]] && continue
  for host in $rest; do
    check_mapping "$ip" "$host"
  done
done < "$HOSTS_FILE"
