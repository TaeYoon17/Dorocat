# Dorocat - Focus Cute Timer
> 빠르게 설정하고 실행할 수 있는 뽀모도로 타이머

[![AppstoreBlack](https://github.com/user-attachments/assets/0c3620d2-5f78-4b2d-9edc-076f6e4716ee)](https://apps.apple.com/kr/app/dorocat-cute-focus-timer/id6480333786)
![Group_28](https://github.com/user-attachments/assets/d2f81bf0-c227-4af6-88ec-d66cfa4bfd22)
### 프로젝트 요약


- 디자이너 요청으로 시작한 프로젝트, 사용자가 직접 쉬는 시간, 작업 주기를 설정하고 기록 할 수 있는 타이머
- 팀 프로젝트 - 디자이너 1, **iOS 개발 1**
- 2024.03.02 ~ 2024.07.28 - 업데이트 진행 중
- iOS App - Minimum deployment target **17.0**

맡은 역할: iOS 개발
진행 기간: 2024.03 ~ 2024.08
팀 구성: iOS 개발 1, 디자이너 1
### 사용 기술 목록

| **Services, Technology** | **Stack** |
| --- | --- |
| Architectrue | TCA, Clean Architecture |
| Asynchronous | Swift Concurrency, Combine |
| UI | SwiftUI |
| Pay | StoreKit |
| DataBase | CoreData |
| Apple APIs | UNNotification, Haptics, LiveActivity |

# 타이머 사이클 구조
<img width="434" alt="%E1%84%89%E1%85%A1%E1%84%8B%E1%85%B5%E1%84%8F%E1%85%B3%E1%86%AF" src="https://github.com/user-attachments/assets/021cdfa9-f16c-4978-bf1b-dde0cf0fec58">


## 주요 제공 서비스



### 1. 타이머
![Group_1597880432](https://github.com/user-attachments/assets/1288e722-311c-4a18-8552-bc673d8fd8a8)


### 2. LiveActivity 및 Notification 제공
https://github.com/user-attachments/assets/9578d390-14de-4091-8cc6-cba4d6363168

### 3. 유료 고양이 애셋 변경 기능 제공
![%E1%84%8B%E1%85%B2%E1%84%85%E1%85%AD%E1%84%80%E1%85%A7%E1%86%AF%E1%84%8C%E1%85%A6](https://github.com/user-attachments/assets/cce5b3aa-f6d9-4c97-b966-48e00d668d6a)

### 주요 기술 구현 특징

| **Keyword** | **Description Link** |
| --- | --- |
| **SwiftUI** | [iPad ConfirmationDialog 에러 대응](https://arpple.tistory.com/60) |
| **TCA 및 앱 아키텍처** | [Controller를 이용한 전략 패턴 사용 및 의존성 분리](https://arpple.tistory.com/52) |
| **LiveActivity** | [LiveActivity에서 AppIntent를 사용한 버튼 처리하기](https://arpple.tistory.com/67) |
| **Swift** | [Task.Sleep vs Timer](https://arpple.tistory.com/51) |

## 회고

### 1. 기획의 변경과 유연한 앱 설계

개발 도중 여러 기획 변경 사항 대응

1. **타이머 정책 변경**: Break Time 종료 후 즉시 Focus Time으로 전환하던 정책에서 StandBy 상태를 추가하는 방향으로 변경
2. **DB API 변경**: 아이패드 지원과 iCloud 연동을 위해, RealmDB에서 CoreData로 데이터베이스 API 변경
3. **BM 변경**: 기존 기능 제한 BM이 HIG 리젝 사유가 될 수 있어, 앱 내 고양이 캐릭터 구매 방식으로 BM을 변경

타이머 로직 복잡성을 염두해 **Clean Architecture**와 **TCA**를 적용하여 사전 기능 분리

기획 변경 시 전체 프로젝트를 재구성하지 않고 영향을 받는 부분만 수정, 개발 진행

유연한 앱 설계의 중요성을 더욱 실감

### 2. 안정성과 유저 추적의 필요성

실제 인-앱 결제 구매를 한 유저가 생겨 오류 없는 앱을 제공하는 것에 대한 책임감을 가짐
Firebase Crashlytics를 도입해 에러 모니터링을 시작, 테스트 기반으로 안정성을 높이는 업데이트의 필요성을 느낌

한편, 구매 전환율이 다소 아쉬워, 수익 증대 방안 모색
Firebase Analytics와 같은 도구를 활용해 유저 사용 데이터를 추적할 필요성을 느낌
