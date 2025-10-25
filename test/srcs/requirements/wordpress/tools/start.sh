#!/bin/bash
set -e
set -o pipefail

WP_PATH="/var/www/html"

# -------------------------
# Préparer le volume
# -------------------------
mkdir -p "$WP_PATH"
chown -R www-data:www-data "$WP_PATH"
cd "$WP_PATH"

# -------------------------
# Installer WP-CLI si nécessaire
# -------------------------
if [ ! -f /usr/local/bin/wp ]; then
    echo "📦 Installation de WP-CLI..."
    curl -sO https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

# -------------------------
# Attendre MariaDB
# -------------------------
echo "⏳ Attente de MariaDB..."
until mysqladmin ping -h mariadb -u"$DB_USER" -p"$DB_PWD" --silent; do
    echo "MariaDB non prête, attente 2s..."
    sleep 2
done

# -------------------------
# Installer WordPress si nécessaire
# -------------------------
if [ ! -f "$WP_PATH/wp-config.php" ]; then
    echo "📥 Téléchargement de WordPress..."
    rm -rf "$WP_PATH"/*
    wp core download --allow-root

    echo "⚙️ Création du fichier wp-config.php..."
    wp config create \
        --dbname="$DB_NAME" \
        --dbuser="$DB_USER" \
        --dbpass="$DB_PWD" \
        --dbhost="mariadb" \
        --allow-root \
        --skip-check

    echo "🧱 Installation de WordPress..."
    wp core install \
        --url="http://$DOMAIN_NAME" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USR" \
        --admin_password="$WP_ADMIN_PWD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root

    echo "👥 Création d’un utilisateur supplémentaire..."
    wp user create "$WP_USR" "$WP_EMAIL" \
        --role=author \
        --user_pass="$WP_PWD" \
        --allow-root

    echo "🎨 Activation du thème Astra..."
    wp theme install astra --activate --allow-root

    echo "🔌 Activation du plugin Redis..."
    wp plugin install redis-cache --activate --allow-root

    echo "⬆️ Mise à jour de tous les plugins..."
    wp plugin update --all --allow-root
else
    echo "✅ WordPress déjà installé, passage à l’exécution..."
fi

# -------------------------
# Lancer Apache en avant-plan
# -------------------------
echo "🚀 Lancement d’Apache..."
exec apachectl -D FOREGROUND
