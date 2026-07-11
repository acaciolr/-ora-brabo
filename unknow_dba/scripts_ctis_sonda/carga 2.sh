## VERSAO 3
## Criado por Hiran Horta , em 12/12/2015
## Este arquivo gera um arquivo texto usando como demimitador de campos o sinal de ; (ponto e virgula) 
## Para que depois seja populado uma external table do Oracle, contendo data, hora, minuto, com a perfmance do SO / Servidor
## Inicio do arquivo carga.sh

export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/12.1.0.2/dbhome_1
export ORACLE_SID=WHPRO1301

## Capta as informacoes correntes e as carrega nas variaveis
qtdecore=$(cat /proc/cpuinfo | egrep "core id|physical id" | tr -d "\n" | sed s/physical/\\nphysical/g | grep -v ^$ | sort | uniq | wc -l)
loadaver=$(uptime | awk '{ print substr($11,0,4) ";"}')
ativadia=$(uptime | awk '{ print substr($3,1,4) ";"}')
#temprede=$($ORACLE_HOME/bin/tnsping IRCX | tail -1 | awk '{print ";" substr($2,2)";"}')
temprede=$(ping -c 3 spcdexa0002-adm | tail -1 | awk '{print ";" substr($4,19)";"}')
memofree=$(vmstat | tail -1 | awk '{ print $4 ";"}')
cpusfree=$(vmstat | tail -1 | awk '{ print ";" $15 ";"}')
cpulivre=$(/usr/bin/sar -u 1 1 |grep -i "Average:" | tail -1 | awk '{ print $8}')
##cpulivre=$(/usr/bin/sar -u 1 1 |grep -i "Média:" | tail -1 | awk '{ print ";" $8 ";"}')
usodswap=$(vmstat | tail -1 | awk '{ print $3 ";"}' )
serverid=$(hostname | awk '{ print substr($1,1,14) ";"}')
datahora=$(date '+%y%m%d;%H:%M;')

## gera a informacao no arquivo cartaserver.txt que compoe a tabela externa do Oracle carga.
echo $datahora$serverid$ativadia$memofree$usodswap$qtdecore$cpusfree$cpulivre$temprede$loadaver >> '/home/oracle/exttable/cargaserver.txt'
## echo $datahora$serverid$ativadia$memofree$usodswap$qtdecore$cpusfree$cpulivre$temprede$loadaver >> '/home/oracle/exttable/carga3.txt'

## final do arquivo
##  Aonde.:
##   Temos as linhas de export de variáveis de ambiente.
##    Carregamos a variável datahora com a data e hora que o comando é executado no formato ano+mês+dia, e hora:minuto
##    Carregamos a variável serverid com o nome do revidor que o processo esta sendo executado
##    Carregamos a variável ativades com o total de dias que o servidor esta ativo.
##    Carregamos a variável memofree com a quantidade de memória livre nos últimos 5 minutos.
##    Carregamos a variável usodswap com a quantidade de memória swap utilizada nos últimos 5 minutos.
##    Carregamos a variável qtdecore com a quantidade de Cores (Nucleos de CPU).
##    Carregamos a variável cpusfree com o percentual livre do conjunto das CPUs, vmstat.
##    Carregamos a variável cpulivre com o percentual livre do conjunto das CPUs, sar.
##    Carregamos a variável temprede com o resultado em tempo (mile segundos) de um ping usando a rede Oracle entre os servidores exadata.
##    Carregamos a variável loadaver com o resultado da media do load average dos últimos 5 minutos.
##
##   Para depois tirar a média diária e mensal.
##    Enviamos para dentro do arquivo cargaserver.txt o conteúdo do conjunto das variáveis.
##    Se o ODBC estiver configurado corretamente, basta abrir a planilha Excel e atualizar  a mesmo, se não estiver configurado, tem
##    que copiar o arquivo do servidor e fazer todo o trabalho manualmente.
