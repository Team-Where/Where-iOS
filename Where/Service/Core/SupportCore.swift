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
    /// FAQ 목록
    var FAQs: AnyPublisher<[UInt64: Announcement], SupportCoreError> { get }
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
    private var cancellables = Set<AnyCancellable>()
    
    init(authCore: AuthentificationCoreProtocol) {
        self.authCore = authCore
        subscribe()
    }
    
    private func subscribe() {
        authCore.user
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    #if DEBUG
                    print(error)
                    #endif
                }
            } receiveValue: { [weak self] user in
                guard let id = user?.id else {
                    self?._inquiries.removeAll()
                    self?._announcements.removeAll()
                    self?.userID = nil
                    return
                }
                // TODO: 관리자 계정일 때는 동작 방식이 상이하니 추후 수정할 것
                self?.userID = id
                self?.readInquiries()
                // self?.readAdminInquiries()
                self?.readAnnouncements()
            }
            .store(in: &cancellables)
    }
}

// MARK: - SupportCoreProtocol Confirmation
extension SupportCore: SupportCoreProtocol {
    var inquiries: AnyPublisher<[UInt64: Inquiry], SupportCoreError> {
        $_inquiries
            .map { $0 }
            .setFailureType(to: SupportCoreError.self)
            .eraseToAnyPublisher()
    }
    
    var FAQs: AnyPublisher<[UInt64: Announcement], SupportCoreError> {
        $_announcements
            .filter { $0.values.allSatisfy { $0.type == .FAQ } }
            .setFailureType(to: SupportCoreError.self)
            .eraseToAnyPublisher()
    }
    
    var announcements: AnyPublisher<[UInt64: Announcement], SupportCoreError> {
        $_announcements
            .filter { $0.values.allSatisfy { $0.type == .common } }
            .setFailureType(to: SupportCoreError.self)
            .eraseToAnyPublisher()
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
