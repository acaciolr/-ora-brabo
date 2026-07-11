-- =========================================================================================================
-- GUIA DE REFERÊNCIA: REDIMENSIONAMENTO DE GRID DISKS NO EXADATA
-- =========================================================================================================
-- Propósito: Redimensionamento de Grid Disks no Exadata
-- Data: Janeiro 2026
-- =========================================================================================================

-- =========================================================================================================
-- X ERRO COMUM QUE O CLIENTE ESTAVA COMETENDO
-- =========================================================================================================
--
-- for i in $(printf "%02d " {0..11}); do
--     cellcli -e "alter griddisk DATE1113P6_CD_${i}_$(hostname | cut -d. -f1) size = 105000M"
-- done
--
-- PROBLEMAS:
-- 1. X ORDEM ERRADA: Tentando redimensionar grid disks ANTES dos discos ASM
-- 2. X SINTAXE ERRADA: "size = 105000M" com espaços (correto: "size=105000M")
-- 3. X PULOU ETAPA CRÍTICA: Não redimensionou os discos ASM primeiro
--
-- CONSEQUÊNCIA: Erro "size is lower than the allocation for some ASM disk"
-- =========================================================================================================

-- =========================================================================================================
-- SEQUÊNCIA CORRETA (OBRIGATÓRIA!)
-- =========================================================================================================
--
-- A ordem é CRÍTICA e NÃO pode ser invertida:
--
-- 1º) Redimensionar discos ASM (no servidor DB)
-- 2º) Aguardar conclusão de rebalance (se houver)
-- 3º) Redimensionar grid disks (nas células)
--
-- NUNCA faça ao contrário! Grid disk não pode ser menor que o ASM disk acima dele.
-- =========================================================================================================

-- =========================================================================================================
--         DISK STORAGE ENTITIES AND RELATIONSHIPS - EXADATA
-- =========================================================================================================

HIERARQUIA DE ARMAZENAMENTO:
───────────────────────────────────────────────────────────────────────────────

    ┌──────┐      ┌─────┐      ┌──────────┐      ┌──────────┐      ┌──────────┐
    │ Disk │─────▶│ LUN │─────▶│ CELLDISK │─────▶│ GRIDDISK │─────▶│ ASM disk │
    └──────┘      └─────┘      └──────────┘      └──────────┘      └──────────┘
                                                                          │
                                                                          │
                                                                   Visível para
                                                                      ASM/DB
───────────────────────────────────────────────────────────────────────────────

-- =========================================================================================================
--                     DENTRO DA CÉLULA EXADATA
-- =========================================================================================================

    CellCLI> CREATE GRIDDISK ...
    
    ╔═══════════════════════════════════════════════════════════════════════╗
    ║                         EXADATA CELL                                  ║
    ║                                                                       ║
    ║  ┌─────────────────────────┐                                          ║
    ║  │  Data Storage Partition │                                          ║
    ║  │                         │   First two                              ║
    ║  │                         │   LUNs only          ┌────────────────┐  ║
    ║  │                         │ ────────────────────▶│                │  ║
    ║  │                         │                      │                │  ║
    ║  └─────────────────────────┘                      │                │  ║
    ║  │     System Area         │                      │                │  ║
    ║  └─────────────────────────┘                      │                │  ║
    ║                                   OR              │   Cell Disk    │  ║
    ║                                  │                │                │  ║
    ║                                  │                │                │  ║
    ║  ┌─────────────────────────┐     │                │                │  ║
    ║  │                         │     │                │                │  ║
    ║  │                         │     │                └────────────────┘  ║
    ║  │         LUN             │     │                         │          ║
    ║  │                         │ ────┘                         │          ║
    ║  │                         │   Other ten                   │          ║
    ║  │                         │   LUNs                        │          ║
    ║  └─────────────────────────┘                               │          ║
    ║                                                            │          ║
    ║                                                            │          ║
    ║                                    ┌───────────────────────┼──────┐   ║
    ║                                    │                       │      │   ║
    ║                                    │   ┌───────────────┐   │      │   ║
    ║                                    │   │   Grid Disk   │   │      │   ║
    ║                                    OR  │               │   │      │   ║
    ║                                    │   └───────────────┘   │      │   ║
    ║                                    │                       │      │   ║
    ║                                    │   ┌───────────────┐   │      │   ║
    ║                                    │   │  Grid Disk    │◀──┘      │   ║
    ║                                    │   │  (hot part)   │          │   ║
    ║                                    │   ├───────────────┤  Visível │   ║
    ║                                    │   │  Grid Disk    │  para    │   ║
    ║                                    └───│  (cold part)  │  ASM ────┘   ║
    ║                                        └───────────────┘              ║
    ║                                                                       ║
    ╚═══════════════════════════════════════════════════════════════════════╝

