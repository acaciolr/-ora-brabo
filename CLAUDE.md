# ORA BRABO — CLAUDE CODE BRIEFING
> Leia este arquivo inteiro antes de qualquer ação no projeto.

---

## O QUE É ESTE PROJETO

**ORA BRABO Monitoring Tool** — TUI (Terminal User Interface) para Oracle Database, inspirada no Dolphie para MySQL, com funcionalidades equivalentes ao Oracle Enterprise Manager (OEM). Roda 100% em terminal Linux via SSH.

**Autor:** Acacio Lima Rocha (DBA BRABO)  
**Stack:** Python 3.12+, Textual, Rich, oracledb (Thin Mode), AsyncIO  
**Versão atual:** 1.0.0 (base funcional, em evolução)

---

## ESTRUTURA DO PROJETO

```
ora_brabo/
├── app.py                        # Entry point, OraBraboApp (Textual App), bindings F1-F12
├── ora_brabo.tcss                # Dark theme CSS (GitHub dark palette)
├── requirements.txt              # oracledb>=2.0, textual>=0.52, rich>=13.7
├── README.md
│
├── core/
│   ├── config.py                 # AppConfig dataclass (host, port, service, user, pass, refresh, sysdba)
│   ├── connection_manager.py     # Pool async oracledb Thin Mode, execute_query/ddl/fetch_one
│   ├── cache.py                  # MetricsCache: TTL + ring-buffer 120 pontos, thread-safe
│   └── scheduler.py              # Async scheduler, roda todos collectors em tasks paralelas
│
├── collectors/
│   ├── base.py                   # BaseCollector ABC
│   ├── health.py                 # CPU, memória, SGA, PGA, sessões, rates (diff-based)
│   ├── sessions.py               # GV$SESSION completo com blocking
│   ├── sql.py                    # Top SQL por CPU, full text, explain plan, sql monitor
│   ├── waits.py                  # GV$SYSTEM_EVENT, active waits, por classe
│   ├── rac.py                    # GV$INSTANCE, GC stats + latência calculada, interconnect
│   ├── dg.py                     # V$DATAGUARD_STATS, MRP/RFS processes, archive dests, gaps
│   ├── asm.py                    # V$ASM_DISKGROUP, FRA, archive generation rate
│   ├── rman.py                   # V$RMAN_STATUS: jobs ativos, histórico, backup sets
│   └── awr.py                    # DBA_HIST_SNAPSHOT, ADDM tasks/findings, ASH, Tablespaces
│
├── widgets/
│   └── panels.py                 # 12 painéis Textual (F1=Dashboard até F12=Advisor)
│
├── advisor/
│   └── engine.py                 # AdvisorEngine: regras contínuas, Finding dataclass, Severity enum
│
└── shell/
    ├── collect_rac.sh            # srvctl / crsctl / olsnodes → JSON stdout
    ├── collect_dg.sh             # dgmgrl show configuration
    └── collect_asm.sh            # asmcmd lsdg
```

---

## ESTADO ATUAL — O QUE FUNCIONA

### ✅ Core (sólido, não mexer sem motivo)
- `AppConfig` com DSN property
- `ConnectionManager`: pool async, introspection (`_collect_db_info`), execute_query/ddl/fetch_one, tratamento de erros
- `MetricsCache`: TTL por chave, ring-buffer de histórico, thread-safe com RLock
- `Scheduler`: tasks paralelas por collector, intervalos diferenciados (health=5s, sql=10s, awr=60s, etc.)
- `BaseCollector`: ABC simples e funcional

### ✅ Collectors (todos implementados)
| Collector | Cache Keys Produzidas |
|---|---|
| HealthCollector | `health.db_info`, `health.total_sessions`, `health.active_sessions`, `health.sga_mb`, `health.pga_mb`, `health.cpu_load`, `health.memory`, `health.rates` |
| SessionsCollector | `sessions.list`, `sessions.active_count`, `sessions.total_count` |
| SQLCollector | `sql.top` |
| WaitsCollector | `waits.system_top`, `waits.active_sessions`, `waits.by_class` |
| RACCollector | `rac.detected`, `rac.instances`, `rac.gc_stats`, `rac.interconnect` |
| DataGuardCollector | `dg.role`, `dg.protection_mode`, `dg.stats`, `dg.standby_processes`, `dg.archive_dests`, `dg.archive_gap`, `dg.log_history` |
| ASMCollector | `asm.diskgroups`, `asm.fra`, `asm.fra_files`, `asm.archive_rate_mb` |
| RMANCollector | `rman.active`, `rman.history`, `rman.backup_sets` |
| AWRCollector | `awr.snapshots`, `awr.addm_tasks`, `awr.addm_findings`, `ash.samples`, `awr.tablespaces` |

