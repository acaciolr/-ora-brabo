# ORA BRABO — CLAUDE CODE BRIEFING
> Leia este arquivo inteiro antes de qualquer ação no projeto.

---

## O QUE É ESTE PROJETO

**ORA BRABO Monitoring Tool** — TUI (Terminal User Interface) para Oracle Database, inspirada no Dolphie para MySQL, com funcionalidades equivalentes ao Oracle Enterprise Manager (OEM). Roda 100% em terminal Linux via SSH.

**Autor:** Acacio Lima Rocha (DBA BRABO)
**Stack:** Python 3.12+, Textual, Rich, oracledb (Thin Mode por padrão, Thick Mode opcional), AsyncIO
**Versão atual:** 1.3.3 — multi-tab, thick mode, cache priming (ver `core/version.py` / `pyproject.toml`)

---

## ESTRUTURA DO PROJETO

```
ora_brabo/
├── app.py                        # Entry point, OraBraboApp (Textual App), bindings F1-F12 + Ctrl+1-9
├── ora_brabo.tcss                # Dark theme CSS (GitHub dark palette)
├── requirements.txt              # oracledb, textual, rich, plotext, keyring
├── requirements-optional.txt     # reportlab+pillow — só para export de PDF (F-Report)
├── README.md
│
├── core/
│   ├── config.py                 # AppConfig dataclass (conexão padrão, wallet/ADB, thick mode, timeouts)
│   ├── connection_manager.py     # Pool async oracledb (Thin ou Thick), execute_query/ddl/fetch_one
│   ├── connection_session.py     # Bundle por aba: 1 conn_manager + 1 cache + 1 scheduler + 1 advisor
│   ├── connections_store.py      # Histórico de conexões (~/.ora_brabo/connections.json)
│   ├── demo_data.py              # DemoRunner — popula o cache com dados simulados (--demo, sem Oracle)
│   ├── cache.py                  # MetricsCache: TTL + ring-buffer 120 pontos, thread-safe
│   ├── scheduler.py              # Async scheduler por sessão, 17 collectors em tasks paralelas
│   └── version.py                # __version__ + BANNER_ART (fonte única de versão)
│
├── collectors/                   # 17 collectors ativos no scheduler (ver tabela abaixo)
│   ├── base.py                   # BaseCollector ABC
│   ├── health.py / sessions.py / sql.py / waits.py / rac.py / sqlmon.py
│   ├── dg.py / asm.py / rman.py / io_activity.py / pdb.py
│   ├── exadata.py / advisor.py / memory_advisor.py
│   └── awr.py / objects.py / alertlog.py
│
├── widgets/
│   ├── panels.py                 # 24 painéis Textual (F1-F12, Ctrl+1-9, x, p)
│   ├── charts.py                 # sparkline() e helpers de gráfico (plotext)
│   ├── add_connection_modal.py   # Tela de nova conexão (multi-tab)
│   ├── confirm_modal.py          # Modal de confirmação para Kill/Trace
│   ├── explain_screen.py         # Overlay de Explain Plan (F3 → 'e')
│   ├── session_detail_screen.py
│   ├── sql_input_screen.py
│   ├── text_view_screen.py
│   └── help_screen.py
│
├── advisor/
│   └── engine.py                 # AdvisorEngine: regras contínuas, Finding dataclass, Severity enum
│                                  # (instanciado por ConnectionSession, um por aba/conexão)
│
└── shell/
    ├── collect_rac.sh            # srvctl / crsctl / olsnodes → JSON stdout
    ├── collect_dg.sh             # dgmgrl show configuration
    └── collect_asm.sh            # asmcmd lsdg
```

> Nota: arquivos com sufixo `" 2.py"` (ex.: `exadata 2.py`, `connection_manager 2.py`) são cópias de conflito criadas pelo sync do iCloud Drive — não são rastreados pelo git (`.gitignore`) e podem ser ignorados/apagados com segurança.

---

## ARQUITETURA MULTI-TAB (mudança estrutural desde a v1.0.0)

O app deixou de ser single-connection. Cada aba é um `ConnectionSession` (`core/connection_session.py`) que empacota:
- seu próprio `ConnectionManager` (pool de conexão)
- seu próprio `MetricsCache`
- seu próprio `Scheduler` (17 collectors)
- seu próprio `AdvisorEngine`
- um health-check loop (`_health_check_loop`) que faz `SELECT 1 FROM DUAL` a cada 15s e tenta reconectar após 3 falhas consecutivas

