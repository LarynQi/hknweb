PIP_HOME = $(shell python3 -c "import site; import os; print(os.path.join(site.USER_BASE, 'bin'))" \
	|| python -c "import site; import os; print(os.path.join(site.USER_BASE, 'bin'))")

VENV := .venv
BIN := $(VENV)/bin
PYTHON := $(BIN)/python
MANAGE := UPEWEB_MODE='dev' $(PYTHON) ./manage.py

IP ?= 127.0.0.1
PORT ?= 3000

.PHONY: dev
dev:
	$(MANAGE) runserver $(IP):$(PORT)

.PHONY: livereload
livereload:
	$(MANAGE) livereload $(IP):$(PORT)

.PHONY: venv
venv:
	python3 -m venv $(VENV)
	@echo "When developing, activate the virtualenv with 'source .venv/bin/activate' so Python can access the installed dependencies."

.PHONY: install-prod
install-prod:
	# For issues with binary packages, consider https://pythonwheels.com/
	$(PYTHON) -m pip install --upgrade "pip<=20.3.4"
	$(PYTHON) -m pip install --upgrade "setuptools<=51.2.0"
	# TODO: pinned/unpinned dependency version.
	# See https://upe-mu.atlassian.net/browse/COMPSERV-110
	$(PYTHON) -m pip install -r requirements.txt

.PHONY: install
install:
	make install-prod
	$(PYTHON) -m pip install -r requirements-dev.txt

.PHONY: createsuperuser superuser
superuser: createsuperuser
createsuperuser:
	$(MANAGE) createsuperuser

.PHONY: migrate
migrate:
	$(MANAGE) migrate

.PHONY: makemigrations migrations
migrations: makemigrations
makemigrations:
	$(MANAGE) makemigrations

.PHONY: shell
shell:
	$(MANAGE) shell

.PHONY: test
test: venv
	$(BIN)/pytest -v tests/
	$(BIN)/pre-commit run --all-files

.PHONY: clean
clean:
	rm -rf $(VENV)

.PHONY: mysql
mysql:
	mysql -e "CREATE DATABASE IF NOT EXISTS upe;"
	mysql -e "GRANT ALL PRIVILEGES ON upe.* TO 'upe'@'localhost' IDENTIFIED BY 'upeweb-dev';"

.PHONY: permissions
permissions:
	$(MANAGE) shell < upeweb/init_permissions.py
