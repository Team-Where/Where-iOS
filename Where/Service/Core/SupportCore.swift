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
    var inquiries: AnyPublisher<[Inquiry], SupportCoreError> { get }
    /// FAQ 목록
    var FAQs: AnyPublisher<[Announcement], SupportCoreError> { get }
    /// 공지사항 목록
    var announcements: AnyPublisher<[Announcement], SupportCoreError> { get }
    
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
