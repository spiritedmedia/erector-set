#!/bin/bash
#
# "The system clock on my linux box is different than Amazon SES' system clock
# by more than 300 seconds. Therefore can't send emails..."
#
# https://spiritedmedia.slack.com/archives/C02KP1SEA/p1480440231001636

cd ../ || exit
vagrant ssh -- -t 'sudo systemctl daemon-reload && sudo timedatectl set-ntp off && sudo timedatectl set-ntp on; exit;'
