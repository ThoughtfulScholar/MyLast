# !/bin/bash
shopt -s lastpipe
formatare_auth_failed()
{
    info=""
    while [ "$#" -gt "0" ]; do
        info+="$1"
        shift
    done
    data=`date -d "${info:0:19}" "+%a %b %d %T"`
    nume=${info#*rhost=}
    nume=${nume#*user=}
    terminal=${info#*tty=}
    terminal=${terminal#*/dev/}
    terminal=${terminal%ruser*}
    if [  $terminal = $info ]; then
        terminal="ssh:notty"
    fi
    sursa=${info#from}
    if [ $sursa = $info ]; then
        sursa=""
    fi
    echo "$nume ______ $terminal ______ $sursa ______ $data"
    return 1
}
formatare_restul(){
    info=""
    while [ "$#" -gt "0" ]; do
        info+="$1 "
        shift
    done
    data=`date -d "${info:0:19}" "+%a %b %d %T"`
    cuvinte_cheie_user=('FOR' 'to root' 'for' 'user')
    nume=""
    for cuv  in "${cuvinte_cheie_user[@]}"; do
        nume=`echo $info | grep -oP "$cuv\K.*"`
        if [[ -n $nume ]]; then
            if [ "$cuv" = "to root" ]; then
                nume=`echo $nume | awk '{print $2}'`
            else
                nume=`echo $nume | awk '{print $1}'`
            fi
            break
        fi
        
    done
    sursa=`echo $info | grep -oP ".*from\K"`
        if [ -z $sursa ]; then
            sursa=" "
        else
            sursa=`echo $sursa | awk '{print $1}'`
        fi
    terminal1=${info#*/dev/}
    terminal2=${info#*on }
    terminal=""
        if [ "$terminal1" != "$info" ]; then
            terminal=`echo $terminal1 | awk '{print $1}'`
        elif [ "$terminal2" != "$info" ]; then
            terminal=$terminal2
        else
            
            terminal="ssh:notty"
        fi 
    echo "$nume ______ $terminal ______ $sursa ______ $data"
}
since=""
until=""
limit=-1
while [ $# -gt "0" ]; do
    case "$1" in
    -s)
        shift
        data=$1
        if [ "${#data}" = "14" ]; then
            data="${data:0:4}-${data:4:2}-${data:6:2} ${data:8:2}:${data:10:2}:${data:12:2}"
        fi
        since=`date -d "$data" "+%Y-%m-%dT%T"`
        ;;
    -t)
        shift
        data=$1
        if [ "${#data}" = "14" ]; then
            data="${data:0:4}-${data:4:2}-${data:6:2} ${data:8:2}:${data:10:2}:${data:12:2}"
        fi
        until=`date -d "$data" "+%Y-%m-%dT%T"`
        ;;
    -p)
        shift
        data=$1
        if [ "${#data}" = "14" ]; then
            data="${data:0:4}-${data:4:2}-${data:6:2} ${data:8:2}:${data:10:2}:${data:12:2}"
        fi
        since=`date -d "$data" "+%Y-%m-%dT%T"`
        until=$since
        ;;
    -n)
        shift
        limit=$1
        ;;
    *)
        shift
        ;;
    esac
done
sudo zgrep -haE "sshd.*Failed|sshd.*Invalid|login.*FAILED LOGIN|su.*FAILED SU" /var/log/auth.log* |\
grep -v "COMMAND" | while read info && [ $limit -gt "0"  -o $limit = "-1" ]; do
    time=${info:0:19}
    if [[ "$time" > "$since" || "$time" = "$since" ]] && \
     [[ -z "$until" || "$time" < "$until" || "$time" = "$until" ]]; then
        echo "$(formatare_restul $info)"
    fi
    if [ $limit != "-1" ]; then
        ((limit-=1))
    fi
done
sudo zgrep -haE "pam_unix.*authentication failure|sshd.*authentication failure" /var/log/auth.log* |\
grep -v "COMMAND" | while read info && [ $limit -gt "0"  -o $limit = "-1" ]; do
    time=${info:0:19}
    if [[ "$time" > "$since" || "$time" = "$since" ]] && \
     [[ -z "$until" || "$time" < "$until" || "$time" = "$until" ]]; then
        echo "$(formatare_auth_failed $info)"
    fi
    if [ $limit != "-1" ]; then
        ((limit-=1))
    fi
done