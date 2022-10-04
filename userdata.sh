#!/bin/bash -x

# Set environment variables required to get this working
# These aren't exported normally until the system is setup,
# hence doing it here instead.
echo "export PATH=$PATH:/usr/local/bin" >> ~/.bash_profile && \
echo "export GOCACHE=/root/go/cache" >> ~/.bash_profile && \
echo "export HOME=/root" >> ~/.bash_profile && \
source ~/.bash_profile

mkdir -p /root/go/cache

# Update the OS
sudo yum update -y

# Install dependencies required
sudo yum install docker conntrack-tools golang git -y

# Install kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl 
chmod +x ./kubectl 
sudo mv ./kubectl /usr/local/bin/kubectl

# Install docker
sudo systemctl enable --now docker
# Make it so no root is required for docker commands
sudo usermod -aG docker ssm-user
newgrp docker

# Install minikube
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/

# Setup service file for minikube
cat >/etc/systemd/system/minikube.service <<EOL
[Unit]
Description=minikube
After=docker.service docker.socket

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/root
ExecStart=/usr/local/bin/minikube start --embed-certs --driver=none 
ExecStop=/usr/local/bin/minikube stop

[Install]
WantedBy=multi-user.target
EOL


# Install cri-ctl (minikube dependency)
VERSION="v1.25.0"
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz
tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin
cp /usr/local/bin/crictl /usr/sbin/ # Hacky fix to get minikube to see crictl
rm -f crictl-$VERSION-linux-amd64.tar.gz

# Instructions for installing cri-dockerd: https://github.com/Mirantis/cri-dockerd#build-and-install
# Install cri-dockerd
cd /tmp
git clone https://github.com/Mirantis/cri-dockerd.git
cd cri-dockerd
mkdir bin
go build -o bin/cri-dockerd -buildvcs=false
install -o root -g root -m 0755 bin/cri-dockerd /usr/local/bin/cri-dockerd
cp -a packaging/systemd/* /etc/systemd/system
sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service

# Reload systemctl then start the services.  Might need a sleep before minikube?
systemctl daemon-reload && \
systemctl enable cri-docker.service && \
systemctl enable --now cri-docker.socket
systemctl enable minikube && \
systemctl start minikube

# Need to learn more about minikube & kubectl 
# before I know whether this is required or not
sleep 60
mkdir /root/.kube
cp /etc/kubernetes/admin.conf /root/.kube/config
chown root /root/.kube/config