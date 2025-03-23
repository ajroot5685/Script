#!/bin/bash

set -e

### Nginx + Docker-compose 환경에서의 blue&green 배포

### 필요한 사전 작업
# docker-compose.yml 정의
# nginx.conf에 들어갈 블록 정의(sites-available 추천)
# 블록의 템플릿 정의
# 변경될 nginx 파일 경로의 소유자 변경
# runners의 sudo 권한 설정

APP_NAME="컨테이너명"

BLUE="blue"
BLUE_PORT="8080"
GREEN="green"
GREEN_PORT="8081"

if docker ps --format '{{.Names}}' | grep -q "${APP_NAME}-${BLUE}"; then
  COLOR=${GREEN}
  OLD_COLOR=${BLUE}
  PORT=${GREEN_PORT}
else
  COLOR=${BLUE}
  OLD_COLOR=${GREEN}
  PORT=${BLUE_PORT}
fi

SERVICE_NAME="${APP_NAME}-${COLOR}"
OLD_SERVICE_NAME="${APP_NAME}-${OLD_COLOR}"

# 주의 : docker-compose.yml 파일과 호환되어야함
docker-compose up -d --build "$SERVICE_NAME"

for i in {1..10}; do
  if curl -s "http://localhost:$PORT/health" | grep 'OK' > /dev/null; then
    break
  fi
  echo "⏳ 헬스체크 대기중... ($i/10)"
  sleep 5
done

if ! curl -s "http://localhost:$PORT/health" | grep 'OK' > /dev/null; then
  echo "❌ 헬스체크 실패"
  docker-compose stop "$SERVICE_NAME"
  exit 1
fi

echo "✅ 헬스체크 통과"

# sites-available의 소유권이 runners 실행자에게 있어야함
export PORT
envsubst '$PORT' < /etc/nginx/template/${APP_NAME} > /etc/nginx/sites-available/${APP_NAME}

# sudo에서 password 요구 에러가 발생하는 경우 sudo visudo로 다음 문장 추가
# <runners실행자> ALL=(ALL) NOPASSWD: /usr/sbin/nginx
if ! sudo nginx -t; then
  echo "❌ nginx 설정 오류"
  docker-compose stop "$SERVICE_NAME"
  exit 1
fi

sudo nginx -s reload

docker stop $OLD_SERVICE_NAME || true

echo "✅ 배포 완료"