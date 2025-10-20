#!/bin/sh
set -e

# 📁 Vérifie que les dossiers nécessaires existent
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

# 🧩 Initialise la base si elle n'existe pas encore
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "🧱 Initialisation de la base de données..."
    mysql_install_db --user=mysql --ldata=/var/lib/mysql > /dev/null

    # Démarrage temporaire de mysqld pour créer l'utilisateur et la base
    mysqld_safe --skip-networking &
    sleep 5

    echo "🔧 Configuration initiale de MariaDB..."
    mysql -u root <<EOSQL
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOSQL

    echo "🧹 Arrêt du serveur temporaire..."
    mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown || true
fi

# 🚀 Démarre le vrai serveur MariaDB au premier plan
echo "✅ Lancement final de MariaDB..."
exec mysqld_safe
