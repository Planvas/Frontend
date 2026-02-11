<div align="center">

# Planvas

**💻 UMC 9기 데모 프로젝트 💻**

</div>

<br/>

## 🙋🏻‍♀️ Planvas의 iOS Developer를 소개합니다!

| <a href="https://github.com/mzxxzysy"><img src="https://avatars.githubusercontent.com/u/163836325?v=4" width="120px" /></a> | <a href="https://github.com/Jieun13"><img src="https://avatars.githubusercontent.com/u/83360389?v=4"  width="120px"/></a> | <a href="https://github.com/wk1717"><img src="https://avatars.githubusercontent.com/u/161578753?v=4"  width="120px"/></a> | <a href="https://github.com/hmj6589"><img src="https://avatars.githubusercontent.com/u/139426988?v=4"  width="120px"/></a> |
| --------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- | -- |
| 정서영                                                                                                                      | 백지은                                                                                                                    | 송민교                                                                                                                    | 황민지  |

<br>

## 🔎 기술 스택

### Environment

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

### 📁 PR Convention

- PR 시, 템플릿이 등장한다. 해당 템플릿에서 작성해야할 부분은 아래와 같다.
  1. `PR 제목`, '[태그] 작업 요약' 형식에 맞춰 작성한다.
  2. `이슈 번호`, PR과 관련된 이슈 번호를 표기한다.
  3. `작업 내용`, 작업 내용에 대해 간략히 작성한다.
  4. `코멘트`, 코드 리뷰가 필요한 부분이나 팀원들에게 공지가 필요한 내용에 대해 작성한다.
  5. `구현 결과`, 구현한 기능을 보여줄 수 있는 파일을 첨부한다.

#### 태그 종류

| 태그       | 설명                                     |
| ---------- | ---------------------------------------- |
| [Feat]     | 새로운 기능 추가                         |
| [Fix]      | 버그 수정                                |
| [Refactor] | 코드 리팩토링 (기능 변경 없이 구조 개선) |
| [Style]    | 코드 포맷팅, 들여쓰기 수정 등            |
| [Docs]     | 문서 관련 수정                           |
| [Test]     | 테스트 코드 추가 또는 수정               |
| [Chore]    | 빌드/설정 관련 작업                      |
| [Design]   | UI 디자인 수정                           |
| [Hotfix]   | 운영 중 긴급 수정                        |
| [CI/CD]    | 배포 및 워크플로우 관련 작업             |

- **PR 예시**:
  - [Init] 프로젝트 초기 세팅
  - [Feat] 메인페이지 개발

<br>

## ⌨️ Code Styling

**줄바꿈**

- 파라미터가 2개 이상일 경우 파라미터 이름을 기준으로 줄바꿈 한다.

```swift
let actionSheet = UIActionSheet(
  title: "정말 계정을 삭제하실 건가요?",
  delegate: self,
  cancelButtonTitle: "취소",
  destructiveButtonTitle: "삭제해주세요"
)

```

- if let 구문이 길 경우에 줄바꿈 한다

```swift
if let user = self.veryLongFunctionNameWhichReturnsOptionalUser(),
   let name = user.veryLongFunctionNameWhichReturnsOptionalName(),
  user.gender == .female {
  // ...
}

```

**주석**

- 나중에 추가로 작업해야 할 부분에 대해서는 `// TODO: - xxx` 주석을 남기도록 한다.
- 코드의 섹션을 분리할 때는 `// MARK: - xxx` 주석을 남기도록 한다.
- 함수에 대해 전부 주석을 남기도록 하여 무슨 액션을 하는지 알 수 있도록 한다.

**색상, 폰트**

- 색상은 Color 등록 후 사용한다. (rgb코드 사용 금지)
- 폰트는 Font extension 선언 후 사용한다.

**컴포넌트**

- 2개 이상의 View에서 사용하는 컴포넌트는 Components 폴더 내부에 생성한다.
- 1개의 View에서 사용하는 컴포넌트는 해당 View 하단에 작성한다.

<br>

## 📂 프로젝트 구조

- App - 앱의 진입점과 전반적인 앱 흐름 담당
- Core - 공통으로 사용되는 핵심 도메인 레이어
- Features - 사용자에게 노출되는 실제 기능 단위
- Resource - 앱에서 사용되는 정적 리소스
- Service - 외부 시스템과의 상호작용을 담당하는 레이어
- Utilities - 전역에서 사용되는 보조 기능 함수
