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
    var inquiries: AnyPublisher<[UInt64: Inquiry], Never> { get }
    /// 공지사항 목록
    var announcements: AnyPublisher<[UInt64: Announcement], Never> { get }
    
    var latestVersion: AnyPublisher<String, Never> { get }
    
    /// 1:1문의 작성 - 사용자
    func createInquiry(title: String, content: String, images: [Data?]) -> AnyPublisher<Void, SupportCoreError>
    /// 1:1문의 답변 작성 - 관리자
    /// - Parameters:
    ///     - id: 문의 식별자
    ///     - content: 답변 내용
    func createAdminInquiryReply(id: UInt64, content: String) -> AnyPublisher<Void, SupportCoreError>
    /// 공지사항 등록
    func createAnnouncement(title: String, content: String) -> AnyPublisher<Void, SupportCoreError>
    /// 공지사항 수정
    /// - Parameters:
    ///     - id: 공지사항 식별자
    ///     - title: 문의 제목
    ///     - content: 문의 내용
    func updateAnnouncement(id: UInt64, title: String?, content: String?) -> AnyPublisher<Void, SupportCoreError>
    /// 공지사항 삭제
    /// - Parameters:
    ///     - id: 문의 식별자
    func deleteAnnouncement(id: UInt64) -> AnyPublisher<Void, SupportCoreError>
    /// FAQ 등록
    func createFAQ(title: String, content: String) -> AnyPublisher<Void, SupportCoreError>
    /// FAQ 수정
    /// - Parameters:
    ///     - id: 공지사항 식별자
    ///     - title: 공지사항 제목
    ///     - content: 공지사항 내용
    func updateFAQ(id: UInt64, title: String?, content: String?) -> AnyPublisher<Void, SupportCoreError>
    /// FAQ 삭제
    func deleteFAQ(id: UInt64) -> AnyPublisher<Void, SupportCoreError>
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
    /// 사용자 로그아웃 시 작업 수행을 지시, 중재자에 의해 호출됨
    func userDidLogout()
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
    
    private let inquiriesSubject = CurrentValueSubject<[UInt64: Inquiry], Never>([:])
    private let announcementsSubject = CurrentValueSubject<[UInt64: Announcement], Never>([:])
    private let latestVersionSubject = CurrentValueSubject<String, Never>(String())
    
    private let encoder: JSONEncoder
    private let apiService: APIServable
    private let cancellableBag = CancellableBag()
    
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
                
            } receiveValue: { [weak self] dict in
                self?._inquiries = dict
            }
            .store(in: cancellableBag, key: "InquiriesSubject")
        
        announcementsSubject
            .sink { completion in
                
            } receiveValue: { [weak self] dict in
                self?._announcements = dict
            }
            .store(in: cancellableBag, key: "AnnouncementsSubject")
    }
}

// MARK: - SupportCoreProtocol Confirmation
extension SupportCore: SupportCoreProtocol {
    var inquiries: AnyPublisher<[UInt64 : Inquiry], Never> {
        inquiriesSubject.eraseToAnyPublisher()
    }
    
    var announcements: AnyPublisher<[UInt64 : Announcement], Never> {
        announcementsSubject.eraseToAnyPublisher()
    }
    
    var latestVersion: AnyPublisher<String, Never> {
        latestVersionSubject.eraseToAnyPublisher()
    }
    
    func createInquiry(title: String, content: String, images: [Data?]) -> AnyPublisher<Void, SupportCoreError> {
        guard let userID = currentUserID else {
            return Fail(error: .userIDNotSet).eraseToAnyPublisher()
        }
        
        let dto = CreateUserInquiryDTO.Request(title: title, content: content, userID: userID)
        guard let inquiryData = try? encoder.encode(dto) else {
            return Fail(error: .encodingError).eraseToAnyPublisher()
        }
        
        return apiService.requestPublisher(Endpoint.createUserInquiry(inquiryData: inquiryData, imageDatas: images), CreateUserInquiryDTO.Response.self)
            .mapError { SupportCoreError.networkingError($0) }
            .map { [weak self] response in
                let inquiry = response.toEntity()
                guard var inquiries = self?.inquiriesSubject.value else { return }
                inquiries[inquiry.id] = inquiry
                self?.inquiriesSubject.send(inquiries)
            }
            .eraseToAnyPublisher()
    }
    
