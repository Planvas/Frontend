<div align="center">

# Planvas

**UMC 9기 데모 프로젝트**

</div>

<br/>

## 🙋🏻‍♀️ Planvas의 iOS Developer를 소개합니다!

| <a href="https://github.com/mzxxzysy"><img src="https://avatars.githubusercontent.com/u/163836325?v=4" width="120px" /></a> | <a href="https://github.com/Jieun13"><img src="https://avatars.githubusercontent.com/u/83360389?v=4"  width="120px"/></a> | <a href="https://github.com/wk1717"><img src="https://avatars.githubusercontent.com/u/161578753?v=4"  width="120px"/></a> |
| --------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| 정서영                                                                                                                      | 백지은                                                                                                                    | 송민교                                                                                                                    |

| <a href="#"><img src="#"  width="120px" /></a> | <a href="https://github.com/hmj6589"><img src="https://avatars.githubusercontent.com/u/139426988?v=4"  width="120px"/></a> |
| ---------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| 최우진                                         | 황민지                                                                                                                     |

<br>

## 🔎 기술 스택

### Envrionment

<div align="left">
<img src="https://img.shields.io/badge/git-%23F05033.svg?style=for-the-badge&logo=git&logoColor=white" />
<img src="https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white" />
<img src="https://img.shields.io/badge/SPM-FA7343?style=for-the-badge&logo=swift&logoColor=white" />
</div>

### Development

<div align="left">
<img src="https://img.shields.io/badge/Xcode-007ACC?style=for-the-badge&logo=Xcode&logoColor=white" />
<img src="https://img.shields.io/badge/SwiftUI-42A5F5?style=for-the-badge&logo=swift&logoColor=white" />
<img src="https://img.shields.io/badge/Alamofire-FF5722?style=for-the-badge&logo=swift&logoColor=white" />
<img src="https://img.shields.io/badge/Moya-8A4182?style=for-the-badge&logo=swift&logoColor=white" />
<img src="https://img.shields.io/badge/Kingfisher-0F92F3?style=for-the-badge&logo=swift&logoColor=white" />
</div>

### Communication

<div align="left">
<img src="https://img.shields.io/badge/Notion-white.svg?style=for-the-badge&logo=Notion&logoColor=000000" />
<img src="https://img.shields.io/badge/Discord-5865F2?style=for-the-badge&logo=Discord&logoColor=white" />
<img src="https://img.shields.io/badge/Figma-F24E1E?style=for-the-badge&logo=figma&logoColor=white" />
</div>

<br>

## 🎉 Git Convention

### 📌 Git Flow

```
main ← 작업 브랜치
```

- `main branch` : 메인 브랜치
- `feature branch` : 페이지/기능 브랜치

<br>

### 🔥 Commit Message Convention

- **커밋 유형**

  - 🎉 Init: 프로젝트 세팅
  - ✨ Feat: 새로운 기능 추가
  - 🐛 Fix : 버그 수정
  - 💄 Design : UI(CSS) 수정
  - ✏️ Typing Error : 오타 수정
  - 📝 Docs : 문서 수정
  - 🚚 Mod : 폴더 구조 이동 및 파일 이름 수정
  - 💡 Add : 파일 추가 (ex- 이미지 추가)
  - 🔥 Del : 파일 삭제
  - ♻️ Refactor : 코드 리펙토링
  - 🚧 Chore : 배포, 빌드 등 기타 작업
  - 🔀 Merge : 브랜치 병합

- **형식**: `커밋유형: 상세설명 (#이슈번호)`
- **예시**:
  - 🎉 Init: 프로젝트 초기 세팅 (#1)
  - ✨ Feat: 메인페이지 개발 (#2)

<br>

### 🌿 Branch Convention

**Branch Naming 규칙**

- **브랜치 종류**

  - `init`: 프로젝트 세팅
  - `feat`: 새로운 기능 추가
  - `fix` : 버그 수정
  - `refactor` : 코드 리펙토링

- **형식**: `브랜치종류/#이슈번호/상세기능`
- **예시**:
  - init/#1/init
  - fix/#2/splash

<br>

### 📋 Issue Convention

**Issue Title 규칙**

- **태그 목록**:

  - `Init`: 프로젝트 세팅
  - `Feat`: 새로운 기능 추가
  - `Fix` : 버그 수정
  - `Refactor` : 코드 리펙토링

- **형식**: [태그] 작업 요약
- **예시**:
  - [Init] 프로젝트 초기 세팅
  - [Feat] Header 컴포넌트 구현

<br>

## 📂 프로젝트 구조

- App - 앱의 진입점과 전반적인 앱 흐름 담당
- Core - 공통으로 사용되는 핵심 도메인 레이어
- Features - 사용자에게 노출되는 실제 기능 단위
- Resouce - 앱에서 사용되는 정적 리소스
- Service - 외부 시스템과의 상호작용을 담당하는 레이어
- Utilities - 전역에서 사용되는 보조 기능 함수
