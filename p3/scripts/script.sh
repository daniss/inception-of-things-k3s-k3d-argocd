#!/bin/bash

# Step 1: Install Docker
install_docker() {
    if [ -x "$(command -v docker)" ]; then
        echo "Docker is already installed."
        return
    fi
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    echo "Docker installed successfully."
}

# Step 2: Install K3D
# k3d is a lightweight wrapper to run k3s (Rancher Lab's minimal Kubernetes distribution) in Docker.
install_k3d() {
    if [ -x "$(command -v k3d)" ]; then
        echo "K3D is already installed."
        return
    fi
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
    echo "K3D installed successfully."
}

# Step 3: Install kubectl
# kubectl is a command-line tool that allows you to run commands against Kubernetes clusters.
install_kubectl() {
    if [ -x "$(command -v kubectl)" ]; then
        echo "kubectl is already installed."
        return
    fi
    curl -LO "https://dl.k8s.io/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
    echo "kubectl installed successfully."
}

# Step 4: Create Kubernetes Cluster
# A cluster is a set of physical or virtual machines and other infrastructure resources used by Kubernetes to run your applications.
create_cluster() {
    if [ -n "$(k3d cluster list | grep mycluster)" ]; then
        echo "Kubernetes Cluster already exists."
        return
    fi
    k3d cluster create mycluster
    echo "Kubernetes Cluster created successfully."
}

# Step 5: Configure Namespaces
# Namespaces are a way to divide cluster resources between multiple users (via resource quota).
configure_namespaces() {
    if [ -n "$(kubectl get namespace argocd)" ] && [ -n "$(kubectl get namespace dev)" ]; then
        echo "Namespaces already configured."
        return
    fi
    kubectl create namespace argocd
    kubectl create namespace dev
    echo "Namespaces configured successfully."
}

# Step 6: Deploy Argo CD
# Argo CD is a declarative, GitOps continuous delivery tool for Kubernetes.
deploy_argocd() {
    if [ -n "$(kubectl get deployment -n argocd argocd-server)" ]; then
        echo "Argo CD is already deployed."
        return
    fi
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml # Deploy Argo CD
    kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n argocd # Wait for Argo CD to be available
    kubectl apply -n argocd -f ../confs/application.yaml # Deploy the sample application
    echo "Argo CD deployed successfully."
}

final_instructions() {
    echo "kubectl port-forward svc/argocd-server -n argocd 8080:443"
    echo "Then open your browser and go to https://localhost:8080"
    echo "To get the password run: sudo kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d"
    echo "To test the app you first need to port-forward the service: sudo kubectl get pods -n dev, then sudo kubectl port-forward <pod-name> 8085:8085 -n dev"
    echo "Then curl 0.0.0.0:8085/hello or 0.0.0.0:8085 to get version"
}

install_docker
install_k3d
install_kubectl
create_cluster
configure_namespaces
deploy_argocd
final_instructions
