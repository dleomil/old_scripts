#!/bin/bash

#################################################################
#                                                               #
#	Data: 16/01/2013                                            #
#	Ver:0.1                                                     #
#	Autor: Daniel Leomil                                        #
#	Empresa: xxxxxxxxxxxxxxxxx                                 #
#                                                               #
#	Script que cria um tunnel usando a uma ponte para           #
#	acesso aos servidores remotos                #
#                                                               #
#################################################################

# Aqui comecamos a coletar os Dados.
clear
echo 
echo "Digite o nome de usuario no servidor"
echo
read NOME
export $NOME

echo
echo
#echo "Digite sua senha, ela nao sera mostrada."
#read -s PASS
#export $PASS
echo
echo '
      ###########################################
      #		ESCOLHA A LOCALIDADE                #
      #                                         #
      #		xx - server                     #
      #		yy - server                         #
      #                                         #
      ###########################################
'
read LOCAL


#Esta secao contem as funcoes de conexao, uma para cada localidade.

PD() {
	ssh $NOME@xxx.xxx.xxx.xxx -L 35001:10.23.136.80:22
}



CIS() {
	ssh $NOME@xxx.xxx.xxx.xxx -L 35000:10.23.136.208:22
}

case $LOCAL in

PD) echo "Fazendo conexao em xx...
Apos digitar sua senha de conexao no server 1
Abra um novo terminal e digite:
ssh -XC root@localhost -p35001"
PD
;;

CIS) echo "Fazendo conexao no yy
Apos digitar sua senha de conexao no server 1
Abra um novo terminal e digite:
ssh -XC root@localhost -p35000"
CIS
;;

*) echo "Opcao invalida $FUNC 
As opcoes sao: XX ou YY"
echo
;;

esac