-- =========================================================================================================
--                         DETALHAMENTO DOS COMPONENTES
-- =========================================================================================================

1. DISK (Disco Físico)
   └─ Disco físico HDD ou SSD na célula Exadata
   └─ Base de toda a hierarquia

2. LUN (Logical Unit Number)
   └─ Abstração lógica do disco físico
   └─ Pode usar apenas os primeiros 2 LUNs (Data Storage Partition)
   └─ Ou pode usar os outros 10 LUNs disponíveis

3. CELLDISK
   └─ Entidade de armazenamento gerenciada pelo Exadata Cell
   └─ Criado a partir de LUNs
   └─ Gerenciado via CellCLI

4. GRIDDISK
   └─ Fatia do CELLDISK alocada para uso pelo ASM
   └─ Pode ser dividido em hot/cold tiers (intelligent caching)
   └─ Criado com comando: CellCLI> CREATE GRIDDISK ...
   └─ Este é o nível onde ocorre o REDIMENSIONAMENTO

5. ASM DISK
   └─ Como o Grid Disk é visto pelo ASM (Automatic Storage Management)
   └─ Usado para criar Diskgroups (DATA, RECO, etc.)
   └─ Visível para o banco de dados Oracle

-- =========================================================================================================
--                     FLUXO DE REDIMENSIONAMENTO
-- =========================================================================================================

IMPORTANTE: A ordem de redimensionamento é CRÍTICA!

  PASSO 1: Redimensionar ASM DISK
           ↓
           ALTER DISKGROUP DATA1113P6 RESIZE ALL SIZE 105000M;
           ↓
  
  PASSO 2: Aguardar rebalance (se houver)
           ↓
  
  PASSO 3: Redimensionar GRID DISK (na célula)
           ↓
           cellcli -e "alter griddisk ... size=105000M"

Por que esta ordem?
───────────────────
  • Grid Disk NÃO pode ser menor que o ASM disk acima dele
  • ASM precisa liberar o espaço primeiro
  • Só então o Grid Disk pode ser reduzido


-- =========================================================================================================
--                         RELACIONAMENTOS
-- =========================================================================================================

                    CAMADA FÍSICA           CAMADA LÓGICA           CAMADA ASM
                    ─────────────           ─────────────           ──────────

                    Disk                    LUN                     
                      │                       │                     
                      ▼                       ▼                     
                    Hardware                CellDisk                
                                              │                     
                                              ▼                     
                                           GridDisk ────────────▶  ASM Disk
                                              │                        │
                                              │                        ▼
                                        (Gerenciado                DiskGroup
                                         por CellCLI)                  │
                                                                       ▼
                                                                    Database


-- =========================================================================================================
--                        COMANDOS PRINCIPAIS
-- =========================================================================================================

NO SERVIDOR ASM (SQL):
──────────────────────
-- Ver discos ASM
SELECT name, total_mb, free_mb FROM v$asm_disk WHERE name LIKE 'DATE1113P6%';

-- Redimensionar disco ASM
ALTER DISKGROUP DATA1113P6 RESIZE DISK 'DATE1113P6_CD_00_E1113CEADM17' SIZE 105000M;


NAS CÉLULAS EXADATA (CellCLI):
───────────────────────────────
# Ver grid disks
cellcli -e "list griddisk attributes name, size, status"

# Ver cell disks
cellcli -e "list celldisk attributes name, size, status"

# Redimensionar grid disk
cellcli -e "alter griddisk DATE1113P6_CD_00_E1113CEADM17 size=105000M"


-- =========================================================================================================
--                         TIPOS DE GRID DISK
-- =========================================================================================================

Grid Disk COMPLETO:
───────────────────
  ┌─────────────────┐
  │                 │
  │   Grid Disk     │  ◀── Todo o espaço do Cell Disk
  │                 │
  └─────────────────┘


