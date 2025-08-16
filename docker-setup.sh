#!/bin/bash

echo "🚀 Configurando Wave SaaS no Docker..."

# Verificar se o Docker está rodando
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker não está rodando. Por favor, inicie o Docker primeiro."
    exit 1
fi

# Copiar arquivo de ambiente
if [ ! -f .env ]; then
    echo "📋 Copiando arquivo de ambiente..."
    cp env.docker .env
    echo "✅ Arquivo .env criado com configurações do Docker"
else
    echo "⚠️  Arquivo .env já existe. Verifique se as configurações estão corretas."
fi

# Construir e iniciar os containers
echo "🔨 Construindo containers..."
docker-compose build

echo "🚀 Iniciando serviços..."
docker-compose up -d

# Aguardar o banco de dados estar pronto
echo "⏳ Aguardando banco de dados..."
sleep 30

# Executar migrações e seeders
echo "🗄️  Executando migrações..."
docker-compose exec app php artisan migrate --force

echo "🌱 Executando seeders..."
docker-compose exec app php artisan db:seed --force

echo "🔑 Gerando chave da aplicação..."
docker-compose exec app php artisan key:generate

echo "🔗 Criando link simbólico do storage..."
docker-compose exec app php artisan storage:link

echo "📦 Publicando assets..."
docker-compose exec app php artisan vendor:publish --all

echo "✅ Setup concluído!"
echo ""
echo "🌐 Aplicação disponível em: http://localhost"
echo "🗄️  MySQL disponível em: localhost:3306"
echo "🔴 Redis disponível em: localhost:6379"
echo ""
echo "📋 Comandos úteis:"
echo "  - docker-compose logs -f    # Ver logs em tempo real"
echo "  - docker-compose down       # Parar containers"
echo "  - docker-compose restart    # Reiniciar containers"
