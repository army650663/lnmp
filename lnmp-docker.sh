#!/bin/bash

# git remote add origin git@github.com:khs1994-docker/lnmp.git
# git remote add aliyun git@code.aliyun.com:khs1994-docker/lnmp.git
# git remote add tgit git@git.qcloud.com:khs1994-docker/lnmp.git
# git remote add coding git@git.coding.net:khs1994/lnmp.git

# Don't Run this shell script on git bash Windows, please use ./lnmp-docker.ps1

#
# sudo ? only need by install docker-compose
#

set -e

if [ `uname -s` != 'Darwin' ] && [ `uname -s` != 'Linux' ];then echo -e "\n\033[31mError \033[0m  Please use ./lnmp-docker.ps1 on PowerShell in Windows"; exit 1; fi

print_info(){
  echo -e "\033[32mINFO \033[0m  $@"
}

print_error(){
  echo -e "\033[31mERROR\033[0m  $@"
}

print_warning(){
  echo -e "\033[33mWARNING\033[0m  $@"
}

NOTSUPPORT(){
  print_error "Not Support ${OS} ${ARCH}\n"
  exit 1
}

if [ -f cli/khs1994-robot.enc ];then
    print_info "Use LNMP CLI in LNMP Root $PWD\n"
else
    if ! [ -z "${LNMP_PATH}" ];then
      # 存在环境变量，进入
      print_info "Use LNMP CLI in $PWD\n"
      cd ${LNMP_PATH}
    else
      print_error  "在任意目录使用 LNMP CLI 必须设置环境变量，cli/README.md"
      exit 1
    fi
fi

# PHPer command

if [ -z "$LNMP_PATH" ];then print_warning "Try lnmp-* commands? Please see cli/README.md\n"; fi

