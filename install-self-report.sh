#!/bin/bash

CWD=$(pwd)
cd /etc/systemd/system
systemctl stop self-reporting
systemctl daemon-reload
systemctl enable self-reporting.timer
systemctl start self-reporting
cd $CWD
