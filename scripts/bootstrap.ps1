$ClusterName = "devops-test"

Write-Host "Creating kind cluster..."
kind create cluster --name $ClusterName

Write-Host "Installing ArgoCD..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

Write-Host "Waiting for ArgoCD pods..."
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s

Write-Host "Applying ArgoCD applications..."
kubectl apply -f applications/backend-app.yaml
kubectl apply -f applications/frontend-app.yaml

Write-Host "Done."
Write-Host ""
Write-Host "Check apps:"
Write-Host "kubectl get applications -n argocd"
Write-Host "kubectl get pods"
Write-Host ""
Write-Host "Open ArgoCD UI:"
Write-Host "kubectl port-forward svc/argocd-server -n argocd 8081:443"
Write-Host "https://localhost:8081"