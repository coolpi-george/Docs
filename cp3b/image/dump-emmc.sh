#!/bin/bash
IMAGE_NAME="$(date "+%Y%m%d")-rootfs.img"
IMAGE_SIZE="$(df -h /dev/mmcblk0p2 |awk 'NR==2{print $3}'|awk -F '.' '{print ($1+2)*1024}')"
LOOP_NUMBER=$(losetup -f)
echo "01:Check the environment"
apt update
apt install dump -y
echo "02:Establishing a mount directory"
if [ ! -d "./mnt" ]; then
	mkdir ./mnt
fi
echo "03:dd image file"
if [ ! -f "$IMAGE_NAME" ]; then
	dd if=/dev/zero of=./$IMAGE_NAME bs=1M count=$IMAGE_SIZE
fi
echo "04:Mirror Partition"
printf 'n\np\n1\n32768\n1081343\nn\np\n2\n1081344\n\n\nw\n' | fdisk ./$IMAGE_NAME
echo "05:format partition"
partx -av ./$IMAGE_NAME
mkfs.vfat $LOOP_NUMBER"p1"
echo 'yes\n' | mkfs.ext4 $LOOP_NUMBER"p2"
echo "06:copy boot files"
mount $LOOP_NUMBER"p1" ./mnt
cp -rf /boot/firmware/* ./mnt/
umount ./mnt
echo "07:backup rootfs"
if [ -f "backup.fs" ]; then
	rm ./backup.fs
fi
dump -0u -f - /dev/mmcblk0p2 >> ./backup.fs
echo "08:copy rootfs files"
mount $LOOP_NUMBER"p2" ./mnt
cd ./mnt
restore -rf ../backup.fs
cd ../
rm ./mnt/var/lib/misc/firstrun
cat /dev/null >./mnt/etc/fstab
umount ./mnt
e2fsck -p -f $LOOP_NUMBER"p2"
resize2fs -M $LOOP_NUMBER"p2"
e2label $LOOP_NUMBER"p2" writable
losetup -d $LOOP_NUMBER
echo "09:backimg ok"
fdisk -l ./$IMAGE_NAME
