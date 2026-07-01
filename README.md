DevOps Test Project

Учебный DevOps-проект для демонстрации локального Kubernetes, GitOps, Helm, ArgoCD, CI/CD, PostgreSQL и мониторинга.

Архитектура
Developer
   |
   | git push
   v
GitHub Repositories
   |
   | GitHub Actions
   v
GitHub Container Registry
   |
   v
ArgoCD
   |
   | reads GitOps repo
   v
Helm Charts
   |
   v
Kubernetes kind cluster
   |
   |-- Frontend React
   |-- Backend Django
   |-- PostgreSQL + PVC
   |-- Prometheus + Grafana
Репозитории

Проект состоит из трёх репозиториев:

devops-test-frontend  - React/Vite frontend
devops-test-backend   - Django backend
devops-test-gitops    - Helm charts and ArgoCD applications
Что реализовано
Локальный Kubernetes-кластер через kind
Backend на Django
Frontend на React/Vite
Dockerfile для frontend и backend
GitHub Actions для сборки Docker images
Публикация images в GitHub Container Registry
Helm charts для frontend, backend и PostgreSQL
ArgoCD для GitOps-деплоя
PostgreSQL внутри Kubernetes
PersistentVolumeClaim для хранения данных PostgreSQL
ConfigMap и Secret для настроек backend
ReadinessProbe и LivenessProbe для backend
Prometheus + Grafana через kube-prometheus-stack
Скрипт запуска проекта на новом ПК
Как работает деплой

Разработчик вносит изменения в frontend или backend и выполняет git push.

GitHub Actions автоматически собирает Docker image и публикует его в GitHub Container Registry.

ArgoCD следит за gitops-репозиторием. В нём лежат Helm charts и Application manifests. Если состояние в Git отличается от состояния в Kubernetes, ArgoCD синхронизирует кластер.

Структура gitops-репозитория
devops-test-gitops
├── applications
│   ├── backend-app.yaml
│   ├── frontend-app.yaml
│   ├── postgres-app.yaml
│   └── monitoring-app.yaml
│
├── charts
│   ├── backend
│   ├── frontend
│   └── postgres
│
└── scripts
    └── run.ps1
Быстрый запуск на новом ПК

Перед запуском должны быть установлены:

Docker Desktop
Git
kubectl
kind
Helm

Клонировать репозиторий:

git clone https://github.com/alexvic-che/devops-test-gitops.git
cd devops-test-gitops

Разрешить запуск PowerShell-скриптов в текущем окне:

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

Запустить проект:

.\scripts\run.ps1

Скрипт создаст kind-кластер, установит ArgoCD и применит все Application-манифесты.

Проверка сервисов

Проверить pods:

kubectl get pods
kubectl get pods -n monitoring
kubectl get applications -n argocd

Открыть frontend:

kubectl port-forward svc/frontend 8080:80

Адрес:

http://localhost:8080

Открыть backend:

kubectl port-forward svc/backend 8000:8000

Адрес:

http://localhost:8000/api/health/

Открыть Grafana:

kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80

Адрес:

http://localhost:3000

Логин:

admin

Получить пароль Grafana:

kubectl get secret -n monitoring monitoring-grafana -o jsonpath="{.data.admin-password}" | % {[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_))}

Открыть ArgoCD:

kubectl port-forward svc/argocd-server -n argocd 8081:443

Адрес:

https://localhost:8081
Основная идея проекта

Проект демонстрирует полный путь доставки приложения:

Code
  ↓
GitHub
  ↓
GitHub Actions
  ↓
Docker image
  ↓
Container Registry
  ↓
GitOps repository
  ↓
ArgoCD
  ↓
Helm
  ↓
Kubernetes

Такой подход позволяет хранить инфраструктуру в Git, автоматически разворачивать приложения и контролировать состояние Kubernetes-кластера через ArgoCD.

Что можно улучшить дальше
Добавить Ingress для доступа без port-forward
Добавить автоматическое обновление image tag в gitops-репозитории
Добавить тесты и линтеры в GitHub Actions
Добавить Cloudflare Tunnel и публичный HTTPS-доступ
Добавить алерты в Alertmanager