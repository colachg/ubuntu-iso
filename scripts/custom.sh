echo "******************** mount dirs ********************"

mount -t proc none /proc
mount -t sysfs none /sys
mount -t devpts none /dev/pts

export HOME=/root
export LC_ALL=C
dbus-uuidgen > /var/lib/dbus/machine-id
dpkg-divert --local --rename --add /sbin/initctl
ln -s /bin/true /sbin/initctl

echo "******************** install packages ********************"

dpkg --add-architecture amd64
apt-get update

apt install -y curl gnupg software-properties-common
apt-add-repository --yes --update ppa:ansible/ansible



apt install -y curl gnupg
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

echo "deb [arch=amd64] http://mirrors.trantect.com/repository/ustc/docker-ce/linux/ubuntu xenial stable " > /etc/apt/sources.list.d/docker.list
echo "deb http://mirrors.trantect.com/repository/ustc/kubernetes/apt kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

apt-get update

apt install -y \
    apt-transport-https \
    ca-certificates \
    make \
    ansible \
    sshpass \
    vim \
    net-tools \
    git \
    tar \
    jq \
    python3 \
    python3-pip \
    gnupg-agent \
    software-properties-common\
    nfs-common \
    nfs-kernel-server\
    unzip \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    kubectl=1.15.0-00 \
    kubelet=1.15.0-00 \
    kubeadm=1.15.0-00 \
    kubernetes-cni=0.7.5-00

echo "******************** clean up ********************"

rm -rf /etc/apt/*.save
rm -rf /etc/apt/sources.list.d/*.save
apt-get autoremove && apt-get autoclean
rm -rf /tmp/* ~/.bash_history
rm /var/lib/dbus/machine-id
rm /sbin/initctl
dpkg-divert --rename --remove /sbin/initctl

echo "******************** unmount dirs ********************"

umount /proc || umount -lf /proc
umount /sys
umount /dev/pts
exit
