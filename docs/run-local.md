# AI-Stock-Analysis-Assistant

AI Stock Analysis Assistant

## 로컬 실행 방법

### 사전 요구사항

- Python 3.11 이상
- Node.js 18 이상
- uv (Python 패키지 관리자)

### 1. uv 설치

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

설치 후 터미널을 재시작하거나 다음 명령어를 실행하세요:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

### 2. Backend 설정

#### 환경 변수 설정

`backend/env.example` 파일을 참고하여 `backend/.env` 파일을 생성하고 API 키를 설정하세요:

```bash
cd backend
cp env.example .env
```

`.env` 파일을 열어서 `OPENAI_API_KEY`를 설정하세요:

```env
OPENAI_API_KEY=your_api_key_here
```

#### 의존성 설치

```bash
cd backend
uv sync
```

### 3. Frontend 설정

#### 의존성 설치

```bash
cd frontend
npm install
```

### 4. 실행

#### 방법 1: 스크립트 사용 (가장 간단)

```bash
./scripts/run-local.sh
```

또는

```bash
scripts/run-local.sh
```

#### 방법 2: 별도 터미널에서 실행 (권장)

**터미널 1 - Backend 실행:**

```bash
export PATH="$HOME/.local/bin:$PATH"
cd backend
uv run python main.py
```

**터미널 2 - Frontend 실행:**

```bash
cd frontend
npm run dev
```

#### 방법 2: 백그라운드 실행

**Backend:**

```bash
export PATH="$HOME/.local/bin:$PATH"
cd backend
uv run python main.py &
```

**Frontend:**

```bash
cd frontend
npm run dev &
```

### 5. 접속

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8888

### 문제 해결

#### Backend가 실행되지 않는 경우

1. `.env` 파일이 올바르게 설정되었는지 확인
2. Python 버전 확인: `python3 --version` (3.11 이상 필요)
3. 의존성 재설치: `cd backend && uv sync`

#### Frontend가 실행되지 않는 경우

1. Node.js 버전 확인: `node --version` (18 이상 필요)
2. 의존성 재설치: `cd frontend && rm -rf node_modules && npm install`

#### 포트가 이미 사용 중인 경우

- Backend 포트 변경: `main.py`의 `uvicorn.run(app, host='0.0.0.0', port=8888)` 부분 수정
- Frontend 포트 변경: `frontend/vite.config.ts`의 `server.port` 수정
