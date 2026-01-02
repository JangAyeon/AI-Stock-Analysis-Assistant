# AI Stock Analysis Assistant

AI 기반 주식 분석 어시스턴트 애플리케이션입니다. LangChain과 OpenAI API를 활용하여 실시간 주식 정보를 조회하고 분석하는 챗봇 서비스를 제공합니다.

## ✨ 주요 기능

- 📈 **실시간 주식 가격 조회** - 티커 심볼을 기반으로 현재 주가 조회
- 📊 **과거 주가 데이터** - 특정 기간의 주가 히스토리 조회
- 📰 **주식 뉴스** - 관련 뉴스 및 시장 정보 제공
- 💼 **재무제표 조회** - 기업의 재무 상태 분석
- 💬 **AI 챗봇** - 자연어로 주식 정보를 질문하고 분석 결과를 받을 수 있는 대화형 인터페이스

## 🛠️ 기술 스택

### Backend

- **FastAPI** - 고성능 Python 웹 프레임워크
- **LangChain** - LLM 애플리케이션 개발 프레임워크
- **LangGraph** - 상태 관리 및 에이전트 오케스트레이션
- **OpenAI API** - GPT 모델 (Thesys API 사용)
- **yfinance** - Yahoo Finance 데이터 수집
- **uvicorn** - ASGI 서버

### Frontend

- **React 19** - UI 라이브러리
- **TypeScript** - 타입 안정성
- **Vite** - 빌드 도구
- **@crayonai/react-ui** - UI 컴포넌트
- **@thesysai/genui-sdk** - GenUI SDK

## 📁 프로젝트 구조

```text
AI-Stock-Analysis-Assistant/
├── backend/              # Python FastAPI 백엔드
│   ├── main.py          # FastAPI 애플리케이션 메인 파일
│   ├── pyproject.toml   # Python 의존성 관리
│   ├── Dockerfile       # Backend Docker 이미지
│   └── env.example      # 환경 변수 예제
├── frontend/            # React + TypeScript 프론트엔드
│   ├── src/            # 소스 코드
│   ├── package.json    # Node.js 의존성 관리
│   ├── Dockerfile      # Frontend Docker 이미지
│   └── nginx.conf      # Nginx 설정
├── scripts/            # 유틸리티 스크립트
│   ├── run-local.sh    # 로컬 실행 스크립트
│   ├── deploy.sh       # 배포 스크립트
│   └── git-cleanup.sh  # Git 브랜치 정리 스크립트
├── docs/               # 문서
│   ├── run-local.md    # 로컬 실행 가이드
│   └── deploy.md       # 배포 가이드
├── docker-compose.yml  # Docker Compose 설정
└── README.md           # 이 파일
```

## 🚀 빠른 시작

### 사전 요구사항

- Python 3.11 이상
- Node.js 18 이상
- uv (Python 패키지 관리자)
- Docker 및 Docker Compose (배포 시)

### 1. 저장소 클론

```bash
git clone https://github.com/JangAyeon/AI-Stock-Analysis-Assistant.git
cd AI-Stock-Analysis-Assistant
```

### 2. 환경 변수 설정

```bash
cd backend
cp env.example .env
```

`.env` 파일을 열어서 API 키를 설정하세요:

```env
OPENAI_API_KEY=your_api_key_here
```

### 3. 로컬 실행

#### 방법 1: 스크립트 사용 (권장)

```bash
./scripts/run-local.sh
```

#### 방법 2: 수동 실행

**Backend 실행:**

```bash
export PATH="$HOME/.local/bin:$PATH"
cd backend
uv sync
uv run python main.py
```

**Frontend 실행 (새 터미널):**

```bash
cd frontend
npm install
npm run dev
```

더 자세한 내용은 [로컬 실행 가이드](docs/run-local.md)를 참고하세요.

### 4. 접속

- **Frontend**: <http://localhost:3000>
- **Backend API**: <http://localhost:8888>
- **API Health Check**: <http://localhost:8888/>

## 📚 API 엔드포인트

### `GET /`

서버 상태 확인

**응답:**

```json
{
  "message": "Hello, World!"
}
```

### `POST /api/chat`

AI 챗봇과 대화

**요청 본문:**

```json
{
  "prompt": {
    "content": "AAPL의 현재 주가를 알려줘",
    "id": "message-id",
    "role": "user"
  },
  "threadId": "thread-id",
  "responseId": "response-id"
}
```

**응답:** Server-Sent Events (SSE) 스트리밍

## 🐳 Docker를 사용한 배포

### 빠른 배포

```bash
./scripts/deploy.sh
```

### 수동 배포

```bash
# 환경 변수 설정
cd backend
cp env.example .env
# .env 파일에 OPENAI_API_KEY 설정

# Docker Compose로 실행
docker-compose up -d

# 로그 확인
docker-compose logs -f

# 중지
docker-compose down
```

자세한 배포 방법은 [배포 가이드](docs/deploy.md)를 참고하세요.

## 🛠️ 스크립트

프로젝트의 유틸리티 스크립트는 `scripts/` 디렉토리에 있습니다:

| 스크립트                 | 설명                                          |
| ------------------------ | --------------------------------------------- |
| `scripts/run-local.sh`   | 로컬 환경에서 백엔드와 프론트엔드를 함께 실행 |
| `scripts/deploy.sh`      | Docker를 사용한 배포 (헬스 체크 포함)         |
| `scripts/git-cleanup.sh` | 원격에 없는 로컬 Git 브랜치 정리              |

## 📖 문서

- [로컬 실행 가이드](docs/run-local.md) - 로컬 개발 환경 설정 및 실행 방법
- [배포 가이드](docs/deploy.md) - 프로덕션 배포 방법 (Railway, Render, Fly.io, AWS, GCP 등)

## 🔧 개발

### Backend 개발

```bash
cd backend
uv sync
uv run python main.py
```

### Frontend 개발

```bash
cd frontend
npm install
npm run dev
```

### 빌드

**Backend:**

```bash
cd backend
uv sync --frozen
```

**Frontend:**

```bash
cd frontend
npm ci
npm run build
```

## 🐛 트러블슈팅

### Backend가 실행되지 않는 경우

1. `.env` 파일이 올바르게 설정되었는지 확인
2. Python 버전 확인: `python3 --version` (3.11 이상 필요)
3. 의존성 재설치: `cd backend && uv sync`

### Frontend가 실행되지 않는 경우

1. Node.js 버전 확인: `node --version` (18 이상 필요)
2. 의존성 재설치: `cd frontend && rm -rf node_modules && npm install`

### 포트 충돌

- Backend 포트 변경: `backend/main.py`의 `uvicorn.run(app, host='0.0.0.0', port=8888)` 부분 수정
- Frontend 포트 변경: `frontend/vite.config.ts`의 `server.port` 수정


## 🤝 기여

기여를 환영합니다! 이슈를 열거나 Pull Request를 제출해주세요.

## 📧 문의

프로젝트에 대한 문의사항이 있으시면 이슈를 생성해주세요.