### ✅ AdvisorEngine (regras implementadas)
Regras cobrindo: Top SQL (CPU% e buffer gets/exec), sessões altas, bloqueios, waits críticos (log file sync, db file sequential read, buffer busy waits), tablespaces cheios, RMAN failures, Data Guard lag, FRA usage, OS load, hard parses.

### ✅ TUI Panels (12 painéis)
Dashboard (F1), Sessions (F2), Top SQL (F3), Waits (F4), Locks (F5), RAC (F6), Data Guard (F7), ASM (F8), RMAN (F9), AWR/Tablespaces (F10), ASH (F11), Advisor (F12).

---

## BUGS CONHECIDOS — CORRIGIR ANTES DE QUALQUER FEATURE

### 🔴 BUG 1 — AdvisorEngine nunca é iniciado
**Arquivo:** `app.py`  
**Problema:** `AdvisorEngine` está implementado em `advisor/engine.py` mas **nunca é instanciado nem iniciado** no `on_mount()` do `OraBraboApp`. O painel F12 (AdvisorPanel) sempre mostra "No issues detected." mesmo havendo problemas.  
**Fix:**
```python
# Em app.py, adicionar import:
from advisor.engine import AdvisorEngine

# Em OraBraboApp.__init__():
self.advisor_engine: AdvisorEngine | None = None

# Em on_mount(), após criar o scheduler:
self.advisor_engine = AdvisorEngine(
    conn_manager=self.conn_manager,
    cache=self.cache,
    interval=self.config.advisor_eval_interval_sec,
)
asyncio.create_task(self.advisor_engine.run())
```

### 🔴 BUG 2 — Inconsistência de chave no cache (active_sessions)
**Arquivo:** `collectors/health.py` e `widgets/panels.py`  
**Problema:** `HealthCollector` grava `health.active_sessions` mas `DashboardPanel._render_health()` lê `health.active_count` (chave inexistente). Active sessions sempre aparece 0 no dashboard.  
**Fix em `panels.py`:**
```python
# Linha incorreta:
active = self.cache.get("health.active_count", 0) or 0
# Corrigir para:
active = self.cache.get("health.active_sessions", 0) or 0
```

### 🔴 BUG 3 — RMAN JOIN incorreto
**Arquivo:** `collectors/rman.py`, `_SQL_ACTIVE`  
**Problema:** `JOIN v$session s ON s.sid = rs.session_key` — o campo `session_key` em `V$RMAN_STATUS` não é o SID da sessão, é um identificador interno do RMAN. O JOIN vai produzir resultado errado ou vazio.  
**Fix:** Remover o JOIN com v$session ou usar `rs.session_recid`/subquery correta. A query de jobs ativos deve ser simplificada:
```sql
SELECT
    rs.status,
    rs.command_id,
    rs.input_type,
    rs.output_device_type,
    rs.start_time,
    rs.input_bytes_per_sec / 1048576    AS input_mb_per_sec,
    rs.output_bytes_per_sec / 1048576   AS output_mb_per_sec,
    rs.input_bytes / 1048576            AS input_mb,
    rs.output_bytes / 1048576           AS output_mb,
    rs.elapsed_seconds,
    rs.est_remaining_time_display       AS eta,
    rs.operation
FROM v$rman_status rs
WHERE rs.status = 'RUNNING'
ORDER BY rs.start_time DESC
```

### 🔴 BUG 4 — Faltam `__init__.py` nos pacotes
**Problema:** `core/`, `collectors/`, `widgets/`, `advisor/` não têm `__init__.py`. Em alguns ambientes Python os imports relativos vão falhar.  
**Fix:** Criar arquivo vazio `__init__.py` em cada diretório de pacote.

### 🟡 BUG 5 — Incompatibilidade Oracle 11g (`FETCH FIRST`)
**Arquivo:** `collectors/rman.py`, `_SQL_BACKUP_SETS`  
**Problema:** `FETCH FIRST 30 ROWS ONLY` não é suportado no Oracle 11g.  
**Fix:** Envolver com `WHERE ROWNUM <= 30` como já feito nos outros SQLs.

---

## PRÓXIMAS FEATURES — BACKLOG PRIORIZADO

### PRIORIDADE 1 — Gráficos sparkline no Dashboard
O `MetricsCache` já armazena ring-buffer de 120 pontos (`get_history_values(key)`). Falta renderizar.  
- Criar `widgets/charts.py` com função `sparkline(values: list[float], width: int = 20) -> Text`
- Usar caracteres Unicode: `▁▂▃▄▅▆▇█`
- Integrar no `DashboardPanel` para: CPU load, Active Sessions, Redo MB/s, Logical Reads/s

### PRIORIDADE 2 — Tela de login interativa
Atualmente só aceita parâmetros CLI. Criar tela Textual inicial com campos:
- Host, Port, Service, Username, Password, SYSDBA checkbox
- Histórico de conexões recentes (salvo em `~/.ora_brabo/connections.json`)

