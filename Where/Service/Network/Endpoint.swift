//
//  Endpoint.swift
//  Where
//
//  Created by Swain Yun on 3/30/25.
//

import Foundation
import Moya

enum Endpoint {
    // MARK: User Related
    /// 회원가입
    case register(dto: RegisterDTO.Request)
    /// 회원탈퇴
    case unregister(userID: UInt64)
    /// 로그인
    case login(dto: LoginDTO.Request)
    /// 이메일 중복확인
    case checkEmailDuplication(dto: CheckEmailDuplicationDTO.Request)
    /// 마이페이지 사용자 정보 조회
    case readUserInfo(userID: UInt64)
    /// 프로필이미지 등록
    case uploadProfileImage(userID: UInt64, image: Data)
    /// accessToken 재발급
    case reissueAccessToken(refreshToken: String)
    
    // MARK: - Friends Related
    /// 친구 조회
    case readFriends(userID: UInt64)
    /// 친구 삭제
    case deleteFriend(dto: DeleteFriendDTO.Request)
    /// 친구 북마크
    case bookmarkFriend(dto: BookmarkFriendDTO.Request)
    
    // MARK: Meeting Related
    /// 모임 생성
    case createMeeting(encodedMeetingData: Data, imageData: Data?)
    /// 모임 수정
    case updateMeeting(encodedMeetingData: Data, imageData: Data?)
    /// 모임 종료
    case endMeeting(dto: EndMeetingDTO.Request)
    /// 모임 탈퇴
    case leaveMeeting(dto: LeaveMeetingDTO.Request)
    /// 모임 초대현황 조회
    case readInvitationStatus(meetingID: UInt64)
    /// 모임 정보 조회
    case readMeetingDetail(userID: UInt64)
    /// 모임 초대
    case inviteFriends(dto: InviteFriendsDTO.Request)
    /// 모임 초대 수락
    case acceptMeeetingInvitation(dto: AcceptMeeetingInvitationDTO.Request)
    /// 모임 초대 수락 - 링크
    case acceptMeetingInvitationByLink(dto: AcceptMeetingInvitationByLinkDTO.Request)
    /// 초대장 링크로 모임 정보 조회
    case readMeetingDetailForInvitationLink(inviteCode: String)
    
    // MARK: Schedule Related
    /// 모임 일정 등록
    /// - Note:
    ///     - date: yyyy-MM-dd 형식
    ///     - time: HH:mm 형식
    case createSchedule(dto: CreateScheduleDTO.Request)
    /// 모임 일정 조회
    case readSchedule(meetingID: UInt64)
    /// 모임 일정 수정
    /// - Note:
    ///     - date: yyyy-MM-dd 형식
    ///     - time: HH:mm 형식
    case updateSchedule(dto: UpdateScheduleDTO.Request)
    /// 모임 일정 삭제
    case deleteSchedule(dto: DeleteScheduleDTO.Request)
    
    // MARK: Place Related
    /// 장소 생성
    case createPlace(dto: CreatePlaceDTO.Request)
    /// 장소 조회
    case readPlaceDetail(userID: UInt64, meetingID: UInt64)
    /// 장소 삭제
    case deletePlace(dto: DeletePlaceDTO.Request)
    /// 장소 선택
    case pickPlace(dto: PickPlaceDTO.Request)
    /// 장소 좋아요 변경
    case togglePlaceLike(dto: TogglePlaceLikeDTO.Request)
    /// 장소 코멘트 작성
    case createComment(dto: CreateCommentDTO.Request)
    /// 장소 코멘트 수정
    case updateComment(dto: UpdateCommentDTO.Request)
    /// 장소 코멘트 삭제
    case deleteComment(dto: DeletePlaceDTO.Request)
    /// 장소 코멘트 조회
    case readComments(placeID: UInt64)
    
    // MARK: Document Related
    /// 1:1문의 조회 - 일반 사용자
    case readUserInquiries(userID: UInt64)
    /// 1:1문의 작성 - 일반 사용자
    case createUserInquiry(inquiryData: Data, imageDatas: [Data]?)
    /// 1:1문의 조회 - 관리자
    case readAdminInquiries(criteria: Int)
    /// 1:1문의 답변 등록 - 관리자
    case createAdminInquiryReply(dto: CreateAdminInquiryReplyDTO.Request)
    /// 공지사항 조회
    case readAnnouncements
    /// 공지사항 등록
    case createAnnouncement(dto: CreateAnnouncementDTO.Request)
    /// 공지사항 수정
    case updateAnnouncement(dto: UpdateAnnouncementDTO.Request)
    /// 공지사항 삭제
    case deleteAnnouncement(dto: DeleteAnnouncementDTO.Request)
    /// FAQ 조회
    case readFAQs
    /// FAQ 등록
    case createFAQ(dto: CreateFAQDTO.Request)
    /// FAQ 수정
    case updateFAQ(dto: UpdateFAQDTO.Request)
    /// FAQ 삭제
    case deleteFAQ(dto: DeleteFAQDTO.Request)
}

// MARK: TargetType Confirmation
extension Endpoint: TargetType {
    var baseURL: URL {
        URL(string: "https://audiwhere.codns.com/api")!
    }
    
