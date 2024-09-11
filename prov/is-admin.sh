#!/bin/bash
echo "PAM_USER"$PAM_USER
if id -nG $PAM_USER | grep -qw "admins"; then
        echo "group admins"
        exit 0
else
        if [ $(date +%a) = "Sat" ] || [ $(date +%a) = "Sun" ]; then
                        if id -nG $PAM_USER | grep -qw "weekends"; then
                                echo "group weekends"
                                exit 0
                        else
                echo "Sa-Su other group"
                exit 1
                        fi
        else
                echo "Mo-Fri all users"
                exit 0
        fi
fi
