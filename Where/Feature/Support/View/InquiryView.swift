//
//  InquiryView.swift
//  Where
//
//  Created by Swain Yun on 3/24/25.
//

import SwiftUI

struct InquiryView: View {
    @State private var inquiries: [Inquiry] = []
    
    private var waitingForReplyInquiries: [Inquiry] {
        inquiries.filter { $0.isAnswered == false }
    }
    
    private var answerCompleteInquiries: [Inquiry] {
        inquiries.filter { $0.isAnswered == true }
    }
    
    var body: some View {
        SelectionTab<TabViewItem>(selection: [
            .waitingForReply(inquiries: waitingForReplyInquiries),
            .answerComplete(inquiries: answerCompleteInquiries)
        ])
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbarVisibility(.hidden, for: .tabBar)
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
        case waitingForReply(inquiries: [Inquiry])
        case answerComplete(inquiries: [Inquiry])
        
        var id: String { String(describing: self) }
        
        var title: String {
            switch self {
            case .waitingForReply(let inquiries): return "답변대기(\(inquiries.count))"
            case .answerComplete(let inquiries): return "답변완료(\(inquiries.count))"
            }
        }
        
        @ViewBuilder func view() -> some View {
            switch self {
            case .waitingForReply(let inquiries): InquiryListView(inquiries: inquiries)
            case .answerComplete(let inquiries): InquiryListView(inquiries: inquiries)
            }
        }
    }
    
    struct InquiryListView: View {
        @State private var sheetType: SheetType?
        
        let inquiries: [Inquiry]
        
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
            .sheet(item: $sheetType) { type in
                switch type {
                case .deleteInquiry(let inquiry):
                    DeleteInquirySheet(inquiry: inquiry)
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
                    
                    HStack(spacing: 10) {
                        Spacer()
                        
                        Button {
                            // TODO: 문의 수정 기능 연결
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
                        
                        Button {
                            sheetType = .deleteInquiry(inquiry: inquiry)
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
                        
                        AsyncDateView(date: .constant(inquiry.modifiedAt), format: .yyyyMMdd, prompt: "")
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
    /// 문의 화면에서 라우팅 가능한 시트의 종류
    enum SheetType: Identifiable {
        case deleteInquiry(inquiry: Inquiry)
        
        var id: String { String(describing: self) }
    }
    
    struct DeleteInquirySheet: View {
        let inquiry: Inquiry
        
        var body: some View {
            Button {
                // TODO: 문의 삭제 기능 연결
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

#Preview {
    NavigationStack {
        InquiryView()
    }
}
