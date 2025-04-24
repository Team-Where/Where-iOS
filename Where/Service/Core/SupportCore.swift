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
    /// 1:1문의 답변 작성 - 관리자
    /// - Parameters:
    ///     - id: 문의 식별자
    ///     - content: 답변 내용
    func createAdminInquiryReply(id: UInt64, content: String)
    /// 공지사항 등록
    func createAnnouncement(title: String, content: String)
    /// 공지사항 수정
    /// - Parameters:
    ///     - id: 공지사항 식별자
    ///     - title: 문의 제목
    ///     - content: 문의 내용
    func updateAnnouncement(id: UInt64, title: String?, content: String?)
    /// 공지사항 삭제
    /// - Parameters:
    ///     - id: 문의 식별자
    func deleteAnnouncement(id: UInt64)
    /// FAQ 등록
    func createFAQ(title: String, content: String)
    /// FAQ 수정
    /// - Parameters:
    ///     - id: 공지사항 식별자
    ///     - title: 공지사항 제목
    ///     - content: 공지사항 내용
    func updateFAQ(id: UInt64, title: String?, content: String?)
    /// FAQ 삭제
    func deleteFAQ(id: UInt64)
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
    case encodingError
}

final class SupportCore {
    weak var mediator: Notifiable?
    
    private var _inquiries = [UInt64: Inquiry]()
    private var _announcements = [UInt64: Announcement]()
    private var currentUserID: UInt64?
    
    private let inquiriesSubject = CurrentValueSubject<[UInt64: Inquiry], SupportCoreError>([:])
    private let announcementsSubject = CurrentValueSubject<[UInt64: Announcement], SupportCoreError>([:])
    
    private let encoder: JSONEncoder
    private let apiService: APIServable
    private var cancellables = Set<AnyCancellable>()
    
    init(
        encoder: JSONEncoder,
        apiService: APIServable
    ) {
        self.encoder = encoder
        self.apiService = apiService
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
        guard let userID = currentUserID else {
            inquiriesSubject.send(completion: .failure(.userIDNotSet))
            return
        }
        
        do {
            let dto = CreateUserInquiryDTO.Request(title: title, content: content, userID: userID)
            let inquiryData = try encoder.encode(dto)
            
            apiService
                .requestPublisher(Endpoint.createUserInquiry(inquiryData: inquiryData, imageDatas: images), CreateUserInquiryDTO.Response.self)
                .sink { completion in
                    // TODO: 에러 핸들링
                } receiveValue: { [weak self] response in
                    let inquiry = response.toEntity()
                    guard var inquiries = self?.inquiriesSubject.value else { return }
                    inquiries[inquiry.id] = inquiry
                    self?.inquiriesSubject.send(inquiries)
                }
                .store(in: &cancellables)

        } catch {
            inquiriesSubject.send(completion: .failure(.encodingError))
        }
    }
    
    func createAdminInquiryReply(id: UInt64, content: String) {
        let dto = CreateAdminInquiryReplyDTO.Request(inquiryID: id, answerContent: content)
        
        apiService
            .requestPublisher(Endpoint.createAdminInquiryReply(dto: dto), CreateAdminInquiryReplyDTO.Response.self)
            .sink { completion in
                // TODO: 에러 핸들링
            } receiveValue: { [weak self] response in
                let inquiry = response.toEntity()
                guard var inquiries = self?.inquiriesSubject.value else { return }
                inquiries[inquiry.id] = inquiry
                self?.inquiriesSubject.send(inquiries)
            }
            .store(in: &cancellables)
    }
    
    func createAnnouncement(title: String, content: String) {
        let dto = CreateAnnouncementDTO.Request(title: title, content: content)
        
        apiService
            .requestPublisher(Endpoint.createAnnouncement(dto: dto), CreateAnnouncementDTO.Response.self)
            .sink { completion in
                // TODO: 에러 핸들링
            } receiveValue: { [weak self] response in
                let announcement = response.toEntity()
                guard var announcements = self?.announcementsSubject.value else { return }
                announcements[announcement.id] = announcement
                self?.announcementsSubject.send(announcements)
            }
            .store(in: &cancellables)
    }
    
    func updateAnnouncement(id: UInt64, title: String?, content: String?) {
        let dto = UpdateAnnouncementDTO.Request(announcementID: id, title: title, content: content)
        
        apiService
            .requestPublisher(Endpoint.updateAnnouncement(dto: dto), UpdateAnnouncementDTO.Response.self)
            .sink { completion in
                // TODO: 에러 핸들링
            } receiveValue: { [weak self] response in
                let announcement = Announcement(
                    id: response.announcementID,
                    title: response.title,
                    content: response.content,
                    date: .now,
                    type: .common
                )
                guard var announcements = self?.announcementsSubject.value else { return }
                announcements[announcement.id] = announcement
                self?.announcementsSubject.send(announcements)
            }
            .store(in: &cancellables)
    }
    
