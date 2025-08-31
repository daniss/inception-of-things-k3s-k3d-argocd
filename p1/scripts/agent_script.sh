apt update
apt install -y curl ssh

export K3S_KUBECONFIG_MODE="644" #kubectl without sudo

K3S_TOKEN=$(cat /vagrant/shared/node-token)
curl -sfL https://get.k3s.io | K3S_URL=https://192.168.56.110:6443 K3S_TOKEN=${K3S_TOKEN} sh -s - --node-ip=192.168.56.111
