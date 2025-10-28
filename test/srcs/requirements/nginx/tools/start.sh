#!/bin/bash
set -e

: "${DOMAIN_NAME:?Vous devez définir DOMAIN_NAME}"
: "${CERTS_:?Vous devez définir CERTS_}"

mkdir -p /etc/ssl/certs /etc/ssl/private
chmod 700 /etc/ssl/private

if [ ! -f "$CERTS_" ]; then
    echo "🔐 Génération du certificat SSL auto-signé..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/ssl/private/nginx-selfsigned.key \
        -out "$CERTS_" \
        -subj "/C=MO/L=KH/O=1337/OU=student/CN=$DOMAIN_NAME"
fi

mkdir -p /var/www/html
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

cat > /etc/nginx/sites-available/default <<EOF
# Redirection HTTP vers HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN_NAME;
    
    return 301 https://\$server_name\$request_uri;
}

# Configuration HTTPS
server {
    listen 443 ssl;
    listen [::]:443 ssl;

    server_name $DOMAIN_NAME;

    ssl_certificate $CERTS_;
    ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'HIGH:!aNULL:!MD5';
    ssl_prefer_server_ciphers on;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    index index.php index.html ;
    root /var/www/html;

    location / {
        proxy_pass http://wordpress:80;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

}

EOF

echo "📝 Configuration Nginx générée :"
cat /etc/nginx/sites-available/default


echo "🚀 Démarrage de Nginx..."
exec nginx -g "daemon off;"
