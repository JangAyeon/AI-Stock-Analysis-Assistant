#!/bin/bash

# 배포 스크립트
# 사용법: ./deploy.sh [production|development]

set -e

ENV=${1:-production}

echo "🚀 배포 시작: $ENV 모드"

# 환경 변수 확인
if [ ! -f "backend/.env" ]; then
    echo "⚠️  backend/.env 파일이 없습니다."
    echo "📝 backend/env.example을 복사하여 .env 파일을 생성하고 API 키를 설정하세요."
    exit 1
fi

# Docker 이미지 빌드
echo "📦 Docker 이미지 빌드 중..."
docker-compose build

# 기존 컨테이너 중지 및 제거
echo "🛑 기존 컨테이너 중지 중..."
docker-compose down

# 새 컨테이너 시작
echo "▶️  새 컨테이너 시작 중..."
docker-compose up -d

# 헬스 체크
echo "🏥 헬스 체크 중..."
sleep 5

# Backend 헬스 체크
if curl -f http://localhost:8888/ > /dev/null 2>&1; then
    echo "✅ Backend가 정상적으로 실행 중입니다."
else
    echo "❌ Backend 헬스 체크 실패"
    docker-compose logs backend
    exit 1
fi

# Frontend 헬스 체크
if curl -f http://localhost:3000/ > /dev/null 2>&1; then
    echo "✅ Frontend가 정상적으로 실행 중입니다."
else
    echo "❌ Frontend 헬스 체크 실패"
    docker-compose logs frontend
    exit 1
fi

echo "🎉 배포 완료!"
echo "📍 Frontend: http://localhost:3000"
echo "📍 Backend API: http://localhost:8888"
echo ""
echo "로그 확인: docker-compose logs -f"
echo "중지: docker-compose down"

