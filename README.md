<div align="center">

```
 ██████╗ ██████╗  █████╗     ██████╗ ██████╗  █████╗ ██████╗  ██████╗ 
██╔═══██╗██╔══██╗██╔══██╗    ██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔═══██╗
██║   ██║██████╔╝███████║    ██████╔╝██████╔╝███████║██████╔╝██║   ██║
██║   ██║██╔══██╗██╔══██║    ██╔══██╗██╔══██╗██╔══██║██╔══██╗██║   ██║
╚██████╔╝██║  ██║██║  ██║    ██████╔╝██║  ██║██║  ██║██████╔╝╚██████╔╝
 ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝  ╚═════╝ 
```

**Oracle Database TUI Monitoring Tool**

*The Dolphie for Oracle. The OEM you can SSH into.*

[![Python](https://img.shields.io/badge/Python-3.10%2B-blue?style=flat-square&logo=python)](https://python.org)
[![Oracle](https://img.shields.io/badge/Oracle-11g%20→%2023ai-red?style=flat-square&logo=oracle)](https://oracle.com)
[![Textual](https://img.shields.io/badge/TUI-Textual-purple?style=flat-square)](https://textual.textualize.io)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)
[![DBA BRABO](https://img.shields.io/badge/by-DBA%20BRABO-orange?style=flat-square)](https://github.com/acaciolr)

</div>

---

## O que é o ORA BRABO?

**ORA BRABO** é uma ferramenta de monitoramento Oracle Database que roda 100% no terminal via SSH — sem agente, sem Java, sem browser, sem licença de OEM.

Inspirada no [Dolphie](https://github.com/charles-001/dolphie) (MySQL), foi construída para DBAs Oracle que vivem no terminal e precisam de uma visão operacional completa em tempo real: sessões, SQL, waits, bloqueios, RAC, Data Guard, RMAN, ASM, Exadata e muito mais — tudo em uma única interface interativa, com **múltiplos bancos em abas simultâneas**, **Thin ou Thick mode**, e **instalação offline** para ambientes air-gapped.

> *"O que o Dolphie é pro MySQL, o ORA BRABO é pro Oracle — com funcionalidades do OEM, Foglight e Toad Monitor numa TUI moderna."*

---

## Screenshots

### 🖥️ Dashboard Principal (F1)
> Visão geral completa do banco em tempo real: identidade do banco, health overview com gráficos de CPU/Sessões/Redo/Execuções, top wait events com barras coloridas por classe, RAC instances e Data Guard status — tudo numa única tela.
![Dashboard](docs/images/01_dashboard.png)

### 👥 Sessions Monitor (F2)
> Monitor completo de sessões com `GV$SESSION`: SID, Serial#, Username, Status, Event, Wait Class, SQL ID, Machine, Program e sessões bloqueadoras em vermelho. Suporte a Kill `[K]`, Trace `[T]`, Detail `[D]` e filtro `[/]`.
![Sessions](docs/images/02_sessions.png)

### 🔍 Top SQL por CPU (F3)
> Top SQL rankeado por consumo de CPU com gráficos em tempo real de CPU Seconds, Elapsed e Buffer Gets. Tabela com SQL_ID, Schema, Execuções, CPU%, Buffer Gets, Disk Reads e preview automático do SQL text ao navegar.
![Top SQL](docs/images/03_top_sql.png)

### ⏱️ Wait Event Monitor (F4)
> Monitor completo de wait events: gráficos de Top Wait Event, Non-Idle Total e Active Wait Sessions. Tabela com Event, Wait Class, Time(s), Avg(ms), Total Waits e % Non-Idle. Wait Class Summary com distribuição visual.
![Waits](docs/images/04_waits.png)

### 🔒 Lock Monitor (F5)
> Monitoramento avançado de bloqueios com drill-down completo: tabela de blockers com Kill Command pronto, painel do bloqueador com DATABASE INFORMATION, TIME LOCK em segundos, SQL_ID, objetos bloqueados (TABLE/INDEX com Lock Mode) e lista de waiters.
![Locks](docs/images/05_locks.png)

### 🏗️ RAC Cluster Monitor (F6)
> Visão completa do ambiente RAC: instâncias com Interconnect IP, Status, Sessions e GC Latency. Painel de RAC Services com Status/Goal por instância. Cache Fusion/GC Statistics com CR Blocks e Current Blocks por instância. Active Cluster Sessions com sessões bloqueadoras destacadas.
![RAC](docs/images/06_rac.png)

### 🛡️ Data Guard Monitor (F7)
> Monitoramento completo de Data Guard: Role, Protection Mode, Primary/Standby DB e Hosts, Apply Lag, Transport Lag, Redo Rate e Archive Gap. Archive Gap Monitor em tempo real. Standby Processes (MRP/RFS/ARCH) com Status, Thread, Sequence. RAC Standby Processes por instância via GV$.
![Data Guard](docs/images/07_dataguard.png)

### 💽 ASM Storage Monitor (F8)
> Storage Capacity Overview com barras de uso por diskgroup (DATA/FRA/RECO). ASM Diskgroups com Type, State, Total/Free/Used%. ASM Disks per Diskgroup com Path, Failgroup, R-ms e W-ms por disco. Fast Recovery Area com Archive Rate e forecast. Top Database Objects by Size.
![ASM](docs/images/08_asm.png)

### 📊 Tablespaces & AWR (F10)
> Tablespaces com barras coloridas de uso % (verde/amarelo/vermelho), AutoExtend e Status. AWR Top SQL by Elapsed Time com SQL Text preview. AWR Top Wait Events da última hora. Instance Activity Metrics: DB Time, CPU, Redo, Transactions, Executes, Physical I/O.
![Tablespaces AWR](docs/images/09_tablespaces_awr.png)

### 💾 RMAN Monitor (F9)
> Monitor completo de backup RMAN em tempo real: Active Sessions com canal e elapsed. Channel Progress via `V$SESSION_LONGOPS` com progresso %, MB/s e ETA. Wait Events das sessões RMAN. Disk I/O Async com arquivo sendo processado. Overall Performance Summary. Backup Growth Chart com histórico de 7 dias.
![RMAN](docs/images/10_rman.png)

### 🕐 ASH — Active Session History (F11)
> ASH Activity Summary com top events dos últimos 120 samples e barras de distribuição. Tabela de samples com Sample Time, Inst, SID, SQL_ID, Event, Wait Class, State e Module — dados direto de `DBA_HIST_ACTIVE_SESS_HISTORY`.
![ASH](docs/images/11_ash.png)

### 🧠 ORA BRABO Advisor (F12)
> Engine de análise contínua e automática com findings CRITICAL/WARNING/INFO: Top SQL consumindo CPU, Tablespace crítico, Row Lock Contention, RMAN failure, PGA elevado. Oracle Advisor Framework com status de ADDM, SQL Tuning Advisor, SGA/PGA Advisor, Segment Advisor e mais. Advisor Findings & Recommendations do ADDM.
![Advisor](docs/images/12_advisor.png)

### ⚡ I/O Activity Monitor (^1)
> I/O Activity total com Top File e Top Function. I/O by Datafile com Reads, Writes, Read/Write MB e latência Avg R(ms)/W(ms) por arquivo. I/O by Function (DBWR, LGWR, Archiver, SQL, Buffer Cache). Load Profile dos últimos 60s via `V$SYSMETRIC`. Redo Log Groups com Status, Sequence e Members.
![I/O](docs/images/13_io.png)

### 🧮 Memory Advisor (^2)
> Memory Advisor com SGA Size, PGA Target, Buffer Cache Hit% e PGA Cache Hit%. SGA Target Advice com simulação de DB Time e Est. Physical Reads para diferentes tamanhos. PGA Target Advice com Est. Hit% e Overalloc por tamanho. Buffer Pool Statistics. Recent SGA/PGA Resize Operations.
![Memory](docs/images/15_memory.png)

### 📦 Segments & Objects (^3)
> Segments & Objects com Stale Stats, Sched Failures e PX Sessions. Top Segments por logical reads (filtráveis por teclas 1-5). Stale/Missing Object Statistics com Days Old, DML Since e flag Stale. Scheduler Jobs com State, Next Run, Run Count e Failures. Failed Job Run History com Error# e Info.
![Segments](docs/images/17_segments.png)

### 🔬 Real-Time SQL Monitor (^4)
> Real-Time SQL Monitor via `GV$SQL_MONITOR`: SQLs EXECUTING e DONE com SID, SQL ID, Status colorido, User, Elapsed(s), CPU(s), Buffer Gets, Disk Reads, PX Req/Alloc e preview do SQL Text. **Ao selecionar um SQL, o plano de execução aparece inline logo abaixo** (V$SQL_PLAN). Drill-down com Enter para SQL text completo.
![SQL Monitor](docs/images/18_sql_monitor.png)

### 🚨 Alert Log Monitor (^5)
> Alert Log Monitor em tempo real: Incidents, Alert entries e Last ORA-. Tabela com Timestamp, Level (ERROR/CRITICAL), Component, Host, Instance e Message completo — incluindo ORA-00060, ORA-04031, ORA-01555, ORA-00600, ORA-07445. Incidents/Problems Summary com Problem Key, Incident ID, Count e Last Time.
![Alert Log](docs/images/19_alert_log.png)

### ⛓️ Wait Chains (^6)
> Wait Chains via `V$WAIT_CHAINS`: detecção de cadeias de bloqueio com identificação de deadlocks (cycles). Visualização em árvore da chain completa: SID, PID, tempo de espera em segundos e evento — mostrando a hierarquia exata de quem está bloqueando quem.
![Wait Chains](docs/images/20_wait_chains.png)

### 📋 SQL Plan Baselines (^7)
> SQL Plan Management via `DBA_SQL_PLAN_BASELINES`: Total Baselines, Fixed e Not Reproduced. Tabela com SQL Handle, Plan Name, Schema, Accepted, Fixed, Enabled, Reproduced, Execuções, Elapsed(s) e Last Executed.
![Plan Baselines](docs/images/21_plan_baselines.png)

### ⚙️ Parallel Query Monitor (^8)
> Parallel Query Monitor via `GV$PX_SESSION`: Total PX Sessions, Active Coordinators e Total Slaves. Tabela com Inst, SID, Serial#, Username, Status, Req DOP, Act DOP (em vermelho quando degradado), Slave Sets, PX Req/Alloc, SQL ID e Wait Event em tempo real.
![Parallel Query](docs/images/22_parallel_query.png)

### 📄 Report (^9)
> Geração de **report PDF profissional** da conexão atual (tecla `G`): capa com KPIs, health com gráficos de tendência, top waits/tablespaces/ASM em gráficos de barra, e **Top 5 SQL mais custosos com plano de execução completo** (estilo DBMS_XPLAN). Também gera **AWR report em texto** (tecla `R` no painel AWR).

### 🚀 Exadata (`x`)
> Exadata Monitor com DB Nodes e Storage Cells. Smart Scan %, Storage Index %, Offload Efficiency %, Flash Cache Hit % com barras visuais. Cell Servers com IP, Status e Version. Top SQLs por Offload Efficiency %, Cell Wait Events, HCC Compressed Objects e parâmetros Exadata.
![Exadata](docs/images/23_exadata.png)

### 🗄️ PDB Monitoring (`p`)
> Monitoramento de Pluggable Databases em ambientes CDB: lista de PDBs com Open Mode, Restricted, Total Size e status — detecção automática de CDB.

---

## Bancos e Ambientes Suportados

| Versão | Suporte |
|--------|---------|
| Oracle 11g | ✅ (Thick mode) |
| Oracle 12c R1/R2 | ✅ |
| Oracle 18c | ✅ |
| Oracle 19c | ✅ (recomendado) |
| Oracle 21c | ✅ |
| Oracle 23ai | ✅ |
| Single Instance | ✅ |
| RAC | ✅ |
| Data Guard | ✅ |
| ASM | ✅ |
| CDB/PDB | ✅ |
| Exadata | ✅ |

> **Thin mode** (padrão, sem Oracle Client) alcança **Oracle 12.1+**.
> **Thick mode** (`--thick`, requer Instant Client) é necessário para **Oracle 11g** ou bancos com **Native Network Encryption**.

---

## Instalação

**Requisitos:** Python 3.10+ · Thin Mode não exige Oracle Client

```bash
# Clonar
git clone https://github.com/acaciolr/-ora-brabo.git
cd -ora-brabo

# Criar ambiente virtual
python3 -m venv .venv
source .venv/bin/activate

# Instalar dependências
pip install -r requirements.txt
```

**Dependências:**
```
oracledb>=2.0.0    # Oracle Thin/Thick Mode
textual>=0.52.0    # TUI framework
rich>=13.7.0       # Renderização visual
plotext>=5.0.0     # Gráficos/sparklines no terminal
keyring>=24.0.0    # Armazenamento seguro de senhas (opcional em runtime)
```

**Opcional — export de PDF (painel Report):**
```bash
pip install --prefer-binary -r requirements-optional.txt   # reportlab + Pillow
```
> O `--prefer-binary` evita compilar a Pillow em servidores com gcc antigo / Python do Anaconda. O app roda 100% sem esse pacote; só o export de PDF fica desabilitado.

**Instalação offline (air-gapped):** veja `packaging/offline/` — pacote autocontido com todos os *wheels* + `install.sh`/`reinstall.sh` para servidores sem internet.

---

## Uso

```bash
# Single Instance
python app.py --host 192.168.1.10 --port 1521 --service ORCL \
              --user system --password SenhaAqui --refresh 5

# Como SYSDBA
python app.py --host localhost --service ORCL \
              --user sys --password SenhaAqui --sysdba

# Thick mode (Oracle 11g / Native Network Encryption)
python app.py --host legacy11g --service ORCL --user system --password SenhaAqui \
              --thick --client-dir /opt/oracle/instantclient_21_13

# Wallet / ADB / OCI
python app.py --wallet-zip ~/wallet.zip --service mydb_high \
              --user admin --password SenhaAqui

# Abrir várias abas já conectadas a partir de conexões salvas (pelos LABELs)
python app.py --start-saved PROD,DW,STANDBY
python app.py --start-saved all        # abre todas as salvas
python app.py --list-saved             # lista os LABELs salvos (thin/thick/wallet)

# Sem argumentos → abre a tela de conexão interativa
python app.py

# Versão
python app.py --version

# Alias recomendado (~/.bashrc)
alias ora-brabo='source ~/ora-brabo/.venv/bin/activate && cd ~/ora-brabo && python app.py'
```

---

## Navegação por Teclado

### Painéis principais
| Tecla | Painel |
|-------|--------|
| `F1` | Dashboard |
| `F2` | Sessions |
| `F3` | Top SQL |
| `F4` | Wait Events |
| `F5` | Lock Monitor |
| `F6` | RAC Cluster |
| `F7` | Data Guard |
| `F8` | ASM Storage |
| `F9` | RMAN |
| `F10` | AWR / Tablespaces |
| `F11` | ASH |
| `F12` | Advisor |

### Sub-painéis (Ctrl)
| Tecla | Painel |
|-------|--------|
| `^1` | I/O Activity |
| `^2` | Memory Advisor |
| `^3` | Segments & Objects |
| `^4` | SQL Monitor |
| `^5` | Alert Log |
| `^6` | Wait Chains |
| `^7` | Plan Baselines |
| `^8` | Parallel Query |
| `^9` | Report (PDF) |
| `x` | Exadata |
| `p` | PDB |

### Conexões / Abas
| Tecla | Ação |
|-------|------|
| `+` | Nova conexão / abrir tela de conexões (funciona em qualquer terminal) |
| `Ctrl+N` / `Ctrl+O` | Nova conexão (alternativas ao `+`) |
| `Ctrl+W` | Fechar aba |

> Cada aba é um banco independente. Thin e Thick **não** coexistem no mesmo processo (limitação do driver Oracle) — para monitorar em modos diferentes, abra outra instância do ORA BRABO.

### Ações
| Tecla | Ação |
|-------|------|
| `K` | Kill Session |
| `T` | Trace Session |
| `E` | Explain Plan |
| `D` | Session Detail |
| `G` | Gerar Report PDF |
| `R` | Gerar AWR Report (painel AWR) |
| `/` | Filtrar |
| `?` | Ajuda |
| `Q` | Sair |

---

## Arquitetura

```
ora_brabo/
├── app.py                       # Entry point — OraBraboApp (Textual), multi-tab, CLI
├── core/
│   ├── config.py                # AppConfig dataclass
│   ├── version.py               # Fonte única de versão + banner
│   ├── connection_manager.py    # Pool async oracledb (Thin + Thick)
│   ├── connection_session.py    # Bundle por aba: conn + cache + scheduler + advisor
│   ├── connections_store.py     # Conexões salvas (~/.ora_brabo/connections.json)
│   ├── cache.py                 # MetricsCache: TTL + ring-buffer de 120 pontos
│   ├── scheduler.py             # Scheduler async — 17 collectors em tiers
│   └── demo_data.py             # Dados simulados (--demo, sem banco)
├── collectors/                  # 17 collectors independentes (async)
│   ├── health.py  sessions.py  sql.py  waits.py  rac.py
│   ├── dg.py  asm.py  rman.py  io_activity.py  pdb.py
│   ├── exadata.py  advisor.py  memory_advisor.py
│   └── awr.py  objects.py  sqlmon.py  alertlog.py
├── widgets/
│   ├── panels.py                # 24 painéis Textual
│   ├── add_connection_modal.py  # Tela de conexão + histórico salvo
│   ├── connection_pane.py       # Uma aba = uma conexão
│   └── explain_screen.py, ...   # Overlays (explain plan, SQL text, help)
├── advisor/
│   └── engine.py                # AdvisorEngine: regras contínuas, Severity, Finding
├── reports/
│   └── generator.py             # Report PDF (gráficos + Top 5 SQL com plano)
├── packaging/offline/           # Pacote offline (air-gapped): install/reinstall
└── shell/                       # Coletas via srvctl/dgmgrl/asmcmd → JSON
```

**Diferenciais de arquitetura:**
- **Zero Oracle Client** no Thin Mode — conecta via `oracledb` direto do Python (Thick opcional para 11g/NNE)
- **Multi-banco simultâneo** — cada aba é uma `ConnectionSession` isolada (conn + cache + scheduler + advisor + health-check com reconexão automática)
- **Async nativo** — collectors rodam em paralelo sem bloquear a UI
- **Refresh em tiers** — coleta por peso da query: realtime (Health/Waits ~2s), fast (Sessions/SQL/RAC/SQLMon ~5s), medium (ASM/DG/RMAN/IO/PDB ~12s), slow (advisors ~30s), heavy (AWR/Objects/AlertLog ~60s) — e **coleta imediata ao trocar de painel**
- **Ring-buffer de métricas** — 120 pontos históricos por métrica para gráficos em tempo real
- **RAC-aware** — detecção automática, usa `GV$` quando disponível
- **Exadata-aware** — detecção automática de Cell Servers e Smart Scan
- **Offline-ready** — pacote air-gapped com wheels embutidos

---

## Roadmap

- [x] Dashboard com Health, RAC, Data Guard, FRA e gráficos em tempo real
- [x] Sessions Monitor com Kill/Trace
- [x] Top SQL com Explain Plan e SQL Preview
- [x] Wait Event Monitor com gráficos
- [x] Lock Monitor com drill-down completo
- [x] RAC Cluster Monitor com Cache Fusion stats
- [x] Data Guard Monitor com MRP/RFS
- [x] ASM Storage Monitor com discos individuais
- [x] RMAN Monitor com progresso em tempo real
- [x] AWR / ADDM / ASH / Tablespaces
- [x] Advisor Engine com regras automáticas
- [x] I/O Activity Monitor
- [x] Memory Advisor (SGA/PGA Target Advice)
- [x] Segments & Objects com Stale Stats
- [x] Real-Time SQL Monitor com plano de execução inline
- [x] Alert Log Monitor
- [x] Wait Chains (V$WAIT_CHAINS)
- [x] SQL Plan Baselines
- [x] Parallel Query Monitor
- [x] Exadata (Smart Scan, Offload, HCC, Cell Wait Events)
- [x] Tela de login interativa com histórico de conexões
- [x] PDB Monitoring (CDB)
- [x] Suporte multi-banco simultâneo (abas)
- [x] Thick mode (Oracle 11g / Native Network Encryption)
- [x] Persistência de conexões (thin/thick, sysdba, wallet)
- [x] Abrir múltiplas abas por linha de comando (`--start-saved`)
- [x] Refresh em tiers + coleta ao trocar de painel
- [x] Report PDF com gráficos e Top 5 SQL com plano de execução
- [x] Flag `--version` com banner
- [x] Instalação offline (air-gapped) com wheels embutidos
- [ ] Exportação de relatórios em HTML / CSV
- [ ] Modo cliente/servidor (monitorar centenas de bancos)

---

## Contribuindo

Pull requests são bem-vindos. Para mudanças grandes, abra uma issue primeiro.

```bash
git checkout -b feature/minha-feature
git commit -m "feat: descrição da feature"
git push origin feature/minha-feature
```

**Padrões do projeto:**
- Python 3.10+ com tipagem
- PEP8 + docstrings
- SQL compatível com Oracle 11g (sem `FETCH FIRST`; usar `ROWNUM`)
- Testar em Single Instance antes de RAC

---

## Licença

MIT License — veja [LICENSE](LICENSE)

---

<div align="center">

Feito com ☕ e muito `V$SESSION` por **DBA BRABO**

*Se essa ferramenta te salvou de um incidente às 3h da manhã, deixa uma ⭐*

</div>
