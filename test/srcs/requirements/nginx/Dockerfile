# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ttreichl <ttreichl@student.42lausanne.c    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/10/07 14:20:15 by ttreichl          #+#    #+#              #
#    Updated: 2025/10/20 16:54:49 by ttreichl         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM debian:bullseye

RUN apt -y update && apt install -y nginx && apt install openssl -y

COPY ./tools/start.sh /
RUN chmod +x /start.sh

CMD [ "/start.sh" ]



