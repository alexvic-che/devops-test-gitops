if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "Run install.ps1 first."
    exit
}

$ClusterName = "devops-test"

Write-Host "=== DevOps Test Bootstrap ==="

# Check Docker
Write-Host "Checking Docker..."
docker ps | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker is not running. Start Docker Desktop first."
    exit 1
}

# Check kind cluster
Write-Host "Checking kind cluster..."
$clusters = kind get clusters

if ($clusters -contains $ClusterName) {
    Write-Host "Cluster '$ClusterName' already exists."
}
else {
    Write-Host "Creating kind cluster '$ClusterName'..."
    kind create cluster --name $ClusterName
}

# Use cluster context
kubectl cluster-info | Out-Null

# Install ArgoCD
Write-Host "Installing ArgoCD..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD
Write-Host "Waiting for ArgoCD pods..."
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s

# Apply applications
Write-Host "Applying ArgoCD applications..."
kubectl apply -f applications/backend-app.yaml
kubectl apply -f applications/frontend-app.yaml

Write-Host "Waiting for application pods..."
Start-Sleep -Seconds 20

kubectl get applications -n argocd
kubectl get pods
kubectl get svc

Write-Host ""
Write-Host "=== Done ==="
Write-Host ""
Write-Host "Open ArgoCD UI:"
Write-Host "kubectl port-forward svc/argocd-server -n argocd 8081:443"
Write-Host "https://localhost:8081"
Write-Host ""
Write-Host "Get ArgoCD admin password:"
Write-Host 'kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | % {[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_))}'
Write-Host ""
Write-Host "Check frontend:"
Write-Host "kubectl port-forward svc/frontend 8080:80"
Write-Host "http://localhost:8080"