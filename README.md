# 프로젝트 소개

<img width="6662" height="2968" alt="앱스크린샷_IOS" src="https://github.com/user-attachments/assets/2b05209b-df0c-4864-a910-16abf3514c96" />


모임을 만들고 초대된 사람들과
📍 장소를 공유하고
💬 의견을 나누고
🗓 일정을 정할 수 있는 올인원 모임 관리 앱 `어디`입니다.

# 기술스택
|분류|사용 기술 및 구조|
|----|-----|
|View FrameWork| SwiftUI |
|FirstParty| Combine, ShareExtention, APNs|
|Social Login| Naver, Kakao, Apple |
|Architecture| MVVM |
|Design Pattern| Mediator Pattern |
|ThirdParty| Moya, FCM, KakaoAuth, NaverAuth|
|Dependency Injection| Swinject|

# 프로젝트 구조


<img width="1424" height="952" alt="Group 135" src="https://github.com/user-attachments/assets/c1d9b2d4-e7ec-49fb-a122-6a24d455be2f" />


## Layer 및 주요 구현 사항

### ViewModels
>각 View별로 사용자와의 상호작용에 필요한 작업을 각 Core를 통해 호출하고,
그 결과로 받은 데이터를 View에 전달해 화면에 보여줍니다.

---


### CoreMediator
각 Core는 필요한 데이터를 얻기 위해 서로를 참조해야 하며, 이로 인해 Core 간 결합도가 높아지고 유지보수가 어려워질 위험이 있습니다. 이러한 문제를 해결하기 위해 Core 간 상호작용을 Mediator가 중재하도록 하여 각 Core 간 의존성을 줄이고 구조를 단순화했습니다.


**적용 전**
<img width="1350" height="1200" alt="Group 137" src="https://github.com/user-attachments/assets/63ef8ace-1d94-4be5-8df6-3f4258b8b621" />

각 Core들이 서로 다른 Core에 의존하여 자신이 동작하기 위해 필요한 데이터를 얻어야 하는 두 가지 시나리오를 예시로 들겠습니다.

1. **`사용자가 로그인하여 사용자 정보가 변경된 경우, 친구 목록을 갱신할 수 있어야 합니다.`**
따라서 CommunityCore는 AuthenticationCore에 의존하여 사용자 정보의 변경을 감지하다가 로그인 상태가 바뀌면 친구 목록을 다시 읽어옵니다.
2. **`특정 친구와 함께한 모임을 확인할 수 있어야 합니다.`**
따라서 MeetingCore와 PlaceCore는 CommunityCore에 의존하여 친구 목록의 변경을 감지하다가 친구 목록 데이터가 바뀌면 해당 친구와 연관된 모임이 무엇인지, 또 각각의 공유된 장소는 무엇인지 준비합니다.

한 Core가 자신의 동작에 필요한 다른 Core들에 직접 의존하는 `M:N`관계에서는 구현 코드가 복잡해지고 유지보수에 불리한 구조가 됩니다. (예: 다른 Core에서 발생한 에러를 호출한 Core에서 직접 핸들링 하기 위해 추가적인 방어코드를 작성하게 됨.)
<br>

**적용 후**
<img width="1836" height="2260" alt="Group 133" src="https://github.com/user-attachments/assets/1dd0a165-a21f-436c-a702-d953a82395e4" />


각 Core는 더이상 서로를 의존하지 않으며, 단지 중재자에 의존합니다.
중재자는 각 Core로부터 이벤트를 보고받고 해당 이벤트와 관련된 Core에게 지시를 내립니다.

동일한 시나리오로 살펴보면 다음과 같은 변화가 있습니다.
1. **`사용자가 로그인하여 사용자 정보가 변경된 경우, 친구 목록을 갱신할 수 있어야 합니다.`**
Auth-Core는 사용자 로그인 동작을 처리한 뒤 사용자가 로그인에 성공했음을 중재자에게 보고합니다. 중재자는 Commu-Core에게 친구 목록을 갱신하라고 지시합니다.
2. **`특정 친구와 함께한 모임을 확인할 수 있어야 합니다.`**
Commu-Core는 친구 목록이 바뀌었음을 중재자에게 보고합니다. 중재자는 Meet-Core에게 변경된 친구와 연관된 모임을 찾으라고 지시합니다. 또한 Meet-Core는 연관된 모임을 찾았음을 중재자에게 보고합니다. 중재자는 PlaceCore에게 해당 모임에 공유된 장소가 무엇인지 찾으라고 지시합니다.

