#!/usr/bin/env bash

echo sanitycheck #TODO: fjernes inden aflevering

#TODO: skal hentes fra en config eller lign
file="targets.list"
log="script_man.log"

# regex fra ai. behøver kun at forstå at regexen sikre at de adresser vi monitore er skrevet korrekt. ellers kan curl buggy ud og forhindre vores script i at forsætte.
domain_regex='^(https?://)?[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)+(:[0-9]{1,5})?([/?#][^[:space:]]*)?$'
ipv4_regex='^(https?://)?((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(:[0-9]{1,5})?([/?#][^[:space:]]*)?$'
localhost_regex='^(https?://)?localhost(:[0-9]{1,5})?([/?#][^[:space:]]*)?$'
port_regex='^(https?://)?([^/:]+):([0-9]{1,5})$'

while read -r line || [[ -n "$line" ]]; do
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    if ! ([[ "$line" =~ $domain_regex ]] ||
          [[ "$line" =~ $ipv4_regex ]] ||
          [[ "$line" =~ $localhost_regex ]]); then
        echo "$timestamp - $line - address not valid" >> "$log"
        continue
    fi

    # If target contains a port, use nc for a TCP connectivity check
    if [[ "$line" =~ ^(https?://)?([^/:]+):([0-9]{1,5})$ ]]; then
        host="${BASH_REMATCH[2]}"
        port="${BASH_REMATCH[3]}"

        nc -z -w 3 "$host" "$port" >/dev/null 2>&1
        result=$?
    else
        # Otherwise use curl for HTTP/HTTPS
        curl -Isf --max-time 3 "$line" >/dev/null 2>&1
        result=$?
    fi

    if [ "$result" -eq 0 ]; then
        echo "$timestamp - $line - UP" >> "$log"
    else
        echo "$timestamp - $line - DOWN" >> "$log"
    fi

done < "$file"