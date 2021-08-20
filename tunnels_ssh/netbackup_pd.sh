#!/bin/bash
##############################################################
#                                                            #
#       Script para criar tunnel ssh                         #
#                                                            #
#       Nome: Daniel Leomil                                  #
#       Data: 15/09/2012                                     #
#       Versão: v1.0                                         #
#                                                            #
# Conectar na GESA e fazer um tunnel para Netbackup de PD    # 
#                                                            #
##############################################################
echo
echo 'Startando o tunnel de acesso na porta 35001'
echo
echo

ssh r339054@200.204.1.4 -L 35001:10.23.136.80:22