Grid Disk com HOT/COLD (Tiered Storage):
─────────────────────────────────────────
  ┌─────────────────┐
  │   Grid Disk     │  ◀── Hot Part (dados frequentes, SSD)
  │   (hot part)    │
  ├─────────────────┤
  │   Grid Disk     │  ◀── Cold Part (dados antigos, HDD)
  │   (cold part)   │
  └─────────────────┘


-- =========================================================================================================
--                         NOTAS IMPORTANTES
-- =========================================================================================================

1. O diagrama mostra que há DUAS opções para criar Cell Disk:
   • Data Storage Partition (primeiros 2 LUNs) - mais comum
   • LUNs diretos (outros 10 LUNs) - menos comum

2. Grid Disks são sempre criados a partir de Cell Disks

3. ASM só "vê" Grid Disks, não Cell Disks ou LUNs

4. A camada de Cell/Grid Disk fornece:
   • Intelligent caching
   • Smart Scan
   • Storage indexes
   • Predicate pushdown
   • Todas as funcionalidades Exadata

5. O redimensionamento afeta a cadeia:
   ASM disk ──▶ Grid Disk ──▶ Cell Disk (tamanho permanece igual)


-- =========================================================================================================
--                        HIERARQUIA RESUMIDA
-- =========================================================================================================

    Hardware          Cell Software          ASM/Database
    ────────          ──────────────         ────────────
    
    Physical          Cell Disk              
      Disk      ────▶ (CELLDISK)       
        │                  │
        │                  ▼
       LUN      ────▶  Grid Disk       ────▶  ASM Disk
                      (GRIDDISK)                  │
                                                  ▼
                                              Diskgroup
                                                  │
                                                  ▼
                                              Tablespace
                                                  │
                                                  ▼
                                              Data Files


-- =========================================================================================================
-- FIM DO DIAGRAMA
-- =========================================================================================================

-- =========================================================================================================
-- ETAPA 1: VERIFICAÇÃO INICIAL
-- =========================================================================================================
-- Local: Servidor de Banco de Dados (instância ASM)
-- Usuário: oracle / SYSASM
-- =========================================================================================================

-- Conectar à instância ASM
-- sqlplus / as sysasm

-- Verificar tamanhos atuais dos discos ASM
SELECT name, total_mb, free_mb, ROUND((free_mb/total_mb)*100, 2) AS pct_free
FROM v$asm_disk 
WHERE name LIKE 'DATE1113P6_CD%'
ORDER BY name;

-- Verificar espaço do diskgroup
SELECT name, state, total_mb, free_mb, usable_file_mb
FROM v$asm_diskgroup 
WHERE name = 'DATA1113P6';

-- Verificar se há rebalance em andamento (deve estar vazio)
SELECT group_number, operation, state, power, est_minutes
FROM v$asm_operation;

-- =========================================================================================================
-- VERIFICAÇÃO NAS CÉLULAS EXADATA
-- =========================================================================================================
-- Local: Células Exadata
-- Usuário: root ou celladmin
-- Executar via SSH em cada célula
-- =========================================================================================================

-- Verificar grid disks atuais (executar nas células, NÃO no SQL)
cellcli -e "list griddisk attributes name, size, status" | grep DATE1113P6

-- Verificar um grid disk específico
cellcli -e "list griddisk DATE1113P6_CD_00_E1113CEADM17 attributes name, size"

-- Listar todos os grid disks do diskgroup
cellcli -e "list griddisk where name like 'DATE1113P6.*' attributes name, size, status"

-- =========================================================================================================
-- ETAPA 2: REDIMENSIONAR DISCOS ASM (PRIMEIRO!)
-- =========================================================================================================
-- CRÍTICO: Esta etapa DEVE vir ANTES de redimensionar os grid disks
-- Local: Servidor de Banco de Dados (instância ASM)
-- Usuário: SYSASM
-- Janela de Manutenção: RECOMENDADO
-- =========================================================================================================

-- Conectar à instância ASM
-- sqlplus / as sysasm

-- OPÇÃO 1: Redimensionar TODOS os discos de uma vez (RECOMENDADO)
ALTER DISKGROUP DATA1113P6 RESIZE ALL SIZE 105000M;

