# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ttreichl <ttreichl@student.42lausanne.c    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/10/17 14:52:46 by ttreichl          #+#    #+#              #
#    Updated: 2025/10/17 19:25:58 by ttreichl         ###   ########.fr        #
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
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html
RUN chown -R www-data:www-data /var/www/html

COPY ./tools/start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 80

CMD ["/start.sh"]