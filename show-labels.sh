#!/bin/bash

echo "Showing Drives By-Label..."
#ls -al /dev/disk/by-label/*

for FILE in /dev/disk/by-label/*; do
    #echo "Found $FILE"
    case $FILE in
       *"EFI"*)
       F="$(basename -- $FILE)"
       #echo "    EFI Ignored... $F"
       ;;
       *)
       F="$(basename -- $FILE)"
       echo "    For $FILE : $F"
       ;;
    esac
done

echo ""
echo "Showing Drives By-PartLabel..."
#ls -al /dev/disk/by-partlabel/*
for FILE in /dev/disk/by-partlabel/*; do
    #echo "Found $FILE"
    case $FILE in
       *"EFI"*)
       F="$(basename -- $FILE)"
       #echo "    EFI Ignored... $F"
       ;;
       *)
       F="$(basename -- $FILE)"
       echo "    For $FILE : $F"
       ;;
    esac
done
exit 0

