FROM php:8.2-fpm

# Argumentos para configuração
ARG user=laravel
ARG uid=1000

# Instalar dependências do sistema
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libicu-dev \
    zip \
    unzip \
    supervisor \
    cron \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip intl

# Instalar extensão Redis PHP
RUN pecl install redis && docker-php-ext-enable redis

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Criar usuário do sistema para executar comandos Composer e Artisan
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

# Definir diretório de trabalho
WORKDIR /var/www

# Copiar arquivos do projeto
COPY . /var/www

# Criar diretórios necessários e definir permissões
RUN mkdir -p /var/www/bootstrap/cache /var/www/storage/logs /var/www/storage/framework/cache /var/www/storage/framework/sessions /var/www/storage/framework/views
RUN chown -R $user:$user /var/www
RUN chmod -R 755 /var/www/storage
RUN chmod -R 755 /var/www/bootstrap/cache

# Instalar dependências do Composer
RUN composer install --no-dev --optimize-autoloader

# Instalar dependências do Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
RUN apt-get install -y nodejs
RUN npm install
RUN npm run build

# Definir permissões corretas
RUN chown -R $user:$user /var/www
RUN chmod -R 755 /var/www/storage
RUN chmod -R 755 /var/www/bootstrap/cache

# Expor porta 9000 para PHP-FPM
EXPOSE 9000

# Comando padrão
CMD ["php-fpm"]
