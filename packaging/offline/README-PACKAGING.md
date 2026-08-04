# Convenção de empacotamento OFFLINE (air-gapped)

Todo pacote offline gerado para o servidor de produção DEVE conter, na raiz:

```
ora-brabo-offline/
├── ora_brabo/            # código da app (com requirements.txt e requirements-optional.txt)
├── wheels/               # TODAS as dependencias em wheel (cp311, x86_64, glibc 2.28)
├── install.sh            # primeira instalacao offline (deste diretorio: packaging/offline/)
├── reinstall.sh          # recria o venv do zero (usar ao ATUALIZAR / se corromper)
└── LEIA-ME-OFFLINE.md    # passo a passo
```

Regras:
- `install.sh` e `reinstall.sh` vêm SEMPRE deste diretório (`packaging/offline/`), não são os
  scripts online da raiz do projeto (aquele `install.sh` da raiz é para máquina de dev com internet).
- Os scripts auto-detectam o Python nesta ordem: `$PYTHON` -> `../python/bin/python3`
  (python portátil ao lado do pacote) -> `python3.11` do sistema.
- Alvo atual: Oracle Linux 8, x86_64, glibc 2.28, Python 3.11 (wheels cp311).
  Se mudar arquitetura/versão do Python, regerar os wheels correspondentes.

Layout no servidor (versionado + symlink para rollback fácil):
```
/home/oracle/acaciolr/orabrabo/
├── python/               # python-build-standalone (reutilizado entre versoes)
├── ora-brabo-1.3.3/      # cada versao numa pasta
├── ora-brabo-1.3.4/
└── current -> ora-brabo-1.3.4   # o alias aponta para 'current'
```
