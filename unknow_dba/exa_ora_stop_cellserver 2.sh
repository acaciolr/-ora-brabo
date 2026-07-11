#!/bin/bash
#_______________________________________________________________________________________________________________________________________________________________
#__
#__ programa: ora_stop_cellserver.sh
#__ objetivo: Realizar o procedimento de OFFLINE seguro dos discos do GRIDDISK das celulas para posterior reboot do cellserver
#__           Procedimento seguindo o doc id 1188080.1
#__ autor   : Charles Severino
#__ data    : 30/04/2020
#__ 
#__ Observações relevantes do script shell:
#__ 
#__ Realizar a transferência do script shell ora_stop_cellserver.sh em anexo para o diretório /root de cada Storage Cell
#__ Dar permissão de execução no script ora_stop_cellserver.sh
#__ Ao ser iniciado o script ora_stop_cellserver.sh ficará em execução por 4 minutos e caso os discos não fiquem OFFLINE neste período, será necessário acompanhar manualmente
#__ No diretório /tmp ficam os logs de execução do script, conforme exemplo abaixo:
#__ -rw-r--r-- 1 root root    0 Apr 30 15:14 ofline_griddisk_osboxes_300420_ativos.log
#__ -rw-r--r-- 1 root root    0 Apr 30 15:14 ofline_griddisk_osboxes_300420_asmoff.log
#__ -rw-r--r-- 1 root root    0 Apr 30 15:14 ofline_griddisk_osboxes_300420_inativos.log
#__ -rw-r--r-- 1 root root 3239 Apr 30 15:14 ofline_griddisk_osboxes_300420_stop.log
#__  
#_______________________________________________________________________________________________________________________________________________________________

HST=$(hostname -s)
DMY=$(date +%d%m%y)
FLG=/tmp/ofline_griddisk_${HST}_${DMY}_stop.log
AOF=/tmp/ofline_griddisk_${HST}_${DMY}_asmoff.log
FAT=/tmp/ofline_griddisk_${HST}_${DMY}_ativos.log
FIN=/tmp/ofline_griddisk_${HST}_${DMY}_inativos.log
FILTRO_ONLINE="where status='active' and asmmodestatus='ONLINE' and asmdeactivationoutcome='Yes'"
FILTRO_OFLINE="where status='inactive' and asmmodestatus='OFFLINE' and asmdeactivationoutcome='Yes'"
FILTRO_ASMYES="where asmdeactivationoutcome!='Yes'"

> ${FLG}
> ${AOF}
> ${FAT}
> ${FIN}

ECHO()
{
 echo "###############################################################################################################################################################################"
}

DATA()
{
 echo "$(date +%d-%m-%y" "%H:%M:%S)"
}

ECHO																|tee -a ${FLG}
echo "# $(DATA) - Iniciando o procedimento de OFFLINE dos discos GRIDDISK do Cellserver [ $HST ]" 				|tee -a ${FLG}
ECHO																|tee -a ${FLG}
echo "# $(DATA) - Verificando os discos ONLINE do GRIDDISK com o parametro asmdeactivationoutcome igual [YES]"			|tee -a ${FLG}
echo "# CMD: cellcli -e list griddisk attributes name,status,asmmodestatus,asmdeactivationoutcome ${FILTRO_ONLINE}" 		|tee -a ${FLG}
ECHO																|tee -a ${FLG}
cellcli -e list griddisk attributes name,status,asmmodestatus,asmdeactivationoutcome ${FILTRO_ONLINE} 				|tee -a ${FLG}|tee -a ${FAT} 
ECHO																|tee -a ${FLG}
echo "# $(DATA) - Verificando se existe algum disco com o parametro asmdeactivationoutcome diferente [YES]"			|tee -a ${FLG}
echo "# CMD: cellcli -e list griddisk attributes name,status,asmmodestatus,asmdeactivationoutcome ${FILTRO_ASMYES}"		|tee -a ${FLG}
ECHO																|tee -a ${FLG}
cellcli -e list griddisk attributes name,status,asmmodestatus,asmdeactivationoutcome ${FILTRO_ASMYES}				|tee -a ${FLG}|tee -a ${AOF}
sleep 1

QAT=$(cat ${FAT}|wc -l)
QOF=$(cat ${AOF}|wc -l)

