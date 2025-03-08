#!/bin/bash

# OS 확인
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    OS=$ID
else
    echo "지원되지 않는 OS입니다."
    exit 1
fi

echo "✅ 현재 OS: $OS"

# Nginx 설치
install_nginx() {
    echo "🚀 Nginx 설치 시작..."

    if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
        sudo apt update -y
        sudo apt install nginx -y
    elif [[ "$OS" == "centos" || "$OS" == "rhel" ]]; then
        sudo yum install epel-release -y
        sudo yum install nginx -y
    else
        echo "❌ 지원되지 않는 OS입니다."
        exit 1
    fi

    echo "✅ Nginx 설치 완료!"
}

# 보안 관련 파일 생성
create_global_security_conf() {
    echo "🚀 Nginx 보안 파일 생성 시작..."
    local conf_path="/etc/nginx/global_security.conf"

    sudo tee "$conf_path" > /dev/null <<EOL
location ~* \.(php|sh|pl|py|cgi)$ {
    deny all;
}
EOL

    echo "✅ $conf_path 생성 완료!"
}

# Nginx 실행 및 부팅 시 자동 시작 설정
start_nginx() {
    echo "🚀 Nginx 서비스 시작..."
    sudo systemctl start nginx
    sudo systemctl enable nginx
    echo "✅ Nginx 실행 완료!"
}

# Nginx 상태 확인
check_nginx() {
    echo "🔍 Nginx 실행 상태 확인..."
    sudo systemctl status nginx --no-pager
}

# 실행 순서
install_nginx
create_global_security_conf
start_nginx
check_nginx

echo "🎉 Nginx 설치 및 설정이 완료되었습니다!"

# 이후 방화벽 설정, nginx.conf 설정 필요