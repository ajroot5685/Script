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

# Docker 설치 함수
install_docker() {
    echo "🚀 Docker 설치 시작..."

    if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
        sudo apt update -y
        sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.docker.com/linux/$OS/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/$OS $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt update -y
        sudo apt install -y docker-ce docker-ce-cli containerd.io
    elif [[ "$OS" == "centos" || "$OS" == "rhel" ]]; then
        sudo yum install -y yum-utils
        sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        sudo yum install -y docker-ce docker-ce-cli containerd.io
    else
        echo "❌ 지원되지 않는 OS입니다."
        exit 1
    fi

    echo "✅ Docker 설치 완료!"
}

# Docker 서비스 시작 및 자동 실행 설정
start_docker() {
    echo "🚀 Docker 서비스 시작..."
    sudo systemctl start docker
    sudo systemctl enable docker
    echo "✅ Docker 실행 완료!"
}

# Docker Compose 설치
install_docker_compose() {
    echo "🚀 Docker Compose 설치 시작..."
    LATEST_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -oP '"tag_name": "\K[^"]+')
    sudo curl -L "https://github.com/docker/compose/releases/download/${LATEST_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "✅ Docker Compose 설치 완료!"
}

# Docker 버전 확인
check_docker() {
    echo "🔍 Docker 버전 확인..."
    docker --version
    docker-compose --version
}

# 실행 순서
install_docker
start_docker
install_docker_compose
check_docker

echo "🎉 Docker 및 Docker Compose 설치 및 설정이 완료되었습니다!"

# 이후 docker 권한 설정 필요