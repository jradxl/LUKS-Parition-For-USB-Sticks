#!/bin/bash

##https://www.cyberciti.biz/security/howto-linux-hard-disk-encryption-with-luks-cryptsetup-command/

source ./env.dat
echo "Unmounting all USB drives..."
echo "Environments loaded: SPEED=$SPEED"

is_mounted()
{   #echo "In Mounted 0$0, 1$1, 2$2, 3$3"
    #echo "<<$(mount | grep $1)>>"
    #echo $USER
    mount | awk -v DIR="$1" '{ if ($3 == DIR) { exit 0 } } ENDFILE { exit -1 }'
}

for FILE in /dev/disk/by-label/*; do
    #echo ""
    echo "Checking $FILE"
    sleep $SPEED
    case $FILE in
      *"EFAT"*)
        #echo "It's EFAT."
        F="$(basename -- $FILE)"
        #echo "$F"
        if is_mounted "/media/$USER/$F"; then
          echo "$F already mounted"
          udisksctl unmount -b  $FILE
        else
          echo "$F not mounted"
        fi
        ;;
      *"LUKS"*)
        #echo "It's LUKS."
        F="$(basename -- $FILE)"
        #echo "$F"
        if is_mounted "/media/$USER/$F"; then
          echo "$F already mounted"
          echo "Unmounting LUKS Partititon"
          udisksctl unmount -b $FILE
          sleep $SPEED
          echo "Locking LUKS Partition"
          udisksctl lock -b /dev/disk/by-partlabel/$F
        else
          echo "$F not mounted"        
        fi        
        ;;        
    esac
done
echo "Completed"
exit 0

