//
//  SupportCore.swift
//  Where
//
//  Created by Swain Yun on 4/5/25.
//

import Foundation
import Combine

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

protocol SupportMediationProtocol {
    /// 1:1문의 목록 로드를 지시, 중재자에 의해 호출됨
    func loadInquiries()
    /// 1:1문의 목록 로드를 지시, 중재자에 의해 호출됨
    /// - Note: 관리자 권한 메서드입니다.
    func loadAdminInquiries()
    /// 공지사항, FAQ 목록 로드를 지시, 중재자에 의해 호출됨
    func loadAnnouncements()
    /// 현재 사용자 식별자를 설정, 중재자에 의해 호출됨
    func setCurrentUserID(_ id: UInt64?)
}

enum SupportCoreError: Error {
    case networkingError(Error)
    case userIDNotSet
}

final class SupportCore {
    weak var mediator: Notifiable?
    
    private var _inquiries = [UInt64: Inquiry]()
    private var _announcements = [UInt64: Announcement]()
    
    private let inquiriesSubject = CurrentValueSubject<[UInt64: Inquiry], SupportCoreError>([:])
    private let announcementsSubject = CurrentValueSubject<[UInt64: Announcement], SupportCoreError>([:])
    
    private var currentUserID: UInt64?
    private let tokenStorage: TokenStorageProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(
        tokenStorage: TokenStorageProtocol
    ) {
        self.tokenStorage = tokenStorage
        subscribe()
    }
    
    private func subscribe() {
        inquiriesSubject
            .sink { completion in
                // TODO: 에러 핸들링 강화
            } receiveValue: { [weak self] dict in
                self?._inquiries = dict
            }
            .store(in: &cancellables)
        
        announcementsSubject
            .sink { completion in
                // TODO: 에러 핸들링 강화
            } receiveValue: { [weak self] dict in
                self?._announcements = dict
            }
            .store(in: &cancellables)
    }
}

// MARK: - SupportCoreProtocol Confirmation
extension SupportCore: SupportCoreProtocol {
    var inquiries: AnyPublisher<[UInt64 : Inquiry], SupportCoreError> {
        inquiriesSubject.eraseToAnyPublisher()
    }
    
    var announcements: AnyPublisher<[UInt64 : Announcement], SupportCoreError> {
        announcementsSubject.eraseToAnyPublisher()
    }
    
    func createInquiry(title: String, content: String, images: [Data]?) {
        
    }
    
    func fetchInquiry(id: UInt64) -> Inquiry? {
        _inquiries[id]
    }
    
    func createAdminInquiryReply(id: UInt64, content: String) {
        
    }
    
    func createAnnouncement(title: String, content: String) {
        
    }
    
    func fetchAnnouncement(id: UInt64) -> Announcement? {
        _announcements[id]
    }
    
    func updateAnnouncement(id: UInt64, title: String?, content: String?) {
        
    }
    
    func deleteAnnouncement(id: UInt64) {
        
    }
}

// MARK: - SupportMediationProtocol Conformation
extension SupportCore: SupportMediationProtocol {
    func loadInquiries() {
        // TODO: 1:1 문의 목록 로직 구현
        guard let userID = currentUserID else {
            inquiriesSubject.send(completion: .failure(.userIDNotSet))
            return
        }
        
        // 1. 캐시 확인, 없다면 네트워크 요청
    }
    
    func loadAdminInquiries() {
        // TODO: 1:1문의 목록 로직 구현
        // 1. 관리자 권한 확인
        // 2. 캐시 확인, 없다면 네트워크 요청
    }
    
    func loadAnnouncements() {
        // TODO: 공지사항, FAQ 목록 로직 구현
        // 1. 캐시 확인, 없다면 네트워크 요청
    }
    
    func setCurrentUserID(_ id: UInt64?) {
        currentUserID = id
    }
}