help(){
  echo  -e "
Docker-LNMP CLI ${KHS1994_LNMP_DOCKER_VERSION}

Official WebSite https://lnmp.khs1994.com

Usage: ./docker-lnmp.sh COMMAND

Commands:
  acme.sh              Run original acme.sh command to issue SSL certificate
  backup               Backup MySQL databases
  build                Build or rebuild LNMP Self Build images (Only Support x86_64)
  build-config         Validate and view the LNMP Self Build images Compose file
  build-push           Build and Pushes images to Docker Registory
  build-up             Create and start LNMP containers With Self Build images (Only Support x86_64)
  cleanup              Cleanup log files
  compose              Install docker-compose
  development          Use LNMP in Development
  development-config   Validate and view the Development Compose file
  development-pull     Pull LNMP Docker Images in development
  daemon-socket        Expose Docker daemon on tcp://0.0.0.0:2375 without TLS on macOS
  down                 Stop and remove LNMP Docker containers, networks
  docs                 Read support documents
  help                 Display this help message
  init                 Init LNMP environment
  restore              Restore MySQL databases
  restart              Restart LNMP services
  registry             Start Docker Registry
  registry-down        Stop Docker Registry
  update               Upgrades LNMP
  upgrade              Upgrades LNMP
  update-version       Update LNMP soft to latest vesion

PHP Tools:
  httpd-config         Generate Apache2 vhost conf
  new                  New PHP Project and generate nginx conf and issue SSL certificate
  nginx-config         Generate nginx vhost conf
  ssl                  Issue SSL certificate powered by acme.sh, Thanks Let's Encrypt
  ssl-self             Issue Self-signed SSL certificate
  tp                   Create a new ThinkPHP application

Kubernets:
  dashboard            Print how run kubernetes dashboard in Dcoekr for Desktop

Swarm mode:
  swarm-build          Build Swarm mode LNMP images (nginx php7)
  swarm-config         Validate and view the Swarm mode Compose file
  swarm-deploy         Deploy LNMP stack IN Swarm mode
  swarm-down           Remove LNMP stack IN Swarm mode
  swarm-ps             List the LNMP tasks
  swarm-pull           Pull LNMP Docker Images IN Swarm mode
  swarm-push           Push Swarm mode LNMP images (nginx php7)
  swarm-update         Print update LNMP service example

ClusterKit
  clusterkit [-d]              UP LNMP With Mysql Redis Memcached Cluster [Background]
  clusterkit-COMMAND           Run docker-compsoe commands(config, pull, etc)

  swarm-clusterkit             UP LNMP With Mysql Redis Memcached Cluster IN Swarm mode

  clusterkit-mysql-up          Up MySQL Cluster
  clusterkit-mysql-down        Stop MySQL Cluster
  clusterkit-mysql-exec        Execute a command in a running MySQL Cluster node

  clusterkit-mysql-deploy      Deploy MySQL Cluster in Swarm mode
  clusterkit-mysql-remove      Remove MySQL Cluster in Swarm mode

  clusterkit-memcached-up      Up memcached Cluster
  clusterkit-memcached-down    Stop memcached Cluster
  clusterkit-memcached-exec    Execute a command in a running memcached Cluster node

  clusterkit-memcached-deploy  Deploy memcached Cluster in Swarm mode
  clusterkit-memcached-remove  Remove memcached Cluster in Swarm mode

  clusterkit-redis-up          Up Redis Cluster
  clusterkit-redis-down        Stop Redis Cluster
  clusterkit-redis-exec        Execute a command in a running Redis Cluster node

  clusterkit-redis-deploy      Deploy Redis Cluster in Swarm mode
  clusterkit-redis-remove      Remove Redis Cluster in Swarm mode

  clusterkit-redis-master-slave-up       Up Redis M-S
  clusterkit-redis-master-slave-down     Stop Redis M-S
  clusterkit-redis-master-slave-exec     Execute a command in a running Redis M-S node

  clusterkit-redis-master-slave-deploy   Deploy Redis M-S in Swarm mode
  clusterkit-redis-master-slave-remove   Remove Redis M-S in Swarm mode

  clusterkit-redis-sentinel-up           Up Redis S
  clusterkit-redis-sentinel-down         Stop Redis S
  clusterkit-redis-sentinel-exec         Execute a command in a running Redis S node

  clusterkit-redis-sentinel-deploy       Deploy Redis S in Swarm mode
  clusterkit-redis-sentinel-remove       Remove Redis S in Swarm mode

Container CLI:
  SERVICE-cli          Execute a command in a running LNMP container

LogKit:
  SERVICE-logs         Print LNMP containers logs (journald)

Developer Tools:
  commit               Commit LNMP to Git
  cn-mirror            Push master branch to CN mirror
  reset-master         Reset master branch in dev branch
  test                 Test LNMP

Read './docs/*.md' for more information about CLI commands.

You can open issue in [ https://github.com/khs1994-docker/lnmp/issues ] when you meet problems.

You must Update .env file when update this project.

Donate https://zan.khs1994.com
"
}

_registry(){

  # SSL 相关

  if [ ! -f config/${NGINX_CONF_D:-nginx}/ssl/${KHS1994_LNMP_REGISTRY_HOST}.crt ] || [ ! -f config/${NGINX_CONF_D:-nginx}/ssl/${KHS1994_LNMP_REGISTRY_HOST}.key ];then
    print_warning "Docker Registry SSL not found, generating ...."
    ssl_self $KHS1994_LNMP_REGISTRY_HOST
  fi

  if [ ! -f config/${NGINX_CONF_D:-nginx}/ssl/${KHS1994_LNMP_REGISTRY_HOST}.crt ] || [ ! -f config/${NGINX_CONF_D:-nginx}/ssl/${KHS1994_LNMP_REGISTRY_HOST}.key ];then
    print_error "Docker Registry SSL error"
    exit 1
  else
    print_info "Docker Registry SSL Correct"
  fi

  # 生成 密码 验证文件

  if ! [ -f config/${NGINX_CONF_D:-nginx}/auth/docker_registry.htpasswd ];then
    echo; print_info "First start, Please set username and password"
    read -p "username: " username
    if [ -z $username ];then echo; print_error "用户名不能为空"; exit 1; fi
    read -s -p "password: " password; echo
    if [ -z $password ];then echo; print_error "密码不能为空"; exit 1; fi
    read -s -p "Please reinput password: " password_verify; echo; echo

    if ! [ "$password" = "$password_verify" ];then
      print_error "两次输入的密码不同，请再次执行 ./lnmp-docker.sh registry 完成操作"; exit 1
    fi

    docker run --init --rm \
      --entrypoint htpasswd \
      registry \
      -Bbn $username $password > config/${NGINX_CONF_D:-nginx}/auth/docker_registry.htpasswd
      # 部分 nginx 可能不能解密，你可以替换为下面的命令
      # -mbn username password > auth/nginx.htpasswd \
  fi

  # NGINX 配置文件

  if ! [ -f config/${NGINX_CONF_D:-nginx}/${REGISTRY_CONF:-registry.conf} ];then
    if [ -f config/${NGINX_CONF_D:-nginx}/registry.conf.backup ];then
      cp config/${NGINX_CONF_D:-nginx}/registry.conf.backup config/${NGINX_CONF_D:-nginx}/registry.conf
    else
      cp config/${NGINX_CONF_D:-nginx}/demo-registry.config config/${NGINX_CONF_D:-nginx}/registry.conf
    fi
  fi

  sed -i '' "s#KHS1994_DOMAIN#${KHS1994_LNMP_REGISTRY_HOST}#g" config/${NGINX_CONF_D:-nginx}/registry.conf

  exec docker-compose up -d registry nginx
}

_registry_down(){
  docker-compose stop registry
  docker-compose rm -f registry
  mv config/${NGINX_CONF_D:-nginx}/registry.conf config/${NGINX_CONF_D:-nginx}/registry.conf.backup
}

env_status(){
  # cp .env.example to .env
  if [ -f .env ];then print_info ".env file existing\n"; else print_warning ".env file NOT existing (Maybe First Run)\n"; cp .env.example .env ; fi
}

# 自动升级软件版本

update_version(){
  . .env.example

  local softs='PHP \
              NGINX \
              HTTPD \
              MYSQL \
              MARIADB \
              REDIS \
              MEMCACHED \
              RABBITMQ \
              POSTGRESQL \
              MONGODB \
              '
  for soft in $softs; do
    version="KHS1994_LNMP_${soft}_VERSION"
    eval version=$(echo \$$version)
    if [ $OS = "Darwin" ];then
      sed -i '' 's/^KHS1994_LNMP_'"${soft}"'_VERSION.*/KHS1994_LNMP_'"${soft}"'_VERSION='"${version}"'/g' .env
    else
      sed -i 's/^KHS1994_LNMP_'"${soft}"'_VERSION.*/KHS1994_LNMP_'"${soft}"'_VERSION='"${version}"'/g' .env
    fi
  done
}

# Docker 是否运行

run_docker(){
  docker info > /dev/null 2>&1 || (clear ; \
    echo "==========================" ;\
    echo "=== Please Run Docker ====" ;\
    echo "==========================" ;\
    exit 1)
}

# 创建日志文件

logs(){
  if ! [ -d logs/httpd ];then mkdir -p logs/httpd; fi

  if ! [ -d logs/mongodb ];then mkdir -p logs/mongodb && echo > logs/mongodb/mongo.log; fi

  if ! [ -d logs/mysql ];then mkdir -p logs/mysql && echo > logs/mysql/error.log; fi

  if ! [ -d logs/mariadb ];then mkdir -p logs/mariadb && echo > logs/mariadb/error.log; fi

  if ! [ -d logs/nginx ];then mkdir -p logs/nginx && echo > logs/nginx/error.log && echo > logs/nginx/access.log; fi

  if ! [ -d logs/php-fpm ];then
    mkdir -p logs/php-fpm && echo > logs/php-fpm/error.log \
      && echo > logs/php-fpm/access.log \
      && echo > logs/php-fpm/xdebug-remote.log
  fi

  if ! [ -d logs/redis ];then mkdir -p logs/redis && echo > logs/redis/redis.log ; fi
  chmod -R 777 logs/mongodb \
               logs/mysql \
               logs/nginx \
               logs/php-fpm \
               logs/redis || sudo chmod -R 777 logs/mongodb \
                                          logs/mysql \
                                          logs/nginx \
                                          logs/php-fpm \
                                          logs/redis
}

# 清理日志文件

cleanup(){
      logs \
      && echo > logs/mongodb/mongo.log \
      && echo > logs/mysql/error.log \
      && echo > logs/mariadb/error.log \
      && echo > logs/nginx/error.log \
      && echo > logs/nginx/access.log \
      && echo > logs/php-fpm/access.log \
      && echo > logs/php-fpm/error.log \
      && echo > logs/php-fpm/xdebug-remote.log \
      && echo > logs/redis/redis.log \
      && rm -rf logs/httpd/* \
      print_info "Clean log files SUCCESS\n"
}

gitbook(){
  docker rm -f lnmp-docs > /dev/null 2>&1 || echo
  exec docker run --init -it --rm \
    -p 4000:4000 \
    --name lnmp-docs \
    -v $PWD/docs:/srv/gitbook-src \
    khs1994/gitbook \
    server
}

# 将 compose 移入 PATH

install_docker_compose_move(){
  if [ -f /etc/os-release ];then
    . /etc/os-release
    case "$ID" in
      coreos )
        if ! [ -d /opt/bin ];then sudo mkdir -p /opt/bin; fi
        sudo install -m755 /tmp/docker-compose /opt/bin/docker-compose
        ;;
      * )
        sudo install -m755 /tmp/docker-compose /usr/local/bin/docker-compose || install -m755 /tmp/docker-compose /usr/local/bin/docker-compose
        ;;
    esac
  else
    NOTSUPPORT
  fi
}

# 从 GitHub 安装 compose

install_docker_compose_official(){
  if [ "$OS" != 'Linux' ];then exit 1;fi
  curl -L ${COMPOSE_LINK_OFFICIAL}/$LNMP_DOCKER_COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m` > /tmp/docker-compose
  install_docker_compose_move
}

# 安装 compose arm 版本

install_docker_compose_arm(){
  print_info "$OS $ARCH docker-compose v$LNMP_DOCKER_COMPOSE_VERSION is installing by pip3 ...\n"
  command -v pip3 >/dev/null 2>&1 || sudo apt install -y python3-pip
  if ! [ -d ~/.pip ];then
    mkdir -p ~/.pip; echo -e "[global]\nindex-url = https://pypi.douban.com/simple\n[list]\nformat=columns" > ~/.pip/pip.conf
  fi
  sudo pip3 install --upgrade docker-compose
}

install_docker_compose(){
  if ! [ "$OS" = 'Linux' ];then echo; print_error "Docker For Mac not Support install docker-compose"; exit 1; fi
  if [ "${ARCH}" = 'armv7l' ] || [ ${ARCH} = 'aarch64' ];then
    install_docker_compose_arm "$@"
  elif [ "$ARCH" = 'x86_64' ];then
    curl -L ${COMPOSE_LINK}/${LNMP_DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /tmp/docker-compose
    install_docker_compose_move
  fi
}

docker_compose(){
  command -v docker-compose >/dev/null 2>&1 || local a=1

  if ! [ "$a" = 1 ];then
    # 存在
    # 取得版本号
    DOCKER_COMPOSE_VERSION=`docker-compose --version | cut -d ' ' -f 3 | cut -d , -f 1`
    local x=`echo $DOCKER_COMPOSE_VERSION | cut -d . -f 1`
    local y=`echo $DOCKER_COMPOSE_VERSION | cut -d . -f 2`
    #local z=`echo $DOCKER_COMPOSE_VERSION | cut -d . -f 3`
    local true_x=`echo $LNMP_DOCKER_COMPOSE_VERSION | cut -d . -f 1`
    local true_y=`echo $LNMP_DOCKER_COMPOSE_VERSION | cut -d . -f 2`
    #local true_z=`echo $LNMP_DOCKER_COMPOSE_VERSION | cut -d . -f 3`
    if [ "$x" != "$true_x" ];then exit 1; fi
    # 判断是否安装正确
    # -lt 小于
    if [ "$y" -lt "$true_y" ];then
      # 安装不正确
      if [ "$1" = '--official' ];then shift; print_info "Install compose from GitHub"; install_docker_compose_official "$@"; return 0; fi
      if [ "$1" = '-f' ];then install_docker_compose -f; return 0; fi
      # 判断 OS
      if [ "$OS" = 'Darwin' ] ;then
        print_error "docker-compose v$DOCKER_COMPOSE_VERSION NOT installed Correct version, You MUST update Docker for Mac Edge Version\n"
      elif [ "$OS" = 'Linux' ];then
        print_error "docker-compose v$DOCKER_COMPOSE_VERSION NOT installed Correct version, You MUST EXEC $ ./lnmp-docker.sh compose -f\n"
      elif [ "$OS" = 'MINGW64_NT-10.0' ];then
        print_error "docker-compose v$DOCKER_COMPOSE_VERSION NOT installed Correct version, You MUST update Docker for Windows Edge Version\n"
      else
        NOTSUPPORT
      fi
    # 安装正确
    else
      print_info "docker-compose v$DOCKER_COMPOSE_VERSION already installed Correct version\n"; return 0
    fi
  else
    # 不存在
    print_error "docker-compose NOT install, install...\n"
    if [[ "$1" = '--official' || "$2" = '--official' ]];then shift; print_info "Install compose from GitHub"; install_docker_compose_official "$@" && return 0; fi
    install_docker_compose
  fi
}

# 克隆示例项目、nginx 配置文件

demo() {
  if [ -d config/nginx/.git ] || [ -f config/nginx/.git ];then
    echo > /dev/null 2>&1
  else
    print_info "Import app and nginx conf Demo ...\n"
    # 检查网络连接
    ping -c 3 -i 0.2 -W 3 baidu.com > /dev/null 2>&1 || ( print_error "Network connection error" ;exit 1)
    echo ;print_info "Update Git Submodule\n"
    git submodule update --init --recursive
  fi
}

# 初始化

init() {
  case $APP_ENV in
    # 开发环境 拉取示例项目 [cn github]
    development )
      print_info "$APP_ENV\n"
      demo
      ;;

    # 生产环境 转移项目文件、配置文件、安装依赖包
    production )
      print_info "$APP_ENV\n"
      # 请在 ./scripts/production-init 定义要执行的操作
      scripts/production-init
      ;;
  esac
  # 初始化完成提示
  print_info "Init is SUCCESS\n"
}

# 备份数据库

backup(){
  docker-compose exec mysql /backup/backup.sh $@
}

# 恢复数据库

restore(){
  docker-compose exec mysql /backup/restore.sh $1
}

network(){
  ping -c 3 -W 3 baidu.com > /dev/null 2>&1 || ( print_error "Network connection error" ;exit 1)
}

# 更新项目

set_git_remote_origin_url(){
  network
  git remote get-url origin > /dev/null 2>&1 || local a=1
  if [ "$a" = 1 ];then
    # 不存在
    print_error "This git remote origin NOT set, seting...\n"
    git remote add origin git@github.com:khs1994-docker/lnmp.git
    # 不能使用 SSH
    git fetch origin > /dev/null 2>&1 || git remote set-url origin https://github.com/khs1994-docker/lnmp
    print_info `git remote get-url origin`
    echo
  elif [ `git remote get-url origin` != 'git@github.com:khs1994-docker/lnmp.git' ] && [ `git remote get-url origin` != 'https://github.com/khs1994-docker/lnmp' ];then
    # 存在但是设置错误
    print_error "This git remote origin NOT set Correct, reseting...\n"
    git remote rm origin
    git remote add origin git@github.com:khs1994-docker/lnmp.git
    # 不能使用 SSH
    git fetch origin > /dev/null 2>&1 || git remote set-url origin https://github.com/khs1994-docker/lnmp
    print_info `git remote get-url origin`
  fi
}

update(){
  if ! [ -d .git ];then git init > /dev/null 2>&1; BRANCH=master; fi

  set_git_remote_origin_url

  for force in "$@"
  do
    if [ "$force" = '-f' ];then force='true'; fi
  done

  GIT_STATUS=`git status -s --ignore-submodules`
  if [ ! -z "${GIT_STATUS}" ] && [ ! "$force" = 'true' ];then
     git status -s --ignore-submodules
     echo; print_error "Please commit then update"
     exit 1
  fi
  git fetch origin
  print_info "Branch is ${BRANCH}\n"
  if [ "${BRANCH}" = 'dev' ] || [ "${BRANCH}" = 'master' ];then
    git reset --hard origin/${BRANCH}
    echo ;print_info "Update Git Submodule\n"
    git submodule update --init --recursive
  else
    print_error "${BRANCH} error，Please checkout to dev or master branch\n\n$ git checkout dev\n "
  fi
  command -v bash > /dev/null 2>&1 || sed -i 's!^#\!/bin/bash.*!#\!/bin/sh!g' lnmp-docker.sh
}

# 提交项目「开发者选项」

commit(){
  # 检查网络连接
  network
  print_info `git remote get-url origin` ${BRANCH}
  if [ ${BRANCH} = 'dev' ];then
    git add .
    git commit -m "Update [skip ci]"
    git push origin dev
  else
    print_error "${BRANCH} error\n"
  fi
}

reset-master(){
  set_git_remote_origin_url
  print_info "Branch is ${BRANCH}\n"
  print_info "Reset master branch in dev branch\n"
  if [ ${BRANCH} = 'dev' ];then
    git fetch origin
    git reset --hard origin/master
    echo ;print_info "Update Git Submodule\n"
    git submodule update --init --recursive
  elif [ ${BRANCH} = 'master' ];then
    print_error "${BRANCH} branch，Please exec ./lnmp-docker.sh update [-f]"
  else
    print_error "${BRANCH} error，Please checkout to  dev branch\n\n$ git checkout dev\n"
  fi
}

cn_mirror(){
  set_git_remote_origin_url
  git fetch origin
  git push -f aliyun remotes/origin/dev:dev
  git push -f aliyun remotes/origin/master:master
  git push -f aliyun --tags
  git push -f tgit remotes/origin/dev:dev
  git push -f tgit remotes/origin/master:master
  git push -f tgit --tags
  git push -f coding remotes/origin/dev:dev
  git push -f coding remotes/origin/master:master
  git push -f coding --tags
}

nginx_http(){

  echo "#
# Generate nginx config By khs1994-docker/lnmp
#

server {
  listen        80;
  server_name   $1;
  root          /app/$2;
  index         index.html index.htm index.php;

  location / {
    try_files \$uri \$uri/ /index.php?\$query_string;
  }

  location ~ .*\.php(\/.*)*$ {
    fastcgi_pass   php7:9000;
    include        fastcgi.conf;
  }
}" > config/${NGINX_CONF_D:-nginx}/$1.conf

}

apache_http(){
  echo "#
# Generate Apache2 connfig By khs1994-docker/lnmp
#

<VirtualHost *:80>
  DocumentRoot \"/app/$2\"
  ServerName $1
  ServerAlias $1

  ErrorLog \"logs/$1.error.log\"
  CustomLog \"logs/$1.access.log\" common

  <FilesMatch \.php$>
    SetHandler \"proxy:fcgi://php7:9000\"
  </FilesMatch>

  <Directory \"/app/$2\" >
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
  </Directory>

</VirtualHost>" >> config/${HTTPD_CONF_D:-httpd}/$1.conf
}

apache_https(){
  echo "#
# Generate Apache2 HTTPS config By khs1994-docker/lnmp
#

<VirtualHost *:443>
  DocumentRoot \"/app/$2\"
  ServerName $1
  ServerAlias $1

  ErrorLog \"logs/$1.error.log\"
  CustomLog \"logs/$1.access.log\" common

  SSLEngine on
  SSLCertificateFile conf/ssl/$1.crt
  SSLCertificateKeyFile conf/ssl/$1.key

  # HSTS (mod_headers is required) (15768000 seconds = 6 months)
  Header always set Strict-Transport-Security \"max-age=15768000\"

  <FilesMatch \.php$>
    SetHandler \"proxy:fcgi://php7:9000\"
  </FilesMatch>

  <Directory \"/app/$2\" >
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
  </Directory>

</VirtualHost>" >> config/${HTTPD_CONF_D:-httpd}/$1.conf
}

nginx_https(){

  echo "#
# Generate nginx HTTPS config By khs1994-docker/lnmp
#

server {
  listen                    80;
  server_name               $1;
  return 301                https://\$host\$request_uri;
}

server{
  listen                     443 ssl http2;
  server_name                $1;
  root                       /app/$2;
  index                      index.html index.htm index.php;

  ssl_certificate            conf.d/ssl/$1.crt;
  ssl_certificate_key        conf.d/ssl/$1.key;

  ssl_session_cache          shared:SSL:1m;
  ssl_session_timeout        5m;
  ssl_protocols              TLSv1.2 TLSv1.3;
  ssl_ciphers                'ECDHE-RSA-AES128-GCM-SHA256:HIGH:!aNULL:!MD5';
  ssl_prefer_server_ciphers  on;

  ssl_stapling               on;
  ssl_stapling_verify        on;

  location / {
    try_files \$uri \$uri/ /index.php?\$query_string;
  }

  location ~ .*\.php(\/.*)*$ {
    fastcgi_pass   php7:9000;
    include        fastcgi.conf;
  }
}" > config/${NGINX_CONF_D:-nginx}/$1.conf

}

# 申请 ssl 证书

acme(){
  exec docker run --init -it --rm \
         -v $PWD/config/${NGINX_CONF_D:-nginx}/ssl:/ssl \
         --mount source=lnmp_ssl-data,target=/acme.sh \
         --env-file .env \
         khs1994/acme:${ACME_VERSION} acme.sh "$@"
}

ssl(){
  if [ -z "$1" ];then
    exec echo "command example

$ ./lnmp-docker.sh ssl khs1994.com [--rsa] [--httpd] [--debug] [acme other parameters]

通配符证书

$ ./lnmp-docker.sh ssl khs1994.com -d *.khs1994.com -d t.khs1994.com -d *.t.khs1994.com

RSA 证书（默认 ECC 证书）

$ ./lnmp-docker.sh ssl khs1994.com -d *.khs1994.com --rsa [--httpd] [--debug] [acme other parameters]

HTTPD server

$ ./lnmp-docker.sh ssl khs1994.com -d *.khs1994.com --httpd [--rsa] [--debug] [acme other parameters]

ACME.sh help

$ ./lnmp-docker.sh acme.sh
"
  fi

  for httpd in "$@"
  do
    if [ "${httpd}" = '--httpd' ];then
      HTTPD=1
    fi
    if [ "${httpd}" = '--rsa' ];then
      RSA=1
    fi
  done

  command="$@"
  command=${command[@]//'--rsa'/}
  command=${command[@]//'--httpd'/}

  exec docker run --init -it --rm \
         -v $PWD/config/$(if [ "$HTTPD" = 1 ];then echo ${HTTPD_CONF_D:-httpd}; else echo ${NGINX_CONF_D:-nginx}; fi)/ssl:/ssl \
         --mount source=lnmp_ssl-data,target=/acme.sh \
         --env-file .env \
         -e HTTPD=${HTTPD:-0} \
         -e RSA=${RSA:-0} \
         khs1994/acme:${ACME_VERSION} "$command"
}

ssl_self(){
  docker run --init -it --rm -v $PWD/config/${NGINX_CONF_D:-nginx}/ssl:/ssl khs1994/tls "$@"
}

# 快捷开始 PHP 项目开发

start(){
  for arg in "$@"
  do
    if [ $arg = '-f' ];then rm -rf app/$1; fi
  done

  if [ -z "$1" ];then read -p "Please input project name: /app/" name; else name=$1; fi

  if [ -z "$name" ];then echo; print_error 'Please input content'; exit 1; fi

  if [ -d app/$name ];then print_error "This folder existing"; exit 1; fi

  if [ -z "$2" -o "$2" = '-f' ];then read -p "Please input domain:「example http[s]://$name.domain.com 」" input_url; else input_url=$2; fi

  if [ -z "$input_url" ]; then echo; print_error 'Please input content'; exit 1; fi

  protocol=$(echo $input_url | awk -F':' '{print $1}')

  url=$(echo $input_url | awk -F'[/:]' '{print $4}')

  if [ -z $url ];then url=$input_url; protocol=http; fi

  echo; print_info "PROTOCOL IS $protocol\n"

  print_info "URL IS $url"

  if [ $protocol = 'https' ];then
    # 申请 ssl 证书
    read -n 1 -t 5 -p "如果要申请自签名证书请输入 y Self-Signed SSL certificate? [y/N]:" self_signed
    if [ "$self_signed" = 'y' ];then
      ssl_self $url
    else
      ssl $url
    fi
    # 生成 nginx 配置文件
    nginx_https $url $name
  else
    nginx_http $url $name
  fi

  mkdir -p app/$name

  print_info "Now you can start PHP project in /app/$name"
  print_info "Please set hosts in /etc/hosts in development"
}

#
# $1 compose name
# $2 Swarm mode name
# $3 bash or sh
#

bash_cli(){
  run_docker
  docker exec -it \
      $( docker container ls \
          --format "{{.ID}}" \
          -f label=${LNMP_DOMAIN:-com.khs1994.lnmp} \
          -f label=com.docker.compose.service=$1 -n 1 ) \
          $2 2> /dev/null || \
      docker exec -it \
      $( docker container ls \
          --format "{{.ID}}" \
          -f label=${LNMP_DOMAIN:-com.khs1994.lnmp} \
          -f label=com.docker.swarm.service.name=${COMPOSE_PROJECT_NAME:-lnmp}_$1 -n 1 ) $2
  exit $?
}

clusterkit_bash_cli(){
  docker exec -it \
    $( docker container ls \
        --format "{{.ID}}" \
        --filter \
        label=${LNMP_DOMAIN:-com.khs1994.lnmp} \
        --filter label=${LNMP_DOMAIN:-com.khs1994.lnmp}.app.env=$1 \
        --filter label=com.docker.compose.service=$2 -n 1 ) $3 2> /dev/null || \
  docker exec -it \
    $( docker container ls \
        --format "{{.ID}}" \
        --filter \
        label=${LNMP_DOMAIN:-com.khs1994.lnmp} \
        --filter label=${LNMP_DOMAIN:-com.khs1994.lnmp}.app.env=$1 \
        --filter label=com.docker.swarm.service.name=${COMPOSE_PROJECT_NAME:-lnmp}_$2 -n 1 ) $3

  exit $?
}

# 入口文件

main() {
  logs
  local command=$1; shift
  case $command in
  acme.sh )
    run_docker; acme "$@"
    ;;

  init )
    init
    ;;

  backup )
    run_docker; backup "$@"
    ;;

  development-config )
    exec docker-compose config
    ;;

  demo )
    demo
    ;;

  cleanup )
    cleanup
    ;;

  test )
    run_docker; cli/test
    ;;

  commit )
    commit
    ;;

  reset-master )
    reset-master
    ;;

  registry )
    _registry
    ;;

  registry-down )
    _registry_down
    ;;

  swarm-config )
    init; exec docker-compose -f ${PRODUCTION_COMPOSE_FILE} config
    ;;

  swarm-pull )
    run_docker
    # 仅允许运行在 Linux x86_64
    if [ "$OS" = 'Linux' ] && [ ${ARCH} = 'x86_64' ];then
      init; sleep 2; exec docker-compose -f ${PRODUCTION_COMPOSE_FILE} pull "$@"
    else
      print_error "Production NOT Support ${OS} ${ARCH}\n"
    fi
    ;;

  swarm-build )
    docker-compose -f ${PRODUCTION_COMPOSE_FILE} build "$@"
    ;;

  swarm-push )
    docker-compose -f ${PRODUCTION_COMPOSE_FILE} push "$@"
    ;;

  swarm-deploy )
    if [ "$OS" = 'Linux' ] && [ ${ARCH} = 'x86_64' ];then
      run_docker
      docker stack deploy -c ${PRODUCTION_COMPOSE_FILE} lnmp

      sleep 2; docker stack ps lnmp

    else
      print_error "Production NOT Support ${OS} ${ARCH}\n"
    fi
    ;;

  swarm-down )
    docker stack rm lnmp
    ;;

  swarm-ps )
    docker stack ps lnmp
    ;;

  swarm-update )
  echo -e "
Example:


$ docker config create nginx_khs1994_com_conf_v2 config/${NGINX_CONF_D:-nginx}/khs1994.com.conf

$ docker service update \\
    --config-rm nginx_khs1994_com_conf \\
    --config-add source=nginx_khs1994_com_conf_v2,target=/etc/nginx/conf.d/khs1994.com.conf \\
    lnmp_nginx

$ docker secret create khs1994_com_ssl_crt_v2 config/${NGINX_CONF_D:-nginx}/ssl/khs1994.com.crt

$ docker service update \\
    --secret-rm khs1994_com_ssl_crt \\
    --secret-add source=khs1994_com_ssl_crt_v2,target=/etc/nginx/conf.d/ssl/khs1994.com.crt \\
    lnmp_nginx

$ docker service update --image nginx:1.13.10 lnmp_nginx

For information please run $ docker service update --help
"
  ;;

  build )
    run_docker
    init

    if [ ${ARCH} = 'x86_64' ];then
      exec docker-compose -f docker-compose.yml -f docker-compose.build.yml build "$@"
    else
      NOTSUPPORT
    fi

    ;;

  build-up )
    run_docker
    init

    if [ ${ARCH} = 'x86_64' ];then
      exec docker-compose -f docker-compose.yml -f docker-compose.build.yml up -d "$@"
    else
      NOTSUPPORT
    fi

    ;;

  development )
    run_docker
    init
    # 判断架构
    if [ "$1" != '--systemd' ];then opt='-d'; else opt= ;fi
    if [ ${ARCH} = 'x86_64' ];then
      docker-compose up $opt ${DEVELOPMENT_INCLUDE}
      echo; sleep 1; print_info "Test nginx configuration file...\n"
      docker exec -it $(docker container ls --format {{.ID}} -f label=${LNMP_DOMAIN:-com.khs1994.lnmp} -f label=com.docker.compose.service=nginx -n 1 ) nginx -t
    elif [ ${ARCH} = 'armv7l' -o ${ARCH} = 'aarch64' ];then
      docker-compose -f docker-arm.yml up $opt ${DEVELOPMENT_INCLUDE}
      echo; sleep 1; print_info "Test nginx configuration file...\n"
      docker-compose -f docker-arm.yml exec nginx nginx -t || \
        (print_error "nginx configuration file test failed, You must check nginx configuration file!"; exit 1)

      echo; print_info "nginx configuration file test is successful\n" ; exit 0
    else
      NOTSUPPORT
    fi
    ;;

  build-config )
    init; if [ ${ARCH} = 'x86_64' ];then exec docker-compose -f docker-compose.yml -f docker-compose.build.yml config; else NOTSUPPORT; fi
    ;;

  restore )
    run_docker; restore "$@"
    ;;

  update|upgrade )
    update "$@"
    ;;

  nginx-config )
     if [ -z "$3" ];then print_error "$ ./lnmp-docker.sh nginx-config {https|http} {PATH} {URL}"; exit 1; fi
     print_info 'Please set hosts in /etc/hosts in development\n'
     print_info 'Maybe you need generate nginx HTTPS conf in website https://khs1994-website.github.io/server-side-tls/ssl-config-generator/'
     if [ "$1" = 'http' ];then shift; nginx_http $2 $1; fi
     if [ "$1" = 'https' ];then shift; nginx_https $2 $1; fi
     echo
     print_info "You must checkout ./config/${NGINX_CONF_D:-nginx}/$2.conf, then restart nginx"
     ;;

  httpd-config )
    if [ -z "$3" ];then print_error "$ ./lnmp-docker.sh apache-config {https|http} {PATH} {URL}"; exit 1; fi
    print_info 'Please set hosts in /etc/hosts in development\n'
    print_info 'Maybe you need generate Apache2 HTTPS conf in website https://khs1994-website.github.io/server-side-tls/ssl-config-generator/'
    if [ "$1" = 'http' ];then shift; apache_http $2 $1; fi
    if [ "$1" = 'https' ];then shift; apache_https $2 $1; fi
    echo
    print_info "You must checkout ./config/${HTTPD_CONF_D:-httpd}/$2.conf, then restart httpd"
    ;;

  php-cli | php7-cli )
      bash_cli php7 bash
    ;;

  mongodb-cli | mongo-cli )
    bash_cli mongodb bash
    ;;

  mariadb-cli )
    bash_cli mariadb bash
    ;;

  mysql-cli )
    bash_cli mysql bash
    ;;

  *-cli )
    SERVICE=$(echo $command | cut -d '-' -f 1)
    run_docker;
    bash_cli $SERVICE sh
    ;;

  *-logs | *-log )

    if ! [ "${OS}" = 'Linux' ];then NOTSUPPORT; fi

    SERVICE=$(echo $command | cut -d '-' -f 1)
    journalctl -u docker.service CONTAINER_ID=$(docker container ls --format "{{.ID}}" -f label=${LNMP_DOMAIN:-com.khs1994.lnmp} -f label=com.docker.swarm.service.name=lnmp_${SERVICE} ) "$@"
    ;;

  build-push )
    run_docker; init; exec docker-compose -f docker-compose.build.yml build && docker-compose -f docker-compose.build.yml push
    ;;

  down )
    init; docker-compose down --remove-orphans
    ;;

  docs )
    run_docker; gitbook
    ;;

  development-pull )
    run_docker; init
    case "${ARCH}" in
        x86_64 )
          sleep 2; exec docker-compose pull ${DEVELOPMENT_INCLUDE}
          ;;
        aarch64 | armv7l )
          sleep 2; exec docker-compose -f docker-arm.yml pull ${DEVELOPMENT_INCLUDE}
          ;;
        * )
          NOTSUPPORT
          ;;
    esac
     ;;

  cn-mirror )
    cn_mirror
    ;;

  compose )
    docker_compose "$@"
    ;;

  new )
    start "$@"
    ;;

  ssl )
    run_docker; ssl "$@"
    ;;

  ssl-self )
    if [ -z "$1" ];then
      print_error '$ ./lnmp-docker.sh ssl-self {IP|DOMAIN}'
      echo -e "
Example:

$ ./lnmp-docker.sh ssl-self khs1994.com 127.0.0.1 192.168.199.100 localhost ...

$ ./lnmp-docker.sh ssl-self khs1994.com *.khs1994.com t.khs1994.com *.t.khs1994.com 127.0.0.1 192.168.199.100 localhost ...
"
    exit 1
    fi
    ssl_self "$@"
    echo; print_info 'Please set hosts in /etc/hosts'
    ;;

  tests )
    print_info "Test Shell Script"
    exec echo
    ;;

  version )
    echo Docker-LNMP ${KHS1994_LNMP_DOCKER_VERSION}
    ;;

  -h | --help | help )
   help
   ;;

  tp )
    run_docker
    if [ -z "$1" ];then
      print_error "$ ./lnmp-docker.sh tp {PATH} {CMD}"; exit 1
    else
      path="$1"
      shift
      cmd="$@"
    fi
    cd app
    ../bin/lnmp-composer create-project topthink/think=5.0.* ${path} --prefer-dist ${cmd}
    ;;

  restart )
    if [ -z "$1" ];then docker-compose down --remove-orphans; print_info "Please exec \n\n$ ./lnmp-docker.sh development | production\n"; exit 0; fi

    for soft in "$@"
    do
      if [ $soft = 'nginx' ];then opt='true'; fi
    done

    if [ "$opt" = 'true' ];then
      docker exec -it $(docker container ls --format {{.ID}} -f label=${LNMP_DOMAIN:-com.khs1994.lnmp} -f label=com.docker.compose.service=nginx -n 1 ) nginx -t || \
        (echo; print_error "nginx configuration file test failed, You must check nginx configuration file!"; exit 1)

      echo; print_info "nginx configuration file test is successful\n"
      exec docker-compose $command "$@"
    else
      print_info "You Exec docker-compose commands"; echo
      exec docker-compose $command "$@"
    fi
    ;;

 daemon-socket )
   if [ $OS != 'Darwin' ];then NOTSUPPORT; fi
   docker run -d --restart=always \
     -p 2375:2375 \
     -v /var/run/docker.sock:/var/run/docker.sock \
     -e PORT=2375 \
     shipyard/docker-proxy
     ;;

  clusterkit )
     docker-compose -f docker-compose.yml \
       -f docker-compose.override.yml \
       -f docker-cluster.mysql.yml \
       -f docker-cluster.redis.yml \
       up "$@"
     ;;

  clusterkit-mysql-up )
     docker-compose -f docker-cluster.mysql.yml up "$@"
     ;;

  clusterkit-mysql-down )
     docker-compose -f docker-cluster.mysql.yml down "$@"
     ;;

  clusterkit-mysql-exec )

  if [ "$#" -lt 2 ];then
     print_error '$ ./lnmp-docker.sh clusterkit-mysql-exec {master|node-N} {COMMAND}' ; exit 1
  fi

     NODE=$1
     shift
     COMMAND=$@

       clusterkit_bash_cli clusterkit_mysql mysql_$NODE ${COMMAND:-bash}
     ;;

  clusterkit-mysql-deploy )
       docker stack deploy -c docker-cluster.mysql.yml mysql_cluster
        ;;

  clusterkit-mysql-remove )
       docker stack rm mysql_cluster
        ;;

  clusterkit-memcached-up )
    docker-compose -f docker-cluster.memcached.yml up "$@"
    ;;

  clusterkit-memcached-down )
    docker-compose -f docker-cluster.memcached.yml down "$@"
    ;;

  clusterkit-memcached-exec )

  if [ "$#" -lt 2 ];then
     print_error '$ ./lnmp-docker.sh clusterkit-memcached-exec {N} {COMMAND}' ; exit 1
  fi

    NODE=$1
    shift
    COMMAND=$@

    clusterkit_bash_cli clusterkit_memcached memcached-$NODE ${COMMAND:-bash}
    ;;

  clusterkit-memcached-deploy )
    docker stack deploy -c docker-cluster.memcached.yml memcached_cluster
    ;;

  clusterkit-memcached-remove )
    docker stack rm memcached_cluster
    ;;

  clusterkit-redis-up )
        docker-compose -f docker-cluster.redis.yml up "$@"
        ;;

  clusterkit-redis-down )
        docker-compose -f docker-cluster.redis.yml down "$@"
        ;;

  clusterkit-redis-exec )

  if [ "$#" -lt 2 ];then
     print_error '$ ./lnmp-docker.sh clusterkit-redis-exec {master-N|slave-N} {COMMAND}' ; exit 1
  fi
        NODE=$1
        shift
        COMMAND=$@

          clusterkit_bash_cli clusterkit_redis redis_$NODE ${COMMAND:-bash}
        ;;

  clusterkit-redis-deploy )
    docker stack deploy -c docker-cluster.redis.yml redis_cluster
    ;;

  clusterkit-redis-remove )
    docker stack rm redis_cluster
    ;;

  clusterkit-redis-master-slave-up )
        docker-compose -f docker-cluster.redis.master.slave.yml up "$@"
        ;;

  clusterkit-redis-master-slave-down )
        docker-compose -f docker-cluster.redis.master.slave.yml down "$@"
        ;;

  clusterkit-redis-master-slave-exec )
    if [ "$#" -lt 2 ];then
       print_error '$ ./lnmp-docker.sh clusterkit-redis-master-slave-exec {master | slave-N} {COMMAND}' ; exit 1
    fi

        NODE="$1"
        shift
        COMMAND="$@"
        clusterkit_bash_cli clusterkit_redis_master_slave redis_m_s_$NODE ${COMMAND:-bash}
        ;;

  clusterkit-redis-master-slave-deploy )
    docker stack deploy -c docker-cluster.redis.master.slave.yml redis_m_s_cluster
    ;;

  clusterkit-redis-master-slave-remove )
    docker stack rm redis_m_s_cluster
    ;;

  clusterkit-redis-sentinel-up )
        docker-compose -f docker-cluster.redis.sentinel.yml up "$@"
        ;;

  clusterkit-redis-sentinel-down )
        docker-compose -f docker-cluster.redis.sentinel.yml down "$@"
        ;;

  clusterkit-redis-sentinel-exec )

  if [ "$#" -lt 2 ];then
     print_error '$ ./lnmp-docker.sh clusterkit-redis-sentinel-exec {master-N|slave-N|sentinel-N} {COMMAND}' ; exit 1
  fi

        NODE=$1
        shift
        COMMAND=$@
          clusterkit_bash_cli clusterkit_redis_sentinel redis_sentinel_$NODE ${COMMAND:-bash}
        ;;

  clusterkit-redis-sentinel-deploy )
    docker stack deploy -c docker-cluster.redis.sentinel.yml redis_s_cluster
    ;;

  clusterkit-redis-sentinel-remove )
    docker stack rm redis_s_cluster
    ;;

  clusterkit-* )
        command=$(echo $command | cut -d '-' -f 2)
        exec docker-compose -f docker-compose.yml \
             -f docker-compose.override.yml \
             -f docker-cluster.mysql.yml \
             -f docker-cluster.redis.yml \
             $command "$@"
        ;;

  swarm-clusterkit )
    docker stack deploy -c docker-production.yml -c docker-cluster.mysql.yml lnmp
        ;;

  dashboard )
    echo -e "
$ cd kubernetes

$ kubectl apply -f kubernetes-dashboard.yaml

$ kubectl proxy

OPEN http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/

First Run? Maybe you wait 60s then open url.
"
    print_info "More information please see https://github.com/kubernetes/dashboard"

    ;;

    update-version )
        update_version
    ;;

  * )
  if ! [ -z "$command" ];then
    print_warning "command not found, Now Exec docker-compose commands"; echo
    exec docker-compose $command "$@"
  fi
  help
    ;;
  esac
}

ARCH=`uname -m`

OS=`uname -s`

COMPOSE_LINK_OFFICIAL=https://github.com/docker/compose/releases/download

COMPOSE_LINK=https://code.aliyun.com/khs1994-docker/compose-cn-mirror/raw

# 获取正确版本号

env_status

. .env

. cli/.env

if [ -d .git ];then BRANCH=`git rev-parse --abbrev-ref HEAD`; fi

if [ "$1" = "development" ] || [ "$1" = "production" ];then APP_ENV=$1; fi

# 写入版本号

if [ ${OS} = "Darwin" ];then
  sed -i "" "s/^KHS1994_LNMP_DOCKER_VERSION.*/KHS1994_LNMP_DOCKER_VERSION=${KHS1994_LNMP_DOCKER_VERSION}/g" .env
else
  sed -i "s/^KHS1994_LNMP_DOCKER_VERSION.*/KHS1994_LNMP_DOCKER_VERSION=${KHS1994_LNMP_DOCKER_VERSION}/g" .env
fi

if [ ${ARCH} = 'armv7l' ];then
    sed -i "s/^ARM_ARCH.*/ARM_ARCH=arm32v7/g" .env
    sed -i "s/^ARM_PHP_BASED_OS.*/ARM_PHP_BASED_OS=stretch/g" .env
    sed -i "s/^ARM_BASED_OS.*/ARM_BASED_OS=/g" .env
elif [ ${ARCH} = 'aarch64' ];then
    sed -i "s/^ARM_ARCH.*/ARM_ARCH=arm64v8/g" .env
    sed -i "s/^ARM_PHP_BASED_OS.*/ARM_PHP_BASED_OS=alpine3.7/g" .env
fi

print_info "ARCH is ${OS} ${ARCH}\n"

command -v docker > /dev/null 2>&1 && print_info `docker --version`

command -v > /dev/null 2>&1 || print_warning "docker cli is not install"

echo ; docker_compose "$@"

# output help

if [ $# = 0 ];then help; exit 0; fi

# 生产环境 compose 文件

PRODUCTION_COMPOSE_FILE='docker-production.yml'

set +e

ls docker-production.*.yml > /dev/null 2>&1

if [ $? = '0' ];then
  PRODUCTION_COMPOSE_FILE=`ls docker-production.*.yml`
fi

set -e

main "$@"
