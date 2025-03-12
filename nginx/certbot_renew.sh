#!/bin/bash

# 로그 파일 경로
LOGFILE="/var/log/certbot/renew.log"
SITE_NAME="ssl"
NGINX_SITE_AVAILABLE_PATH="/etc/nginx/sites-available"
ENABLE_SITE_SCRIPT_PATH=""
DISABLE_SITE_SCRIPT_PATH=""

if ! sudo find "$NGINX_SITE_AVAILABLE_PATH" -maxdepth 1 -name "$SITE_NAME" | grep -q .; then
    echo "❌ Let's encrypt의 HTTP-01 인증을 위해 $SITE_NAME server block이 필요합니다."
    exit 1
fi

if [ -z "$ENABLE_SITE_SCRIPT_PATH" ] || [ -z "$DISABLE_SITE_SCRIPT_PATH" ]; then
    echo "❌ 스크립트의 경로를 설정해주세요."
    exit 1
fi

if ! "$ENABLE_SITE_SCRIPT_PATH" "$SITE_NAME"; then
    exit 1
fi

# 날짜 출력
echo "[$(date)] Starting certbot renew process..." >> "$LOGFILE"

# Certbot 갱신
sudo certbot renew >> "$LOGFILE" 2>&1

if ! "$DISABLE_SITE_SCRIPT_PATH" "$SITE_NAME"; then
    exit 1
fi