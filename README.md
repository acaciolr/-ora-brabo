# ORA BRABO Monitoring Tool
**Oracle Database TUI Monitor | DBA BRABO | Acacio Lima Rocha**

---

## O que é

Ferramenta TUI (Terminal User Interface) para Oracle Database inspirada no Dolphie para MySQL, incorporando funcionalidades equivalentes ao Oracle Enterprise Manager (OEM) — totalmente no terminal, via SSH, sem interface gráfica.

---

## Instalação

```bash
# Clonar/copiar o projeto
cd ora_brabo

# Instalar dependências (Python 3.12+)
pip install -r requirements.txt

# Dar permissão nos scripts shell
chmod +x shell/*.sh
```

---

## Uso

```bash
python app.py \
  --host   192.168.1.10 \
  --port   1521 \
  --service ORCL \
  --user   system \
  --password SenhaAqui \
  --refresh 5

# Como SYSDBA
python app.py \
  --host    localhost \
  --service ORCL \
  --user    sys \
  --password SenhaAqui \
  --sysdba \
  --refresh 3
```

---

## Navegação

| Tecla | Painel           |
|-------|-----------------|
| F1    | Dashboard        |
| F2    | Sessions         |
| F3    | Top SQL          |
| F4    | Wait Events      |
| F5    | Lock Tree        |
| F6    | RAC Overview     |
| F7    | Data Guard       |
| F8    | ASM / FRA        |
| F9    | RMAN             |
| F10   | AWR / Tablespaces|
| F11   | ASH              |
| F12   | Advisor          |

| Atalho | Ação                      |
|--------|--------------------------|
| K      | Kill session selecionada  |
| T      | Trace session selecionada |
| E      | Explain Plan (Top SQL)    |
| R      | Gerar AWR Report          |
| Q      | Sair                      |

---

## Arquitetura

```
ora_brabo/
├── app.py                      # Entry point / Textual App
├── ora_brabo.tcss              # Dark theme CSS
├── requirements.txt
│
├── core/
│   ├── config.py               # AppConfig dataclass
│   ├── connection_manager.py   # oracledb pool (Thin Mode)
│   ├── cache.py                # MetricsCache com TTL + ring-buffer
│   └── scheduler.py            # Async scheduler de collectors
│
├── collectors/
│   ├── base.py                 # BaseCollector abstract
│   ├── health.py               # CPU, mem, SGA, PGA, rates
│   ├── sessions.py             # GV$SESSION
│   ├── sql.py                  # GV$SQL top SQL
│   ├── waits.py                # GV$SYSTEM_EVENT, GV$SESSION waits
│   ├── rac.py                  # GV$INSTANCE, GC stats, interconnect
│   ├── dg.py                   # V$DATAGUARD_STATS, V$MANAGED_STANDBY
│   ├── asm.py                  # V$ASM_DISKGROUP, V$RECOVERY_FILE_DEST
│   ├── rman.py                 # V$RMAN_STATUS
│   └── awr.py                  # DBA_HIST_*, GV$ACTIVE_SESSION_HISTORY
│
├── widgets/
│   └── panels.py               # 12 painéis Textual (F1–F12)
│
├── advisor/
│   └── engine.py               # Advisor engine — regras e findings
│
└── shell/
    ├── collect_rac.sh          # srvctl / crsctl / olsnodes
    ├── collect_dg.sh           # dgmgrl show configuration
    └── collect_asm.sh          # asmcmd lsdg
```

---

## Privilégios mínimos recomendados

```sql
-- Usuário de monitoramento (sem SYSDBA)
CREATE USER ora_brabo IDENTIFIED BY SenhaMonitor;
GRANT CREATE SESSION TO ora_brabo;
GRANT SELECT ANY DICTIONARY TO ora_brabo;
GRANT SELECT ON V_$SESSION TO ora_brabo;
GRANT SELECT ON V_$SQL TO ora_brabo;
GRANT SELECT ON V_$SYSTEM_EVENT TO ora_brabo;
GRANT SELECT ON V_$SYSSTAT TO ora_brabo;
GRANT SELECT ON V_$OSSTAT TO ora_brabo;
GRANT SELECT ON V_$RMAN_STATUS TO ora_brabo;
GRANT SELECT ON GV_$SESSION TO ora_brabo;
GRANT SELECT ON GV_$SQL TO ora_brabo;
GRANT SELECT ON GV_$INSTANCE TO ora_brabo;
GRANT SELECT ON GV_$ACTIVE_SESSION_HISTORY TO ora_brabo;
GRANT SELECT ON DBA_HIST_SNAPSHOT TO ora_brabo;
GRANT SELECT ON DBA_HIST_SQL_PLAN TO ora_brabo;
GRANT SELECT ON DBA_ADVISOR_TASKS TO ora_brabo;
GRANT SELECT ON DBA_ADVISOR_FINDINGS TO ora_brabo;
GRANT SELECT ON DBA_TABLESPACES TO ora_brabo;
GRANT SELECT ON DBA_FREE_SPACE TO ora_brabo;
GRANT SELECT ON DBA_DATA_FILES TO ora_brabo;
-- Para kill session (opcional — somente DBA)
GRANT ALTER SYSTEM TO ora_brabo;
```

---

## Compatibilidade

| Feature        | 11g | 12c | 18c | 19c | 21c | 23ai |
|---------------|-----|-----|-----|-----|-----|------|
| Dashboard     | ✓   | ✓   | ✓   | ✓   | ✓   | ✓    |
| Sessions      | ✓   | ✓   | ✓   | ✓   | ✓   | ✓    |
| Top SQL       | ✓   | ✓   | ✓   | ✓   | ✓   | ✓    |
| RAC           | ✓   | ✓   | ✓   | ✓   | ✓   | ✓    |
| Data Guard    | ✓   | ✓   | ✓   | ✓   | ✓   | ✓    |
| ASM           | ✓   | ✓   | ✓   | ✓   | ✓   | ✓    |
| RMAN          | ✓   | ✓   | ✓   | ✓   | ✓   | ✓    |
| AWR/ASH       | ✓*  | ✓   | ✓   | ✓   | ✓   | ✓    |
| PDB Monitor   | -   | ✓   | ✓   | ✓   | ✓   | ✓    |
| Exadata       | -   | ✓   | ✓   | ✓   | ✓   | ✓    |

*AWR/ASH requerem Diagnostics Pack license no 11g/12c.

---

## Logs

```bash
tail -f /tmp/ora_brabo.log
```

---

**DBA BRABO | Oracle TUI Monitor v1.0**
