#!/bin/bash

# 인자로 사이트 이름을 입력받음
if [ -z "$1" ]; then
    echo "❌ 사용법: $0 <사이트이름>"
    exit 1
fi

SITE_NAME=$1
DOMAIN="$SITE_NAME.example.com" # 원하는 도메인으로 변경
NGINX_AVAILABLE="/etc/nginx/sites-available/$SITE_NAME"
NGINX_ENABLED="/etc/nginx/sites-enabled/$SITE_NAME"
WEB_ROOT="/var/www/$SITE_NAME"

if [[ "$DOMAIN" == *".example.com" ]]; then
    echo "❌ DOMAIN 변수의 '.example.com'을 변경해주세요."
    exit 1
fi

# SSL 인증 선행 필요
if ! sudo find /etc/letsencrypt/live -maxdepth 1 -name "$DOMAIN" | grep -q .; then
    echo "❌ $DOMAIN에 대한 SSL 인증이 필요합니다."
    exit 1
fi

echo "🚀 Nginx 설정 생성 중: $DOMAIN"

# 사이트 설정 파일 생성
sudo tee $NGINX_AVAILABLE > /dev/null <<EOL
server {
    listen 443 ssl;
    server_name $DOMAIN;

    root $WEB_ROOT;
    index index.html;

    location / {
        proxy_pass http://localhost:<port>;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

    include /etc/nginx/global_security.conf;
}
EOL

echo "✅ Nginx 설정 파일 생성 완료: $NGINX_AVAILABLE"

# 웹 루트 디렉토리 생성 및 기본 index.html 추가
sudo mkdir -p $WEB_ROOT
echo "<h1>Welcome to $SITE_NAME</h1>" | sudo tee $WEB_ROOT/index.html > /dev/null
sudo chown -R www-data:www-data $WEB_ROOT
sudo chmod -R 755 $WEB_ROOT

echo "✅ 웹 루트 디렉토리 생성 완료: $WEB_ROOT"

# 심볼릭 링크를 sites-enabled에 생성하여 사이트 활성화
if ! ./enable_site.sh "$SITE_NAME"; then
    exit 1
fi

# Nginx 설정 테스트 및 재시작
if sudo nginx -t; then
    sudo systemctl restart nginx
    echo "🎉 $DOMAIN 설정 완료! 이제 https://$DOMAIN 에서 확인하세요."
else
    echo "❌ Nginx 설정 테스트 실패, Nginx 설정을 확인하세요."
    exit 1
fi