-- OPÇÃO 2: Se RESIZE ALL falhar, redimensionar individualmente:
/*
ALTER DISKGROUP DATA1113P6 RESIZE DISK 'DATE1113P6_CD_00_E1113CEADM17' SIZE 105000M;
ALTER DISKGROUP DATA1113P6 RESIZE DISK 'DATE1113P6_CD_01_E1113CEADM17' SIZE 105000M;
ALTER DISKGROUP DATA1113P6 RESIZE DISK 'DATE1113P6_CD_02_E1113CEADM17' SIZE 105000M;
ALTER DISKGROUP DATA1113P6 RESIZE DISK 'DATE1113P6_CD_03_E1113CEADM17' SIZE 105000M;
ALTER DISKGROUP DATA1113P6 RESIZE DISK 'DATE1113P6_CD_04_E1113CEADM17' SIZE 105000M;
ALTER DISKGROUP DATA1113P6 RESIZE DISK 'DATE1113P6_CD_05_E1113CEADM17' SIZE 105000M;
ALTER DISKGROUP DATA1113P6 RESIZE DISK 'DATE1113P6_CD_06_E1113CEADM17' SIZE 105000M;
ALTER DISKGROUP DATA1113P6 RESIZE DISK 'DATE1113P6_CD_07_E1113CEADM17' SIZE 105000M;
ALTER DISKGROUP DATA1113P6 RESIZE DISK 'DATE1113P6_CD_08_E1113CEADM17' SIZE 105000M;
ALTER DISKGROUP DATA1113P6 RESIZE DISK 'DATE1113P6_CD_09_E1113CEADM17' SIZE 105000M;
ALTER DISKGROUP DATA1113P6 RESIZE DISK 'DATE1113P6_CD_10_E1113CEADM17' SIZE 105000M;
ALTER DISKGROUP DATA1113P6 RESIZE DISK 'DATE1113P6_CD_11_E1113CEADM17' SIZE 105000M;
*/

-- Monitorar operações de rebalance (se houver)
SELECT group_number, operation, state, power, sofar, est_work, est_minutes
FROM v$asm_operation;

-- IMPORTANTE: Aguarde até que não haja mais operações em andamento antes de prosseguir!
-- Execute a query acima periodicamente até retornar 0 linhas

-- Verificar se o redimensionamento foi aplicado
SELECT name, total_mb, free_mb
FROM v$asm_disk 
WHERE name LIKE 'DATE1113P6_CD%'
ORDER BY name;
-- Todos devem mostrar total_mb = 105000

-- =========================================================================================================
-- ETAPA 3: REDIMENSIONAR GRID DISKS (DEPOIS!)
-- =========================================================================================================
-- SOMENTE execute após completar a ETAPA 2 com sucesso
-- Local: Células Exadata
-- Usuário: root ou celladmin
-- =========================================================================================================

-- COMANDO CORRETO para redimensionar grid disks em uma célula:
-- 
-- for i in $(printf "%02d " {0..11}); do
--     cellcli -e "alter griddisk DATE1113P6_CD_${i}_$(hostname | cut -d. -f1) size=105000M"
-- done
--
-- CORREÇÕES aplicadas:
-- ✓ size=105000M (SEM espaços, diferente do erro "size = 105000M")
-- ✓ Executado APÓS redimensionar ASM (ordem correta)

-- Script mais detalhado com verificação (executar nas células):
-- 
-- #!/bin/bash
-- CELL_NAME=$(hostname | cut -d. -f1)
-- 
-- echo "=== Verificando ANTES ==="
cellcli -e "list griddisk attributes name, size, status" | grep DATE1113P6
-- 
-- echo "=== Redimensionando ==="
-- for i in {00..11}; do
--     echo "Redimensionando: DATE1113P6_CD_${i}_${CELL_NAME}"
--     cellcli -e "alter griddisk DATE1113P6_CD_${i}_${CELL_NAME} size=105000M"
--     sleep 1
-- done
-- 
-- echo "=== Verificando DEPOIS ==="
cellcli -e "list griddisk attributes name, size, status" | grep DATE1113P6

-- Para executar em múltiplas células de uma vez (de um servidor central):
--
-- CELLS="e1113ceadm17 e1113ceadm18"
-- 
-- for cell in $CELLS; do
--     echo ">>> Processando célula: $cell"
--     ssh celladmin@$cell.exadata.prevnet "for i in {00..11}; do cellcli -e \"alter griddisk DATE1113P6_CD_\${i}_${cell^^} size=105000M\"; done"
-- done

-- =========================================================================================================
-- ETAPA 4: VERIFICAÇÃO FINAL
-- =========================================================================================================

-- No servidor DB (ASM):
SELECT name, total_mb, free_mb
FROM v$asm_disk 
WHERE name LIKE 'DATE1113P6_CD%'
ORDER BY name;

