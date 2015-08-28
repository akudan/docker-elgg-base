#!/bin/bash
sed -i -e "s/#rewriteDomain=/rewriteDomain=$HOSTNAME/" \
    -e "/hostname=/d" \
    -e "/FromLineOverride=YES" \
    /etc/ssmtp/ssmtp.conf

