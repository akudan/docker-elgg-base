#!/bin/bash
source /etc/apache2/envvars
exec 2>&1
exec httpd -eDEBUG -DNO_DETACH -DFOREGROUND
