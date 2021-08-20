#!/bin/bash
#set -x 
#################################################################################
#	Script para gerar log dos servidores antes e depois da janela 		#
# 			   							#
#										#
# -								#
#										#
# Autor: Daniel Leomil								#
# Data:26/02/2013 									#
#################################################################################
 
# VARIAVEIS para funcionamento do script
SERVIDORES="./servidores.txt"
DAYLIGHT="./radius.exp"

 
# Testa se o arquivo servidores.txt existe
if [ ! -e ${SERVIDORES} ]
    then
    echo "Arquivo 'servidores.txt' não encontrado."
    exit 1
fi
 
# Ler o arquivo ${SERVIDORES} e processar cada linha que contém informações
# acerca da conexão
cat ${SERVIDORES} | while read LINHA
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
 
done