Core Layer는 중재자 패턴을 통해 `1:N`관계로 정리됩니다. Core간의 협력 관계는 중재자가 관리하게되고 각 Core는 더이상 서로를 의존하지 않고 각자 자신의 일만 열심히 수행하면 됩니다.

---

##### MediationProtocol
중재자가 Core에게 지시하기 위해 사용하는 Interface를 의미합니다.

**CommunityCore 예시**
```swift
protocol CommunityMediationProtocol {
    /// 현재 사용자의 친구 목록 로드를 지시, 중재자에 의해 호출됨
    /// - Parameters:
    ///     - 친구 목록을 로드할 사용자 식별자
    func loadFriends(with id: UInt64)
}
```

중재자는 ViewModel에 노출된 Interface인 CommunityCoreProtocol을 사용하지 않습니다. 그저 다른 Core에서 보고한 이벤트가 해당 Core와 연관되어 있는지 판단하여 추가 작업을 지시할 뿐입니다.
따라서 DIP(의존 역전 원칙)에 의거해 주어진 이벤트와 전혀 관련없는 메서드를 호출하지 않도록 중재자 전용의 Interface인 각각의 `MediatorProtocol`을 마련했습니다.

##### CoreMediatorProtocol
Core가 중재자의 도움을 받기 위해 사용하는 Interface를 의미합니다.

```swift
typealias CoreMediatorProtocol = CoreLinkageProtocol & Notifiable

protocol CoreLinkageProtocol: AnyObject {
    func attachAuthentificationCore(_ core: AuthentificationMediationProtocol)
    func attachCommunityCore(_ core: CommunityMediationProtocol)
    // ...
}

protocol Notifiable: AnyObject {
    func notify(event: CoreEvent)
}
```

```swift
enum CoreEvent {
    case userDidLogin(user: User)
    // ...
}
```

각 Core는 `CoreLinkageProtocol`을 통해 자신을 중재자에게 등록하며, 순환 참조 방지를 위해 중재자를 약하게 참조합니다. 또한 자신의 동작과 연관된 다른 Core의 후속 작업이 필요할 경우, 중재자에게 `CoreEvent`를 통해 보고합니다. 앞선 시나리오대로면 다음과 같습니다.

1. Auth-Core는 사용자가 로그인에 성공했음을 중재자에게 알립니다.
   * `mediator.notify(.userDidLogin(user: user)`
2. 중재자는 Commu-Core에게 친구 목록 갱신을 지시합니다.
   * `communityCore.loadFriends(with: user.id)`

<br>

---


### Core

> **`AuthenticationCore`**
> 사용자 정보 관리를 주요 관심사로 설정한 객체입니다.

<details>
<summary>코드 예시</summary>

```swift
protocol AuthentificationCoreProtocol: CoreProtocol {
    /// 사용자 정보
    var currentUser: AnyPublisher<User?, AuthentificationCoreError> { get }
    
    /// 로그인 필요 여부
    var isLoginNeeded: Bool { get }
    
    /// Redirection URL Handling
    func handleOpenURL(_ provider: AuthentificationProvider, _ url: URL)
    
    /// 애플 로그인
    func loginWithApple(auth: ASAuthorization)
    
    /// 카카오 로그인
    func loginWithKakao()
    
    /// 네이버 로그인
    func loginWithNaver()
    
    /// 자체 로그인
    func login(email: String, password: String)
    
    /// 로그아웃
    func logout()
}
```
</details>

<br>

> **`CommunityCore`**
> 친구 정보 관리를 주요 관심사로 설정한 객체입니다.

<details>
<summary>코드 예시</summary>
    
```swift
protocol CommunityCoreProtocol: CoreProtocol {
    /// 나의 친구 목록
    var friends: AnyPublisher<[UInt64: FriendRelationship], CommunityCoreError> { get }
    
    /// 친구 추가
    func createFriend(friend: FriendRelationship)
    /// 특정 친구 조회
    func fetchFriend(id: UInt64) -> FriendRelationship?
    /// 친구 삭제
    func deleteFriend(id: UInt64)
    /// 친구 즐겨찾기 토글
    func toggleBookmarkFriend(id: UInt64)
}
```
</details>
    