`OraBraboApp` (`app.py`) gerencia N sessões simultâneas via `Tabs`/`ContentSwitcher`. Nova conexão: tecla `+` (ou `Ctrl+N`/`Ctrl+O` como fallback para terminais que engolem essas teclas) abre `AddConnectionModal`. Fechar aba: `Ctrl+W`.

Modo demo (`--demo`) usa `DemoRunner` (`core/demo_data.py`, ~1100 linhas) em vez de scheduler+conn_manager — popula o cache com dados fake, sem precisar de Oracle.

---

## COLLECTORS ATIVOS E TIERS DE INTERVALO

Definidos em `core/scheduler.py`. Tiers calculados a partir do `refresh_interval` da sessão:
- `rt` (realtime) = `min(refresh, 2)` — Health, Waits
- `fast` = `max(refresh, 3)` — Sessions, SQL, RAC, SQL Monitor
- `med` = `max(refresh*2, 12)` — Data Guard, ASM, RMAN, I/O, PDB
- `slow` = `30` — Exadata, Advisor findings, Memory Advisor
- `heavy` = `60` — AWR, Objects, Alert Log (scans caros, mantidos espaçados para proteger produção)

| Collector | Tier | Painel(is) que consome |
|---|---|---|
| HealthCollector | rt | Dashboard (F1) |
| WaitsCollector | rt | Waits (F4), Dashboard |
| SessionsCollector | fast | Sessions (F2), Locks (F5) |
| SQLCollector | fast | Top SQL (F3) |
| RACCollector | fast | RAC (F6) |
| SQLMonitorCollector | fast | SQL Monitor (Ctrl+4) |
| DataGuardCollector | med | Data Guard (F7) |
| ASMCollector | med | ASM (F8) |
| RMANCollector | med | RMAN (F9) |
| IOActivityCollector | med | I/O (Ctrl+1) |
| PDBCollector | med | PDB (`p`) |
| ExadataCollector | slow | Exadata (`x`) |
| AdvisorCollector | slow | Advisor (F12) |
| MemoryAdvisorCollector | slow | Memory (Ctrl+2) |
| AWRCollector | heavy | AWR (F10), Segments (Ctrl+3) |
| ObjectsCollector | heavy | Segments (Ctrl+3) |
| AlertLogCollector | heavy | Alert Log (Ctrl+5) |

ASH é derivado de AWR/`v$active_session_history` (painel F11), não tem collector próprio dedicado.

---

## PAINÉIS (24 no total)

**Function keys:** F1 Dashboard · F2 Sessions · F3 Top SQL · F4 Waits · F5 Locks · F6 RAC · F7 Data Guard · F8 ASM · F9 RMAN · F10 AWR · F11 ASH · F12 Advisor
**Ctrl+1..9:** I/O · Memory Advisor · Segments · SQL Monitor · Alert Log · Wait Chains · Plan Baselines · Parallel Query · Report (export PDF)
**Teclas soltas (show=False):** `x` Exadata · `p` PDB
**In-panel:** `k` Kill session · `t` Trace session (ambos passam por `ConfirmModal`) · `e` Explain Plan · `r` Generate AWR report · `g` Generate PDF report (Report panel) · `?` Help · `q` Quit

Classes correspondentes em `widgets/panels.py`: `DashboardPanel`, `SessionsPanel`, `TopSQLPanel`, `WaitsPanel`, `LocksPanel`, `RACPanel`, `DataGuardPanel`, `ASMPanel`, `RMANPanel`, `AWRPanel`, `ASHPanel`, `AdvisorPanel`, `ExadataPanel`, `PDBPanel`, `IOActivityPanel`, `MemoryAdvisorPanel`, `SegmentsPanel`, `SQLMonitorPanel`, `AlertLogPanel`, `WaitChainPanel`, `PlanBaselinesPanel`, `ParallelQueryPanel`, `ReportPanel`.

---

## CONEXÃO — MODOS SUPORTADOS

1. **TCP padrão** — `--host --port --service --user --password`
2. **Wallet / ADB / OCI** — `--wallet-zip` (+ `--wallet-password` opcional para `ewallet.p12`; omitir para auto-login via `cwallet.sso`)
3. **Thick Mode** — `--thick` (+ `--client-dir` opcional) — necessário para Oracle 11g ou Native Network Encryption (Thin mode só alcança 12.1+ com TLS). `init_oracle_client()` é global ao processo e irreversível: uma vez ativado, o app inteiro roda Thick até reiniciar.
4. **Demo** — `--demo`, sem banco algum, dados simulados via `DemoRunner`.

