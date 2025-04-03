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
    case register
    /// 회원탈퇴
    case unregister
    /// 로그인
    case login
    /// 이메일 중복확인
    case checkEmailDuplication(email: String)
    /// 마이페이지 사용자 정보 조회
    case readUserInfo
    /// 프로필이미지 등록
    case uploadProfileImage(image: Data)
    /// 네이버 로그인API - 사용자 정보 조회
    case readNaverUserInfo(token: String)
    /// 친구 조회
    case readFriends
    /// 친구 삭제
    case deleteFriend
    /// 친구 북마크
    case bookmarkFriend
    
    // MARK: Meeting Related
    /// 모임 생성
    case createMeeting
    /// 모임 수정
    case updateMeeting
    /// 모임 탈퇴
    case leaveMeeting
    /// 모임 초대현황 조회
    case readInvitationStatus
    /// 모임 정보 조회
    case readMeetingDetail
    /// 모임 초대
    case inviteFriends
    /// 모임 초대 수락
    case acceptMeeetingInvitation
    
    // MARK: Schedule Related
    /// 모임 일정 등록
    case createSchedule
    /// 모임 일정 조회
    case readSchedule
    /// 모임 일정 수정
    case updateSchedule
    /// 모임 일정 삭제
    case deleteSchedule
    
    // MARK: Place Related
    /// 장소 생성
    case createPlace
    /// 장소 조회
    case readPlaceDetail
    /// 장소 삭제
    case deletePlace
    /// 장소 선택
    case pickPlace
    /// 장소 좋아요 변경
    case togglePlaceLike
    /// 장소 코멘트 작성
    case createComment
    /// 장소 코멘트 수정
    case updateComment
    /// 장소 코멘트 삭제
    case deleteComment
    /// 장소 코멘트 조회
    case readComments
    
    // MARK: Document Related
    /// 1:1문의 조회 - 일반 사용자
    case readUserInquiries
    /// 1:1문의 작성 - 일반 사용자
    case createUserInquiry
    /// 1:1문의 조회 - 관리자
    case readAdminInquiries
    /// 1:1문의 답변 등록 - 관리자
    case createAdminInquiryReply
    /// 공지사항 조회
    case readAnnouncements
    /// 공지사항 등록
    case createAnnouncement
    /// 공지사항 수정
    case updateAnnouncement
    /// 공지사항 삭제
    case deleteAnnouncement
    /// FAQ 조회
    case readFAQs
    /// FAQ 등록
    case createFAQ
    /// FAQ 수정
    case updateFAQ
    /// FAQ 삭제
    case deleteFAQ
}

// MARK: TargetType Confirmation
//extension Endpoint: TargetType {
//    var baseURL: URL {
//        URL(string: "BaseURL")!
//    }
//    
//    var path: String {
//        
//    }
//    
//    var method: Moya.Method {
//        
//    }
//    
//    var task: Moya.Task {
//        
//    }
//    
//    var headers: [String: String]? {
//
//    }
//    
//    var validationType: ValidationType { .successCodes }
//}