    func createAdminInquiryReply(id: UInt64, content: String) -> AnyPublisher<Void, SupportCoreError> {
        let dto = CreateAdminInquiryReplyDTO.Request(inquiryID: id, answerContent: content)
        return apiService.requestPublisher(Endpoint.createAdminInquiryReply(dto: dto), CreateAdminInquiryReplyDTO.Response.self)
            .mapError { SupportCoreError.networkingError($0) }
            .map { [weak self] response in
                let inquiry = response.toEntity()
                guard var inquiries = self?.inquiriesSubject.value else { return }
                inquiries[inquiry.id] = inquiry
                self?.inquiriesSubject.send(inquiries)
            }
            .eraseToAnyPublisher()
    }
    
    func createAnnouncement(title: String, content: String) -> AnyPublisher<Void, SupportCoreError> {
        let dto = CreateAnnouncementDTO.Request(title: title, content: content)
        return apiService.requestPublisher(Endpoint.createAnnouncement(dto: dto), CreateAnnouncementDTO.Response.self)
            .mapError { SupportCoreError.networkingError($0) }
            .map { [weak self] response in
                let announcement = response.toEntity()
                guard var announcements = self?.announcementsSubject.value else { return }
                announcements[announcement.id] = announcement
                self?.announcementsSubject.send(announcements)
            }
            .eraseToAnyPublisher()
    }
    
