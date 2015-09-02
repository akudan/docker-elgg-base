#!/bin/bash
source /etc/apache2/envvars
exec 2>&1
exec /usr/sbin/apache2 -eDEBUG -DNO_DETACH -DFOREGROUND
