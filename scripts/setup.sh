ISO_URL=http://mirrors.trantect.com/repository/ustc/ubuntu-cdimage/releases/18.04.3/release/ubuntu-18.04.3-server-amd64.iso 

echo "******************** prepare env ********************"
apt-get update
apt-get install -y squashfs-tools genisoimage rsync wget

echo "******************** extract iso ********************"

mkdir ~/output
cd ~/output
wget $ISO_URL -O ubuntu.iso

mkdir mnt || true
mount -o loop ubuntu.iso mnt
mkdir extract
rsync --exclude=/install/filesystem.squashfs -a mnt/ extract

unsquashfs ./mnt/install/filesystem.squashfs
mv ./squashfs-root ./edit

echo "******************** change root ********************"

cp /etc/resolv.conf ./edit/etc/

mount --bind /dev/ ./edit/dev
cp custom.sh ./edit
cp /etc/apt/sources.list ./edit/etc/apt/sources.list
chroot ./edit ./custom.sh

cd ~/output
rm -rf ./edit/custom.sh
umount ./edit/dev
# echo "******************** gen manifest ********************"

chmod +w extract/install/filesystem.manifest

chroot ./edit dpkg-query -W --showformat='${Package} ${Version}\n' | tee ./extract/install/filesystem.manifest
cp ./extract/install/filesystem.manifest ./extract/install/filesystem.manifest-desktop
sed -i '/ubiquity/d' ./extract/install/filesystem.manifest-desktop
sed -i '/install/d' ./extract/install/filesystem.manifest-desktop

echo "******************** gen manifest ********************"

mksquashfs edit extract/install/filesystem.squashfs -b 1048576

printf $(du -sx --block-size=1 edit | cut -f1) | tee ./extract/install/filesystem.size

echo "******************** gen md5 ********************"

cd ./extract
rm ./md5sum.txt
find -type f -print0 | xargs -0 md5sum | grep -v isolinux/boot.cat | tee md5sum.txt

echo "******************** gen iso ********************"

genisoimage -D -r -V "$IMAGE_NAME" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o /output/ubuntu-server.iso .

