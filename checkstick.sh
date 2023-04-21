#!/bin/bash
echo "Non-destructive check of (preferably) unmounted Partitions"
source ./env.dat
echo "Environments loaded: <$EFATNAME, $LUKSNAME>"

echo ""

udisksctl status

echo ""
echo "EXFAT"
sudo fsck.exfat -n /dev/disk/by-label/$EFATNAME
echo ""
echo "Opening LUKS"
sudo cryptsetup luksOpen /dev/disk/by-partlabel/$LUKSNAME luks-$LUKSNAME
echo ""
echo "EXT4 from LUKS"
sudo fsck -n /dev/disk/by-label/$LUKSNAME 
echo ""
sudo cryptsetup luksClose luks-$LUKSNAME
echo "LUKS closed"
echo "Completed"
exit 0

