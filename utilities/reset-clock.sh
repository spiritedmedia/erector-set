#!/bin/bash
#
# "The system clock on my linux box is different than Amazon SES' system clock
# by more than 300 seconds. Therefore can't send emails..."
# 
# https://spiritedmedia.slack.com/archives/C02KP1SEA/p1480440231001636

cd ../
vagrant ssh -- -t 'sudo /usr/sbin/ntpdate 0.north-america.pool.ntp.org 1.north-america.pool.ntp.org 2.north-america.pool.ntp.org 3.north-america.pool.ntp.org; exit;'
