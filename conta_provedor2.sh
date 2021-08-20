#!/bin/bash
#set -x

#########################################################################
#                                                                       #
#       Script para contar logins do provedor                           #
#                                                                       #
#       Autor:  Daniel Leomil           empresa: xxxxxxxxxxxxxxx        #
#       script: coleta_provedor.sh      Data:   08/03/2013              #
#       Definicao: Conta as autenticacoes dos                           #
#       provedores e faz uma statistica dos logins                      #
#       versao: v.01                                                    #
#                                                                       #
#       data:   13/03/2013                                              #
#       versao: v.02                                                    #
#       Adicionando timeout de Accounting                               #
#                                                                       #
#                                                                       #
#       data: 14/03/2013                                                #
#       versao: v.03                                                    #
#       Adicionado pesquisa com "pearl timestamp" na funcao Periodo     #
#                                                                       #
#       data: 18/04/2013                                                #
#       versao: v.04                                                    #
#       Adicionado contagem dos logins sem REALM                        #
#                                                                       #
#########################################################################

### Limpando a tela

clear

### Aqui solicitamos o provedor que sera coletado

echo "Digite o provedor que deseja verificar
Ex: globo.com"

read PROVEDOR

### Aqui solicitamos o tipo de consulta, se sera por periodo ou o dia todo

echo "Quer consultar qual periodo
Ex: TUDO ou PERIODO (Letras sempre maiusculas)"
read FUNCAO

echo
echo
echo "Caso tenha escolhido TUDO apenas tecle enter"
echo
echo
echo "Caso tenha escolhido PERIODO digite o tempo que deseja em segundos:

        Ex: 300  --> Ultimos 5 minutos
        EX: 600  --> Ultimos 10 minutos
        EX: 900  --> Ultimos 15 minutos
        Ex: 1800 --> Ultima meia hora
        EX: 3600 --> Ultima hora"
echo
echo
read PERIODO



###Definindo as Funcoes

TUDO() {

ARQ=nr`date -u '+%Y%m%d'`.log
        
LOGOK=`cat "$ARQ"| grep "$PROVEDOR" |grep login_ok |wc -l |awk -F" " '{print $1}'`
LOGREJ=`cat "$ARQ"| grep "$PROVEDOR" |grep reject  |wc -l |awk -F" " '{print $1}'`
LOGTIM=`cat "$ARQ"| grep "$PROVEDOR" |grep timeout |grep -v "Accounting" |wc -l |awk -F" " '{print $1}'`
LOGTOT=`cat "$ARQ"| grep "$PROVEDOR" |wc -l |awk -F" " '{print $1}'`
LOGACC=`cat "$ARQ"| grep "$PROVEDOR" |grep timeout |grep -v "Autenticacao" |wc -l |awk -F" " '{print $1}'`
LOGREALM=`cat "$ARQ"| grep "$PROVEDOR" |grep REALM |wc -l |awk -F" " '{print $1}'`


###Definindo a porcentagem de logins

PERREJ=`echo "$LOGREJ / $LOGTOT" |bc -l`
PEROK=`echo "$LOGOK / $LOGTOT" |bc -l`
PERTIM=`echo "$LOGTIM / $LOGTOT" |bc -l`
PERACC=`echo "$LOGACC / $LOGTOT" |bc -l`
PERREALM=`echo "$LOGREALM / $LOGTOT" |bc -l`

RESULTREJECT=`echo $PERREJ \* 100 |bc -l |cut -c 1-5`
RESULTOK=`echo $PEROK \* 100 |bc -l |cut -c 1-5`
RESULTTIM=`echo $PERTIM \* 100 |bc -l |cut -c 1-5`
RESULTACC=`echo $PERACC \* 100 |bc -l |cut -c 1-5`
RESULTREALM=`echo $PERREALM \* 100 |bc -l |cut -c 1-5`

#Ecoando os resultados

while true
do
echo
echo "          Total de autenticacoes $PROVEDOR ate o momento"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Login_ok |       Reject  |       Timeout_AUTH    |       Timeout_ACC     |       SEM REALM       |       Total      +"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "$LOGOK      |       $LOGREJ        |              $LOGTIM       |       $LOGACC                    |              $LOGREALM       |       $LOGTOT       +"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo

echo "Total de rejects por usuario Top 20"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
cat "$ARQ"| grep reject | grep "$PROVEDOR" | awk -F"|" '{print $2 " " $4}' | sort | uniq -c | sort -n |tail -20
echo
echo
echo "          Total percentual de requisicoes do $PROVEDOR"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Login_ok |       Reject  |       Timeout_AUTH    |       SEM REALM       |       Timeout_ACC     +"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "$RESULTOK%  |     $RESULTREJECT%  |       $RESULTTIM%             |       $RESULTREALM            |       $RESULTACC%           +"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo
echo

sleep 60
clear

done
}


