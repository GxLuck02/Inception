#!/bin/bash
set -e

echo "🚀 Initialisation de MariaDB..."

DATA_DIR="/var/lib/mysql"
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld "$DATA_DIR"

# Démarrer MariaDB en arrière-plan normalement
mysqld_safe &
PID="$!"

# Attendre que MariaDB soit prêt
echo "⏳ Attente que MariaDB démarre..."
until mysqladmin ping -uroot -p"$MYSQL_ROOT_PASSWORD" --silent; do
    sleep 2
done

# Vérifier si l'utilisateur wpuser existe
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

# Arrêter le serveur temporaire
kill "$PID"
wait "$PID" 2>/dev/null || true

# Lancer MariaDB normalement
echo "🚀 Lancement final de MariaDB..."
exec mysqld_safe
