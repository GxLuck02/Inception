#!/bin/bash
set -e

# --- Config couleurs pour logs ---
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

echo -e "${CYAN}🚀 Démarrage du conteneur WordPress...${RESET}"

# --- Variables ---
WP_PATH="/var/www/html"
DB_HOST="mariadb"
THEME_NAME="twentytwentyone"

# Vérification de la variable DOMAIN_NAME
if [ -z "$DOMAIN_NAME" ]; then
    echo -e "${YELLOW}❌ La variable d'environnement DOMAIN_NAME n'est pas définie. Veuillez la définir pour continuer.${RESET}"
    exit 1
fi

# -------------------------
# Installer WordPress si nécessaire
# -------------------------
if [ ! -f "$WP_PATH/wp-config.php" ]; then
    echo -e "${YELLOW}📥 Téléchargement de WordPress...${RESET}"
    rm -rf "$WP_PATH"/*
    wp core download --allow-root

    echo -e "${YELLOW}⚙️ Création du fichier wp-config.php...${RESET}"
    wp config create \
        --dbname="$DB_NAME" \
        --dbuser="$DB_USER" \
        --dbpass="$DB_PWD" \
        --dbhost="$DB_HOST" \
        --allow-root \
        --skip-check

    echo -e "${YELLOW}🔒 Configuration HTTPS dans wp-config.php...${RESET}"
    # Ajout AVANT la ligne "That's all, stop editing!"
    sed -i "/That's all, stop editing/i \
# --- Force HTTPS ---\n\
if (isset(\$_SERVER['HTTP_X_FORWARDED_PROTO']) && \$_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {\n\
    \$_SERVER['HTTPS'] = 'on';\n\
}\n\
\$_SERVER['HTTPS'] = 'on';\n\
define('FORCE_SSL_ADMIN', true);\n\
define('WP_HOME', 'https://$DOMAIN_NAME');\n\
define('WP_SITEURL', 'https://$DOMAIN_NAME');\n\
" "$WP_PATH/wp-config.php"

    echo -e "${YELLOW}🧱 Installation de WordPress...${RESET}"
    wp core install \
        --url="https://$DOMAIN_NAME" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USR" \
        --admin_password="$WP_ADMIN_PWD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root

    # Force HTTPS dans les options
    wp option update home "https://$DOMAIN_NAME" --allow-root
    wp option update siteurl "https://$DOMAIN_NAME" --allow-root

    echo -e "${YELLOW}👥 Création d'un utilisateur supplémentaire...${RESET}"
    wp user create "$WP_USR" "$WP_EMAIL" \
        --role=author \
        --user_pass="$WP_PWD" \
        --allow-root || echo -e "${YELLOW}Utilisateur déjà existant, ignoré.${RESET}"

    echo -e "${YELLOW}🔒 Installation et activation du plugin Really Simple SSL...${RESET}"
    wp plugin install really-simple-ssl --activate --allow-root || echo -e "${YELLOW}Plugin déjà installé.${RESET}"

    echo -e "${GREEN}✅ Really Simple SSL installé et activé !${RESET}"

    echo -e "${YELLOW}🔌 Installation et activation du plugin Redis...${RESET}"
    wp plugin install redis-cache --activate --allow-root || echo -e "${YELLOW}Plugin déjà présent.${RESET}"

    echo -e "${YELLOW}🎨 Installation et activation du thème $THEME_NAME...${RESET}"

    # Vérifier si le thème est installé
    if ! wp theme is-installed $THEME_NAME --allow-root; then
        echo -e "${YELLOW}📥 Installation du thème $THEME_NAME...${RESET}"
        wp theme install $THEME_NAME --allow-root
    else
        echo -e "${YELLOW}Thème $THEME_NAME déjà installé.${RESET}"
    fi

    # Activer le thème
    wp theme activate $THEME_NAME --allow-root

    echo -e "${YELLOW}⬆️ Mise à jour de tous les plugins et thèmes...${RESET}"
    wp plugin update --all --allow-root
    wp theme update --all --allow-root

    echo -e "${YELLOW}🔗 Remplacement HTTP -> HTTPS dans la base de données...${RESET}"
    wp search-replace "http://$DOMAIN_NAME" "https://$DOMAIN_NAME" --skip-columns=guid --allow-root
    wp search-replace "http://" "https://" --skip-columns=guid --allow-root

    echo -e "${GREEN}✅ WordPress installé et configuré pour HTTPS avec $THEME_NAME et Redis !${RESET}"
else
    echo -e "${CYAN}✅ WordPress déjà installé, vérification HTTPS...${RESET}"
    
    # Force HTTPS même si déjà installé
    wp option update home "https://$DOMAIN_NAME" --allow-root
    wp option update siteurl "https://$DOMAIN_NAME" --allow-root
    
    wp core update --allow-root || true
    wp plugin update --all --allow-root || true
    wp theme update --all --allow-root || true

    echo -e "${YELLOW}🔗 Vérification / correction des URLs HTTPS...${RESET}"
    wp search-replace "http://$DOMAIN_NAME" "https://$DOMAIN_NAME" --skip-columns=guid --allow-root
fi

# -------------------------
# Lancement d'Apache
# -------------------------
echo -e "${CYAN}🚀 Lancement d'Apache en foreground...${RESET}"
exec apache2ctl -D FOREGROUND