Todas essas opções vivem em `AppConfig` (`core/config.py`) e são passadas via CLI em `app.py:main()`. Sem argumentos suficientes, o app abre a tela de conexão interativa (`AddConnectionModal`).

---

## BUGS HISTÓRICOS — TODOS CORRIGIDOS (mantido como referência)

As versões anteriores deste briefing (era v1.0.0) listavam 5 bugs conhecidos. Todos já foram corrigidos no código atual — confirmado por grep em 2026-08-06:

- ~~AdvisorEngine nunca era iniciado~~ → agora instanciado por `ConnectionSession.connect()` (`core/connection_session.py`), um por aba.
- ~~Cache key mismatch `health.active_count` vs `health.active_sessions`~~ → `panels.py` já lê `health.active_sessions` corretamente.
- ~~RMAN JOIN incorreto com `session_key`~~ → `collectors/rman.py` não usa mais esse JOIN.
- ~~Faltavam `__init__.py`~~ → presentes em `core/`, `collectors/`, `widgets/`, `advisor/`.
- ~~`FETCH FIRST` incompatível com 11g~~ → só resta um comentário em `collectors/exadata.py` avisando para não reintroduzir; o SQL real usa `ROWNUM`.

Se reaparecer alguma regressão nesses pontos, tratar como prioridade alta — são bugs que já causaram problemas reais em produção.

---

## PRÓXIMAS FEATURES — BACKLOG

Itens do backlog antigo já entregues: sparklines (`widgets/charts.py`), tela de login/conexão (`AddConnectionModal` + `connections_store.py`), PDB monitoring (`collectors/pdb.py` + `PDBPanel`), Exadata detection (`collectors/exadata.py` + `ExadataPanel`), Kill/Trace com confirmação (`ConfirmModal`), Explain Plan inline (`explain_screen.py`), multi-banco (arquitetura multi-tab).

Em aberto / candidatos a próximo trabalho:
- Consolidar os arquivos `widgets/tables.py` (helpers de tabela ainda vivem soltos em `panels.py`, que está com 4285 linhas — vale extrair)
- Revisar duplicidade de lógica entre `collectors/advisor.py` (collector) e `advisor/engine.py` (engine) — nomes parecidos, checar se há sobreposição de responsabilidade antes de mexer
- Limpar os arquivos-fantasma `" 2.py"` do iCloud sync quando o usuário confirmar que não há edições pendentes neles

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

O modo demo já está implementado e é a forma recomendada de testar UI sem banco:

```bash
python app.py --demo --refresh 5
```

Isso inicia uma sessão com `DemoRunner` (`core/demo_data.py`) alimentando o cache com dados simulados — dashboard, sessões, SQL, waits, RAC, Data Guard, ASM, RMAN, AWR, tudo populado sem conexão real.

---

## REFERÊNCIA — DEMO HTML

O arquivo `ora_brabo_demo.html` (na raiz do projeto, se presente) é o **design reference** visual da interface. Consultar sempre que criar novos painéis ou componentes visuais.

---

## DEPENDÊNCIAS

```
oracledb>=2.0.0      # Oracle Thin Mode (padrão) ou Thick Mode via Instant Client (--thick)
textual>=0.52.0      # TUI framework
rich>=13.7.0         # Renderização visual
plotext>=5.0.0       # Sparklines/gráficos nos painéis
keyring>=24.0.0      # Armazenamento seguro de credenciais (connections_store)
```

Opcional (só para export de PDF no painel Report):
```
reportlab>=4.0.0
pillow>=10.4.0       # instalar sempre com --prefer-binary (ver requirements-optional.txt)
```

Instalar:
```bash
pip install -r requirements.txt
pip install --prefer-binary -r requirements-optional.txt   # opcional, para PDF
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

# Oracle ADB / OCI via Wallet
python app.py --wallet-zip ~/wallet.zip --service mydb_high \
              --user admin --password SenhaAqui

# Thick mode (11g ou Native Network Encryption)
python app.py --host legacy11g --service ORCL --user system --password SenhaAqui \
              --thick --client-dir /opt/oracle/instantclient_21_13

# Demo, sem Oracle
python app.py --demo

# Sem argumentos — abre tela de conexão interativa
python app.py
```

---

*Este briefing foi atualizado em 2026-08-06 a partir da análise completa do código-fonte atual (v1.3.3). Atualizar sempre que fizer mudanças estruturais significativas.*