    func updateAnnouncement(id: UInt64, title: String?, content: String?) -> AnyPublisher<Void, SupportCoreError> {
        let dto = UpdateAnnouncementDTO.Request(announcementID: id, title: title, content: content)
        return apiService.requestPublisher(Endpoint.updateAnnouncement(dto: dto), UpdateAnnouncementDTO.Response.self)
            .mapError { SupportCoreError.networkingError($0) }
            .map { [weak self] response in
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
            .eraseToAnyPublisher()
    }
    
    func deleteAnnouncement(id: UInt64) -> AnyPublisher<Void, SupportCoreError> {
        let dto = DeleteAnnouncementDTO.Request(announcementID: id)
        return apiService.requestVoidPublisher(Endpoint.deleteAnnouncement(dto: dto))
            .mapError { SupportCoreError.networkingError($0) }
            .map { [weak self] _ in
                guard var announcements = self?.announcementsSubject.value else { return }
                announcements.removeValue(forKey: id)
                self?.announcementsSubject.send(announcements)
            }
            .eraseToAnyPublisher()
    }
    
    func createFAQ(title: String, content: String) -> AnyPublisher<Void, SupportCoreError> {
        let dto = CreateFAQDTO.Request(title: title, content: content)
        return apiService.requestPublisher(Endpoint.createFAQ(dto: dto), CreateFAQDTO.Response.self)
            .mapError { SupportCoreError.networkingError($0) }
            .map { [weak self] response in
                let faq = response.toEntity()
                guard var announcements = self?.announcementsSubject.value else { return }
                announcements[faq.id] = faq
                self?.announcementsSubject.send(announcements)
            }
            .eraseToAnyPublisher()
    }
    
    func updateFAQ(id: UInt64, title: String?, content: String?) -> AnyPublisher<Void, SupportCoreError> {
        let dto = UpdateFAQDTO.Request(id: id, title: title, content: content)
        return apiService.requestPublisher(Endpoint.updateFAQ(dto: dto), UpdateFAQDTO.Response.self)
            .mapError { SupportCoreError.networkingError($0) }
            .map { [weak self] response in
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
            .eraseToAnyPublisher()
    }
    
    func deleteFAQ(id: UInt64) -> AnyPublisher<Void, SupportCoreError> {
        let dto = DeleteFAQDTO.Request(id: id)
        return apiService.requestVoidPublisher(Endpoint.deleteFAQ(dto: dto))
            .mapError { SupportCoreError.networkingError($0) }
            .map { [weak self] _ in
                guard var announcements = self?.announcementsSubject.value else { return }
                announcements.removeValue(forKey: id)
                self?.announcementsSubject.send(announcements)
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - SupportMediationProtocol Conformation
extension SupportCore: SupportMediationProtocol {
    func loadInquiries() {
        guard let userID = currentUserID else { return }
        
        cancellableBag[#function] = apiService.requestPublisher(Endpoint.readUserInquiries(userID: userID), ReadUserInquiriesDTO.Response.self)
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    print(error)
                }
            } receiveValue: { [weak self] response in
                let inquiries = response.map { $0.toEntity() }
                let inquiriesDict = inquiries.reduce(into: [:]) { $0[$1.id] = $1 }
                self?.inquiriesSubject.send(inquiriesDict)
            }
    }
    
    func loadAdminInquiries() {
        /// - Note: 관리자 1:1문의 조회 API에서 검색 기준을 받고 있는데, 사실 프론트에서 항상 모든 문의에 대해서 조회하고 있으므로 실질적으론 Criteria 설정값은 '3' 외에 쓸 일이 없음.
        cancellableBag[#function] = apiService.requestPublisher(Endpoint.readAdminInquiries(criteria: 3), ReadAdminInquiriesDTO.Response.self)
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    print(error)
                }
            } receiveValue: { [weak self] response in
                let inquiries = response.map { $0.toEntity() }
                let inquiriesDict = inquiries.reduce(into: [:]) { $0[$1.id] = $1 }
                self?.inquiriesSubject.send(inquiriesDict)
            }
    }
    
    func loadAnnouncements() {
        let announcementsPublisher = apiService.requestPublisher(Endpoint.readAnnouncements, ReadAnnouncementsDTO.Response.self)
        let faqPublisher = apiService.requestPublisher(Endpoint.readFAQs, ReadFAQsDTO.Response.self)
        
        cancellableBag[#function] = announcementsPublisher
            .combineLatest(faqPublisher)
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    print(error)
                }
            } receiveValue: { [weak self] (announcementsResponse, faqsResponse) in
                let announcements = announcementsResponse.map { $0.toEntity() }
                let faqs = faqsResponse.map { $0.toEntity() }
                let announcementsDict = (announcements + faqs).reduce(into: [:]) { $0[$1.id] = $1 }
                self?.announcementsSubject.send(announcementsDict)
            }
    }
    
    func setCurrentUserID(_ id: UInt64?) {
        currentUserID = id
        
        let latestVersion = Bundle.main.appVersion
        cancellableBag[#function] = apiService.requestStringPublisher(Endpoint.checkLatestVersion(version: latestVersion))
            .map { isLatestVersionString in
                isLatestVersionString == "true"
            }
            .sink { [weak self] completion in
                switch completion {
                case .finished: break
                case .failure:
                    guard latestVersion == UserDefaults.standard.string(forKey: AppStorageKey.latestVersion) else {
                        self?.latestVersionSubject.send("업데이트")
                        return
                    }
                    self?.latestVersionSubject.send("최신버전")
                }
            } receiveValue: { [weak self] isLatestVersion in
                guard isLatestVersion else {
                    self?.latestVersionSubject.send("업데이트")
                    return
                }
                UserDefaults.standard.set(latestVersion, forKey: AppStorageKey.latestVersion)
                self?.latestVersionSubject.send("최신버전")
            }
    }
    
    func userDidLogout() {
        currentUserID = nil
        inquiriesSubject.send([:])
    }
}
