# !/bin/bash
shopt -s lastpipe
formatare_auth_failed()
{
    info=""
    while [ "$#" -gt "0" ]; do
        info+="$1"
        shift
    done
    data=`date -d "${info:0:19}" "+%a %b %d %H:%M"`
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
since=""
until=""
limit=-1
while [ $# -gt "0" ]; do
    case "$1" in
    -s)
        shift
        since=`date -d "$1" "+%Y-%m-%dT%T"`
        ;;
    -t)
        shift
        until=`date -d "$1" "+%Y-%m-%dT%T`
        ;;
    -p)
        shift
        since=`date -d "$1" "+%Y-%m-%dT%T"`
        until=`date -d "$1" "+%Y-%m-%dT%T"`
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
sudo zgrep -haE "sshd.*Failed|sshd.*Invalid|login.*FAILED LOGIN|su.*FAILED SU" /var/log/auth.log* | grep -v "COMMAND" | while read info && [ $limit -gt "0"  -o $limit = "-1" ]; do
    if [[ "$time" > "$since" || "$time" = "$since" ]] && [[ -z "$until" || "$time" < "$until" || "$time" = "$until" ]]; then
        echo $info
    fi
    if [ $limit != "-1" ]; then
        ((limit-=1))
    fi
done
sudo zgrep -haE "pam_unix.*authentication failure|sshd.*authentication failure" /var/log/auth.log* | grep -v "COMMAND" | while read info && [ $limit -gt "0"  -o $limit = "-1" ]; d
    if [[ "$time" > "$since" || "$time" = "$since" ]] && [[ -z "$until" || "$time" < "$until" || "$time" = "$until" ]]; then
        echo $info
    fi
    if [ $limit != "-1" ]; then
        ((limit-=1))
    fi
done