    var path: String {
        switch self {
            // MARK: - User Related
        case .register:
            return "\(basePath)/signup"
        case .unregister(let userID):
            return "\(basePath)/\(userID)"
        case .login:
            return "\(basePath)/login"
        case .checkEmailDuplication:
            return "\(basePath)/checkEmail"
        case .readUserInfo(let userID):
            return "\(basePath)/mypage/\(userID)"
        case .uploadProfileImage(let userID, _):
            return "\(basePath)/\(userID)/uploadProfile"
        case .reissueAccessToken:
            return "\(basePath)/refresh"
            
            // MARK: - Friends Related
        case .readFriends(let userID):
            return "\(basePath)/\(userID)"
        case .deleteFriend:
            return "\(basePath)"
        case .bookmarkFriend:
            return "\(basePath)/bookmark"
        case .createMeeting, .updateMeeting, .leaveMeeting:
            return "\(basePath)"
        case .endMeeting:
            return "\(basePath)/finish"
        case .readInvitationStatus(let meetingID):
            return "\(basePath)/participant/\(meetingID)"
        case .readMeetingDetail(let userID):
            return "\(basePath)/\(userID)"
        case .inviteFriends:
            return "\(basePath)/invite"
        case .acceptMeeetingInvitation:
            return "\(basePath)/invite/ok"
        case .acceptMeetingInvitationByLink:
            return "\(basePath)/invite/ok/link"
        case .readMeetingDetailForInvitationLink(let inviteCode):
            return "\(basePath)/invite/\(inviteCode)"
            
            // MARK: - Schedule Related
        case .createSchedule, .updateSchedule, .deleteSchedule:
            return "\(basePath)"
        case .readSchedule(let userID):
            return "\(basePath)/\(userID)"
            
            // MARK: - Place Related
        case .createPlace, .deletePlace, .readPlaceDetail:
            return "\(basePath)"
        case .pickPlace:
            return "\(basePath)/pick"
        case .togglePlaceLike:
            return "\(basePath)/like"
            
            // MARK: - Place Comment
        case .createComment, .updateComment, .deleteComment:
            return "\(basePath)/comment"
        case .readComments(let placeID):
            return "\(basePath)/\(placeID)"
            
            // MARK: -  Document Related
        case .readUserInquiries(let userID):
            return "\(basePath)/\(userID)"
        case .createUserInquiry:
            return "\(basePath)"
        case .readAdminInquiries(let criteria):
            return "\(basePath)/inquiry\(criteria)"
        case .createAdminInquiryReply:
            return "\(basePath)/inquiry"
            
        case .readAnnouncements:
            return "/notice"
        case .createAnnouncement, .updateAnnouncement, .deleteAnnouncement:
            return "\(basePath)/notice"
        case .readFAQs:
            return "/FAQ"
        case .createFAQ, .updateFAQ, .deleteFAQ:
            return "\(basePath)/FAQ"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .readUserInquiries, .readAdminInquiries, .readFAQs, .readAnnouncements, .readUserInfo, .readMeetingDetail, .readInvitationStatus, .readSchedule, .readPlaceDetail, .readComments, .readFriends, .readMeetingDetailForInvitationLink: .get
        case .createAdminInquiryReply, .createUserInquiry, .createFAQ, .updateFAQ, .createAnnouncement, .login, .createMeeting, .inviteFriends, .acceptMeeetingInvitation, .acceptMeetingInvitationByLink, .checkEmailDuplication, .createSchedule, .createPlace, .pickPlace, .togglePlaceLike, .createComment, .uploadProfileImage, .register, .reissueAccessToken: .post
        case .updateAnnouncement, .endMeeting, .updateMeeting, .updateSchedule, .updateComment, .bookmarkFriend: .put
        case .deleteFAQ, .deleteAnnouncement, .leaveMeeting, .deleteSchedule, .deletePlace, .deleteComment, .deleteFriend, .unregister: .delete
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .register(let dto):
            return .requestJSONEncodable(dto)
        case .unregister:
            return .requestPlain
        case .login(let dto):
            return .requestJSONEncodable(dto)
        case .checkEmailDuplication(let dto):
            return .requestJSONEncodable(dto)
        case .readUserInfo:
            return .requestPlain
        case .uploadProfileImage(let userId, let image):
            
            // TODO: 현재 API가 나와있지 않은 상태, API 나오면 업데이트 예정
            return .requestPlain
            
        case .reissueAccessToken(let refreshToken):
            var formData = [MultipartFormData]()
            formData.append(.init(provider: .data(refreshToken.data(using: .utf8) ?? Data()), name: "refreshToken", mimeType: "application/json"))
            return .uploadMultipart(formData)
        case .readFriends:
            return .requestPlain
        case .deleteFriend(let dto):
            return .requestJSONEncodable(dto)
        case .bookmarkFriend(let dto):
            return .requestJSONEncodable(dto)
        case .createMeeting(let encodedMeetingData, let imageData):
            var formData = [MultipartFormData]()
            formData.append(.init(provider: .data(encodedMeetingData), name: "data", mimeType: "application/json"))
            if let imageData = imageData {
                formData.append(.init(provider: .data(imageData), name: "image"))
            }
            return .uploadMultipart(formData)
        case .updateMeeting(let encodedMeetingData, let imageData):
            var formData = [MultipartFormData]()
            formData.append(.init(provider: .data(encodedMeetingData), name: "data", mimeType: "application/json"))
            formData.append(.init(provider: .data(imageData ?? Data()), name: "image"))
            return .uploadMultipart(formData)
        case .endMeeting(let dto):
            return .requestJSONEncodable(dto)
        case .leaveMeeting(let dto):
            return .requestJSONEncodable(dto)
        case .readInvitationStatus, .readMeetingDetail:
            return .requestPlain
        case .inviteFriends(let dto):
            return .requestJSONEncodable(dto)
        case .acceptMeeetingInvitation(let dto):
            return .requestJSONEncodable(dto)
        case .acceptMeetingInvitationByLink(let dto):
            return .requestJSONEncodable(dto)
        case .readMeetingDetailForInvitationLink:
            return .requestPlain
        case .createSchedule(let dto):
            return .requestJSONEncodable(dto)
        case .readSchedule:
            return .requestPlain
        case .updateSchedule(let dto):
            return .requestJSONEncodable(dto)
        case .deleteSchedule(let dto):
            return .requestJSONEncodable(dto)
        case .createPlace(let dto):
            return .requestJSONEncodable(dto)
        case .readPlaceDetail(let userID, let meetingID):
            let parameters = ["meetingId": meetingID, "userId": userID]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case .deletePlace(let dto):
            return .requestJSONEncodable(dto)
        case .pickPlace(let dto):
            return .requestJSONEncodable(dto)
        case .togglePlaceLike(let dto):
            return .requestJSONEncodable(dto)
        case .createComment(let dto):
            return .requestJSONEncodable(dto)
        case .updateComment(let dto):
            return .requestJSONEncodable(dto)
        case .deleteComment(let dto):
            return .requestJSONEncodable(dto)
        case .readComments:
            return .requestPlain
        case .readUserInquiries:
            return .requestPlain
        case .createUserInquiry(let inquiryData, let imageDatas):
            var formData = [MultipartFormData]()
            formData.append(.init(provider: .data(inquiryData), name: "data", mimeType: "application/json"))
            
            guard let imageDatas = imageDatas
            else {
                formData.append(.init(provider: .data(Data()), name: "image"))
                return .uploadMultipart(formData)
            }
            
            imageDatas.enumerated().forEach { formData.append(.init(provider: .data($0.element), name: "image\($0.offset)")) }
            return .uploadMultipart(formData)
        case .readAdminInquiries:
            return .requestPlain
        case .createAdminInquiryReply(let dto):
            return .requestJSONEncodable(dto)
        case .readAnnouncements:
            return .requestPlain
        case .createAnnouncement(let dto):
            return .requestJSONEncodable(dto)
        case .updateAnnouncement(let dto):
            return .requestJSONEncodable(dto)
        case .deleteAnnouncement(let dto):
            return .requestJSONEncodable(dto)
        case .readFAQs:
            return .requestPlain
        case .createFAQ(let dto):
            return .requestJSONEncodable(dto)
        case .updateFAQ(let dto):
            return .requestJSONEncodable(dto)
        case .deleteFAQ(let dto):
            return .requestJSONEncodable(dto)
            
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .unregister, .readUserInfo, .readInvitationStatus, .readMeetingDetail, .readMeetingDetailForInvitationLink, .readPlaceDetail, .readComments, .readSchedule, .readFriends, .readUserInquiries, .readAdminInquiries, .readAnnouncements, .readFAQs:
            return nil
        default:
            return ["Content-Type": "application/json"]
        }
    }
    
