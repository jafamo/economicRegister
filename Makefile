# —— Inspired by ———————————————————————————————————————————————————————————————
# http://fabien.potencier.org/symfony4-best-practices.html
# https://speakerdeck.com/mykiwi/outils-pour-ameliorer-la-vie-des-developpeurs-symfony?slide=47
# https://blog.theodo.fr/2018/05/why-you-need-a-makefile-on-your-project/
# Setup ————————————————————————————————————————————————————————————————————————

# Parameters
SHELL         = bash
PROJECT       = clinical-app
GIT_AUTHOR    = COil
HTTP_PORT     = 8000

# Executables
EXEC_PHP      = php
COMPOSER      = composer
REDIS         = redis-cli
GIT           = git
YARN          = yarn
NPX           = npx

# Executables: local only
SYMFONY_BIN   = symfony
BREW          = brew
DOCKER        = docker
DOCKER_COMP   = docker compose

# Alias
SYMFONY       = $(DOCKER) exec $(PROJECT) $(EXEC_PHP) bin/console
# if you use Docker you can replace with: "docker-compose exec my_php_container $(EXEC_PHP) bin/console"

# Executables: vendors
PHPUNIT       = ./vendor/bin/phpunit
PHPSTAN       = ./vendor/bin/phpstan
PHP_CS_FIXER  = ./vendor/bin/php-cs-fixer
PHPMETRICS    = ./vendor/bin/phpmetrics



# Executables: prod only
#CERTBOT       = certbot

# Misc
.DEFAULT_GOAL = help
.PHONY        : # Not needed here, but you can put your all your targets to be sure
                # there is no name conflict between your files and your targets.

## —— 🐝 The Strangebuzz Symfony Makefile 🐝 ———————————————————————————————————
help: ## Outputs this help screen
	@grep -E '(^[a-zA-Z0-9_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

## —— Composer 🧙‍♂️ ————————————————————————————————————————————————————————————
composer-install: composer.lock ## Install vendors according to the current composer.lock file
	@$(COMPOSER) install --no-progress --prefer-dist --optimize-autoloader

## —— PHP 🐘 (macOS with brew) —————————————————————————————————————————————————
#php-upgrade: ## Upgrade PHP to the last version
#	@$(BREW) upgrade php

#php-set-8-2: ## Set php 8.2 as the current PHP version
#	@$(BREW) unlink php
#	@$(BREW) link --overwrite php@8.2
#
#php-set-8-3: ## Set php 8.3 as the current PHP version
#	@$(BREW) unlink php
#	@$(BREW) link --overwrite php@8.3
#
#php-set-8-4: ## Set php 8.1 as the current PHP version
#	@$(BREW) unlink php
#	@$(BREW) link --overwrite php@8.4

# Snippet L53+14 in _127.html.twig

## —— Symfony 🎵 ———————————————————————————————————————————————————————————————
sf: ## List all Symfony commands
	@$(SYMFONY)

cc: ## Clear the cache. DID YOU CLEAR YOUR CACHE????
	@$(SYMFONY) c:c

warmup: ## Warmup the cache
	@$(SYMFONY) cache:warmup