SELECT name, state, total_mb, free_mb, usable_file_mb
FROM v$asm_diskgroup 
WHERE name = 'DATA1113P6';

-- Verificar que não há operações pendentes
SELECT * FROM v$asm_operation;

-- Nas células (executar em cada uma):
cellcli -e "list griddisk where name like 'DATE1113P6.*' attributes name, size, status"

-- =========================================================================================================
-- TRATAMENTO DE ERROS COMUNS
-- =========================================================================================================

-- ERRO: "ORA-15032: not all alterations performed"
-- CAUSA: Espaço insuficiente no diskgroup para reduzir
-- SOLUÇÃO: Liberar espaço antes de redimensionar ou escolher tamanho maior

-- ERRO: "size is lower than the allocation for some ASM disk"
-- CAUSA: Tentou redimensionar grid disk ANTES do disco ASM
-- SOLUÇÃO: Voltar à ETAPA 2 e redimensionar ASM primeiro

-- ERRO: Grid disk resize retorna "COMMAND FAILED"
-- CAUSA: Disco ASM não foi redimensionado corretamente
-- SOLUÇÃO: Verificar tamanho atual do ASM disk correspondente

-- =========================================================================================================
-- COMANDOS ÚTEIS PARA TROUBLESHOOTING
-- =========================================================================================================

-- Ver espaço detalhado do diskgroup
SELECT name, type, total_mb, free_mb, required_mirror_free_mb, usable_file_mb 
FROM v$asm_diskgroup 
WHERE name = 'DATA1113P6';

-- Ver uso por tipo de arquivo
SELECT type, SUM(bytes)/1024/1024/1024 AS size_gb 
FROM v$asm_file 
WHERE group_number = (SELECT group_number FROM v$asm_diskgroup WHERE name = 'DATA1113P6')
GROUP BY type;

-- Ver atributos de um disco específico
SELECT name, path, mount_status, state, total_mb, free_mb 
FROM v$asm_disk 
WHERE name = 'DATE1113P6_CD_00_E1113CEADM17';

-- Nas células:
-- Ver detalhes completos de um grid disk
cellcli -e "list griddisk DATE1113P6_CD_00_E1113CEADM17 detail"

-- Ver histórico de alertas relacionados a grid disks
cellcli -e "list alerthistory where alertShortName='GridDisk' and severity='critical'"

-- Ver status de todas as células
dcli -g cell_group -l root "cellcli -e list griddisk where name like 'DATE1113P6.*' attributes name, size, status"

-- =========================================================================================================
-- NOTAS IMPORTANTES
-- =========================================================================================================
--
-- 1. ORDEM É CRÍTICA: SEMPRE redimensionar ASM primeiro, Grid Disks depois
-- 2. SINTAXE: Use size=105000M (SEM espaços entre = e o valor)
-- 3. JANELA DE MANUTENÇÃO: Execute durante janela apropriada
-- 4. BACKUP: Tenha backup recente antes de iniciar
-- 5. MONITORAMENTO: Acompanhe alertas e logs durante todo o processo
-- 6. REBALANCE: Aguarde conclusão completa antes de prosseguir para próxima etapa
-- 7. DOCUMENTAÇÃO: Registre todos os comandos executados e seus resultados
-- 8. TESTES: Se possível, teste primeiro em ambiente não-produtivo
-- 9. ROLLBACK: Difícil reverter, planeje bem antes de executar
-- 10. TAMANHO: 105000M = 102.5 GB (confirme se é o tamanho desejado)
--
-- =========================================================================================================

-- =========================================================================================================
-- RESUMO DA SEQUÊNCIA CORRETA
-- =========================================================================================================
--
-- 1. Verificar tamanhos atuais (ASM + Grid Disks)
--    ↓
-- 2. Redimensionar discos ASM para 105000M
--    ↓
-- 3. Aguardar conclusão de rebalance (se houver)
--    ↓
-- 4. Redimensionar grid disks para 105000M em cada célula
--    ↓
-- 5. Verificar que tudo está correto
--    ↓
-- 6. Documentar as mudanças
--
-- NUNCA INVERTA ESTA ORDEM!
--
-- =========================================================================================================

-- Fim das anotações

-- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --
-- | SCRIPTS PARA AUTOMATIZAR
-- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --

-- Problemas no Comando Original do Cliente:

