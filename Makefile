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

bootstrap-tests:	 ##@test
	$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) run codecept bootstrap ./frontend
	$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) run codecept bootstrap ./backend
	$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) run codecept bootstrap ./common

build-tests:	 ##@test run tests
	$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) run codecept build

run-tests:	 ##@test run tests
	$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) run codecept run -x optional -vv --html=_report.html 

debug-tests:	 ##@test run tests
	$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) run codecept run --debug

prepare-test-databases:
	## remove all test db containers
	docker container prune -f
	## remove latest db image
	docker image prune -f
	## build new test db container
	$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) up -d
	#wait for mySQL container to be ready for migration
	docker exec test-mysql /root/waitForMySQL.sh
	$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) run --rm --entrypoint bash backend -c "php yii_test migrate --interactive=0"
	## commit created test db container to image for reusability
	docker commit test-mysql test-mysql-image
	## build three replicas of the test db container with the created test database
	docker run -d --network="docker_dev-env-yii2" --name test-mysql-1 test-mysql-image
	docker run -d --network="docker_dev-env-yii2" --name test-mysql-2 test-mysql-image
	docker run -d --network="docker_dev-env-yii2" --name test-mysql-3 test-mysql-image

clean-test-outputs:
	find frontend/tests/_output ! -name '.gitignore' -type f -exec rm -f {} +
	find backend/tests/_output ! -name '.gitignore' -type f -exec rm -f {} +
	find common/tests/_output ! -name '.gitignore' -type f -exec rm -f {} +

clean-test-parallel-files:
	find frontend/tests/_data/parallel-files ! -name '.gitignore' -type f -exec rm -f {} +
	find backend/tests/_data/parallel-files ! -name '.gitignore' -type f -exec rm -f {} +
	find common/tests/_data/parallel-files ! -name '.gitignore' -type f -exec rm -f {} +

run-tests-parallel:	 ##@test run tests in parallel mode with combining results into html	
	$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) run --rm --entrypoint bash codecept -c "php vendor/consolidation/robo/robo parallel:all"


debug-codeception-container:
	$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) run --rm --entrypoint bash codecept


# open-vnc:	 ##@test open application database service in browser
	# $(OPEN_CMD) vnc://x:secret@$(DOCKER_HOST_IP):$(shell $(DOCKER_COMPOSE) port firefox 5900 | sed 's/[0-9.]*://')
	# $(OPEN_CMD) vnc://x:secret@$(DOCKER_HOST_IP):$(shell $(DOCKER_COMPOSE) port chrome 5900 | sed 's/[0-9.]*://')

# open-report: ##@test open HTML reports
	# $(OPEN_CMD) tests/_output/_report.html
	# $(OPEN_CMD) tests/_output