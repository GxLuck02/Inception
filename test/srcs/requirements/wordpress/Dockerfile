# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ttreichl <ttreichl@student.42lausanne.c    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/10/17 14:52:46 by ttreichl          #+#    #+#              #
#    Updated: 2025/10/28 14:14:56 by ttreichl         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM debian:bullseye
RUN apt-get update && apt-get install -y \
    apache2 \
    php \
    php-mysql \
    php-cli \
    php-curl \
    php-xml \
    php-mbstring \
    wget \
    unzip \
    curl \
    mariadb-client \
    less \
    && rm -rf /var/lib/apt/lists/*

# --- Installer WP-CLI ---
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    php wp-cli.phar --info && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

WORKDIR /var/www/html
RUN chown -R www-data:www-data /var/www/html

COPY ./tools/start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 80

CMD ["/start.sh"]