if [ ${QOF} -eq 0 ]
then
	T=0
	ECHO															|tee -a ${FLG}
	echo "# $(DATA) - Colocando os discos do GRIDDISK no status INATIVO, aguarde 10 segundos..." 				|tee -a ${FLG}
        echo "# CMD: cellcli -e alter griddisk all inactive"									|tee -a ${FLG} 
	ECHO															|tee -a ${FLG}
	cellcli -e alter griddisk all inactive 											|tee -a ${FLG}
	sleep 10
	cellcli -e list griddisk attributes name,status,asmmodestatus,asmdeactivationoutcome ${FILTRO_OFLINE}			|tee -a ${FLG}|tee ${FIN} 
	ECHO															|tee -a ${FLG}
	sleep 1

        ((T+=1))
	QIT=$(cat ${FIN}|wc -l)

	while [[ ${QAT} -ne ${QIT} ]]
	do
	  cellcli -e list griddisk attributes name,status,asmmodestatus,asmdeactivationoutcome ${FILTRO_OFLINE}			|tee -a ${FLG}|tee ${FIN} 
	  sleep 1
	  QIT=$(cat ${FIN}|wc -l)

	  if [ ${T} -eq 24 ]
	  then
	  	ECHO														|tee -a ${FLG}
	  	echo "# $(DATA) - Favor verificar diretamente via cellcli a demora para os discos ficarem INATIVOS ..."		|tee -a ${FLG}
	  	ECHO														|tee -a ${FLG}
		exit 9
	  fi
	  ECHO															|tee -a ${FLG}
	  echo "# $(DATA) - Resumo dos discos do GRIDDISK na $T tentativa - [$QIT discos INATIVOS de $QAT discos]"		|tee -a ${FLG}
	  echo "# CMD: cellcli -e list griddisk attributes name,status,asmmodestatus,asmdeactivationoutcome ${FILTRO_OFLINE}"	|tee -a ${FLG}
	  ECHO															|tee -a ${FLG}
	  sleep 9
          ((T+=1))
	done

	ECHO															|tee -a ${FLG}
	echo "# $(DATA) - Procedimento OFFLINE do GRIDDISK do CELLSERVER $HST realizado com SUCESSO ..."  			|tee -a ${FLG}
	echo "# Confira o status dos discos abaixo e inicie o reboot do CELLSERVER, conforme comando abaixo:"			|tee -a ${FLG}
	echo "# CMD: cellcli -e list griddisk attributes name,status,asmmodestatus,asmdeactivationoutcome "			|tee -a ${FLG}
        echo "# CMD: shutdown -r now"												|tee -a ${FLG}
    	echo "# Retorno esperado para todos os discos: DISKGROUP_NAME, inactive, OFFLINE, Yes"					|tee -a ${FLG}
	ECHO															|tee -a ${FLG}
	cat ${FIN}
	ECHO															|tee -a ${FLG}
	echo "# Quantidade Total de Discos com status INACTIVE = $(cat ${FIN}|wc -l)"						|tee -a ${FLG}
	ECHO															|tee -a ${FLG}
	exit 0
else
	ECHO																	|tee -a ${FLG}
	echo "# $(DATA) - Procedimento REBOOT Cellserver ABORTADO, os discos acima estao com asmdeactivationoutcome diferente [YES]"		|tee -a ${FLG}
        echo "# Verifique o respectivo diskgroup e restaure a redundancia do mesmo antes de prosseguir com a inativação dos demais discos" 	|tee -a ${FLG}
	ECHO																	|tee -a ${FLG}
	exit 9
fi

#---------------------------------------------------------------------------------------

