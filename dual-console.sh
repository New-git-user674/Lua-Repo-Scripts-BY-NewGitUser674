#!/usr/bin/env bash

mode="bash"  # start in bash mode

echo "Dual Console - type ':lua' to switch to Lua, ':bash' to switch to Bash, ':quit' to exit."

while true; do
    if [ "$mode" = "bash" ]; then
        read -rp "[bash] $ " cmd
        case "$cmd" in
            ":lua") mode="lua";;
            ":quit") break;;
            "") ;;
            *) bash -c "$cmd";;
        esac
    else
        read -rp "[lua] > " cmd
        case "$cmd" in
            ":bash") mode="bash";;
            ":quit") break;;
            "") ;;
            *) lua -e "$cmd";;
        esac
    fi
done
