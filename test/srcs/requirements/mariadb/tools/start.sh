#!/bin/bash
set -e

echo "🚀 Initialisation de MariaDB..."

# 1️⃣ Chemin du volume monté dans le conteneur
DATA_DIR="/var/lib/mysql"

# 2️⃣ Préparer les répertoires
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld "$DATA_DIR"

# 3️⃣ Vérifier si MariaDB est déjà initialisé
# On vérifie la présence du fichier système 'user.frm' qui existe seulement si MariaDB est initialisée
if [ ! -f "$DATA_DIR/mysql/user.frm" ]; then
    echo "🧱 Première initialisation de MariaDB..."

    # 4️⃣ Initialisation du système MariaDB
    mariadb-install-db --user=mysql --ldata="$DATA_DIR" > /dev/null

    # 5️⃣ Démarrage temporaire avec skip-grant-tables
    echo "⏳ Démarrage temporaire de MariaDB pour configuration initiale..."
    mysqld_safe --skip-networking --skip-grant-tables &
    pid="$!"
    sleep 5

    # 6️⃣ Script SQL de configuration
    cat <<EOF > /tmp/init.sql
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    # 7️⃣ Exécution du SQL
    echo "⚙️ Application de la configuration initiale..."
    mysql < /tmp/init.sql

    # 8️⃣ Arrêt du serveur temporaire
    echo "🛑 Arrêt du serveur temporaire..."
    kill "$pid"
    wait "$pid" 2>/dev/null || true
fi

# 9️⃣ Lancement final de MariaDB
echo "🚀 Lancement final de MariaDB..."
exec mysqld_safe


