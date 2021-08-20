#!/bin/bash
##############################################################
#                                                            #
#       Script para criar tunnel ssh 			     #
#							     #
#	Nome: Daniel Leomil				     #
#	Data: 15/09/2012				     #
#	Versão: v1.0					     #
#							     #
# Conectar na GESA e fazer um tunnel para Netbackup do CIS   # 
#							     #
##############################################################
echo
echo 'Startando o tunnel de acesso na porta 35000'
echo
echo

#ssh r339054@200.204.1.4 -L 35000:200.171.222.232:22
ssh r339054@200.204.1.4 -L 35000:10.23.136.208:22
