#!/bin/bash
set -e

echo "🚀 Initialisation de MariaDB..."

DATA_DIR="/var/lib/mysql"
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld "$DATA_DIR"

mysqld_safe &
PID="$!"

echo "⏳ Attente que MariaDB démarre..."
for i in {30..0}; do
    if mysqladmin ping -uroot -p"$MYSQL_ROOT_PASSWORD" --silent; then
        break
    fi
    echo "⏳ MariaDB n'est pas encore prêt... ($i)"
    sleep 1
done

USER_EXISTS=$(mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -sse \
"SELECT EXISTS(SELECT 1 FROM mysql.user WHERE User='${MYSQL_USER}');")

if [ "$USER_EXISTS" -eq 0 ]; then
    echo "🧱 Création de l'utilisateur ${MYSQL_USER} et de la base ${MYSQL_DATABASE}..."
    mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
    mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
    mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';"
    mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "FLUSH PRIVILEGES;"
else
    echo "✅ Utilisateur ${MYSQL_USER} déjà existant, rien à faire."
fi

kill "$PID"
wait "$PID" 2>/dev/null || true

echo "🚀 Lancement final de MariaDB..."
exec mysqld_safe