#Abaixo segue um exemplo do retorno esperado ao executar o script ora_stop_cellserver.sh:
#
#Ao iniciar o script é realizado a checagem no sentido verificar a existência de algum disco OFFLINE com o parâmetro asmdeactivationoutcome <> `YES´ e caso exista algum disco neste status, o processo é abortado:
# 
#root@osboxes:/root # ./ora_stop_cellserver.sh
#
################################################################################################################################################################################
#
## 30-04-20 14:47:40 - Iniciando o procedimento de OFFLINE dos discos GRIDDISK do Cellserver [ osboxes ]
#
################################################################################################################################################################################
#
## 30-04-20 14:47:40 - Verificando os discos ONLINE do GRIDDISK com o parametro asmdeactivationoutcome igual [YES]
#
## CMD: cellcli -e list griddisk attributes name,status,asmmodestatus,asmdeactivationoutcome where status='active' and asmmodestatus='ONLINE' and asmdeactivationoutcome='Yes'
#
################################################################################################################################################################################
#
#         CATALOG_CD_02_dfcdcel0063_adm   active  ONLINE  Yes
#
#         CATALOG_CD_03_dfcdcel0063_adm   active  ONLINE  Yes
#
#         CATALOG_CD_04_dfcdcel0063_adm   active  ONLINE  Yes
#
#         CATALOG_CD_05_dfcdcel0063_adm   active  ONLINE  Yes
#
#         CATALOG_CD_06_dfcdcel0063_adm   active  ONLINE  Yes
#
#         CATALOG_CD_07_dfcdcel0063_adm   active  ONLINE  Yes
#
#         CATALOG_CD_08_dfcdcel0063_adm   active  ONLINE  Yes
#
#         CATALOG_CD_09_dfcdcel0063_adm   active  ONLINE  Yes
#
#         CATALOG_CD_10_dfcdcel0063_adm   active  ONLINE  Yes
#
#         CATALOG_CD_11_dfcdcel0063_adm   active  ONLINE  Yes
#
#         DELTA_CD_00_dfcdcel0063_adm     active  ONLINE  Yes
#
#         DELTA_CD_01_dfcdcel0063_adm     active  ONLINE  Yes
#
#         DELTA_CD_02_dfcdcel0063_adm     active  ONLINE  Yes
#
#         DELTA_CD_03_dfcdcel0063_adm     active  ONLINE  Yes
#
#         DELTA_CD_04_dfcdcel0063_adm     active  ONLINE  Yes
#
#         DELTA_CD_05_dfcdcel0063_adm     active  ONLINE  Yes
#
#         DELTA_CD_06_dfcdcel0063_adm     active  ONLINE  Yes
#
#         DELTA_CD_07_dfcdcel0063_adm     active  ONLINE  Yes
#
#         DELTA_CD_08_dfcdcel0063_adm     active  ONLINE  Yes
#
#         DELTA_CD_09_dfcdcel0063_adm     active  ONLINE  Yes
#
#         DELTA_CD_10_dfcdcel0063_adm     active  ONLINE  Yes
#
#         DELTA_CD_11_dfcdcel0063_adm     active  ONLINE  Yes
#
################################################################################################################################################################################
#
## 30-04-20 14:47:40 - Verificando se existe algum disco com o parametro asmdeactivationoutcome diferente [YES]
#
## CMD: cellcli -e list griddisk attributes name,status,asmmodestatus,asmdeactivationoutcome where asmdeactivationoutcome!='Yes'
#
################################################################################################################################################################################
#
#        DELTA_CD_11_dfcdcel0063_adm      inactive        OFFLINE         No
#
################################################################################################################################################################################
#
## 30-04-20 14:47:41 - Procedimento REBOOT Cellserver ABORTADO, os discos acima estao com asmdeactivationoutcome diferente [YES]
#
## Verifique o respectivo diskgroup e restaure a redundancia do mesmo antes de prosseguir com a inativação dos demais discos
#
################################################################################################################################################################################
#
# 
#
#Na sequência após o script certificar que os discos estão OK, será submetido a inativação dos discos da célula, realizando várias consultas repetidas de 10 em 10 segundos, por um período de 4 minutos:
# 
#
#root@osboxes:/root # ./ora_stop_cellserver.sh
#
################################################################################################################################################################################
#
## 30-04-20 14:49:25 - Iniciando o procedimento de OFFLINE dos discos GRIDDISK do Cellserver [ osboxes ]
#
################################################################################################################################################################################
#
## 30-04-20 14:49:25 - Verificando os discos ONLINE do GRIDDISK com o parametro asmdeactivationoutcome igual [YES]
#
## CMD: cellcli -e list griddisk attributes name,status,asmmodestatus,asmdeactivationoutcome where status='active' and asmmodestatus='ONLINE' and asmdeactivationoutcome='Yes'
#
################################################################################################################################################################################
#
#         CATALOG_CD_02_dfcdcel0063_adm   active  ONLINE  Yes
#
#         CATALOG_CD_03_dfcdcel0063_adm   active  ONLINE  Yes
#
#         CATALOG_CD_04_dfcdcel0063_adm   active  ONLINE  Yes
#
#         CATALOG_CD_05_dfcdcel0063_adm   active  ONLINE  Yes
#
#         CATALOG_CD_06_dfcdcel0063_adm   active  ONLINE  Yes
#
#         CATALOG_CD_07_dfcdcel0063_adm   active  ONLINE  Yes
#
#         CATALOG_CD_08_dfcdcel0063_adm   active  ONLINE  Yes
#
#         CATALOG_CD_09_dfcdcel0063_adm   active  ONLINE  Yes
#
#         CATALOG_CD_10_dfcdcel0063_adm   active  ONLINE  Yes
#
#         CATALOG_CD_11_dfcdcel0063_adm   active  ONLINE  Yes
#
#         DELTA_CD_00_dfcdcel0063_adm     active  ONLINE  Yes
#
#         DELTA_CD_01_dfcdcel0063_adm     active  ONLINE  Yes
#
#         DELTA_CD_02_dfcdcel0063_adm     active  ONLINE  Yes
#
#         DELTA_CD_03_dfcdcel0063_adm     active  ONLINE  Yes
#
#         DELTA_CD_04_dfcdcel0063_adm     active  ONLINE  Yes
#
#         DELTA_CD_05_dfcdcel0063_adm     active  ONLINE  Yes
#
#         DELTA_CD_06_dfcdcel0063_adm     active  ONLINE  Yes
#
#         DELTA_CD_07_dfcdcel0063_adm     active  ONLINE  Yes
#
#         DELTA_CD_08_dfcdcel0063_adm     active  ONLINE  Yes
#
#         DELTA_CD_09_dfcdcel0063_adm     active  ONLINE  Yes
#
#         DELTA_CD_10_dfcdcel0063_adm     active  ONLINE  Yes
#
#         DELTA_CD_11_dfcdcel0063_adm     active  ONLINE  Yes
#
################################################################################################################################################################################
#
## 30-04-20 14:49:25 - Verificando se existe algum disco com o parametro asmdeactivationoutcome diferente [YES]
#
## CMD: cellcli -e list griddisk attributes name,status,asmmodestatus,asmdeactivationoutcome where asmdeactivationoutcome!='Yes'
#
################################################################################################################################################################################
#
################################################################################################################################################################################
#
## 30-04-20 14:49:27 - Colocando os discos do GRIDDISK no status INATIVO, aguarde 10 segundos...
#
## CMD: cellcli -e alter griddisk all inactive
#
################################################################################################################################################################################
#
#        GridDisk CATALOG_CD_02_dfcdcel0063_adm successfully altered
#
#        GridDisk CATALOG_CD_03_dfcdcel0063_adm successfully altered
#
#        GridDisk CATALOG_CD_04_dfcdcel0063_adm successfully altered
#
#        GridDisk CATALOG_CD_05_dfcdcel0063_adm successfully altered
#
#        GridDisk CATALOG_CD_06_dfcdcel0063_adm successfully altered
#
#        GridDisk CATALOG_CD_07_dfcdcel0063_adm successfully altered
#
#        GridDisk CATALOG_CD_08_dfcdcel0063_adm successfully altered
#
#        GridDisk CATALOG_CD_09_dfcdcel0063_adm successfully altered
#
#        GridDisk CATALOG_CD_10_dfcdcel0063_adm successfully altered
#
#        GridDisk CATALOG_CD_11_dfcdcel0063_adm successfully altered
#
#        GridDisk DELTA_CD_00_dfcdcel0063_adm successfully altered
#
#        GridDisk DELTA_CD_01_dfcdcel0063_adm successfully altered
#
#        GridDisk DELTA_CD_02_dfcdcel0063_adm successfully altered
#
#        GridDisk DELTA_CD_03_dfcdcel0063_adm successfully altered
#
#        GridDisk DELTA_CD_04_dfcdcel0063_adm successfully altered
#
#        GridDisk DELTA_CD_05_dfcdcel0063_adm successfully altered
#
#        GridDisk DELTA_CD_06_dfcdcel0063_adm successfully altered
#
#        GridDisk DELTA_CD_07_dfcdcel0063_adm successfully altered
#
#        GridDisk DELTA_CD_08_dfcdcel0063_adm successfully altered
#
#        GridDisk DELTA_CD_09_dfcdcel0063_adm successfully altered
#
#        GridDisk DELTA_CD_10_dfcdcel0063_adm successfully altered
#
#        GridDisk DELTA_CD_11_dfcdcel0063_adm successfully altered
#
################################################################################################################################################################################
#
#         DELTA_CD_10_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_11_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_10_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_11_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
################################################################################################################################################################################
#
## 30-04-20 14:49:39 - Resumo dos discos do GRIDDISK na 1 tentativa - [4 discos INATIVOS de 22 discos]
#
## CMD: cellcli -e list griddisk attributes name,status,asmmodestatus,asmdeactivationoutcome where status='inactive' and asmmodestatus='OFFLINE' and asmdeactivationoutcome='Yes'
#
################################################################################################################################################################################
#
#         DELTA_CD_10_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_11_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_10_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_11_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_10_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_11_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#...
#
################################################################################################################################################################################
#
## 30-04-20 14:49:49 - Resumo dos discos do GRIDDISK na 2 tentativa - [6 discos INATIVOS de 22 discos]
#
## CMD: cellcli -e list griddisk attributes name,status,asmmodestatus,asmdeactivationoutcome where status='inactive' and asmmodestatus='OFFLINE' and asmdeactivationoutcome='Yes'
#
################################################################################################################################################################################
#
#         DELTA_CD_10_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_11_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_10_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_11_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_10_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_11_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_10_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_11_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_10_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_11_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_10_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_11_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_10_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_11_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_10_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_11_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_10_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_11_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_10_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_11_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_10_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_11_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_10_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_11_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_10_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_11_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_10_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_11_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_10_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_11_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
################################################################################################################################################################################
#
## 30-04-20 14:51:09 - Resumo dos discos do GRIDDISK na 10 tentativa - [22 discos INATIVOS de 22 discos]
#
## CMD: cellcli -e list griddisk attributes name,status,asmmodestatus,asmdeactivationoutcome where status='inactive' and asmmodestatus='OFFLINE' and asmdeactivationoutcome='Yes'
#
################################################################################################################################################################################
#
################################################################################################################################################################################
#
## 30-04-20 14:51:18 - Procedimento OFFLINE do GRIDDISK do CELLSERVER osboxes realizado com SUCESSO ...
#
## Confira o status dos discos abaixo e inicie o reboot do CELLSERVER, conforme comando abaixo:
#
## CMD: cellcli -e list griddisk attributes name,status,asmmodestatus,asmdeactivationoutcome
#
## CMD: shutdown -r now
#
## Retorno esperado para todos os discos: DISKGROUP_NAME, inactive, OFFLINE, Yes
#
################################################################################################################################################################################
#
#         DELTA_CD_10_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_11_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_10_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_11_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_10_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_11_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_10_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_11_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_10_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_11_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_10_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_11_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_10_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_11_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_10_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_11_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_10_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_11_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_10_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_11_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_10_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
#         DELTA_CD_11_dfcdcel0063_adm     inactive        OFFLINE         Yes
#
################################################################################################################################################################################
#
## Quantidade Total de Discos com status INACTIVE= 22
#
################################################################################################################################################################################
#
# 
#
#Não existindo nenhuma atividade pesada de I/O na célula, 4 minutos será o suficiente para deixar os discos no status OFFLINE, e neste momento basta conferir manualmente e iniciar o reboot do servidor:
#cellcli -e list griddisk attributes name,status,asmmodestatus,asmdeactivationoutcome
#shutdown -r now
# 
#
#No retorno do reboot da célula, basta executar o comando abaixo para ativar os discos novamente
#cellcli -e alter griddisk all active
# 
#
#Na sequência executar o comando abaixo seguidas vezes, até certificar que todos os discos estão no status ACTIVE e ONLINE
#cellcli -e list griddisk attributes name,status,asmmodestatus,asmdeactivationoutcome
