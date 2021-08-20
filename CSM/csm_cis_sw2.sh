#!/bin/bash
#set -x 
#####################################################################
#   Script para retirar Status da CSM em relação aos equipamentos   #
#   do Centro de servicos                                           #
#                                                                   #
#                                                                   #
# Autor: Daniel                                                     #
# Data:  09/05/2013                                                 #
#####################################################################

###Removendo os arquivos antigos.
rm -f csm_cis_sw.txt
rm -f log/csm_cis_sw2.txt
rm -f log/csm_cis_sw.txt


# VARIAVEIS para funcionamento do script
ELEMENTOS="./elementos_cis_sw2.txt"
DAYLIGHT="./csm_cis_sw2.exp"
 
# Testa se o arquivo servidores.txt existe
if [ ! -e ${ELEMENTOS} ]
    then
    echo "Arquivo 'elementos.txt' não encontrado."
    exit 1
fi
 
# Ler o arquivo ${ELEMENTOS} e processar cada linha que contém informações
# acerca da conexão
cat ${ELEMENTOS} | while read LINHA
do
    # Joga os campos em variáveis
    HOST=$(echo ${LINHA} | cut -d',' -f1)
    USERNORMAL=$(echo ${LINHA} | cut -d',' -f2)
    USERPASSWD=$(echo ${LINHA} | cut -d',' -f3)
    ROOTPASSWD=$(echo ${LINHA} | cut -d',' -f4)
 
    # Teste sobre repasse das variáveis
    #echo ${HOST}
    #echo ${USERNORMAL}
    #echo ${USERPASSWD}
    #echo ${ROOTPASSWD}
 
    # Chama o arquivo expect com os parâmetros coletados
    # Testa se o expect existe
    if [ ! -e ${DAYLIGHT} ]
        then
        echo "Arquivo com script expect ${DAYLIGHT} não encontrado"
        exit 1
    else
        # Garantir que o arquivo tenha permissão de execução
        chmod 755 ${DAYLIGHT}
 
        # imprimir na tela o comando que esta sendo executado
        #echo "${DAYLIGHT} ${HOST} ${USERNORMAL} ${USERPASSWD} ${ROOTPASSWD}"
 
        # executar o script expect com os parametros
        ${DAYLIGHT} ${HOST} ${USERNORMAL} ${USERPASSWD} ${ROOTPASSWD}
    fi

###Tratando os logs ao final
touch log/csm_cis_sw.txt | echo "real;servfarm;weight;state;conns/hits" > log/csm_cis_sw.txt |grep -v "-" csm_cis_sw.txt|grep -v terminal |sed 's/server farm/servfarm/g' | grep -v "#" |grep -v real |awk -F" " '{print $1";"$2";"$3";"$4";"$5}' | sed 's/;;;;//g'  >> log/csm_cis_sw.txt
egrep "real|187" log/csm_cis_sw.txt > log/br-psa-cis-sw2.txt


 
done
