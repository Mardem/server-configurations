#!/bin/bash

# Cores e funções
c_reset="\e[0m" # Reseta a cor
c_invert="\e[7m" # Inverte a cor

c_branco="\e[39m"
c_vermelho="\e[91m"
c_verde_claro="\e[92m"
c_verde="\e[32m"
c_azul="\e[34m"
c_ciano="\e[36m"

# --------------- 1ª etapa - Objetivo: Baixar os arquivos do Gitlab ou Github e colocar numa pasta chamada "laravel-app" ---------------

echo -e "$c_vermelho###################### Configuração de servidor Digital Ocean ###################### $c_branco"
echo -e "$c_invert$c_vermelho Será levado em consideração que seu banco de dados está configurado internamente no Laravel, esse script não faz configuração de banco de dados interno. Por favor, use outro script.$c_reset \n"
echo -e "Digite abaixo o link$c_verde HTTPS$c_branco do repositório do$c_vermelho Gitlab/Github$c_ciano:"
# Prepara para entrada de dados e armazena em uma variável
read link;

echo -e "$c_ciano$c_invert Digite o nome da aplicação:$c_reset"
read name_app;

# Procura um programa git no sitema
programGit=$(command -v git)

# Verifica se existe, se existir baixa o repositório. Senão, baixa o Git e baixa o repositório
if [ ! -z "$programGit" ]; then
    # Clona o repositório
    git clone $link laravel-app
else
    # Baixa Git e executa o download do repositório
    echo -e "Aguarde enquanto é feito o download o do$c_vermelho Git no servidor..."

    # Baixa o Git no servidor
    sudo apt get install git

    # Clona o repositório
    git clone $link laravel-app
fi

# --------------- 2ª etapa - Objetivo: Realizar instalação das depedências do projeto e dar permissões ---------------
# Entra na pasta
cd ~/laravel-app
# Instala as dependências usando o composer do docker
docker run --rm -v $(pwd):/app composer install

# Adição de permissões de usuário e também arquivos
sudo chown -R $USER:$USER ~/laravel-app

# --------------- 3ª etapa - Objetivo: Baixar o arquivo Docker Compose e Dockerfile ---------------
# Download do Dockerfile
echo -e "$c_invert$c_verde Baixando arquivo Dockerfile $c_reset"
wget https://raw.githubusercontent.com/Mardem/server-configurations/master/Dockerfile

# Download do Docker Compose
echo -e "$c_invert$c_verde_claro Baixando arquivo Docker Compose $c_reset"
wget https://raw.githubusercontent.com/Mardem/server-configurations/master/docker-compose.yml

# --------------- 4ª etapa - Objetivo: Configurar o PHP corretamente ---------------

php_ini_content="upload_max_filesize=40M \npost_max_size=40M" # Variável de conteúdo do arquivo .ini

# Faz com que crie a pasta PHP e também os antecessores (se não existir)
mkdir laravel-app/php -p

# Cria o arquivo de configuração e escreve o conteúdo dentro do mesmo
touch laravel-app/php/local.ini && echo -e $php_ini_content >> laravel-app/php/local.ini

# --------------- 5ª etapa - Objetivo: Configurar o Nginx corretamente ---------------

# Faz com que crie a pasta Nginx e também os antecessores (se não existir)  e faz o download do arquivo de configuração do Nginx
wget https://raw.githubusercontent.com/Mardem/server-configurations/development/app.conf -P laravel-app/nginx/conf.d --tries=3

# --------------- 6ª etapa - Objetivo: Subir os containers e configurar o .env ---------------

# Baixa o .env do repositório
wget https://raw.githubusercontent.com/Mardem/server-configurations/development/.env --tries=3

# Variável que armazena o caminho do arquivo
FILE=".env"
# Escreve informações no arquivo .env usando o heredoc
/bin/cat >> $FILE <<EOL

APP_NAME="$name_app"
APP_DEBUG=false
EOL

# Sobe os containers
docker-compose up -d

# --------------- 7ª etapa - Objetivo: Finalizar a instalação do Laravel ---------------
echo -e "$c_azul$c_invert Finalizando instalação"
sudo chmod -R 777 ~/laravel-app/storage/** ~/laravel-app/bootstrap/** ~/laravel-app/vendor/**
docker-compose exec app php artisan key:generate