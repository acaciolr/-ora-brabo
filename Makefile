# ORA BRABO — Makefile
VENV    := .venv
PYTHON  := $(VENV)/bin/python
PIP     := $(VENV)/bin/pip

.PHONY: install run dev clean

## Instala dependências em virtualenv e configura alias
install:
	@bash install.sh

## Roda o ORA BRABO (usa venv se existir)
run:
	@bash ora_brabo.sh

## Instala dependências de desenvolvimento (textual devtools)
dev: $(VENV)
	$(PIP) install textual-dev

## Cria o virtualenv se não existir
$(VENV):
	python3 -m venv $(VENV)
	$(PIP) install --upgrade pip -q
	$(PIP) install -r requirements.txt

## Remove virtualenv e arquivos temporários
clean:
	rm -rf $(VENV) __pycache__ **/__pycache__ *.pyc **/*.pyc /tmp/ora_brabo.log
