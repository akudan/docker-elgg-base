#!/bin/bash

echo "=>  Confirming MySQL service startup"
sv start mysql & wait

echo "=> Creating MySQL user ${MYSQL_USER}."

mysql -uroot -e "CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASS}'"
mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_USER}'@'%' WITH GRANT OPTION"
mysql -uroot -e "CREATE DATABASE ${ELGG_DB_NAME}"

# Make sure that NOBODY can access the server without a password
mysql -e "UPDATE mysql.user SET Password = PASSWORD('CHANGEME') WHERE User = 'root'"
# Make our changes take effect
mysql -e "FLUSH PRIVILEGES"

echo "=> Done!"

echo "========================================================================"
echo "You can now connect to this MySQL Server using:"
echo ""
if [ "${SHOW_CREDENTIALS}" -eq 1 ]; then
    echo "    mysql -u${MYSQL_USER} -p${MYSQL_PASS} -h<host> -P<port>"
else
    echo "    mysql -u${MYSQL_USER} -p<pass> -h<host> -P<port>"
fi
echo ""
echo "========================================================================"

