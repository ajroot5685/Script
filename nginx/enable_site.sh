#!/bin/bash

# 인자로 사이트 이름을 입력받음
if [ -z "$1" ]; then
    echo "❌ 사용법: $0 <사이트이름>"
    exit 1
fi

SITE_NAME=$1
NGINX_ENABLED="/etc/nginx/sites-enabled/$SITE_NAME"
NGINX_AVAILABLE="/etc/nginx/sites-available/$SITE_NAME"

echo "🚀 Nginx 심볼릭 링크 연결 중: $SITE_NAME"

if [ -L "$NGINX_ENABLED" ]; then
    sudo unlink "$NGINX_ENABLED"
fi
sudo ln -s "$NGINX_AVAILABLE" "$NGINX_ENABLED"

if sudo nginx -t; then
    sudo systemctl reload nginx
    echo "🎉 $SITE_NAME 활성화 완료!"
else
    echo "❌ Nginx 설정 테스트 실패, Nginx 설정을 확인하세요."
    exit 1
fi