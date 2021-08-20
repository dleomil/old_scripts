#!/bin/bash
#set -x
#####################################################################
#
#
#   Script para gerar NRC para ligue/desligue
#
# nome: Daniel Leomil
# versao: 1.1
# data: 24/09/2012
# 
# Atualizado dia 26/09/2012
#
# Inserido caminho padra
# Leitura de usario e senha para conexao no banco
# Modificacao na data com inclusao do horario
######################################################################


DATA=`date -u '+%Y%m%d%HH%MM'`
DIR="/export/home/r339054/lig-desl/"
# Aquicomecamos a coletar os Dados.
clear
echo 
echo Digite o nome da pessoa que solicitou
echo
echo
read NOME
export $NOME
echo Digite seu usuario para conexao no banco
read USER
echo
echo
echo Digite sua senha, ela nao sera mostrada.
read -s PASS
echo
echo
echo "Digite o nome do arquivo. Apenas o nome, caminho foi corrigido" 
read CAMINHO
echo
##############################################################################

for i in `cat $DIR$CAMINHO |awk -F" " '{print $2$1}' |cut -b "1-5",8- | awk -F" " '{printf "000"$1 "\n"}'`
 do

  sqlplus -s $USER/$PASS @./desreg.sql $i >> $NOME-$DATA.txt
done


paste "$DIR$CAMINHO" $NOME-$DATA.txt >> result.txt


echo "Nas primeiras 5 colunas temos o que foi enviado por $NOME, nas demais sua condicao no banco da seguinte forma:


Nome Data Terminal        CNL   Data  client_id PHONE NRC NAS_PORT NAS_IP Connect-info Blocking_State"

echo "===================================================================================================="


while read line
do
echo $NOME $DATA $line | awk -F";" '{ print $1";"$2";"$3";"$4";"$5";"$6";"$7";"$8";"$9 }' 
done < result.txt | tee  -a  /export/home/r339054/ligue-desligue.log 
echo
echo
echo
#####################################

echo " Seguem os NRC's "
echo
echo "========================================================"
cat result.txt |awk -F";" '{ print $3 }'
rm result.txt
rm $NOME-$DATA.txt