<br>

> **`MeetingCore`**
> 모임 정보 관리를 주요 관심사로 설정한 객체입니다.

<details>
<summary>코드 예시</summary>

```swift
protocol MeetingCoreProtocol: CoreProtocol {
    /// 나와 연관된 모임 목록
    var meetings: AnyPublisher<[UInt64: Meeting], MeetingCoreError> { get }
    /// 최근 살펴본 모임 정보
    var currentMeeting: AnyPublisher<Meeting?, MeetingCoreError> { get }
    
    /// 모임 일정 등록
    /// - Parameters:
    ///     - id: 모임의 고유 식별자
    func createSchedule(id: UInt64)
    /// 모임 일정 조회
    /// - Parameters:
    ///     - id: 모임의 고유 식별자
    ///
    func readSchedule(id: UInt64)
    /// 모임 일정 수정
    /// - Parameters:
    ///     - id: 모임의 고유 식별자
    func updateSchedule(id: UInt64)
    /// 모임 일정 삭제
    /// - Parameters:
    ///     - id: 모임의 고유 식별자
    func deleteSchedule(id: UInt64)
    /// 모임 생성
    /// - Parameters:
    ///     - info: 생성 중인 모임의 임시 정보
    func createMeeting(info: TemporaryMeetingInfo)
    /// 특정 모임 조회
    func fetchMeeting(id: UInt64) -> Meeting?
    /// 모임 수정
    /// - Parameters:
    ///     - id: 모임의 고유 식별자
    ///     - title: 모임 제목
    ///     - description: 모임 설명
    ///     - image: 모임 대표 이미지
    func updateMeeting(id: UInt64, title: String?, description: String?, image: UIImage?)
    /// 모임 종료
    /// - Parameters:
    ///     - id: 모임의 고유 식별자
    func endMeeting(id: UInt64)
    /// 모임 탈퇴
    /// - Parameters:
    ///     - id: 모임의 고유 식별자
    func exitMeeting(id: UInt64)
    /// 모임 초대
    /// - Parameters:
    ///     - id: 모임의 고유 식별자
    ///     - participantId: 초대 대상의 식별자
    func inviteParticipant(id: UInt64, participantId: UInt64)
    /// 모임 초대 수락
    /// - Parameters:
    ///     - id: 초대장 식별자
    func acceptInvitation(id: UInt64)
}
```
</details>    
    

<br>

> **`PlaceCore`**
> 모임별 장소 정보 관리를 주요 관심사로 설정한 객체입니다.

    
<details>
<summary>코드 예시</summary>

```swift
protocol PlaceCoreProtocol: CoreProtocol {
    /// 장소 목록
    var places: AnyPublisher<[UInt64: Place], PlaceCoreError> { get }
    /// 최근 찾은 장소 정보
    var currentPlace: AnyPublisher<Place?, PlaceCoreError> { get }
    /// 장소별 코멘트 목록
    /// - Note:
    ///     - Key: 장소 식별자
    ///     - Value: 해당 장소의 코멘트들
    ///     - Error: `PlaceCoreError`
    var currentPlaceComments: AnyPublisher<[Comment], PlaceCoreError> { get }
    
    /// 장소 생성
    /// - Parameters:
    ///     - meetingID: 모임 식별자
    ///     - name: 장소명
    ///     - address: 장소 주소
    func createPlace(meetingID: UInt64, name: String, address: String)
    /// 특정 장소 조회
    func fetchPlace(id: UInt64) -> Place?
    /// 장소 삭제
    func deletePlace(id: UInt64)
    /// 장소 선택
    func pickPlace(id: UInt64)
    /// 장소 좋아요 변경
    func togglePlaceLike(id: UInt64)
    /// 장소에 대한 코멘트 작성
    /// - Parameters:
    ///     - placeID: 장소 식별자
    ///     - description: 코멘트 내용
    func createComment(placeID: UInt64, description: String)
    /// 특정 코멘트 조회
    func fetchComment(id: UInt64) -> Comment?
    /// 장소에 대한 코멘트 수정
    func updateComment(id: UInt64, description: String)
    /// 장소에 대한 코멘트 삭제
    func deleteComment(id: UInt64)
    /// 사용자가 작성한 코멘트 여부 확인
    func isMyComment(comment: Comment) -> Bool
}
```
</details>
    