PERIODO () {
                
DATA_TMP=`expr \`perl -e 'print time()'\` - $PERIODO`
DATAPERIODO=`perl -M'POSIX' -e 'print strftime ("%H:%M",localtime('"$DATA_TMP"'))'`
ARQ=nr`date -u '+%Y%m%d'`.log
HORAINICIO=`echo $DATAPERIODO |cut -d":" -f1`
MINUTOINICIO=`echo $DATAPERIODO |cut -d":" -f2`
HORAFIM=`date '+%H'`
MINUTOFIM=`date '+%M'`
        
LOGOK=`sed -n "/$HORAINICIO\:$MINUTOINICIO\:00/,/$HORAFIM\:$MINUTOFIM\:59/p" $ARQ| grep "$PROVEDOR" |grep login_ok |wc -l |awk -F" " '{print $1}'`
LOGREJ=`sed -n "/$HORAINICIO\:$MINUTOINICIO\:00/,/$HORAFIM\:$MINUTOFIM\:59/p" $ARQ| grep "$PROVEDOR" |grep reject  |wc -l |awk -F" " '{print $1}'`
LOGTIM=`sed -n "/$HORAINICIO\:$MINUTOINICIO\:00/,/$HORAFIM\:$MINUTOFIM\:59/p" $ARQ| grep "$PROVEDOR" |grep timeout |grep -v "Accounting" |wc -l |awk -F" " '{print $1}'`
LOGTOT=`sed -n "/$HORAINICIO\:$MINUTOINICIO\:00/,/$HORAFIM\:$MINUTOFIM\:59/p" $ARQ| grep "$PROVEDOR" |wc -l |awk -F" " '{print $1}'`
LOGACC=`sed -n "/$HORAINICIO\:$MINUTOINICIO\:00/,/$HORAFIM\:$MINUTOFIM\:59/p" $ARQ| grep "$PROVEDOR" |grep timeout |grep -v "Autenticacao" |wc -l |awk -F" " '{print $1}'`
LOGREALM=`sed -n "/$HORAINICIO\:$MINUTOINICIO\:00/,/$HORAFIM\:$MINUTOFIM\:59/p" $ARQ| grep "$PROVEDOR" |grep REALM |wc -l |awk -F" " '{print $1}'`

###Definindo a porcentagem de logins

PERREJ=`echo "$LOGREJ / $LOGTOT" |bc -l`
PEROK=`echo "$LOGOK / $LOGTOT" |bc -l`
PERTIM=`echo "$LOGTIM / $LOGTOT" |bc -l`
PERACC=`echo "$LOGACC / $LOGTOT" |bc -l`
PERREALM=`echo "$LOGREALM / $LOGTOT" |bc -l`

RESULTREJECT=`echo $PERREJ \* 100 |bc -l |cut -c 1-5`
RESULTOK=`echo $PEROK \* 100 |bc -l |cut -c 1-5`
RESULTTIM=`echo $PERTIM \* 100 |bc -l |cut -c 1-5`
RESULTACC=`echo $PERACC \* 100 |bc -l |cut -c 1-5`
RESULTREALM=`echo $PERREALM \* 100 |bc -l |cut -c 1-5`

###Ecoando os resultados

while true
do
echo
echo "          Total de autenticacoes $PROVEDOR ate o momento"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Login_ok  |       Reject  |       Timeout_AUTH    |       Timeout_ACC     |       SEM REALM       |       Total     +"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "$LOGOK            |       $LOGREJ |       $LOGTIM         |       $LOGACC         |       $LOGREALM               |       $LOGTOT   +"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo
echo

echo "Total de rejects por usuario Top 20"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
cat "$ARQ"| grep reject | grep "$PROVEDOR" | awk -F"|" '{print $2 " " $4}' | sort | uniq -c | sort -n |tail -20
echo

echo "          Total percentual de requisicoes do $PROVEDOR"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Login_ok  |       Reject  |       Timeout_AUTH    |       SEM REALM       |       Timeout_ACC     +"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "$RESULTOK%                |       $RESULTREJECT%  |       $RESULTTIM%             |       $RESULTREALM            |       $RESULTACC%             +"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo
echo

 
sleep 30
clear

done

}




case $FUNCAO in

TUDO)clear
echo "Fazendo a contagem por todo o dia"
TUDO
;;

PERIODO)clear
echo "Fazendo a contagem por Periodo"
PERIODO
;;

esac

#set +x
