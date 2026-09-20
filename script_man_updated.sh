#!/usr/bin/env bash

echo sanitycheck
# /usr/lib/systemd/user/

#https://mywiki.wooledge.org/BashFAQ/001

# curl -Isf google.com >/dev/null
# I for headers
# s for silent
# f for fail (se også --fail-with-body)
# IFS kan nok fjernes https://mywiki.wooledge.org/IFS
#  =~  regular expression match

# || [[ -n "$line" ]] - https://stackoverflow.com/questions/10929453/read-a-file-line-by-line-assigning-the-value-to-a-variable
#If the file isn’t a standard POSIX text file (= not terminated by a newline character), the loop can be modified to handle trailing partial lines:
#Here, || [[ -n $line ]] prevents the last line from being ignored if it doesn't end with a \n (since read returns a non-zero exit code when it encounters EOF).

# $? sidste exit code. bruger exit codes til at se om der er hul igennem. 0 er kommando udført succesfuldt. 
# alt andet betyder noget "gik galt".  med -f sender curl ikke 0 på 400 og 500 statuskoder. 

file="targets.list"
# regex fra ai
domain_regex='^(https?://)?[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)+(:[0-9]{1,5})?([/?#][^[:space:]]*)?$'
ipv4_regex='^(https?://)?((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(:[0-9]{1,5})?([/?#][^[:space:]]*)?$'
localhost_regex='^(https?://)?localhost(:[0-9]{1,5})?([/?#][^[:space:]]*)?$'

while IFS= read -r line || [[ -n "$line" ]]; do
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    if [[ "$line" =~ $domain_regex ]] ||
       [[ "$line" =~ $ipv4_regex ]] ||
       [[ "$line" =~ $localhost_regex ]]; then
        curl -Isf --max-time 5 "$line" >/dev/null
        if [ $? -eq 0 ]; then
            echo "$timestamp - $line - UP" >> script_man.log
        else
            echo "$timestamp - $line - DOWN" >> script_man.log
        fi
    else
        echo "$timestamp - $line - address not valid" >> script_man.log
    fi
done < $file