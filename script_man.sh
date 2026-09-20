#!/usr/bin/env bash

echo sanitycheck #TODO: fjernes inden aflevering

# skal hentes fra en config eller lign
file="targets.list"
log="script_man.log"

# regex fra ai
domain_regex='^(https?://)?[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)+(:[0-9]{1,5})?([/?#][^[:space:]]*)?$'
ipv4_regex='^(https?://)?((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(:[0-9]{1,5})?([/?#][^[:space:]]*)?$'
localhost_regex='^(https?://)?localhost(:[0-9]{1,5})?([/?#][^[:space:]]*)?$'

while read -r line || [[ -n "$line" ]]; do
    timestamp=$(date +"%Y-%m-%d %H:%M:%S") #TODO: til ISO
    if [[ "$line" =~ $domain_regex ]] ||
       [[ "$line" =~ $ipv4_regex ]] ||
       [[ "$line" =~ $localhost_regex ]]; then
        curl -Isf --max-time 5 "$line" >/dev/null
        if [ $? -eq 0 ]; then # ? er den sidste exit code. hvis den er nul, er den sidste kommando succesfuld.
            echo "$timestamp - $line - UP" >> $log
        else
            echo "$timestamp - $line - DOWN" >> $log
        fi
    else
        echo "$timestamp - $line - address not valid" >> script_man.log
    fi
done < $file