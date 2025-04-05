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
    case unregister(userId: UInt64)
    /// 로그인
    case login(email: String, password: String)
    /// 이메일 중복확인
    case checkEmailDuplication(email: String)
    /// 마이페이지 사용자 정보 조회
    case readUserInfo(userId: UInt64)
    /// 프로필이미지 등록
    case uploadProfileImage(userId: UInt64, image: Data)
    /// 네이버 로그인API - 사용자 정보 조회
    case readNaverUserInfo(token: String)
    /// 친구 조회
    case readFriends(userId: UInt64)
    /// 친구 삭제
    case deleteFriend(userId: UInt64, friendId: UInt64)
    /// 친구 북마크
    case bookmarkFriend(userId: UInt64, friendId: UInt64)
    
    // MARK: Meeting Related
    /// 모임 생성
    case createMeeting(userId: UInt64, temp: TemporaryMeetingInfo)
    /// 모임 수정
    case updateMeeting(userId: UInt64, meetingId: UInt64, title: String?, description: String?, image: Data?)
    /// 모임 종료
    case endMeeting(userId: UInt64, meetingId: UInt64)
    /// 모임 탈퇴
    case leaveMeeting(userId: UInt64, meetingId: UInt64)
    /// 모임 초대현황 조회
    case readInvitationStatus(userId: UInt64, meetingId: UInt64)
    /// 모임 정보 조회
    case readMeetingDetail(userId: UInt64)
    /// 모임 초대
    case inviteFriends(userId: UInt64, meetingId: UInt64, friendId: UInt64)
    /// 모임 초대 수락
    case acceptMeeetingInvitation(meetingId: UInt64)
    /// 모임 초대 수락 - 링크
    case acceptMeetingInvitationByLink(userId: UInt64, link: URL)
    
    // MARK: Schedule Related
    /// 모임 일정 등록
    /// - Note:
    ///     - date: yyyy-MM-dd 형식
    ///     - time: HH:mm 형식
    case createSchedule(userId: UInt64, meetingId: UInt64, date: String, time: String)
    /// 모임 일정 조회
    case readSchedule(meetingId: UInt64)
    /// 모임 일정 수정
    /// - Note:
    ///     - date: yyyy-MM-dd 형식
    ///     - time: HH:mm 형식
    case updateSchedule(userId: UInt64, meetingId: UInt64, date: String?, time: String?)
    /// 모임 일정 삭제
    case deleteSchedule(userId: UInt64, meetingId: UInt64)
    
    // MARK: Place Related
    /// 장소 생성
    case createPlace(userId: UInt64, meetingId: UInt64, name: String, address: String)
    /// 장소 조회
    case readPlaceDetail(userId: UInt64, meetingId: UInt64)
    /// 장소 삭제
    case deletePlace(userId: UInt64, placeId: UInt64)
    /// 장소 선택
    case pickPlace(userId: UInt64, placeId: UInt64)
    /// 장소 좋아요 변경
    case togglePlaceLike(userId: UInt64, placeId: UInt64, isLike: Bool)
    /// 장소 코멘트 작성
    case createComment(userId: UInt64, placeId: UInt64, description: String)
    /// 장소 코멘트 수정
    case updateComment(userId: UInt64, commentId: UInt64, description: String)
    /// 장소 코멘트 삭제
    case deleteComment(userId: UInt64, commentId: UInt64)
    /// 장소 코멘트 조회
    case readComments(placeId: UInt64)
    
    // MARK: Document Related
    /// 1:1문의 조회 - 일반 사용자
    case readUserInquiries(userId: UInt64)
    /// 1:1문의 작성 - 일반 사용자
    case createUserInquiry(userId: UInt64, title: String, content: String)
    /// 1:1문의 조회 - 관리자
    case readAdminInquiries(criteria: Int)
    /// 1:1문의 답변 등록 - 관리자
    case createAdminInquiryReply(inquiryId: UInt64, content: String)
    /// 공지사항 조회
    case readAnnouncements
    /// 공지사항 등록
    case createAnnouncement(title: String, content: String)
    /// 공지사항 수정
    case updateAnnouncement(announcementId: UInt64, title: String, content: String)
    /// 공지사항 삭제
    case deleteAnnouncement(announcementId: UInt64)
    /// FAQ 조회
    case readFAQs
    /// FAQ 등록
    case createFAQ(title: String, content: String)
    /// FAQ 수정
    case updateFAQ(inquiryId: UInt64, title: String, content: String)
    /// FAQ 삭제
    case deleteFAQ(inquiryId: UInt64)
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
