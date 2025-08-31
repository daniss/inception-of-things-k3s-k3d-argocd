apt update
apt install -y curl ssh

export K3S_KUBECONFIG_MODE="644" #kubectl without sudo

curl -sfL https://get.k3s.io | sh -s - --node-ip=192.168.56.110
#sudo cp /var/lib/rancher/k3s/server/node-token /vagrant/shared/node-token

kubectl apply -f /vagrant/app1.yaml
kubectl apply -f /vagrant/app2.yaml
kubectl apply -f /vagrant/app3.yaml
kubectl apply -f /vagrant/ingress.yaml 