-- Problemas identificados:
1. X Ordem incorreta: Tentando redimensionar grid disks ANTES dos discos ASM
2. X Espaço extra no =: size = 105000M (deveria ser size=105000M)
3. X Formato inconsistente: 105000M (deve usar M ou G corretamente)

-- Solução Correta - Passo a Passo

-- ETAPA 1: Verificar Tamanhos Atuais

-- 1.1 No servidor de banco de dados (instância ASM):

-- Conectar à instância ASM
sqlplus / as sysasm

-- Verificar tamanho dos discos ASM
SELECT name, path, total_mb, free_mb 
FROM v$asm_disk 
WHERE name LIKE '%DATE1113P6_CD%'
ORDER BY name;

-- Verificar espaço no diskgroup
SELECT name, total_mb, free_mb, usable_file_mb
FROM v$asm_diskgroup 
WHERE name = 'DATA1113P6';

-- 1.2 Nas células Exadata (como root ou celladmin):

-- Verificar tamanho dos grid disks
cellcli -e "list griddisk attributes name, size, status" | grep DATE1113P6

-- Verificar célula específica
cellcli -e "list griddisk DATE1113P6_CD_00_E1113CEADM17 attributes name, size"

-- ETAPA 2: Redimensionar Discos ASM PRIMEIRO ⚠️

-- Arquivo SQL: resize_asm_disks.sql

-- =========================================
-- resize_asm_disks.sql
-- Executar como SYSASM no servidor DB
-- =========================================

-- Conectar à instância ASM
CONNECT / AS SYSASM

-- Definir formato de saída
SET LINESIZE 200
SET PAGESIZE 100
COLUMN name FORMAT A40
COLUMN total_mb FORMAT 999,999,999
COLUMN free_mb FORMAT 999,999,999

-- PASSO 1: Verificar tamanhos ANTES do resize
PROMPT ====================================
PROMPT Tamanhos ANTES do redimensionamento
PROMPT ====================================

SELECT name, total_mb, free_mb 
FROM v$asm_disk 
WHERE name LIKE 'DATE1113P6_CD%'
ORDER BY name;

SELECT name, total_mb, free_mb, usable_file_mb
FROM v$asm_diskgroup 
WHERE name = 'DATA1113P6';

PAUSE Pressione ENTER para continuar com o redimensionamento...

-- PASSO 2: Redimensionar TODOS os discos ASM para 105000M
PROMPT ====================================
PROMPT Redimensionando discos ASM
PROMPT ====================================

-- Opção 1: Redimensionar todos de uma vez (RECOMENDADO)
ALTER DISKGROUP DATA1113P6 RESIZE ALL SIZE 105000M;

-- Opção 2: Se RESIZE ALL falhar, usar comandos individuais:
/*
ALTER DISKGROUP DATA1113P6 RESIZE DISK 'DATE1113P6_CD_00_E1113CEADM17' SIZE 105000M;
ALTER DISKGROUP DATA1113P6 RESIZE DISK 'DATE1113P6_CD_01_E1113CEADM17' SIZE 105000M;
ALTER DISKGROUP DATA1113P6 RESIZE DISK 'DATE1113P6_CD_02_E1113CEADM17' SIZE 105000M;
ALTER DISKGROUP DATA1113P6 RESIZE DISK 'DATE1113P6_CD_03_E1113CEADM17' SIZE 105000M;
ALTER DISKGROUP DATA1113P6 RESIZE DISK 'DATE1113P6_CD_04_E1113CEADM17' SIZE 105000M;
ALTER DISKGROUP DATA1113P6 RESIZE DISK 'DATE1113P6_CD_05_E1113CEADM17' SIZE 105000M;
ALTER DISKGROUP DATA1113P6 RESIZE DISK 'DATE1113P6_CD_06_E1113CEADM17' SIZE 105000M;
ALTER DISKGROUP DATA1113P6 RESIZE DISK 'DATE1113P6_CD_07_E1113CEADM17' SIZE 105000M;
ALTER DISKGROUP DATA1113P6 RESIZE DISK 'DATE1113P6_CD_08_E1113CEADM17' SIZE 105000M;
ALTER DISKGROUP DATA1113P6 RESIZE DISK 'DATE1113P6_CD_09_E1113CEADM17' SIZE 105000M;
ALTER DISKGROUP DATA1113P6 RESIZE DISK 'DATE1113P6_CD_10_E1113CEADM17' SIZE 105000M;
ALTER DISKGROUP DATA1113P6 RESIZE DISK 'DATE1113P6_CD_11_E1113CEADM17' SIZE 105000M;
*/

