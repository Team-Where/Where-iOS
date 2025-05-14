//
//  InquiryView.swift
//  Where
//
//  Created by Swain Yun on 3/24/25.
//

import SwiftUI
import Swinject

fileprivate typealias SheetType = InquiryViewModel.SheetType

struct InquiryView: View {
    @ObservedObject private var viewModel: InquiryViewModel
    
    private let resolver: Resolver
    
    init(resolver: Resolver) {
        self.viewModel = resolver.resolve(InquiryViewModel.self)!
        self.resolver = resolver
    }
    
    var body: some View {
        SelectionTab<TabViewItem>(selection: [
            .waitingForReply(viewModel: viewModel),
            .answerComplete(viewModel: viewModel)
        ])
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton()
            }
            
            ToolbarItem(placement: .principal) {
                Text("1:1 문의")
                    .whereFont(.subtitle18semibold)
                    .foregroundStyle(.where(.gray800))
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    
                } label: {
                    Image(systemName: "pencil.line")
                        .foregroundStyle(.where(.gray800))
                }
            }
        }
    }
}

// MARK: Nested Types
extension InquiryView {
    enum TabViewItem: SelectionTabItem {
        case waitingForReply(viewModel: InquiryViewModel)
        case answerComplete(viewModel: InquiryViewModel)
        
        var id: String { String(describing: self) }
        
        var title: String {
            switch self {
            case .waitingForReply(let viewModel): return "답변대기(\(viewModel.waitingForReplyInquiries.count))"
            case .answerComplete(let viewModel): return "답변완료(\(viewModel.answerCompleteInquiries.count))"
            }
        }
        
        @ViewBuilder func view() -> some View {
            switch self {
            case .waitingForReply(let viewModel): InquiryListView(viewModel, inquiries: viewModel.waitingForReplyInquiries)
            case .answerComplete(let viewModel):
                InquiryListView(viewModel, inquiries: viewModel.answerCompleteInquiries)
            }
        }
    }
    
    struct InquiryListView: View {
        @ObservedObject private var viewModel: InquiryViewModel
        
        let inquiries: [Inquiry]
        
        init(
            _ viewModel: InquiryViewModel,
            inquiries: [Inquiry]
        ) {
            self.viewModel = viewModel
            self.inquiries = inquiries
        }
        
        var body: some View {
            if inquiries.isEmpty {
                unavailableView
            } else {
                inquiriesList
            }
        }
        
        private var unavailableView: some View {
            VStack(spacing: 10) {
                Spacer()
                
                Image(systemName: "exclamationmark.circle")
                    .foregroundStyle(.where(.gray600))
                
                Text("아직 1:1 문의 사항이 없어요!")
                    .whereFont(.body16medium)
                    .foregroundStyle(.where(.gray700))
                
                Spacer()
            }
        }
        
        private var inquiriesList: some View {
            ScrollView(.vertical) {
                LazyVStack {
                    ForEach(inquiries) { inquiry in
                        cell(inquiry)
                            .listRowSeparator(.hidden)
                    }
                }
            }
            .sheet(item: $viewModel.sheetType) { type in
                switch type {
                case .deleteInquiry(let inquiry):
                    DeleteInquirySheet(viewModel, inquiry: inquiry)
                }
            }
        }
        
        @ViewBuilder private func cell(_ inquiry: Inquiry) -> some View {
            DisclosureGroup {
                VStack(alignment: .leading, spacing: 40) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("문의")
                            .whereFont(.caption12regular)
                            .foregroundStyle(.where(.gray800))
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.white)
                            )
                        
                        Text(inquiry.content)
                            .whereFont(.body14regular)
                            .foregroundStyle(.where(.gray700))
                            .multilineTextAlignment(.leading)
                    }
                    /* 1:1 문의 수정, 삭제 기능 없음 (WIP)
                    HStack(spacing: 10) {
                        Spacer()
                        
                        if inquiry.isAnswered == false {
                            Button {
                                viewModel.updateInquiry(inquiry)
                            } label: {
                                Text("수정")
                                    .whereFont(.body14medium)
                                    .foregroundStyle(.accent)
                                    .frame(width: 52, height: 32)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(.white)
                                            .strokeBorder(.accent)
                                    )
                            }
                        }
                        
                        Button {
                            viewModel.presentDeleteInquirySheet(for: inquiry)
                        } label: {
                            Text("삭제")
                                .whereFont(.body14medium)
                                .foregroundStyle(.accent)
                                .frame(width: 52, height: 32)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(.white)
                                        .strokeBorder(.accent)
                                )
                        }
                    }
                     */
                    
                    if let answerContent = inquiry.answerContent {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("답변")
                                .whereFont(.caption12regular)
                                .foregroundStyle(.where(.gray800))
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(.white)
                                )
                            
                            Text(answerContent)
                                .whereFont(.body14regular)
                                .foregroundStyle(.where(.gray700))
                        }
                    }
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(inquiry.title)
                            .whereFont(.body16medium)
                            .foregroundStyle(.where(.gray800))
                        
                        DateView(date: inquiry.modifiedAt, format: .yyyyMMdd, prompt: "")
                            .whereFont(.body14regular)
                            .foregroundStyle(.where(.gray700))
                    }
                    
                    Spacer()
                }
            }
            .disclosureGroupStyle(WhereDisclosureGroupStyle(labelHeight: 74))
        }
    }
}

// MARK: Sheet
extension InquiryView {
    struct DeleteInquirySheet: View {
        @ObservedObject private var viewModel: InquiryViewModel
        
        let inquiry: Inquiry
        
        init(
            _ viewModel: InquiryViewModel,
            inquiry: Inquiry
        ) {
            self.viewModel = viewModel
            self.inquiry = inquiry
        }
        
        var body: some View {
            Button {
                viewModel.deleteInquiry(inquiry)
            } label: {
                Text("1:1 문의 삭제")
                    .whereFont(.body16medium)
                    .frame(height: 54)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.whereRoundedProminent(foreground: .red, background: .where(.gray100)))
            .presentationDetents([.fraction(0.17)])
            .presentationCornerRadius(16)
            .padding()
        }
    }
}