<br>

> **`SupportCore`**
> 공지사항, 고객문의 등 사용자 지원 기능 제공을 주요 관심사로 설정한 객체입니다.

    
<details>
<summary>코드 예시</summary>

```swift
protocol SupportCoreProtocol: CoreProtocol {
    /// 1:1 문의 목록
    var inquiries: AnyPublisher<[UInt64: Inquiry], SupportCoreError> { get }
    /// 공지사항 목록
    var announcements: AnyPublisher<[UInt64: Announcement], SupportCoreError> { get }
    
    /// 1:1문의 작성 - 사용자
    func createInquiry(title: String, content: String, images: [Data]?)
    /// 1:1문의 조회
    func fetchInquiry(id: UInt64) -> Inquiry?
    /// 1:1문의 답변 작성 - 관리자
    /// - Parameters:
    ///     - id: 문의 식별자
    ///     - content: 답변 내용
    func createAdminInquiryReply(id: UInt64, content: String)
    /// 공지사항 등록
    func createAnnouncement(title: String, content: String)
    /// 공지사항 조회
    func fetchAnnouncement(id: UInt64) -> Announcement?
    /// 공지사항 수정
    /// - Parameters:
    ///     - id: 문의 식별자
    ///     - title: 문의 제목
    ///     - content: 문의 내용
    func updateAnnouncement(id: UInt64, title: String?, content: String?)
    /// 공지사항 삭제
    /// - Parameters:
    ///     - id: 문의 식별자
    func deleteAnnouncement(id: UInt64)
}
```
</details>
    
<br>


---
### Service
> #### APIService
    Moya 라이브러리를 활용하여 네트워크 통신을 하고,
    Response Data를 DTO로 변환해주는 역할을 하는 객체입니다.


> #### TokenStorage

#### Token관리 프로세스
    JWT의 accessToken과 refreshToken을 keychain에 저장 및 관리 하는 객체입니다.
    
[이미지]

API 통신을 위해 두가지 방법이 있습니다.
1. accessToken이 필요하지 않은 API통신
2. accessToken이 필요한 API통신
    
accessToken이 필요한 경우, plugin의 prepare 메소드 내부에서 token을 가져와 urlRequest의 header에 삽입 하여 해당 token을 가지고 API통신을 진행합니다.
서버에서 내려오는 response satuscode가 401 시, interceptor 내부에서 retry 메소드로 refreshToken을 통해 새로운 accessToken 발급 및 새로 받아온 Token을 저장하여 새로 받아온 accessToken으로 API 통신을 진행합니다.

---
    
### SwiftUI Reusable Components

SwiftUI로 구현된 재사용 가능한 UI Component를 소개합니다.
    
#### Tooltip
    
특정 요소에 대해 말풍선 모양의 안내 문구를 표시해주는 화면입니다.
추가적인 설명이 필요한 UI 요소에 수정자를 붙여 사용합니다.
설정 값들을 전달하여 말풍선의 모양을 조정시킬 수 있습니다.
`label`인자를 통해 Tooltip에 해당하는 내용을 전달할 수 있습니다.
    
![tooltip](https://github.com/user-attachments/assets/004ead64-a9e2-484e-9614-ae11e851a580)


<br>
    
**참고자료**
* [TipKit](https://developer.apple.com/documentation/tipkit/)
* [AxisTooltip](https://github.com/jasudev/AxisTooltip)
    
-----
    
**Floater**

사용자에게 응답의 결과를 알려주기 위해 잠시 나타났다 사라지는 화면입니다.    
컨테이너뷰에 수정자를 붙여 사용합니다.
등장 조건이 만족되면 부유하는 팝오버 화면이 하단에 나타났다가 일정 시간이 지난 후 사라집니다.
아이콘을 넣어 응답 결과의 성격(성공 또는 실패)을 나타낼 수도 있고, 문구만 작성할 수도 있습니다.
    
    
---
### iOS Team
| <a href="https://github.com/bamsak"><img src="https://avatars.githubusercontent.com/u/114239407?v=4" width="90" height="90"></a> | <a href="https://github.com/Remaked-Swain"><img src="https://avatars.githubusercontent.com/u/99116619?v=4" width="90" height="90"></a>     |
|------|---------|
| [@bamsak](https://github.com/bamsak)  |  [@SwainYun](https://github.com/Remaked-Swain) |


