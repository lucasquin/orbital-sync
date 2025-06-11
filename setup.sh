#!/bin/bash
# start-podman-kube.sh - Script para iniciar o ambiente com Podman Play Kube
set -e
echo "🚀 Iniciando ambiente Ping Pong APIs com Podman Play Kube"

# Função para verificar se comando existe
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Verificar se Podman está instalado
if ! command_exists podman; then
  echo "❌ Podman não encontrado."
  echo "Instale o Podman: https://podman.io/getting-started/installation"
  exit 1
fi

echo "✅ Usando: podman play kube"

# Limpar recursos anteriores
echo "🧹 Limpando ambiente anterior..."
podman pod rm -f pingpong-stack 2>/dev/null || true
podman volume rm -f grafana-storage 2>/dev/null || true
podman system prune -f --volumes || true

# Criar diretórios necessários
echo "📁 Criando estrutura de diretórios..."
mkdir -p monitoring/grafana/{dashboards,provisioning/{datasources,dashboards}}
mkdir -p database logs

# Ajustar permissões para rootless Podman
echo "🔐 Ajustando permissões para Podman rootless..."
chmod -R 755 monitoring/
chmod -R 755 database/ logs/ 2>/dev/null || true

# Pre-pull das imagens base para evitar travamento durante build
echo "📥 Fazendo pre-pull das imagens base principais..."
podman pull docker.io/library/python:3.11-slim || echo "⚠️  Falha no pull da imagem Python"
podman pull docker.io/library/node:18-alpine || echo "⚠️  Falha no pull da imagem Node"
podman pull docker.io/prom/prometheus:latest || echo "⚠️  Falha no pull da imagem Prometheus"
podman pull docker.io/grafana/grafana:latest || echo "⚠️  Falha no pull da imagem Grafana"
podman pull docker.io/traefik:v2.10 || echo "⚠️  Falha no pull da imagem Traefik"

# Construir imagens das aplicações
echo "🏗️  Construindo imagens das aplicações..."
echo "Building Ping API..."
podman build -t localhost/ping-api:latest ./ping/ || {
  echo "❌ Falha no build ping-api"
  exit 1
}

echo "Building Pong API..."
podman build -t localhost/pong-api:latest ./pong/ || {
  echo "❌ Falha no build pong-api"
  exit 1
}

# Verificar se o arquivo YAML existe
if [ ! -f "ping-pong-kube.yaml" ]; then
  echo "❌ Arquivo ping-pong-kube.yaml não encontrado!"
  echo "Certifique-se de que o arquivo está no diretório atual."
  exit 1
fi

# Iniciar com Podman Play Kube
echo "🚀 Iniciando pod com Podman Play Kube..."
timeout 120 podman play kube ping-pong-kube.yaml || {
  echo "❌ Timeout ou falha ao iniciar pod. Verificando logs..."
  podman pod logs pingpong-stack 2>/dev/null || true
  exit 1
}

echo "⏳ Aguardando serviços ficarem prontos..."
sleep 20

echo "📊 Verificando status do pod..."
podman pod ps
echo ""
podman ps --pod

echo "🧪 Testando health checks..."
echo "Testing Ping API..."
for i in {1..5}; do
  if curl -f http://localhost:5000/health 2>/dev/null; then
    echo "✅ Ping API health check OK"
    break
  fi
  echo "⏳ Tentativa $i/5 - aguardando Ping API..."
  sleep 5
done

echo "Testing Pong API..."
for i in {1..5}; do
  if curl -f http://localhost:5001/health 2>/dev/null; then
    echo "✅ Pong API health check OK"
    break
  fi
  echo "⏳ Tentativa $i/5 - aguardando Pong API..."
  sleep 5
done

# Testar comunicação ping-pong
echo "🏓 Testando comunicação ping-pong..."
sleep 5
response=$(curl -s http://localhost:5000/start-ping 2>/dev/null || echo "Falha na comunicação")
echo "Response: $response"

echo ""
echo "✅ Ambiente iniciado com sucesso usando Podman Play Kube!"
echo ""
echo "📱 URLs disponíveis:"
echo "   Ping API:          http://localhost:5000"
echo "   Pong API:          http://localhost:5001"
echo "   Traefik Dashboard: http://localhost:8080"
echo "   Prometheus:        http://localhost:9090"
echo "   Grafana:           http://localhost:3000 (admin/admin123)"
echo ""
echo "🧪 Comandos de teste:"
echo "   Health Check:      curl http://localhost:5000/health"
echo "   Start Ping:        curl http://localhost:5000/start-ping"
echo "   Pong Status:       curl http://localhost:5001/status"
echo ""
echo "📝 Logs:"
echo "   podman pod logs pingpong-stack"
echo "   podman logs pingpong-stack-ping-api"
echo "   podman logs pingpong-stack-pong-api"
echo ""
echo "🔧 Comandos Podman úteis:"
echo "   Parar pod:         podman pod stop pingpong-stack"
echo "   Remover pod:       podman pod rm pingpong-stack"
echo "   Restart pod:       podman pod restart pingpong-stack"
echo "   Ver pods:          podman pod ps"
echo "   Ver containers:    podman ps --pod"
echo "   Gerar YAML:        podman generate kube pingpong-stack"
echo "   Limpar recursos:   podman system prune"
