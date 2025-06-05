//
//  InquiryViewModel.swift
//  Where
//
//  Created by Swain Yun on 4/28/25.
//

import Foundation
import Combine
import Swinject

protocol InquiryDeletable {
    func delete(inquiry: Inquiry)
}

@Observable
final class InquiryViewModel {
    private(set) var waitingForReplyInquiries = [Inquiry]()
    private(set) var answerCompleteInquiries = [Inquiry]()
    
    private let supportCore: SupportCoreProtocol
    private let cancellableBag = CancellableBag()
    
    init(resolver: Resolver) {
        self.supportCore = resolver.resolve(SupportCoreProtocol.self)!
        subscribe()
    }
    
    private func subscribe() {
        supportCore.inquiries
            .receive(on: DispatchQueue.main)
            .sink { [weak self] dict in
                let inquiries = dict.values.sorted { $0.modifiedAt > $1.modifiedAt }
                self?.waitingForReplyInquiries = inquiries.filter { $0.isAnswered == false }
                self?.answerCompleteInquiries = inquiries.filter { $0.isAnswered }
            }
            .store(in: cancellableBag, key: "Inquiries")
    }
}

// MARK: - Nested Types
extension InquiryViewModel {
    /// 문의 화면에서 라우팅 가능한 시트의 종류
    enum SheetType: Identifiable {
        case deleteInquiry(inquiry: Inquiry)
        
        var id: String { String(describing: self) }
    }
}

// MARK: - InquiryDeletable Conformation
extension InquiryViewModel: InquiryDeletable {
    func delete(inquiry: Inquiry) {
        // TODO: 1:1 문의 삭제 기능 부재
    }
}
