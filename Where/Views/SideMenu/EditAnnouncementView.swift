//
//  EditAnnouncementView.swift
//  Where
//
//  Created by Swain Yun on 3/23/25.
//

import SwiftUI

struct EditAnnouncementView: View {
    @State private var selection: Selection? = .FAQ
    @State private var title: String = String()
    @State private var content: String = String()
    @State private var isPopupPresented: Bool = false
    
    private var disabled: Bool { title.isEmpty || content.isEmpty }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 32) {
                ForEach(Selection.allCases) { selection in
                    RadioButton(selectedValue: $selection, value: selection)
                }
            }
            
            RoundedTextField("제목을 입력해주세요.", text: $title, lineColor: .where(.gray200))
            
            RoundedTextEditor("내용을 입력해주세요.", text: $content)
            
            Button {
                isPopupPresented = true
            } label: {
                Text("등록")
                    .whereFont(.body16medium)
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.whereRoundedProminent(disabled: disabled))
        }
        .padding(.horizontal)
        .padding(.top, 40)
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton()
            }
            
            ToolbarItem(placement: .principal) {
                Text("FAQ 및 공지사항 작성")
                    .whereFont(.subtitle18semibold)
                    .foregroundStyle(.where(.gray800))
            }
        }
        .popup($isPopupPresented) {
            VStack(spacing: 24) {
                Text("\(selection == .FAQ ? "FAQ" : "공지사항") 작성이 완료되었습니다.")
                    .whereFont(.body14medium)
                    .foregroundStyle(.where(.gray800))
                
                Button {
                    isPopupPresented = false
                } label: {
                    Text("확인")
                        .whereFont(.body16semibold)
                        .frame(width: 270, height: 48)
                }
                .buttonStyle(.whereRoundedProminent())
            }
            .padding()
        }
    }
}

// MARK: Nested Types
extension EditAnnouncementView {
    enum Selection: RadioButtonSelection {
        case FAQ
        case announcement
        
        var title: String {
            switch self {
            case .FAQ: "FAQ"
            case .announcement: "공지사항"
            }
        }
    }
}

#Preview {
    NavigationStack {
        EditAnnouncementView()
    }
}