    var validationType: ValidationType { .successCodes }
}

private extension Endpoint {
    var basePath: String {
        switch self {
        case .register, .unregister, .login, .checkEmailDuplication,.readUserInfo, .uploadProfileImage:
            return "/user"
        case .readFriends, .deleteFriend, .bookmarkFriend:
            return "/friend"
        case .createMeeting, .updateMeeting, .endMeeting, .leaveMeeting, .readInvitationStatus, .readMeetingDetail, .acceptMeeetingInvitation, .acceptMeetingInvitationByLink, .readMeetingDetailForInvitationLink, .inviteFriends:
            return "/meeting"
        case .createSchedule, .readSchedule, .updateSchedule, .deleteSchedule:
            return "/schedule"
        case .createPlace, .readPlaceDetail, .deletePlace, .pickPlace, .togglePlaceLike, .createComment, .updateComment, .deleteComment, .readComments:
            return "/place"
        case .readUserInquiries, .createUserInquiry:
            return "/inquiry"
        case .readAdminInquiries, .createAdminInquiryReply, .createAnnouncement, .updateAnnouncement, .deleteAnnouncement, .createFAQ, .updateFAQ, .deleteFAQ:
            return "/admin"
        case .reissueAccessToken:
            return "/token"
        @unknown default:
            return ""
        }
    }
}