### PRIORIDADE 3 — `widgets/tables.py` separado
Extrair helpers de tabelas repetidos nos painéis para módulo separado:
- `make_sessions_table(rows)`
- `make_sql_table(rows)`
- `make_waits_table(rows)`
- `pct_bar(pct, width)` (já existe em panels.py como `_pct_bar`)

### PRIORIDADE 4 — PDB Monitoring (CDB)
O `ConnectionManager` já detecta `is_cdb`. Falta:
- Collector `collectors/pdb.py` consultando `CDB_PDBS`, `V$PDBS`
- Painel `PDBPanel` mostrando status, sessions, storage por PDB

### PRIORIDADE 5 — Exadata Detection
- Collector `collectors/exadata.py`: detectar `V$CELL_STATE`, `V$CELL_CONFIG`
- Mostrar Cell Servers, Smart Scan %, Offload %, Flash Cache

### PRIORIDADE 6 — Kill/Trace com confirmação
Atualmente `action_kill` e `action_trace` executam imediatamente. Adicionar modal de confirmação Textual antes de executar DDL destrutivo.

### PRIORIDADE 7 — Explain Plan inline
`SQLCollector.fetch_explain_plan()` já existe. Falta exibir o resultado em modal/overlay no painel F3.

### PRIORIDADE 8 — Suporte multi-banco
A arquitetura atual é single-connection. Preparar para múltiplas conexões simultâneas (lista de bancos monitorados).

---

## CONVENÇÕES E PADRÕES DO PROJETO

### Cache keys
Sempre no formato `{dominio}.{metrica}`. Ex: `health.cpu_load`, `rac.instances`, `dg.stats`.  
TTL padrão = `self.interval + 2` para dados voláteis, `60` para dados semi-estáticos, `300` para dados lentos (AWR snapshots).

### SQL
- Sempre usar `ROWNUM <= N` para limitar (não `FETCH FIRST` — compatibilidade 11g)
- Usar `GV$` em vez de `V$` sempre que fizer sentido em RAC
- Nunca hardcodar schema — filtrar `parsing_schema_name NOT IN ('SYS','SYSTEM','DBSNMP','SYSMAN')`
- Aliases sempre em lowercase (facilita `dict(zip(cols, row))`)

### Logging
```python
log = logging.getLogger(__name__)
# Log vai para /tmp/ora_brabo.log
```

### Erros de query
`execute_query` retorna `[]` em caso de erro (não levanta exceção). `fetch_one` retorna `None`. Sempre tratar o retorno.

### Estilo visual (Dark Theme)
Paleta GitHub dark:
- Background: `#0d1117` / `#161b22` / `#1c2128`
- Texto: `#e6edf3` / `#8b949e`
- Blue: `#58a6ff` | Green: `#3fb950` | Yellow: `#e3b341` | Red: `#f85149`
- Fonte mono em todo lugar

---

## COMO RODAR LOCALMENTE (SEM ORACLE)

Para desenvolver a UI sem banco Oracle disponível, usar dados mockados:

```python
# Exemplo: popular o cache manualmente para testar painéis
cache = MetricsCache()
cache.set("health.db_info", {
    "db_name": "ORCL", "dbid": "1234567890",
    "db_unique_name": "ORCL_PRIMARY", "version": "19.3.0.0.0",
    "host_name": "oraserver01", "open_mode": "READ WRITE",
    "database_role": "PRIMARY", "cdb": "YES",
    "flashback_on": "YES", "log_mode": "ARCHIVELOG",
    "startup_time": datetime.now() - timedelta(days=42),
})
cache.set("health.cpu_load", 3.7)
cache.set("health.total_sessions", 127)
cache.set("health.active_sessions", 23)
# etc...
```

Criar `dev_mock.py` na raiz para iniciar app com dados fake sem precisar de conexão Oracle.

---

## REFERÊNCIA — DEMO HTML

O arquivo `ora_brabo_demo.html` (na raiz do projeto) é o **design reference** visual da interface. Mostra o layout, paleta de cores, tipografia e componentes como deveriam aparecer no terminal. Consultar sempre que criar novos painéis ou componentes visuais.

---

## DEPENDÊNCIAS

```
oracledb>=2.0.0      # Oracle Thin Mode — sem Oracle Client
textual>=0.52.0      # TUI framework
rich>=13.7.0         # Renderização visual
```

Instalar:
```bash
pip install -r requirements.txt
```

---

## EXEMPLO DE USO

```bash
# Single Instance
python app.py --host 192.168.1.10 --port 1521 --service ORCL \
              --user system --password SenhaAqui --refresh 5

# Como SYSDBA
python app.py --host localhost --service ORCL \
              --user sys --password SenhaAqui --sysdba --refresh 3
```

---

*Este briefing foi gerado a partir da análise completa do código-fonte. Atualizar sempre que fizer mudanças estruturais significativas.*
