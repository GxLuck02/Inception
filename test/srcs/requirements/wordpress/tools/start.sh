#!/bin/bash


set -e

cd /var/www/html

# Installer WP-CLI si non présent
if [ ! -f /usr/local/bin/wp ]; then
    echo "📦 Installation de WP-CLI..."
    curl -sO https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

# Si WordPress n’est pas encore installé
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "📥 Téléchargement de WordPress..."
    rm -rf ./*
    wp core download --allow-root

    echo "⏳ Attente que MariaDB soit prêt..."
    until mysqladmin ping -h mariadb -u"$db_user" -p"$db_pwd" --silent; do
    sleep 2
    done
    echo "⚙️ Configuration de WordPress..."
    wp config create \
        --dbname="$db_name" \
        --dbuser="$db_user" \
        --dbpass="$db_pwd" \
        --dbhost="mariadb" \
        --allow-root

    echo "🧱 Installation de WordPress..."
    wp core install \
        --url="$DOMAIN_NAME" \
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

    echo "⬆️ Mise à jour des plugins..."
    wp plugin update --all --allow-root
fi

echo "🚀 Lancement d’Apache..."
exec apachectl -D FOREGROUND
