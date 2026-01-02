#!/bin/bash

# 로컬 실행 스크립트
# 사용법: ./scripts/run-local.sh 또는 scripts/run-local.sh

set -e

# 프로젝트 루트 디렉토리로 이동
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🚀 로컬 환경에서 애플리케이션 실행 중..."

# uv 경로 설정
export PATH="$HOME/.local/bin:$PATH"

# Backend 환경 변수 확인
if [ ! -f "backend/.env" ]; then
    echo "⚠️  backend/.env 파일이 없습니다."
    echo "📝 backend/env.example을 복사하여 .env 파일을 생성하고 API 키를 설정하세요."
    exit 1
fi

# Backend 의존성 확인
if [ ! -d "backend/.venv" ]; then
    echo "📦 Backend 의존성 설치 중..."
    cd backend
    uv sync
    cd ..
fi

# Frontend 의존성 확인
if [ ! -d "frontend/node_modules" ]; then
    echo "📦 Frontend 의존성 설치 중..."
    cd frontend
    npm install
    cd ..
fi

# 기존 프로세스 종료 (선택사항)
echo "🛑 기존 프로세스 확인 중..."
pkill -f "uv run python main.py" 2>/dev/null || true
pkill -f "vite" 2>/dev/null || true

# Backend 실행
echo "▶️  Backend 시작 중..."
cd backend
uv run python main.py &
BACKEND_PID=$!
cd ..

# 잠시 대기
sleep 2

# Frontend 실행
echo "▶️  Frontend 시작 중..."
cd frontend
npm run dev &
FRONTEND_PID=$!
cd ..

# 헬스 체크
echo "🏥 서버 상태 확인 중..."
sleep 3

# Backend 헬스 체크
if curl -f http://localhost:8888/ > /dev/null 2>&1; then
    echo "✅ Backend가 정상적으로 실행 중입니다. (PID: $BACKEND_PID)"
else
    echo "❌ Backend 헬스 체크 실패"
    exit 1
fi

# Frontend 헬스 체크
if curl -f http://localhost:3000/ > /dev/null 2>&1; then
    echo "✅ Frontend가 정상적으로 실행 중입니다. (PID: $FRONTEND_PID)"
else
    echo "⚠️  Frontend가 아직 준비 중입니다..."
fi

echo ""
echo "🎉 애플리케이션이 실행되었습니다!"
echo "📍 Frontend: http://localhost:3000"
echo "📍 Backend API: http://localhost:8888"
echo ""
echo "중지하려면: pkill -f 'uv run python main.py' && pkill -f 'vite'"
echo "또는 Ctrl+C를 누르세요."

# 프로세스 종료 대기
wait
