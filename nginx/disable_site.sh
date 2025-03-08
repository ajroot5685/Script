#!/bin/bash

# 인자로 사이트 이름을 입력받음
if [ -z "$1" ]; then
    echo "❌ 사용법: $0 <사이트이름>"
    exit 1
fi

SITE_NAME=$1
NGINX_ENABLED="/etc/nginx/sites-enabled/$SITE_NAME"
NGINX_AVAILABLE="/etc/nginx/sites-available/$SITE_NAME"

echo "🚀 Nginx 심볼릭 링크 해제 중: $SITE_NAME"

# 심볼릭 링크 존재 여부 확인 후 삭제
if [ -L "$NGINX_ENABLED" ]; then
    sudo unlink "$NGINX_ENABLED"
    echo "✅ 심볼릭 링크 삭제 완료: $NGINX_ENABLED"
else
    echo "⚠️ 해당 사이트의 심볼릭 링크가 없습니다: $NGINX_ENABLED"
fi

# Nginx 설정 테스트 및 재시작
sudo nginx -t && sudo systemctl reload nginx

echo "🎉 $SITE_NAME 비활성화 완료! 이제 사이트가 더 이상 활성화되지 않습니다."