-- PASSO 3: Aguardar conclusão do rebalanceamento (se houver)
PROMPT ====================================
PROMPT Verificando operações de rebalance
PROMPT ====================================

SELECT group_number, operation, state, power, 
       actual, sofar, est_work, est_rate, est_minutes
FROM v$asm_operation;

-- PASSO 4: Verificar tamanhos DEPOIS do resize
PROMPT ====================================
PROMPT Tamanhos DEPOIS do redimensionamento
PROMPT ====================================

SELECT name, total_mb, free_mb 
FROM v$asm_disk 
WHERE name LIKE 'DATE1113P6_CD%'
ORDER BY name;

SELECT name, total_mb, free_mb, usable_file_mb
FROM v$asm_diskgroup 
WHERE name = 'DATA1113P6';

PROMPT ====================================
PROMPT Redimensionamento ASM CONCLUÍDO
PROMPT Agora você pode redimensionar os grid disks
PROMPT ====================================

EXIT;

-- Executar o script SQL:

-- Como usuário oracle no servidor DB
export ORACLE_SID=+ASM1  -- Ajustar conforme seu ambiente
sqlplus / as sysasm @resize_asm_disks.sql

-- ETAPA 3: Redimensionar Grid Disks DEPOIS

-- Script Bash: resize_grid_disks.sh

#!/bin/bash
#########################################
-- resize_grid_disks.sh
-- Executar como root ou celladmin em cada célula
-- SOMENTE APÓS redimensionar os discos ASM
#########################################

set -e  -- Parar em caso de erro

CELL_NAME=$(hostname | cut -d. -f1)
NEW_SIZE="105000M"
DISKGROUP="DATE1113P6"

echo "========================================="
echo "Redimensionamento de Grid Disks"
echo "Célula: $CELL_NAME"
echo "Novo tamanho: $NEW_SIZE"
echo "========================================="
echo ""

-- PASSO 1: Verificar tamanhos ANTES
echo "=== Tamanhos ANTES do redimensionamento ==="
cellcli -e "list griddisk attributes name, size, status" | grep ${DISKGROUP}
echo ""

-- Confirmação
read -p "Deseja continuar com o redimensionamento? (sim/não): " resposta
if [ "$resposta" != "sim" ]; then
    echo "Operação cancelada."
    exit 0
fi

-- PASSO 2: Redimensionar cada grid disk
echo ""
echo "=== Redimensionando grid disks ==="
for i in {00..11}; do
    DISK_NAME="${DISKGROUP}_CD_${i}_${CELL_NAME}"
    echo "Redimensionando: $DISK_NAME"
    
    cellcli -e "alter griddisk ${DISK_NAME} size=${NEW_SIZE}"
    
    if [ $? -eq 0 ]; then
        echo "✓ $DISK_NAME redimensionado com sucesso"
    else
        echo "✗ ERRO ao redimensionar $DISK_NAME"
        exit 1
    fi
    
    sleep 1
done

-- PASSO 3: Verificar tamanhos DEPOIS
echo ""
echo "=== Tamanhos DEPOIS do redimensionamento ==="
cellcli -e "list griddisk attributes name, size, status" | grep ${DISKGROUP}

echo ""
echo "========================================="
echo "Redimensionamento concluído!"
echo "========================================="

-- Dar permissão e executar:

-- Dar permissão de execução
chmod +x resize_grid_disks.sh

-- Executar em cada célula
./resize_grid_disks.sh

-- ETAPA 4: Script Consolidado para Múltiplas Células

-- resize_all_cells.sh

#!/bin/bash
#########################################
-- resize_all_cells.sh
-- Executar de um ponto central
-- Redimensiona ASM + Grid Disks em todas as células
#########################################

set -e

-- CONFIGURAÇÕES
DB_SERVER="db_server_hostname"
DB_USER="oracle"
CELLS="e1113ceadm17 e1113ceadm18"  -- Adicionar todas as células
CELL_USER="celladmin"
NEW_SIZE="105000M"

echo "========================================="
echo "Redimensionamento Completo - ASM + Grid Disks"
echo "========================================="
echo ""

