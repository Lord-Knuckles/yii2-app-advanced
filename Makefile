include Makefile.base

rebuild-docker-env:
	$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) build --force-rm

check-requirements-frontend:
	$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) run --rm --entrypoint bash frontend -c "php requirements.php"

check-requirements-backend:
	$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) run --rm --entrypoint bash backend -c "php requirements.php"

vendor-install:
	docker run --rm --interactive --tty -v ${PWD}:/app composer install 

vendor-update:
	docker run --rm --interactive --tty -v ${PWD}:/app composer update 	

dev-env:
	$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) run --rm --entrypoint bash frontend -c "php init --env=Development --overwrite=All"

migrate-db:
	$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) run --rm --entrypoint bash backend -c "php yii migrate"

migrate-test-db:
	$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) run --rm --entrypoint bash backend -c "php yii_test migrate"	

all:	 ##@test [TEST] shorthand for
	$(MAKE) up run-tests 

init-tests:	 ##@test run tests
	$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) run codecept bootstrap ./frontend
	$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) run codecept bootstrap ./backend

run-tests:	 ##@test run tests
	$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) run codecept run -x optional -vv --html=_report.html 

debug-tests:	 ##@test run tests
	$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) run codecept run --debug

debug-codeception-container:
	$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) run --rm --entrypoint bash codecept


# open-vnc:	 ##@test open application database service in browser
	# $(OPEN_CMD) vnc://x:secret@$(DOCKER_HOST_IP):$(shell $(DOCKER_COMPOSE) port firefox 5900 | sed 's/[0-9.]*://')
	# $(OPEN_CMD) vnc://x:secret@$(DOCKER_HOST_IP):$(shell $(DOCKER_COMPOSE) port chrome 5900 | sed 's/[0-9.]*://')

# open-report: ##@test open HTML reports
	# $(OPEN_CMD) tests/_output/_report.html
	# $(OPEN_CMD) tests/_output