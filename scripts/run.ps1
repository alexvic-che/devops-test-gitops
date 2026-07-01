$ErrorActionPreference = "Stop"

$ClusterName = "devops-test"

function Check-Command {
    param($Name)

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        Write-Host "ERROR: $Name is not installed."
        Write-Host "Install it first and run this script again."
        exit 1
    }

    Write-Host "OK: $Name found"
}

Write-Host "=== DevOps Test Project Runner ==="

Check-Command "docker"
Check-Command "kubectl"
Check-Command "kind"
Check-Command "helm"

Write-Host "Checking Docker..."
docker ps | Out-Null

Write-Host "Checking kind cluster..."
$clusters = kind get clusters

if ($clusters -contains $ClusterName) {
    Write-Host "Cluster '$ClusterName' already exists."
}
else {
    Write-Host "Creating kind cluster '$ClusterName'..."
    kind create cluster --name $ClusterName
}

Write-Host "Using Kubernetes context..."
kubectl config use-context "kind-$ClusterName"

Write-Host "Installing ArgoCD..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

Write-Host "Waiting for ArgoCD..."
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s

Write-Host "Applying ArgoCD applications..."

kubectl apply -f applications/postgres-app.yaml
kubectl apply -f applications/backend-app.yaml
kubectl apply -f applications/frontend-app.yaml
kubectl apply -f applications/monitoring-app.yaml

Write-Host "Waiting for workloads..."
Start-Sleep -Seconds 30

Write-Host ""
Write-Host "Applications:"
kubectl get applications -n argocd

Write-Host ""
Write-Host "Default namespace pods:"
kubectl get pods

Write-Host ""
Write-Host "Monitoring pods:"
kubectl get pods -n monitoring

Write-Host ""
Write-Host "=== Done ==="
Write-Host ""
Write-Host "Frontend:"
Write-Host "kubectl port-forward svc/frontend 8080:80"
Write-Host "http://localhost:8080"
Write-Host ""
Write-Host "Backend:"
Write-Host "kubectl port-forward svc/backend 8000:8000"
Write-Host "http://localhost:8000/api/health/"
Write-Host ""
Write-Host "Grafana:"
Write-Host "kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80"
Write-Host "http://localhost:3000"
Write-Host ""
Write-Host "ArgoCD:"
Write-Host "kubectl port-forward svc/argocd-server -n argocd 8081:443"
Write-Host "https://localhost:8081"