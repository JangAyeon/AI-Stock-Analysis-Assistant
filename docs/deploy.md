# 배포 가이드 (Deployment Guide)

이 문서는 AI Stock Analysis Assistant를 프로덕션 환경에 배포하는 방법을 설명합니다.

## 📋 목차

1. [Docker를 사용한 로컬 배포](#docker를-사용한-로컬-배포)
2. [클라우드 플랫폼 배포](#클라우드-플랫폼-배포)
3. [환경 변수 설정](#환경-변수-설정)
4. [트러블슈팅](#트러블슈팅)

## 🐳 Docker를 사용한 로컬 배포

### 사전 요구사항

- Docker 및 Docker Compose 설치
- API 키 준비 (OpenAI 또는 Thesys API)

### 배포 단계

1. **환경 변수 설정**

   ```bash
   cd backend
   cp env.example .env
   # .env 파일을 열어서 OPENAI_API_KEY를 설정하세요
   ```

2. **Docker Compose로 실행**

   스크립트 사용 (권장):
   ```bash
   ./scripts/deploy.sh
   ```

   또는 직접 실행:
   ```bash
   # 프로젝트 루트에서
   docker-compose up -d
   ```

3. **애플리케이션 접속**

   - Frontend: http://localhost:3000
   - Backend API: http://localhost:8888

4. **로그 확인**

   ```bash
   docker-compose logs -f
   ```

5. **중지**

   ```bash
   docker-compose down
   ```

## ☁️ 클라우드 플랫폼 배포

### Railway 배포

1. **Railway 계정 생성 및 프로젝트 생성**
   - https://railway.app 접속
   - GitHub 저장소 연결

2. **Backend 배포**
   - New Service → GitHub Repo 선택
   - Root Directory: `backend`
   - Build Command: `uv sync --frozen`
   - Start Command: `uv run uvicorn main:app --host 0.0.0.0 --port $PORT`
   - 환경 변수 설정: `OPENAI_API_KEY`

3. **Frontend 배포**
   - New Service → GitHub Repo 선택
   - Root Directory: `frontend`
   - Build Command: `npm ci && npm run build`
   - Output Directory: `dist`
   - 환경 변수 설정: `VITE_API_URL` (Backend URL)

### Render 배포

1. **Backend 배포**
   - New → Web Service
   - Build Command: `cd backend && uv sync --frozen`
   - Start Command: `cd backend && uv run uvicorn main:app --host 0.0.0.0 --port $PORT`
   - Environment Variables: `OPENAI_API_KEY`

2. **Frontend 배포**
   - New → Static Site
   - Build Command: `cd frontend && npm ci && npm run build`
   - Publish Directory: `frontend/dist`
   - Environment Variables: `VITE_API_URL` (Backend URL)

### Fly.io 배포

1. **Fly CLI 설치 및 로그인**

   ```bash
   curl -L https://fly.io/install.sh | sh
   fly auth login
   ```

2. **Backend 배포**

   ```bash
   cd backend
   fly launch
   # 설정 후
   fly secrets set OPENAI_API_KEY=your_key_here
   fly deploy
   ```

3. **Frontend 배포**

   ```bash
   cd frontend
   fly launch
   # nginx 설정 포함
   fly deploy
   ```

### AWS 배포 (ECS/Fargate)

1. **Docker 이미지 빌드 및 푸시**

   ```bash
   # Backend
   docker build -t ai-stock-backend ./backend
   docker tag ai-stock-backend:latest your-ecr-repo/ai-stock-backend:latest
   docker push your-ecr-repo/ai-stock-backend:latest

   # Frontend
   docker build -t ai-stock-frontend ./frontend
   docker tag ai-stock-frontend:latest your-ecr-repo/ai-stock-frontend:latest
   docker push your-ecr-repo/ai-stock-frontend:latest
   ```

2. **ECS Task Definition 생성**
   - ECR 이미지 사용
   - 환경 변수 설정
   - 포트 매핑 설정

3. **ECS Service 생성 및 실행**

### Google Cloud Platform (Cloud Run)

1. **Backend 배포**

   ```bash
   cd backend
   gcloud run deploy ai-stock-backend \
     --source . \
     --platform managed \
     --region asia-northeast3 \
     --allow-unauthenticated \
     --set-env-vars OPENAI_API_KEY=your_key_here
   ```

2. **Frontend 배포**

   ```bash
   cd frontend
   gcloud run deploy ai-stock-frontend \
     --source . \
     --platform managed \
     --region asia-northeast3 \
     --allow-unauthenticated
   ```

## 🔐 환경 변수 설정

### Backend 환경 변수

- `OPENAI_API_KEY`: OpenAI 또는 Thesys API 키 (필수)

### Frontend 환경 변수

프로덕션 빌드 시 다음 환경 변수를 설정하세요:

- `VITE_API_URL`: Backend API URL (예: `https://api.yourdomain.com`)

빌드 시점에 환경 변수가 포함되므로, 빌드 전에 설정해야 합니다:

```bash
export VITE_API_URL=https://api.yourdomain.com
npm run build
```

## 🔧 프로덕션 최적화

### Backend 최적화

1. **Uvicorn 워커 설정**

   ```python
   # main.py 수정
   if __name__ == '__main__':
       uvicorn.run(
           app,
           host='0.0.0.0',
           port=8888,
           workers=4  # CPU 코어 수에 맞게 조정
       )
   ```

2. **환경 변수로 포트 설정**

   ```python
   import os
   port = int(os.getenv('PORT', 8888))
   ```

### Frontend 최적화

1. **Vite 빌드 최적화**

   ```typescript
   // vite.config.ts
   export default defineConfig({
     build: {
       rollupOptions: {
         output: {
           manualChunks: {
             vendor: ['react', 'react-dom'],
           },
         },
       },
     },
   });
   ```

## 🐛 트러블슈팅

### Backend가 시작되지 않는 경우

1. 환경 변수 확인: `.env` 파일이 올바르게 설정되었는지 확인
2. 포트 충돌 확인: 다른 서비스가 8888 포트를 사용하고 있는지 확인
3. 로그 확인: `docker-compose logs backend`

### Frontend에서 API 호출 실패

1. CORS 설정 확인: Backend의 CORS 설정이 올바른지 확인
2. API URL 확인: Frontend의 환경 변수가 올바르게 설정되었는지 확인
3. 네트워크 확인: 브라우저 개발자 도구의 Network 탭 확인

### Docker 빌드 실패

1. 캐시 클리어: `docker-compose build --no-cache`
2. 의존성 확인: `pyproject.toml`과 `package.json` 확인
3. Docker 버전 확인: 최신 Docker 버전 사용

## 📝 추가 참고사항

- 프로덕션 환경에서는 CORS 설정을 특정 도메인으로 제한하세요
- HTTPS를 사용하도록 설정하세요 (Let's Encrypt 등)
- 로깅 및 모니터링 도구를 설정하세요
- 데이터베이스가 필요한 경우 추가 설정이 필요합니다

