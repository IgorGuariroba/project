# 🐳 Wave SaaS - Docker Setup

Este documento explica como executar a aplicação Wave SaaS usando Docker.

## 📋 Pré-requisitos

- Docker
- Docker Compose
- Git

## 🚀 Início Rápido

### 1. Setup Automático (Recomendado)

Execute o script de setup automático:

```bash
./docker-setup.sh
```

Este script irá:
- Copiar as configurações de ambiente
- Construir os containers
- Iniciar todos os serviços
- Executar migrações e seeders
- Configurar a aplicação

### 2. Setup Manual

Se preferir fazer o setup manualmente:

#### 2.1. Configurar ambiente
```bash
cp env.docker .env
```

#### 2.2. Construir e iniciar containers
```bash
docker-compose build
docker-compose up -d
```

#### 2.3. Executar setup da aplicação
```bash
# Aguardar o banco estar pronto (30-60 segundos)
docker-compose exec app php artisan migrate --force
docker-compose exec app php artisan db:seed --force
docker-compose exec app php artisan key:generate
docker-compose exec app php artisan storage:link
docker-compose exec app php artisan vendor:publish --all
```

## 🌐 Acessos

- **Aplicação**: http://localhost
- **MySQL**: localhost:3306
- **Redis**: localhost:6379

### Credenciais do Banco de Dados

- **Host**: db
- **Database**: wave_db
- **Username**: wave_user
- **Password**: wave_password
- **Root Password**: wave_root_password

## 📦 Serviços

### 1. **app** (Laravel)
- **Imagem**: PHP 8.1-FPM customizada
- **Porta**: 9000 (interno)
- **Função**: Aplicação Laravel

### 2. **nginx** (Servidor Web)
- **Imagem**: nginx:alpine
- **Porta**: 80
- **Função**: Servidor web e proxy reverso

### 3. **db** (MySQL)
- **Imagem**: mysql:8.0
- **Porta**: 3306
- **Função**: Banco de dados principal

### 4. **redis** (Cache/Filas)
- **Imagem**: redis:alpine
- **Porta**: 6379
- **Função**: Cache e filas

### 5. **node** (Build Assets)
- **Imagem**: node:18-alpine
- **Função**: Build dos assets frontend

## 🛠️ Comandos Úteis

### Gerenciamento de Containers
```bash
# Ver status dos containers
docker-compose ps

# Ver logs em tempo real
docker-compose logs -f

# Ver logs de um serviço específico
docker-compose logs -f app

# Parar todos os containers
docker-compose down

# Reiniciar containers
docker-compose restart

# Reconstruir containers
docker-compose build --no-cache
```

### Comandos Laravel
```bash
# Acessar container da aplicação
docker-compose exec app bash

# Executar comandos Artisan
docker-compose exec app php artisan migrate
docker-compose exec app php artisan tinker
docker-compose exec app php artisan queue:work

# Instalar dependências
docker-compose exec app composer install
docker-compose exec app npm install

# Build de assets
docker-compose exec app npm run build
```

### Banco de Dados
```bash
# Acessar MySQL
docker-compose exec db mysql -u wave_user -p wave_db

# Backup do banco
docker-compose exec db mysqldump -u wave_user -p wave_db > backup.sql

# Restaurar backup
docker-compose exec -T db mysql -u wave_user -p wave_db < backup.sql
```

## 🔧 Configurações

### PHP
- Arquivo de configuração: `docker/php/local.ini`
- Extensões instaladas: pdo_mysql, mbstring, exif, pcntl, bcmath, gd, zip

### Nginx
- Arquivo de configuração: `docker/nginx/conf.d/app.conf`
- Otimizações para Laravel
- Cache de assets estáticos

### MySQL
- Arquivo de configuração: `docker/mysql/my.cnf`
- Logs habilitados para debug

## 🐛 Troubleshooting

### Problemas Comuns

#### 1. Porta 80 já em uso
```bash
# Verificar o que está usando a porta 80
sudo lsof -i :80

# Ou alterar a porta no docker-compose.yml
ports:
  - "8080:80"  # Usar porta 8080
```

#### 2. Permissões de arquivos
```bash
# Corrigir permissões
docker-compose exec app chown -R laravel:www-data /var/www
docker-compose exec app chmod -R 755 /var/www/storage
```

#### 3. Banco de dados não conecta
```bash
# Verificar se o MySQL está rodando
docker-compose logs db

# Aguardar mais tempo para inicialização
sleep 60
```

#### 4. Assets não carregam
```bash
# Rebuild dos assets
docker-compose exec app npm run build

# Verificar se o storage link existe
docker-compose exec app php artisan storage:link
```

## 📝 Notas

- Os dados do MySQL são persistidos no volume `dbdata`
- Os dados do Redis são persistidos no volume `redisdata`
- O arquivo `.env` é copiado do `env.docker` durante o setup
- Todos os serviços estão na rede `wave-network`

## 🔄 Atualizações

Para atualizar a aplicação:

```bash
# Parar containers
docker-compose down

# Atualizar código
git pull

# Reconstruir e iniciar
docker-compose build --no-cache
docker-compose up -d

# Executar migrações
docker-compose exec app php artisan migrate --force
```
