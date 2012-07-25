#!/bin/bash -x
#
# Script to extract the version number for each component in imt iso
#

# mount directory for imt iso
MNT_ISO=/mnt/imt
# mount direcotry for root image
MNT_ROOT=/mnt/imt-root

# source the basic library for imt iso tools
source ./lib/lib_exec.sh

# process the user args
while [ $# -gt 0 ]
do
    case $1 in
    --iso|--image|-i)
        if [ -z "$2" ]
        then
            fmt_msg "You must specify the ISO image!"
            exit 1
        else
            shift
            ISO=$1
        fi
        ;;
    *)
        fmt_msg "You must specifify the ISO image!"
        exit 1
        ;;
    esac
    shift
done

exec_expr "sudo mkdir -p $MNT_ISO"  "Failed to create $MNT_ISO!"
exec_expr "sudo mkdir -p $MNT_ROOT" "Failed to create $MNT_ROOT!"

temp=$(basename $0)
TMPDIR=$(mktemp -d /tmp/${temp}.XXXXXX)

# mount ISO and root.img
sudo mount -t iso9660 $ISO $MNT_ISO >/dev/null
cp $MNT_ISO/root.img $TMPDIR
cd $TMPDIR
mv root.img root.img.gz
gunzip -d root.img.gz 2>/dev/null
sudo mount -o loop root.img $MNT_ROOT

# get kernel version
cd $MNT_ISO
CMP="kernel"
VERSION=$(file linux | sed 's/^.*version\ \([a-z, 0-9.\-]*\).*/\1/')
echo -e "$CMP version: \t$VERSION"

# get imagetool version
cd $MNT_ISO
CMP="backitup"
VERSION=$(grep ImageTool boot.msg  | head -1 | cut -d' ' -f4)
echo -e "$CMP version: \t$VERSION"

# get isolinux version
cd $MNT_ISO
CMP="isolinux"
VERSION=$(strings isolinux.bin | grep ^ISOLINUX | awk '{print $2}')
echo -e "$CMP version: \t$VERSION"

# get ddrescue version
cd $MNT_ROOT/bin
CMP="ddrescue"
VERSION=$(./ddrescue --version | head -1 | cut -d' ' -f3)
echo -e "$CMP version: \t$VERSION"

# get busybox version
cd $MNT_ROOT/lib
CMP="busybox"
VERSION=$(ls libbusybox.so.* | sed 's/^[a-z.]*\([0-9.]*\)/\1/')
echo -e "$CMP version: \t$VERSION"

cd $TMPDIR 

# clean up
exec_expr "sudo umount $MNT_ISO"    "Failed to umount $MNT_ISO"
exec_expr "sudo umount $MNT_ROOT"   "Failed to umount $MNT_ROOT"

exec_expr "sudo rmdir $MNT_ISO"     "Failed to remove $MNT_ISO"
exec_expr "sudo rmdir $MNT_ROOT"    "Failed to remove $MNT_ROOT"

exec_expr "rm -rf $TMPDIR"          "Failed to remove $TMPDIR"
