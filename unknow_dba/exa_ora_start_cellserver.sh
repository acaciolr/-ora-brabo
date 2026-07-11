#!/bin/bash
#______________________________________________________________________________________________________________
#__
#__ programa: ora_start_cellserver.sh
#__ objetivo: Realizar o procedimento do START seguro dos servicos das celulas apos reboot do cellserver.
#__           Procedimento seguindo o doc id 1188080.1
#__ autor   : Charles Severino
#__ data    : 30/04/2020
#______________________________________________________________________________________________________________

DI=$(date +%s)
HST=$(hostname -s)
DMY=$(date +%d%m%y)
FLG=/tmp/online_griddisk_${HST}_${DMY}_start.log
FIN=/tmp/online_griddisk_${HST}_${DMY}_inativos.log
FAT=/tmp/online_griddisk_${HST}_${DMY}_ativos.log
FRE=/tmp/online_griddisk_${HST}_${DMY}_resumo.log
FILTRO_ONLINE="where status='active' and asmmodestatus='ONLINE' and asmdeactivationoutcome='Yes'"
FILTRO_OFLINE="where status='inactive' and asmmodestatus='OFFLINE' and asmdeactivationoutcome='Yes'"

> ${FLG}
> ${FIN}
> ${FAT}
> ${FRE}

ECHO()
{
 echo "###############################################################################################################################################################################"
}

DATA()
{
 echo "$(date +%d-%m-%y" "%H:%M:%S)"
}

SUMARIZAR()
{
grep -v "#"|awk '{print substr($1,1,8)"-"$2"-"$3"-"}'| awk '{a[$1]++;b[$2]++;}END{for (i in a)print i, a[i];}'|sort|awk -F"-" '
BEGIN {
        formatc="%27s %31s %11s %16s\n"
        formatd="%27s %31s %11s %16d\n"
 	printf "%175s\n", "###############################################################################################################################################################################"
        printf formatc, "        DISKGROUP","            STATUS","             ","       TOTAL DISCOS"
 	printf "%175s\n", "###############################################################################################################################################################################"
      }
      {
        printf formatd, $1,$2,$3,$4
      }
END {
    }
'
}

ECHO																	|tee -a ${FLG}
echo "# $(DATA) - Iniciando o procedimento de START dos discos GRIDDISK do Cellserver [ $HST ]" 					|tee -a ${FLG}
ECHO																	|tee -a ${FLG}
echo "# $(DATA) - Validando a quantidade dos discos no status OFFLINE apos REBOOT do Cellserver [ $HST ]" 				|tee -a ${FLG}
echo "# CMD: cellcli -e list griddisk attributes name,asmmodestatus ${FILTRO_OFLINE}"							|tee -a ${FLG}
cellcli -e list griddisk attributes name,asmmodestatus ${FILTRO_OFLINE}									|tee -a ${FLG}|tee ${FIN}|SUMARIZAR
ECHO																	|tee -a ${FLG}
echo "# TOTAL GERAL DOS DISCOS OFFLINE.: " $(cat ${FIN}|wc -l)
ECHO																	|tee -a ${FLG}

T=0
echo "# $(DATA) - Colocando os discos do GRIDDISK no status ONLINE(ATIVOS), aguarde 10 segundos..." 					|tee -a ${FLG}
echo "# CMD: cellcli -e alter griddisk all active"											|tee -a ${FLG} 
ECHO																	|tee -a ${FLG}
cellcli -e alter griddisk all active 													|tee -a ${FLG}
sleep 10
cellcli -e list griddisk attributes name,asmmodestatus ${FILTRO_ONLINE}									> ${FAT}

((T+=1))
QIT=$(cat ${FIN}|wc -l)
QAT=$(cat ${FAT}|wc -l)

while [[ ${QAT} -ne ${QIT} ]]
do
	cellcli -e list griddisk attributes name,asmmodestatus ${FILTRO_ONLINE}								> ${FAT}
	QAT=$(cat ${FAT}|wc -l)
	ECHO																|tee -a ${FLG}
	echo "# $(DATA) - Resumo do STATUS dos discos do GRIDDISK na $T tentativa - [$QAT discos ATIVOS de $QIT discos INATIVOS]"	|tee -a ${FLG}
	echo "# CMD: cellcli -e list griddisk attributes name,asmmodestatus"								|tee -a ${FLG}
	cellcli -e list griddisk attributes name,asmmodestatus										|SUMARIZAR|tee -a ${FLG}|tee ${FRE}
        ((T+=1))
	sleep 10
done

DF=$(date +%s)
SG=$(($DF-$DI))
DD=$(($SG/86400)); SG=$(($SG%86400)); HH=$(($SG/3600)); SG=$(($SG%3600)); MM=$(($SG/60)); SS=$(($SG%60))

ECHO																	|tee -a ${FLG}
echo "# $(DATA)                 ***** SINCRONISMO DOS DISCOS OFFLINE PARA ONLINE NO GRIDDISK [ $HST ], REALIZADOS COM SUCESSO *****"	|tee -a ${FLG}
ECHO																	|tee -a ${FLG}
echo "# QTDE TOTAL DISCOS OFFLINE ANTES:" $(cat ${FIN}|wc -l)										|tee -a ${FLG}
echo "# QTDE TOTAL DISCOS ONLINE DEPOIS:" $(cat ${FAT}|wc -l)										|tee -a ${FLG}
printf "%34s %02d:%02d:%02d" "# TEMPO DE DURACAO DO SINCRONISMO:" ${HH} ${MM} ${SS}							|tee -a ${FLG}
printf "\n"																|tee -a ${FLG}
ECHO																	|tee -a ${FLG}
