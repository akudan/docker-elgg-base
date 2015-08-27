#!/bin/bash
sed -i -e "s/#rewriteDomain=/rewriteDomain=$HOSTNAME/" \
    -e "/hostname=/d" \
    /etc/ssmtp/ssmtp.conf