-- ETAPA 1: Redimensionar discos ASM
echo "=== ETAPA 1: Redimensionando discos ASM ==="
ssh ${DB_USER}@${DB_SERVER} "sqlplus / as sysasm @/path/to/resize_asm_disks.sql"

if [ $? -ne 0 ]; then
    echo "X ERRO ao redimensionar discos ASM. Abortando."
    exit 1
fi

echo "✓ Discos ASM redimensionados com sucesso"
echo ""

-- ETAPA 2: Redimensionar grid disks em cada célula
echo "=== ETAPA 2: Redimensionando grid disks nas células ==="
for cell in $CELLS; do
    echo ""
    echo ">>> Processando célula: $cell"
    
    ssh ${CELL_USER}@${cell}.exadata.prevnet "bash -s" < resize_grid_disks.sh
    
    if [ $? -eq 0 ]; then
        echo "✓ Célula $cell processada com sucesso"
    else
        echo "✗ ERRO ao processar célula $cell"
        exit 1
    fi
done

echo ""
echo "========================================="
echo "Redimensionamento completo FINALIZADO!"
echo "========================================="

-- Verificação Pós-Redimensionamento

-- Arquivo SQL de Verificação: verify_resize.sql

-- =========================================
-- verify_resize.sql
-- Verificação pós-redimensionamento
-- =========================================

CONNECT / AS SYSASM

SET LINESIZE 200
SET PAGESIZE 100
COLUMN name FORMAT A40
COLUMN total_mb FORMAT 999,999,999
COLUMN free_mb FORMAT 999,999,999

PROMPT ====================================
PROMPT Verificação de Discos ASM
PROMPT ====================================

SELECT name, total_mb, free_mb, 
       ROUND((free_mb/total_mb)*100, 2) AS pct_free
FROM v$asm_disk 
WHERE name LIKE 'DATE1113P6_CD%'
ORDER BY name;

PROMPT ====================================
PROMPT Verificação de Diskgroup
PROMPT ====================================

SELECT name, state, type, total_mb, free_mb, usable_file_mb,
       ROUND((usable_file_mb/total_mb)*100, 2) AS pct_usable
FROM v$asm_diskgroup 
WHERE name = 'DATA1113P6';

PROMPT ====================================
PROMPT Operações de Rebalance (se houver)
PROMPT ====================================

SELECT group_number, operation, state, power, 
       actual, sofar, est_work, est_rate, est_minutes
FROM v$asm_operation;

EXIT;

-- Script de Verificação nas Células:

#!/bin/bash
-- verify_cells.sh

echo "=== Verificação Grid Disks ==="
for cell in e1113ceadm17 e1113ceadm18; do
    echo ""
    echo ">>> Célula: $cell"
    ssh celladmin@${cell}.exadata.prevnet "cellcli -e \"list griddisk attributes name, size, status\" | grep DATE1113P6"
done

-- Pontos Críticos e Boas Práticas

-- Ordem Obrigatória:

/*
1. PRIMEIRO: Redimensionar discos ASM
2. DEPOIS: Redimensionar grid disks
3. NUNCA inverter essa ordem
*/

-- Notas Importantes:
/*
1. Unidades: Usar M para MB, G para GB consistentemente
2. Sintaxe: Sem espaços em size=105000M
3. Rebalance: Pode ocorrer automaticamente, monitorar com v$asm_operation
4. Rollback: Difícil reverter, testar antes em ambiente de desenvolvimento
5. Monitoramento: Acompanhar alertas no Exadata durante o processo
*/

-- Tratamento de Erros:

-- Se o redimensionamento ASM falhar por espaço insuficiente:

-- Verificar espaço utilizado
SELECT name, 
       total_mb, 
       free_mb,
       ROUND((free_mb/total_mb)*100, 2) AS pct_free
FROM v$asm_diskgroup;

-- Pode ser necessário:
-- 1. Limpar espaço (dropar tablespaces temporárias antigas, etc.)
-- 2. Adicionar capacidade temporária
-- 3. Rebalancear dados para outros discos

-- Resumo da Sequência Correta
/*
1. Verificar tamanhos atuais (ASM + Grid Disks)
   ↓
2. Executar resize_asm_disks.sql (redimensionar ASM)
   ↓
3. Aguardar conclusão de rebalance (se houver)
   ↓
4. Executar resize_grid_disks.sh em cada célula
   ↓
5. Verificar com verify_resize.sql
   ↓
6. Documentar mudanças
*/


-- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --
-- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --