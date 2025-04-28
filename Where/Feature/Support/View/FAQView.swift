//
//  FAQView.swift
//  Where
//
//  Created by Swain Yun on 3/21/25.
//

import SwiftUI
import Swinject

fileprivate typealias NavigationType = FAQViewModel.NavigationType

struct FAQView: View {
    @ObservedObject private var viewModel: FAQViewModel
    
    private let resolver: Resolver
    
    init(resolver: Resolver) {
        self.resolver = resolver
        self.viewModel = resolver.resolve(FAQViewModel.self)!
    }
    
    var body: some View {
        VStack {
            ScrollView(.vertical) {
                LazyVStack(spacing: 20) {
                    ForEach(viewModel.faqs) { faq in
                        Cell(faq)
                            .listRowSeparator(.hidden)
                    }
                }
            }
            
            Button {
                viewModel.presentEditInquiryView()
            } label: {
                Text("1:1 문의하기")
                    .whereFont(.body16medium)
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.whereRoundedProminent())
            .padding(.horizontal)
        }
        .navigationDestination(item: $viewModel.navigationType) { type in
            // TODO: 화면 연결 필요
            switch type {
            case .editAnnouncement:
                EmptyView()
            case .editInquiry:
                InquiryView(resolver: resolver)
            }
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton()
            }
            
            ToolbarItem(placement: .principal) {
                Text("FAQ")
                    .whereFont(.subtitle18semibold)
                    .foregroundStyle(.where(.gray800))
            }
            
            // MARK: 관리자 권한인지 판단해서 노출할 수 있도록 수정해야함
//            ToolbarItem(placement: .topBarTrailing) {
//                Button {
//                    navigationType = .editAnnouncement
//                } label: {
//                    Image(systemName: "pencil.line")
//                        .foregroundStyle(.where(.gray800))
//                }
//            }
        }
    }
}

// MARK: Nested Types
extension FAQView {
    struct Cell: View {
        @State private var isExpanded: Bool = false
        
        let faq: Announcement
        
        init(_ faq: Announcement) {
            self.faq = faq
        }
        
        var body: some View {
            DisclosureGroup(isExpanded: $isExpanded) {
                Text(faq.content)
            } label: {
                HStack(spacing: 10) {
                    Text("Q")
                        .foregroundStyle(.accent)
                    
                    Text(faq.title)
                        .foregroundStyle(.where(.gray800))
                }
                .whereFont(.body16semibold)
            }
            .disclosureGroupStyle(WhereDisclosureGroupStyle(labelHeight: 60))
        }
    }
}
