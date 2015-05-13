#!/bin/bash
export LANG=pt_BR.UTF-8

read -p "Interface Rede: " iface
read -p "Partição: " dev
read -p "Monitorar Processos: " process
processarray=($process)
ifacearray=($iface)

aux=0
while (( $aux < ${#processarray[@]} ))
do
pidofprocess=(${pidofprocess[@]} `pidof ${processarray[$aux]}`)
echo PID ${processarray[$aux]} - ${pidofprocess[$aux]}
aux=$((aux + 1))
done

while :
do
mem=`/usr/bin/free -m| grep "Mem:" | awk '{print $2}'`
swap=`/usr/bin/free -m| grep "Swap:" | awk '{print $2}'`
qtdCore=`grep processor /proc/cpuinfo| wc -l`
model=`grep "model name" /proc/cpuinfo|head -n 1|sed 's/model name/CPU/'`
hdmodel=`hdparm -I $dev | grep "Model Number:" | sed 's/Model Number/Modelo HD/'`
hdtrans=` hdparm -I $dev | grep "Transport:" | sed 's/Transport/Velocidade HD/'`
hdsize=`hdparm -I $dev | grep "device size with M" | sed 's/device size with M/Tamanho HD/'`

echo
echo =============================================================================
echo =============================================================================
echo =============================================================================
echo ===== $model
echo ===== $qtdCore Cores
echo ===== Memória Ram = $mem
echo ===== Swap = $swap
echo =====$hdmodel
echo =====$hdtrans
echo =====$hdsize
echo ===== `date`
echo =============================================================================
echo =============================================================================
echo =============================================================================
echo
echo ----Uso de CPU----


cput=`/usr/bin/sar -u 1 5| grep Média|awk '{print $3" ""+ " $4" ""+ " $5" "" + "$6" + "" "$7}'| sed 's/,/./g'|bc`
cputArray=(${cputArray[@]} $cput)
echo Média CPU total: $cput %

aux=0
while (( $aux < $qtdCore ))
do
cpu0=`/usr/bin/sar -P $aux -u 1 5| grep Média | awk '{print $3" ""+ " $4" ""+ " $5" "" + "$6" + "" "$7}'| sed 's/,/./g'|bc`
cpu0Array=(${cpu0Array[@]} $cpu0)
echo CPU$aux: $cpu0 %
aux=`expr $aux + 1`
done
echo

buffers=`/usr/bin/free -m | head -n 2 | tail -n 1 | awk '{print $6}'`
cached=`/usr/bin/free -m | head -n 2 | tail -n 1 | awk '{print $7}'`
used=`/usr/bin/free -m | head -n 2 | tail -n 1 | awk '{print $3}'`
memuse=$((used-(buffers+cached)))
memuseArray=(${memuseArray[@]} $memuse)

echo ----Memória----
echo Memória USO: $memuse MB
echo

aux2=0
while (( $aux2 < ${#ifacearray[@]} ))
do

rx1=`cat /proc/net/dev | grep ${ifacearray[$aux2]} | awk '{print $2}'`
sleep 1s
rx2=`cat /proc/net/dev | grep ${ifacearray[$aux2]}  | awk '{print $2}'`

down=$(($rx2 - $rx1))
downB=$((down))
downBK=$((downB/1024))
qtdBytesDownArray=(${qtdBytesDownArray[@]} $downBK)
rxtotal=`echo ${qtdBytesDownArray[@]} | tr ' ' '+' | bc`

echo ----Rede ${ifacearray[$aux2]}----
echo Download = $downBK KBytes/s
echo Quantidade RX= $rxtotal KBytes
echo

tx1=`cat /proc/net/dev | grep ${ifacearray[$aux2]} | awk '{print $10}'`
sleep 1s
tx2=`cat /proc/net/dev | grep ${ifacearray[$aux2]} | awk '{print $10}'`

up=$(($tx2 - $tx1))
upB=$((up))
upBK=$((upB/1024))
qtdBytesUpArray=(${qtdBytesUpArray[@]} $upB)
txtotal=`echo ${qtdBytesUpArray[@]} | tr ' ' '+' | bc`

#echo ----UP----
echo Upload = $upB Bytes/s
echo Quantidade TX = $txtotal Bytes
echo

aux2=`expr $aux2 + 1`
done

use=`/bin/df | grep $dev | awk '{print $3}'`
sleep 1s
use2=`/bin/df | grep $dev | awk '{print $3}'`

total=$(($use2 - $use)) 
total2=$((total/1024))
qtdBytesDiskArray=(${qtdBytesDiskArray[@]} $total2)
Disktotal=`echo ${qtdBytesDiskArray[@]} | tr ' ' '+' | bc`

echo ----Disco $dev----
echo Escrita Disco = $total2
echo Quantidade Escrita = $Disktotal Bytes
echo
echo --Mensurando Leitura em Disco--
mensurando=`hdparm -tT $dev`
echo $mensurando
echo

echo ----Processos----

aux2=0
while (( $aux2 < ${#processarray[@]} ))
do
VALUECPU=$(ps axo %cpu,pid,cmd | grep ${pidofprocess[$aux2]} | grep -v grep | awk '{print $1}')
VALUEMEM=$(ps axo %mem,pid,cmd | grep ${pidofprocess[$aux2]} | grep -v grep | awk '{print $1}')
readio1=`cat /proc/${pidofprocess[$aux2]}/io | grep "read_bytes" | awk '{print $2}'`
sleep 1
readio2=`cat /proc/${pidofprocess[$aux2]}/io | grep "read_bytes" | awk '{print $2}'`
readio=$(($readio2 - $readio1))
readioarray=(${readioarray[@]} $readio)
totalreadio=`echo ${readioarray[@]} | tr ' ' '+' | bc`

writeio1=`cat /proc/${pidofprocess[$aux2]}/io | grep "write_bytes" | head -n1 | awk '{print $2}'`
sleep 1
writeio2=`cat /proc/${pidofprocess[$aux2]}/io | grep "write_bytes" | head -n1 | awk '{print $2}'`
writeio=$(($writeio2 - $writeio1))
writeioarray=(${writeioarray[@]} $writeio)
totalwriteio=`echo ${writeioarray[@]} | tr ' ' '+' | bc`

echo ${processarray[$aux2]}

echo CPU = $VALUECPU %
echo MEM = $VALUEMEM %
echo Leitura Disco = $readio Bytes/s
echo Total Leitura = $totalreadio Bytes
echo Escrita Diso = $writeio Bytes/s
echo Total Escrita = $totalwriteio Bytes
echo

aux2=`expr $aux2 + 1`
done

done
