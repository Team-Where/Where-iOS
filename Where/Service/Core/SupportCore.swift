//
//  SupportCore.swift
//  Where
//
//  Created by Swain Yun on 4/5/25.
//

import Foundation
import Combine

protocol SupportCoreProtocol {
    /// 1:1 문의 목록
    var inquiries: AnyPublisher<[UInt64: Inquiry], SupportCoreError> { get }
    /// 공지사항 목록
    var announcements: AnyPublisher<[UInt64: Announcement], SupportCoreError> { get }
    
    /// 1:1문의 조회 - 사용자
    func readInquiries()
    /// 1:1문의 작성 - 사용자
    func createInquiry(title: String, content: String, images: [Data]?)
    /// 1:1문의 작성 - 관리자
    func readAdminInquiries()
    /// 1:1문의 답변 작성 - 관리자
    /// - Parameters:
    ///     - id: 문의 식별자
    ///     - content: 답변 내용
    func createAdminInquiryReply(id: UInt64, content: String)
    /// 공지사항 조회
    func readAnnouncements()
    /// 공지사항 등록
    func createAnnouncement(title: String, content: String)
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
    /// FAQ 조회
    func readFAQs()
    /// FAQ 등록
    func createFAQ(title: String, content: String)
    /// FAQ 수정
    /// - Parameters:
    ///     - id: 문의 식별자
    ///     - title: 문의 제목
    ///     - content: 문의 내용
    func updateFAQ(id: UInt64, title: String?, content: String?)
    /// FAQ 수정
    /// - Parameters:
    ///     - id: 문의 식별자
    func deleteFAQ(id: UInt64)
}

enum SupportCoreError: Error {
    
}

final class SupportCore {
    @Published private var _inquiries = [UInt64: Inquiry]()
    @Published private var _announcements = [UInt64: Announcement]()
    
    private var userID: UInt64?
    
    private let authCore: AuthentificationCoreProtocol
    private let tokenStorage: TokenStorageProtocol
    private let inquiriesSubject = CurrentValueSubject<[UInt64: Inquiry], SupportCoreError>([:])
    private let announcementsSubject = CurrentValueSubject<[UInt64: Announcement], SupportCoreError>([:])
    private var cancellables = Set<AnyCancellable>()
    
    init(
        authCore: AuthentificationCoreProtocol,
        tokenStorage: TokenStorageProtocol
    ) {
        self.authCore = authCore
        self.tokenStorage = tokenStorage
        subscribe()
    }
    
    private func subscribe() {
        authCore.user
            .sink { [weak self] completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    switch error {
                    case .loginFailed, .notSupported, .socialAuthProviderAuthorizationFailed, .unknown, .userInfoFetchFailed:
                        self?.userID = nil
                        self?._inquiries.removeAll()
                        self?._announcements.removeAll()
                    case .logoutFailed:
                        break
                    @unknown default: break
                    }
                }
            } receiveValue: { [weak self] user in
                self?.userID = user?.id
                // TODO: 관리자 계정일 때는 동작 방식이 상이하니 추후 수정할 것
                self?.readInquiries()
                // self?.readAdminInquiries()
                self?.readAnnouncements()
            }
            .store(in: &cancellables)
        
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
    
    func readInquiries() {
        
    }
    
    func createInquiry(title: String, content: String, images: [Data]?) {
        
    }
    
    func readAdminInquiries() {
        
    }
    
    func createAdminInquiryReply(id: UInt64, content: String) {
        
    }
    
    func readAnnouncements() {
        
    }
    
    func createAnnouncement(title: String, content: String) {
        
    }
    
    func updateAnnouncement(id: UInt64, title: String?, content: String?) {
        
    }
    
    func deleteAnnouncement(id: UInt64) {
        
    }
    
    func readFAQs() {
        
    }
    
    func createFAQ(title: String, content: String) {
        
    }
    
    func updateFAQ(id: UInt64, title: String?, content: String?) {
        
    }
    
    func deleteFAQ(id: UInt64) {
        
    }
}
