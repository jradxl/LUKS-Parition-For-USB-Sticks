#!/bin/bash

##########################
# Script to create two partitions each of 50% of USB Stick, where one will be formated eFAT,
# and the other as a LUKS ext4.
# Intentionally the LUKS key is not stored anywhere and needs to be entered 3 times
# And as the script is not likely to run frequently, the user must edit this script
# with the needed parameters, SPEED, DEVICE, EFATNAME and LUKSNAME
# Admin access is needed via SUDO
# I think the Sleep $SPEED lines are needed depending on the speed of the USB Stick
# The idea of the EFATNAME and LUKSNAME are to be searchable and indexable to cater
# for multiple sticks
# i.e.USBEFAT001, USBEFAT002, USBEFAT003 etc...
# March 2023 v0.1
##########################

#
# e2label, exfatlabel, partprobe, blockdev
#

##Based on following, with thanks
##https://medium.com/tech-notes-and-geek-stuff/how-to-encrypt-a-usb-disk-47f6a4166f03
##https://www.cyberciti.biz/security/howto-linux-hard-disk-encryption-with-luks-cryptsetup-command/
##https://medium.com/@AndrzejRehmann/encrypt-pendrive-with-luks-a58989889d36

#Defaults
# User needs to set as required
DEVICE=/dev/sdX
EFATNAME=USBEFATnnnn
LUKSNAME=USBLUKSnnnn
SPEED=5

echo "Starting to create the USB..."
source ./env.dat
echo "Environments loaded: Using DEVICE=$DEVICE"

sudo partprobe
echo "Creating GPT"
sleep $SPEED
sudo parted -s $DEVICE mklabel gpt
sleep $SPEED
echo "Creating Partition 1 for exFAT"
sleep $SPEED
sudo parted -s $DEVICE mkpart $EFATNAME 0% 49%
sleep $SPEED
echo "Creating Partition 2 for LUKS"
sudo parted -s $DEVICE mkpart $LUKSNAME 50% 100% 
echo "Creating LUKS Format"
sleep $SPEED
sudo cryptsetup -y -v --type luks2 luksFormat /dev/disk/by-partlabel/$LUKSNAME
echo "Opening the LUKS partition"
sleep $SPEED
sudo cryptsetup --type luks2 luksOpen /dev/disk/by-partlabel/$LUKSNAME luks-$LUKSNAME
sleep $SPEED
echo "Show the LUKS Status"
sudo cryptsetup -v status luks-$LUKSNAME
sleep $SPEED
echo "Formatting EXT4 on the LUKS partition"
sleep $SPEED
sudo mkfs.ext4 -t ext4 -L $LUKSNAME /dev/mapper/luks-$LUKSNAME
echo "Formatting exFAT on the FAT parition "
sleep $SPEED
sudo mkfs.exfat -L $EFATNAME -v /dev/disk/by-partlabel/$EFATNAME 

#Already Open cryptsetup --type luks2 luksOpen /dev/disk/by-partlabel/$LUKSNAME luks-$LUKSNAME
#echo "Open: $?"

###############
# Udisk2 mounts an EXT4 or a LUKS partition as root and not as $USER
# Therefore we create home directories for all users on the asumption
# one of them might use the drive.
###############
sleep $SPEED
echo "Temporarily mount to create home directories in the LUKS partition"
sudo mkdir -p /mnt/$LUKSNAME
sudo mount /dev/disk/by-label/$LUKSNAME /mnt/$LUKSNAME
RET=$?
if [[ $RET -ne 0 ]] ; then
    #Should not happen
    echo "Already Mounted. Exiting..."
    exit 0
fi

for DIR in /home/*; do
    f="$(basename -- $DIR)"
    echo "Processing $DIR as /mnt/$LUKSNAME/$f"
    sudo mkdir -p "/mnt/$LUKSNAME/$f"
    sleep $SPEED
    sudo chown -R $f:$f "/mnt/$LUKSNAME/$f"
    sleep $SPEED
done
echo "Completed creating home directories in the LUKS partition"
sync
echo "Unmounting"
sleep $SPEED
sudo umount /mnt/$LUKSNAME
echo "Removing mount point"
sleep $SPEED
sudo rm -rf /mnt/$LUKSNAME

#Now close the LUKS partiion
sleep $SPEED
sudo cryptsetup -v luksClose luks-$LUKSNAME
sync
exit 0
#Partitions left unmounted and LUKS locked

