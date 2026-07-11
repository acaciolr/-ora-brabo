#Script shell para coleta de dados relacionadas ao flashcache - size, allocated, used e dirty

dcli -g /root/cell_group -l root "cellcli -e 'list flashcache detail' | grep effect" >/tmp/log1
dcli -g /root/cell_group -l root "cellcli -e 'list metriccurrent fc_by_dirty,fc_by_used,fc_by_allocated'" >/tmp/log2
 
date;
printf '%-20s'  "Host" "Cache size" "Allocated" "Used" "Dirty" ;printf '\n'
echo "--------------------------------------------------------------------------------------"
 
for i in `cat /tmp/log1 | awk '{ print $1} '`
do
 
HOST=$i
CACHE=`cat /tmp/log1 | grep $i | awk '{ print $3}'`
ALLOCATED=`cat /tmp/log2 | grep $i | grep FC_BY_ALLOCATED | awk '{ print $4}'`
USED=`cat /tmp/log2 | grep $i | grep FC_BY_USED | awk '{ print $4}'`
DIRTY=`cat /tmp/log2 | grep $i | grep FC_BY_DIRTY | awk '{ print $4}'`
 
printf '%-20s' $HOST $CACHE $ALLOCATED $USED $DIRTY; printf '\n'
done
 
rm /tmp/log1
rm /tmp/log2

#--

#Script para verificar detalhes da flashcache
dcli -l root -g cell_group " cellcli -e 'LIST flashcache attributes name,status,size,creationTime,degradedCelldisks,effectiveCacheSize  ' "

#Script para verificar detalhes da flashlog
dcli -l root -g cell_group " cellcli -e 'LIST flashlog attributes name,status,size,creationTime,degradedCelldisks,effectiveSize,efficiency ' "