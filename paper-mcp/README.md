
# Research Question python 프로그램

## 주의사항
- _Google 아이디, 비번, 코드에 있는 API는 모두 보안사항으로 외부유출 절대 금지_

## 사용방법
- firefox로 구동하므로 firefox를 설치한다.
- obsidian을 사용하므로 설치한다.
- Elicit에 들어가서 자연어로 research question을 적고 논문목록을 다운로드 받는다. 
  - Find papers 탭을 열고 자연어로 입력하고 검색을 누른다. 
  - Download를 누르고 txt로 받는다.
  - txt의 내용을 문서 (C:\Users\acube\Documents\LibgenDownloads)의 논문목록.txt로 저장한다.
- Python 프로그램을 실행시킨다. 

- Elicit과 Connected Papers는 Google로 로그인 한다. 
   - acubens555@gmail.com
   - itiSme0841!

- Python 코드에서 자기 컴퓨터에 맞는 경로로 적절히 변경한다.
  - pip install -r requirements.txt로 필요한 패키지를 다운로드 받는다. 

------------------------------------------------------------------------

# Paper Downloader MCP 서버

이 프로젝트는 Libgen에서 논문을 검색하고 다운로드하는 MCP(Model Context Protocol) 서버입니다. Claude와 같은 AI 어시스턴트와 연동하여 논문 검색과 다운로드를 자동화할 수 있습니다.

## 기능

- 키워드로 논문 검색
- 논문 PDF 다운로드
- 여러 논문 일괄 다운로드
- 다운로드 폴더 위치 관리

## 설치 방법

### 1. 저장소 클론 또는 파일 다운로드

```bash
git clone https://github.com/zephiris21/paper-mcp
cd libgen-mcp
```

또는 `libgen_server.py` 파일을 직접 다운로드하여 원하는 디렉토리에 저장하세요.

### 2. 가상환경 설정

Python 가상환경을 생성하고 활성화합니다:

```bash
# 가상환경 생성
python -m venv .venv

# 가상환경 활성화 (Windows)
.venv\Scripts\activate

# 가상환경 활성화 (macOS/Linux)
source .venv/bin/activate
```

### 3. 필요한 패키지 설치

```bash
pip install fastmcp requests beautifulsoup4
```

또는 `requirements.txt` 파일을 생성하고 설치:

```
# requirements.txt 내용
fastmcp>=2.0.0
requests>=2.28.0
beautifulsoup4>=4.12.0
```

```bash
pip install -r requirements.txt
```

## 서버 실행 방법

### 개발 모드로 실행 (테스트용)

```bash
# 가상환경 활성화 상태에서
fastmcp dev libgen_server.py
```

### 직접 실행

```bash
# 가상환경 활성화 상태에서
python libgen_server.py
```

### Claude 데스크톱에 설치

```bash
# 가상환경 활성화 상태에서
fastmcp install libgen_server.py --name "Paper Downloader"
```

## Claude 데스크톱 설정

Claude 데스크톱 앱과 통합하려면 설정 파일을 수정해야 합니다:

1. Claude 데스크톱 앱 설정 파일(`config.json`)을 엽니다.
   - Windows: `%APPDATA%\Claude\config.json`
   - macOS: `~/Library/Application Support/Claude/config.json`

2. `mcp` 섹션에 다음 내용을 추가합니다:

```json
{
  "mcp": {
    "paper-downloader": {
      "command": "cmd",
      "args": [
        "/c",
        "D:\\path\\to\\libgen-mcp\\.venv\\Scripts\\python.exe",
        "D:\\path\\to\\libgen-mcp\\libgen_server.py"
      ]
    }
  }
}
```

macOS나 Linux의 경우:

```json
{
  "mcp": {
    "paper-downloader": {
      "command": "bash",
      "args": [
        "-c",
        "/path/to/libgen-mcp/.venv/bin/python /path/to/libgen-mcp/libgen_server.py"
      ]
    }
  }
}
```

**중요**: 위 경로를 실제 설치 경로로 바꿔주세요!

3. Claude 데스크톱 앱을 재시작합니다.

## 사용 방법

Claude 데스크톱에서 다음과 같이 사용할 수 있습니다:

```
논문 검색: "The race between man and machine: Implications of technology for growth, factor shares, and employment"를 검색해줘
```

```
논문 다운로드: "Automation and new tasks: How technology displaces and reinstates labor" 논문을 다운로드해줘
```

```
일괄 다운로드: 다음 논문들을 다운로드해줘:
- The race between man and machine: Implications of technology for growth, factor shares, and employment
- Automation and new tasks: How technology displaces and reinstates labor
```

```
다운로드 폴더 확인: 현재 다운로드 폴더 위치를 알려줘
```

```
다운로드 폴더 변경: 다운로드 폴더를 D:\Papers로 변경해줘
```

## 문제 해결

- **다운로드 폴더 문제**: 기본 다운로드 폴더는 `사용자 홈 디렉토리/Documents/LibgenDownloads`입니다. 이 경로에 문제가 있으면 자동으로 대체 경로를 생성합니다.
- **연결 문제**: Libgen 사이트에 접속할 수 없는 경우, 기본 URL을 변경하려면 환경 변수 `PAPER_BASE_URL`을 설정하세요.
- **파일 크기 제한**: 기본적으로 10MB 이하의 파일만 다운로드합니다. 이 제한을 변경하려면 환경 변수 `PAPER_MAX_FILE_SIZE`를 설정하세요.

## 주의사항

이 도구는 학술적, 교육적 목적으로만 사용하세요. 저작권이 있는 콘텐츠를 다운로드할 때는 해당 국가의 저작권법을 준수하는 것이 중요합니다.