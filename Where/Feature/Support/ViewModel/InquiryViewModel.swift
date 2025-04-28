//
//  InquiryViewModel.swift
//  Where
//
//  Created by Swain Yun on 4/28/25.
//

import Foundation
import Combine

final class InquiryViewModel: ObservableObject {
    @Published var sheetType: SheetType?
    @Published private(set) var waitingForReplyInquiries = [Inquiry]()
    @Published private(set) var answerCompleteInquiries = [Inquiry]()
    
    private let supportCore: SupportCoreProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(supportCore: SupportCoreProtocol) {
        self.supportCore = supportCore
        subscribe()
    }
    
    private func subscribe() {
        supportCore.inquiries
            .receive(on: DispatchQueue.main)
            .sink { completion in
                // TODO: 에러 핸들링
            } receiveValue: { [weak self] dict in
                let inquiries = dict.values.sorted { $0.modifiedAt > $1.modifiedAt }
                self?.waitingForReplyInquiries = inquiries.filter { $0.isAnswered == false }
                self?.answerCompleteInquiries = inquiries.filter { $0.isAnswered }
            }
            .store(in: &cancellables)
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

// MARK: - Interfaces
extension InquiryViewModel {
    func updateInquiry(_ inquiry: Inquiry) {
        // TODO: 문의 수정 기능 연결
    }
    
    func presentDeleteInquirySheet(for inquiry: Inquiry) {
        sheetType = .deleteInquiry(inquiry: inquiry)
    }
    
    func deleteInquiry(_ inquiry: Inquiry) {
        // TODO: 문의 삭제 기능 연결
    }
}