fix-perms: ## Fix permissions of all var files
	@chmod -R 777 var/*

assets: purge ## Install the assets with symlinks in the public folder
	@$(SYMFONY) assets:install public/  # Don't use "--symlink --relative" with a Docker env

purge: ## Purge cache and logs
	@rm -rf var/cache/* var/logs/*


## —— Symfony binary 💻 ————————————————————————————————————————————————————————
migrations-migrate:
	@$(SYMFONY) doctrine:migrations:migrate

migrations-list:
	@$(SYMFONY) doctrine:migrations:list

migrations-create:
	@$(SYMFONY) doctrine:migrations:create

## —— Symfony Assets 💻 ————————————————————————————————————————————————————————
assets-compile:
	@$(SYMFONY) asset-map:compile

assets-map:
	@$(SYMFONY) debug:asset-map


## —— Symfony binary 💻 ————————————————————————————————————————————————————————
#cert-install: ## Install the local HTTPS certificates
#	@$(SYMFONY_BIN) server:ca:install

#serve: ## Serve the application with HTTPS support (add "--no-tls" to disable https)
#	@$(SYMFONY_BIN) serve --daemon --port=$(HTTP_PORT)

#unserve: ## Stop the webserver
#	@$(SYMFONY_BIN) server:stop

# Snippet L90+8 => templates/blog/posts/_64.html.twig

## —— elasticsearch 🔎 —————————————————————————————————————————————————————————
#populate: ## Reset and populate the Elasticsearch index
#	#@$(SYMFONY) fos:elastica:reset
#	#@$(SYMFONY) fos:elastica:populate --index=app
#	@$(SYMFONY) strangebuzz:index-articles

# Snippet L102+4 => templates/blog/posts/_51.html.twig

#list-index: ## List all indexes on the cluster
#	@curl http://localhost:9209/_cat/indices?v

#delete-index: ## Delete a given index (parameters: index=app_2021-01-05-075600")
#	@curl -X DELETE "localhost:9209/$(index)?pretty"

## —— Docker 🐳 ————————————————————————————————————————————————————————————————
up: ## Start the docker hub (PHP,caddy,MySQL,redis,adminer,elasticsearch)
	$(DOCKER_COMP) up --detach

build: ## Builds the images (php + caddy)
	$(DOCKER_COMP) build --pull --no-cache

down: ## Stop the docker hub
	$(DOCKER_COMP) down --remove-orphans

check: ## Docker check
	@$(DOCKER) info > /dev/null 2>&1                                                                   # Docker is up
	@test '"healthy"' = `$(DOCKER) inspect --format "{{json .State.Health.Status }}" clinic-db` # Db container is up and healthy

# Snippet L126+2 => templates/snippet/code/_135.html.twig

sh: ## Log to the docker container
	@$(DOCKER_COMP) exec $(PROJECT)sh

logs: ## Show live logs
	@$(DOCKER_COMP) logs --tail=0 --follow

wait-for-mysql: ## Wait for MySQL to be ready
	@bin/wait-for-mysql.sh

#wait-for-elasticsearch: ## Wait for Elasticsearch to be ready
#	@bin/wait-for-elasticsearch.sh

bash: ## Connect to the application container
	@$(DOCKER)  exec -it $(PROJECT) bash

## —— Project 🐝 ———————————————————————————————————————————————————————————————
start: up wait-for-mysql load-fixtures populate serve ## Start docker, load fixtures, populate the Elasticsearch index and start the webserver

reload: load-fixtures populate ## Load fixtures and repopulate the Meilisearch index

stop: down unserve ## Stop docker and the Symfony binary server

cc-redis: ## Flush all Redis cache
	@$(REDIS) -p 6389 flushall

commands: ## Display all commands in the project namespace
	@$(SYMFONY) list $(PROJECT)

#load-fixtures: ## Build the DB, control the schema validity, load fixtures and check the migration status
#	@$(SYMFONY) doctrine:cache:clear-metadata
#	@$(SYMFONY) doctrine:database:create --if-not-exists
#	@$(SYMFONY) doctrine:schema:drop --force
#	@$(SYMFONY) doctrine:schema:create
#	@$(SYMFONY) doctrine:schema:validate
#	@$(SYMFONY) hautelook:fixtures:load --no-interaction

#init-snippet: ## Initialize a new snippet
#	@$(SYMFONY) $(PROJECT):init-snippet

## —— Tests ✅ —————————————————————————————————————————————————————————————————
test: phpunit.xml check ## Run tests with optionnal suite and filter
	@$(eval testsuite ?= 'all')
	@$(eval filter ?= '.')
	@$(PHPUNIT) --testsuite=$(testsuite) --filter=$(filter) --stop-on-failure

# Snippet L171+4 => templates/blog/posts/_123.html.twig + templates/blog/posts/_178.html.twig

test-all: phpunit.xml ## Run all tests
	@$(PHPUNIT) --stop-on-failure

## —— Coding standards ✨ ——————————————————————————————————————————————————————
cs: fix-php fix-js stan ## Run all coding standards checks

static-analysis: stan ## Run the static analysis (PHPStan)

stan: ## Run PHPStan
	@$(PHPSTAN) analyse -c configuration/phpstan.neon --memory-limit 1G

lint-php: ## Lint files with php-cs-fixer
	@$(PHP_CS_FIXER) fix --allow-risky=yes --dry-run --config=php-cs-fixer.php

fix-php: ## Fix files with php-cs-fixer
	@PHP_CS_FIXER_IGNORE_ENV=1 $(PHP_CS_FIXER) fix --allow-risky=yes --config=php-cs-fixer.php

## —— Deploy & Prod 🚀 —————————————————————————————————————————————————————————
#deploy: ## Full no-downtime deployment with EasyDeploy (with pre-deploy Git hooks)
#	@test -z "`git status --porcelain`"                 # Prevent deploy if there are modified or added files
#	@test -z "`git diff --stat --cached origin/master`" # Prevent deploy if there is something to push on master
#	@$(SYMFONY) deploy -v                               # Deploy with EasyDeploy

# Snippet L196+4 => templates/snippet/code/_128.html.twig

env-check: ## Check the main ENV variables of the project
	@printenv | grep -i app_

#le-renew: ## Renew Let's Encrypt HTTPS certificates
#	@$(CERTBOT) --apache -d strangebuzz.com -d www.strangebuzz.com

## —— Yarn 🐱 / JavaScript —————————————————————————————————————————————————————
dev: ## Rebuild assets for the dev env
	@$(YARN) install --check-files
	@$(YARN) run encore dev

watch: ## Watch files and build assets when needed for the dev env
	@$(YARN) run encore dev --watch

encore: ## Build assets for production
	@$(YARN) run encore production

lint-js: ## Lints JS coding standarts
	@$(NPX) eslint assets/js

fix-js: ## Fixes JS files
	@$(NPX) eslint assets/js --fix

## —— Stats 📜 —————————————————————————————————————————————————————————————————
stats: ## Commits by the hour for the main author of this project
	@$(GIT) log --author="$(GIT_AUTHOR)" --date=iso | perl -nalE 'if (/^Date:\s+[\d-]{10}\s(\d{2})/) { say $$1+0 }' | sort | uniq -c|perl -MList::Util=max -nalE '$$h{$$F[1]} = $$F[0]; }{ $$m = max values %h; foreach (0..23) { $$h{$$_} = 0 if not exists $$h{$$_} } foreach (sort {$$a <=> $$b } keys %h) { say sprintf "%02d - %4d %s", $$_, $$h{$$_}, "*"x ($$h{$$_} / $$m * 50); }'

## —— JWT 🕸 ———————————————————————————————————————————————————————————————————
BEARER    = `cat ./config/jwt/bearer.txt`
BASE_URL  = https://127.0.0.1#https://www.strangebuzz.com
PORT      = :8000

jwt-generate-keys: ## Generate the main JWT ket set (you can use the "lexik:jwt:generate-keypair" command now)
	@mkdir -p config/jwt
	@openssl genpkey -out ./config/jwt/private.pem -aes256 -algorithm rsa -pkeyopt rsa_keygen_bits:4096
	@openssl pkey -in ./config/jwt/private.pem -out ./config/jwt/public.pem -pubout

jwt-create-ok: ## Create a JWT for a valid test account (you can use the "lexik:jwt:generate-token" command now)
	@curl -s POST -H "Content-Type: application/json" ${BASE_URL}${PORT}/api/login_check -d '{"username":"reader","password":"test"}' | jq .token | sed "s/\"//g"

jwt-create-nok: ## Login attempt with wrong credentials
	@curl -s POST -H "Content-Type: application/json" ${BASE_URL}${PORT}/api/login_check -d '{"username":"foo","password":"bar"}' | jq

jwt-test: ./config/jwt/bearer.txt ## Test a JWT token to access an API Platform resource
	@curl -s GET -H 'Cache-Control: no-cache' -H "Content-Type: application/json" -H "Authorization: Bearer ${BEARER}" ${BASE_URL}${PORT}/api/books/1 | jq

# Snippet L231+17 => templates/blog/posts/_126.html.twig

## —— Code Quality reports 📊 ——————————————————————————————————————————————————
report-metrics: ## Run the phpmetrics report
	@$(PHPMETRICS) --report-html=var/phpmetrics/ src/

coverage: ## Create the code coverage report with PHPUnit
	$(EXEC_PHP) -d xdebug.enable=1 -d xdebug.mode=coverage -d memory_limit=-1 vendor/bin/phpunit --coverage-html=var/coverage

show-current-target:
	echo 'Making $(@)...'
	echo 'Making $@...'