#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================="
Write-Host " DevOps Test Environment Installer"
Write-Host "========================================="
Write-Host ""

function Test-Command {
    param($Command)

    return [bool](Get-Command $Command -ErrorAction SilentlyContinue)
}

function Install-Package {
    param(
        $Name,
        $WingetId,
        $Command
    )

    Write-Host ""
    Write-Host "Checking $Name..."

    if (Test-Command $Command) {
        Write-Host "$Name already installed."
        return
    }

    Write-Host "Installing $Name..."
    winget install --id $WingetId -e --accept-source-agreements --accept-package-agreements

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to install $Name"
        exit 1
    }
}

# Проверяем winget
if (-not (Test-Command "winget")) {
    Write-Host "Winget not found."
    exit 1
}

Install-Package "Git" "Git.Git" "git"
Install-Package "kubectl" "Kubernetes.kubectl" "kubectl"
Install-Package "kind" "Kubernetes.kind" "kind"
Install-Package "Helm" "Helm.Helm" "helm"

Write-Host ""
Write-Host "Checking Docker..."

if (-not (Test-Command "docker")) {

    Write-Host ""
    Write-Host "Docker Desktop is not installed."
    Write-Host ""

    winget install --id Docker.DockerDesktop -e --accept-source-agreements --accept-package-agreements

    Write-Host ""
    Write-Host "Restart the computer after Docker installation."
    exit
}

Write-Host "Docker installed."

Write-Host ""
Write-Host "========================================="
Write-Host "Installation completed!"
Write-Host "========================================="
Write-Host ""

Write-Host "Versions:"
Write-Host ""

git --version
docker --version
kubectl version --client
kind version
helm version