#! /bin/bash

# During development only.
set -x

# For now, set debug by hand.
DEBUG="1"

# Fill in the variable if you have a pin code to unlock your screen.
# Obviously, this is a fake passwd.
SCREEN_PWD="19012013"
PATH=$PATH:/system/xbin:/system/bin
# Path to adb.
ADB="./adb"

usage() {
    cat <<EOF >&2
Usage: 
    $0 [sms number message]
    $0 [sms number,[number] message]
EOF
    exit 1
}

check_adb_path()
{
   if [ ! -x "$ADB" ]; then
       if [ ! "$DEBUG" -ne 1 ]; then
           cat <<EOF >&2
adb was not found.
Make sure the PATH define into ADB variable is right.
Make sure adb file is an executable file.
EOF
       fi
       exit 1
   fi
}

check_if_device_connected()
{
    nb=$("$ADB" devices | grep -w 'device' | wc -l)
    if [ "$nb" -lt 1 ]; then
        if [ ! "$DEBUG" -ne 1 ]; then
            echo "No device connected"
        fi
        exit 1
    fi
}

check_screen_status()
{
    status=$("$ADB" shell "dumpsys power" \
        | sed -n "s/.*mScreenOn=\(.*\)./\1/p")
    echo "$status"
}

turn_screen_on()
{
    # turn the screen on
    "$ADB" shell "input keyevent 26"
}

turn_screen_off()
{
    # turn the screen off
    "$ADB" shell "input keyevent 26"
}

unlock_screen()
{
    # Enter password
    "$ADB" shell "input text "$SCREEN_PWD""
    # Simulate enter key
    "$ADB" shell "input keyevent 66"
}

send_msg()
{
    "$ADB" shell am start -a android.intent.action.SENDTO \
                          -d sms:"$number" \
                          --es sms_body "$message" \
                          --ez exit_on_sent true

    # sleep during sending text thru usb. 
    sleep 4
    "$ADB" shell input keyevent 22
    sleep 1
    # simulate enter key
    "$ADB" shell input keyevent 66
}

case "${1:-''}" in 
    'sms')
        check_adb_path
        check_if_device_connected
        if [ $(check_screen_status) == "false" ]; then
            turn_screen_on
            sleep 1
            if [ ! -z "$SCREEN_PWD" ]; then
                unlock_screen
                sleep 1
            fi
        fi
        number="$2"
        if [ $# -ge 3 ]; then 
            message="$3"
            while shift && [ -n "$3" ]; do
                message="${message} $3"
            done
        fi
        send_msg
        sleep 2
        turn_screen_off
        exit 0
        ;;
    *)
        usage
        ;;
esac
