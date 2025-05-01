# 🚀 Guia de Configuração Kubernetes e ArgoCD

## 📋 Ferramentas Necessárias

| Ferramenta   | Descrição                                              |
| ------------ | ------------------------------------------------------ |
| **kubectl**  | Ferramenta de linha de comando para Kubernetes         |
| **minikube** | Cluster Kubernetes local para desenvolvimento e testes |

## 🔧 Instalação Inicial

### Instalar kubectl e minikube

```bash
yay -S kubectl minikube
```

### Iniciar o cluster Minikube

```bash
minikube start
```

## 🌐 Configuração do ArgoCD

### 1. Criar namespace e instalar ArgoCD

```bash
# Criar namespace dedicado
kubectl create namespace argocd

# Aplicar manifestos de instalação
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 2. Verificar a instalação

```bash
# Monitorar status dos pods (-w para watch)
kubectl get pods -n argocd -w
```

### 3. Acessar a interface do ArgoCD

```bash
# Expor a UI localmente (mantenha este processo em execução)
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### 4. Obter credenciais de acesso

```bash
# Usuário: admin
# Senha: resultado do comando abaixo (sem % no final)
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### 5. Acesso à interface web

Abra no navegador: [https://localhost:8080](https://localhost:8080)

---
