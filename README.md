# APIs Lua com ArgoCD e Kubernetes

Este projeto contém duas APIs simples em Lua que se comunicam entre si:

- **API User**: Gerencia usuários
- **API Order**: Gerencia pedidos

## Estrutura do Projeto

```
lua-apis/
├── api-user/
│   ├── src/main.lua
│   └── Dockerfile
├── api-order/
│   ├── src/main.lua
│   └── Dockerfile
├── k8s/
│   ├── api-user-deployment.yaml
│   ├── api-order-deployment.yaml
│   ├── ingress.yaml
│   └── kustomization.yaml
├── argocd/
│   └── application.yaml
├── docker-compose.yml
└── build.sh
```

## Desenvolvimento Local

### Com Docker Compose
```bash
docker-compose up --build
```

### Com Podman
```bash
# Build das imagens
./build.sh

# Run individual
podman run -p 8080:8080 api-user:latest
podman run -p 8081:8081 api-order:latest
```

## Deploy no Kubernetes

### 1. Build e Push das Imagens
```bash
# Com Podman
./build.sh

# Ou com Docker
docker build -t api-user:latest api-user/
docker build -t api-order:latest api-order/
```

### 2. Deploy Manual
```bash
kubectl apply -f k8s/
```

### 3. Deploy com ArgoCD
```bash
kubectl apply -f argocd/application.yaml
```

## Endpoints

### API User (porta 8080)
- `GET /users` - Lista usuários
- `GET /users/:id` - Busca usuário
- `GET /users/:id/orders` - Pedidos do usuário
- `POST /users` - Cria usuário
- `GET /health` - Health check

### API Order (porta 8081)
- `GET /orders` - Lista pedidos
- `GET /orders/:id` - Busca pedido
- `GET /orders/user/:user_id` - Pedidos por usuário
- `POST /orders` - Cria pedido
- `GET /health` - Health check

## Exemplos de Uso

### Criar usuário
```bash
curl -X POST http://localhost:8080/users \
  -H "Content-Type: application/json" \
  -d '{"name": "João", "email": "joao@email.com"}'
```

### Criar pedido
```bash
curl -X POST http://localhost:8081/orders \
  -H "Content-Type: application/json" \
  -d '{"user_id": "1", "product": "Notebook", "amount": 2500.00}'
```

### Buscar pedidos do usuário
```bash
curl http://localhost:8080/users/1/orders
```

## Configuração ArgoCD

A aplicação ArgoCD monitora o repositório Git e faz deploy automático das mudanças no cluster Kubernetes.

## Monitoramento

As APIs incluem health checks em `/health` para monitoramento com Kubernetes probes.
