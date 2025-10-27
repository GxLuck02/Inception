# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ttreichl <ttreichl@student.42lausanne.c    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/10/27 12:00:00 by ttreichl          #+#    #+#              #
#    Updated: 2025/10/27 15:24:28 by ttreichl         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME = INCEPTION

# Variables
COMPOSE_FILE = srcs/docker-compose.yml
DATA_DIR = /home/GxLuck/data
MARIADB_DATA = $(DATA_DIR)/mariadb
WORDPRESS_DATA = $(DATA_DIR)/wordpress

# Couleurs pour l'affichage
GREEN = \033[0;32m
YELLOW = \033[0;33m
RED = \033[0;31m
NC = \033[0m # No Color

.PHONY: all build up down clean fclean re restart logs ps help 

# Règle par défaut
all: build up

# Construction des images Docker
build:
	@echo "$(YELLOW)🔨 Construction des images Docker...$(NC)"
	@sudo docker compose -f $(COMPOSE_FILE) build

# Lancement des conteneurs
up:
	@echo "$(GREEN)🚀 Lancement des conteneurs...$(NC)"
	@sudo mkdir -p $(MARIADB_DATA) $(WORDPRESS_DATA)
	@sudo docker compose -f $(COMPOSE_FILE) up -d
	@echo "$(GREEN)✅ Conteneurs lancés avec succès !$(NC)"

# Arrêt des conteneurs
down:
	@echo "$(YELLOW)⏹️  Arrêt des conteneurs...$(NC)"
	@sudo docker compose -f $(COMPOSE_FILE) down
	@echo "$(GREEN)✅ Conteneurs arrêtés !$(NC)"

# Nettoyage léger (arrêt des conteneurs et suppression des volumes Docker)
clean: down
	@echo "$(YELLOW)🧹 Nettoyage des volumes Docker...$(NC)"
	@sudo docker volume prune -f
	@echo "$(GREEN)✅ Nettoyage terminé !$(NC)"

# Nettoyage complet depuis zéro
fclean:
	@echo "$(RED)🗑️  NETTOYAGE COMPLET - Suppression de tout...$(NC)"
	# Arrêt et suppression des conteneurs
	@sudo docker compose -f $(COMPOSE_FILE) down -v --remove-orphans 2>/dev/null || true
	# Suppression des conteneurs
	@sudo docker container prune -f
	# Suppression des images du projet
	@sudo docker rmi -f nginx:42 wordpress:42 mariadb:42 2>/dev/null || true
	# Suppression des volumes Docker
	@sudo docker volume prune -f
	# Suppression des données locales
	@echo "$(RED)🗂️  Suppression des données locales...$(NC)"
	@sudo rm -rf $(MARIADB_DATA)* $(WORDPRESS_DATA)* 2>/dev/null || true
	# Nettoyage réseau
	@sudo docker network prune -f
	@echo "$(GREEN)✅ Nettoyage complet terminé !$(NC)"

# Reconstruction complète depuis zéro
re: fclean
	@echo "$(GREEN)🔄 Reconstruction complète depuis zéro...$(NC)"
	@$(MAKE) all

# Redémarrage simple (shutdown + relance)
restart: down up
	@echo "$(GREEN)🔄 Redémarrage terminé !$(NC)"

# Affichage des logs
logs:
	@sudo docker compose -f $(COMPOSE_FILE) logs -f

# Affichage du statut des conteneurs
ps:
	@sudo docker compose -f $(COMPOSE_FILE) ps


# Aide
help:
	@echo "$(GREEN)📖 Aide - Commandes disponibles :$(NC)"
	@echo "  $(YELLOW)make all$(NC)      - Construction et lancement"
	@echo "  $(YELLOW)make build$(NC)    - Construction des images seulement"
	@echo "  $(YELLOW)make up$(NC)       - Lancement des conteneurs"
	@echo "  $(YELLOW)make down$(NC)     - Arrêt des conteneurs"
	@echo "  $(YELLOW)make restart$(NC)  - Redémarrage simple (down + up)"
	@echo "  $(YELLOW)make clean$(NC)    - Nettoyage léger"
	@echo "  $(YELLOW)make fclean$(NC)   - Nettoyage complet depuis zéro"
	@echo "  $(YELLOW)make re$(NC)       - Reconstruction complète (fclean + all)"
	@echo "  $(YELLOW)make logs$(NC)     - Affichage des logs"
	@echo "  $(YELLOW)make ps$(NC)       - Statut des conteneurs"
	@echo "  $(YELLOW)make help$(NC)     - Affichage de cette aide"
