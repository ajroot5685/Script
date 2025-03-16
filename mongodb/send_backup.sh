#!/bin/bash

BACKUP_DIR="/backup/db"
EMAIL="recipient@example.com"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="/backup_$TIMESTAMP.tar.gz"

if [ ! -d "$BACKUP_DIR" ]; then
    echo "Error: 지정한 백업 디렉토리가 존재하지 않습니다: $BACKUP_DIR"
    exit 1
fi

tar -czf "$BACKUP_FILE" -C "$(dirname "$BACKUP_DIR")" "$(basename "$BACKUP_DIR")"
if [ $? -ne 0 ]; then
    echo "Error: 백업 압축 실패"
    exit 1
fi

echo "MongoDB 최신 백업 파일 ($TIMESTAMP)" | mail -s "DB 백업 파일" -A "$BACKUP_FILE" "$EMAIL"

if [ $? -eq 0 ]; then
    echo "백업 파일이 성공적으로 $EMAIL 로 전송되었습니다."
else
    echo "Error: 이메일 전송 실패"
    exit 1
fi

rm -f "$BACKUP_FILE"

exit 0