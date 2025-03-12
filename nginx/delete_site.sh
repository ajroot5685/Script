#!/bin/bash

# 인자로 사이트 이름을 입력받음
if [ -z "$1" ]; then
    echo "❌ 사용법: $0 <사이트이름>"
    exit 1
fi

SITE_NAME=$1
NGINX_AVAILABLE="/etc/nginx/sites-available/$SITE_NAME"
WEB_ROOT="/var/www/$SITE_NAME"

# 심볼릭 링크 비활성화
if ! ./disable_site.sh "$SITE_NAME"; then
    exit 1
fi

sudo rm -r $WEB_ROOT
sudo rm $NGINX_AVAILABLE