#!/bin/bash

service mysql start

echo "CREATE DATABASE IF NOT EXISTS $db1_name;" > db.sql
echo "CREATE USER IF NOT EXISTS '$db1_user'@'%' IDENTIFIED BY '$db1_password';" >> db.sql
echo "GRANT ALL PRIVILEGES ON $db1_name.* TO '$db1_user'@'%';" >> db.sql
echo "FLUSH PRIVILEGES;" >> db.sql

mysql -u root --password="$db_root_password" < db.sql
rm -rf db.sql

kill -SIGINT $(pidof mysqld)
mysqld