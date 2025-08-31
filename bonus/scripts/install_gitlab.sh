echo "[INFO] Installing Helm..."
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm get_helm.sh

echo "[INFO] Creating namespace gitlab..."
sudo kubectl create namespace gitlab

echo "[INFO] Adding GitLab Helm repo..."
helm repo add gitlab https://charts.gitlab.io/
helm repo update

echo "[INFO] Downloading GitLab values.yaml..."
curl -fsSL -o values-gitlab.yaml https://gitlab.com/gitlab-org/charts/gitlab/raw/master/examples/values-minikube-minimum.yaml

echo "[INFO] Installing GitLab with Helm..."
sudo helm upgrade --install gitlab gitlab/gitlab \
  -n gitlab \
  -f values-gitlab.yaml \
  --timeout 1200s \
  --set global.hosts.domain=gitlab.local \
  --set global.hosts.externalIP=0.0.0.0 \
  --set global.hosts.https=false \
  --set global.edition=ce

echo "[INFO] GitLab installed successfully."

echo "[INFO] Waiting for GitLab pods to be ready..."
sudo kubectl wait --for=condition=ready --timeout=1200s pod -l app=webservice -n gitlab

echo "[INFO] Retrieving GitLab root password..."
GITLAB_PASSWORD=$(kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath="{.data.password}" | base64 --decode)
echo "GitLab root password: $GITLAB_PASSWORD"

echo "[INFO] Applying ArgoCD application configuration..."
sudo kubectl apply -n argocd -f ../confs/application.yaml

echo "[INFO] Forwarding GitLab ports..."
sudo kubectl port-forward svc/gitlab-webservice-default -n gitlab 8181:8181 &
sudo kubectl port-forward svc/gitlab-gitlab-shell -n gitlab 32022:32022 &

echo "[INFO] GitLab setup complete. Access it via http://127.0.0.1:8181"