    func deleteAnnouncement(id: UInt64) {
        let dto = DeleteAnnouncementDTO.Request(announcementID: id)
        
        apiService
            .requestPublisher(Endpoint.deleteAnnouncement(dto: dto), EmptyDTO.Response.self)
            .sink { completion in
                // TODO: 에러 핸들링
            } receiveValue: { [weak self] _ in
                guard var announcements = self?.announcementsSubject.value else { return }
                announcements.removeValue(forKey: id)
                self?.announcementsSubject.send(announcements)
            }
            .store(in: &cancellables)
    }
    
    func createFAQ(title: String, content: String) {
        let dto = CreateFAQDTO.Request(title: title, content: content)
        
        apiService
            .requestPublisher(Endpoint.createFAQ(dto: dto), CreateFAQDTO.Response.self)
            .sink { completion in
                // TODO: 에러 핸들링
            } receiveValue: { [weak self] response in
                let faq = response.toEntity()
                guard var announcements = self?.announcementsSubject.value else { return }
                announcements[faq.id] = faq
                self?.announcementsSubject.send(announcements)
            }
            .store(in: &cancellables)
    }
    
    func updateFAQ(id: UInt64, title: String?, content: String?) {
        let dto = UpdateFAQDTO.Request(id: id, title: title, content: content)
        
        apiService
            .requestPublisher(Endpoint.updateFAQ(dto: dto), UpdateFAQDTO.Response.self)
            .sink { completion in
                // TODO: 에러 핸들링
            } receiveValue: { [weak self] response in
                let faq = Announcement(
                    id: response.id,
                    title: response.title,
                    content: response.content,
                    date: .now,
                    type: .FAQ
                )
                
                guard var announcements = self?.announcementsSubject.value else { return }
                announcements[faq.id] = faq
                self?.announcementsSubject.send(announcements)
            }
            .store(in: &cancellables)
    }
    
    func deleteFAQ(id: UInt64) {
        let dto = DeleteFAQDTO.Request(id: id)
        
        apiService
            .requestPublisher(Endpoint.deleteFAQ(dto: dto), EmptyDTO.Response.self)
            .sink { completion in
                // TODO: 에러 핸들링
            } receiveValue: { [weak self] _ in
                guard var announcements = self?.announcementsSubject.value else { return }
                announcements.removeValue(forKey: id)
                self?.announcementsSubject.send(announcements)
            }
            .store(in: &cancellables)
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
        
        apiService
            .requestPublisher(Endpoint.readUserInquiries(userID: userID), ReadUserInquiriesDTO.Response.self)
            .sink { completion in
                // TODO: 에러 핸들링
            } receiveValue: { [weak self] response in
                let inquiries = response.map { $0.toEntity() }
                let inquiriesDict = inquiries.reduce(into: [:]) { $0[$1.id] = $1 }
                self?.inquiriesSubject.send(inquiriesDict)
            }
            .store(in: &cancellables)
    }
    
    func loadAdminInquiries() {
        // TODO: 관리자 1:1문의 조회 API에서 검색 기준을 받고 있는데, 사실 프론트에서 항상 모든 문의에 대해서 조회하고 있으므로 실질적으론 Criteria 설정값은 '3' 외에 쓸 일이 없음.
        apiService
            .requestPublisher(Endpoint.readAdminInquiries(criteria: 3), ReadAdminInquiriesDTO.Response.self)
            .sink { completion in
                // TODO: 에러 핸들링
            } receiveValue: { [weak self] response in
                let inquiries = response.map { $0.toEntity() }
                let inquiriesDict = inquiries.reduce(into: [:]) { $0[$1.id] = $1 }
                self?.inquiriesSubject.send(inquiriesDict)
            }
            .store(in: &cancellables)
    }
    
    func loadAnnouncements() {
        let announcementsPublisher = apiService.requestPublisher(Endpoint.readAnnouncements, ReadAnnouncementsDTO.Response.self)
        let faqPublisher = apiService.requestPublisher(Endpoint.readFAQs, ReadFAQsDTO.Response.self)
        
        announcementsPublisher
            .combineLatest(faqPublisher)
            .sink { completion in
                // TODO: 에러 핸들링
            } receiveValue: { [weak self] (announcementsResponse, faqsResponse) in
                let announcements = announcementsResponse.map { $0.toEntity() }
                let faqs = faqsResponse.map { $0.toEntity() }
                let announcementsDict = (announcements + faqs).reduce(into: [:]) { $0[$1.id] = $1 }
                self?.announcementsSubject.send(announcementsDict)
            }
            .store(in: &cancellables)
    }
    
    func setCurrentUserID(_ id: UInt64?) {
        currentUserID = id
    }
}
