#!/bin/bash

cat etc/ch.conf | awk '{print "bash qd.sh "$1}' | sh
