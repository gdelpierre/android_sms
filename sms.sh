#! /bin/bash

SCREEN_PWD="19012013"
PATH=$PATH:/system/xbin:/system/bin
ADB="./adb"

number="$2"

usage() {
    cat <<EOF >&2
Usage: $0 [send number message]
EOF
    exit 1
}

unlock_screen()
{
    # Screen on
    ${ADB} shell input keyevent 26
    # Enter password
    ${ADB} shell input text ${SCREEN_PWD}
    # Simulate enter key
    ${ADB} shell input keyevent 66
}

send_msg()
{

if [ $# -ge 3 ]; then 
    message="$3"
    while shift && [ -n "$3" ]; do
        message="${message} $3"
    done
fi

${ADB} shell am start -a android.intent.action.SENDTO \
                      -d sms:${number} \
                      --es sms_body "$message" \
                      --ez exit_on_sent true

# sleep before sending text thru usb. 
sleep 4
${ADB} shell input keyevent 22
sleep 1
# simulate enter key
${ADB} shell input keyevent 66
}

#[ -z "$1" ] && usage

case "${1:-''}" in 
    'send')
        unlock_screen
        sleep 1
        send_msg
        ;;
    *)
        usage
        ;;
esac

