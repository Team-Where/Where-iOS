//
//  MeetingInformationView.swift
//  Where
//
//  Created by Swain Yun on 1/4/25.
//

import SwiftUI

struct MeetingInformationView: View {
    @State private var sheetType: SheetType?
    
    var body: some View {
        SelectionTab(selection: [.meetingInfo, .placeInfo])
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    BackButton()
                }
                
                ToolbarItem(placement: .principal) {
                    // TODO: 모임 도메인 모델 선언 필요
                    Text("2024 연말파티")
                        .whereFont(.subtitle18semibold)
                        .foregroundStyle(Color(hex: 0x1F2937))
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        sheetType = .editMeetingInfo
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.degrees(90))
                            .foregroundStyle(Color(hex: 0x1F2937))
                    }
                }
            }
            .sheet(item: $sheetType) { type in
                switch type {
                case .editMeetingInfo:
                    EditMeetingInfoSheet($sheetType)
                }
            }
    }
}

// MARK: Nested Types - CustomTabbar
extension MeetingInformationView {
    enum TabViewItem {
        case meetingInfo
        case placeInfo
        
        var title: String {
            switch self {
            case .meetingInfo: "모임 정보"
            case .placeInfo: "장소"
            }
        }
        
        @ViewBuilder func view() -> some View {
            switch self {
            case .meetingInfo: MeetingInformationDetailView()
            case .placeInfo: MeetingPlacesView()
            }
        }
    }
    
    struct SelectionTab: View {
        @State private var selectedTab: Int = .zero
        
        private let selection: [TabViewItem]
        
        init(selection: [TabViewItem]) {
            self.selection = selection
        }
        
        var body: some View {
            VStack {
                HStack(spacing: 0) {
                    ForEach(selection.indices, id: \.self) { index in
                        tab(index)
                    }
                }
                
                selection[selectedTab].view()
            }
        }
        
        @ViewBuilder private func tab(_ index: Int) -> some View {
            Button {
                selectedTab = index
            } label: {
                let item = selection[index]
                
                VStack {
                    Text(item.title)
                        .whereFont(selectedTab == index ? .body16semibold : .body16regular)
                    
                    Rectangle()
                        .frame(height: 2)
                }
                .foregroundStyle(selectedTab == index ? Color(hex: 0x1F2937) : Color(hex: 0xE5E7EB))
            }
        }
    }
}

// MARK: Nested Types - Sheet
extension MeetingInformationView {
    /// 모임정보 화면에서 라우팅 가능한 시트의 종류
    enum SheetType: Identifiable {
        /// 모임정보 편집
        case editMeetingInfo
        
        var id: String { String(describing: self) }
    }
    
    struct EditMeetingInfoSheet: View {
        /// 모임정보 편집 간 단계
        enum EditStep {
            /// 모임명, 메모 표시 단계
            case entry
            /// 모임명 수정 단계
            case title
            /// 메모 수정 단계
            case memo
        }
        
        enum EditMeetingFocusState {
            case title, memo
        }
        
        @State private var editStep: EditStep = .entry
        @State private var titleText: String = "2024 연말파티"
        @State private var memoText: String = "메모 입력"
        @Binding var sheetType: SheetType?
        @FocusState private var textFieldFocused: EditMeetingFocusState?
        
        init(
            _ present: Binding<SheetType?>
        ) {
            self._sheetType = present
            // TODO: 모임 모델 주입
        }
        
        var body: some View {
            content()
                .padding()
                .presentationCornerRadius(16)
                .presentationDragIndicator(.hidden)
                .interactiveDismissDisabled()
        }
        
        @ViewBuilder private func content() -> some View {
            switch editStep {
            case .entry: entry
            case .title: title
            case .memo: memo
            }
        }
        
        var entry: some View {
            VStack {
                HStack {
                    Spacer()
                    
                    Button {
                        sheetType = .none
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                            .foregroundStyle(Color(hex: 0x030712))
                    }
                }
                
                HStack {
                    Text("2024 연말파티")
                        .whereFont(.title20semibold)
                        .foregroundStyle(Color(hex: 0x111827))
                    
                    Button {
                        editStep = .title
                    } label: {
                        Image(.pencilIcon)
                            .frame(width: 16, height: 16)
                            .foregroundStyle(.black)
                    }
                    
                    Spacer()
                }
                
                HStack {
                    Text("벌써 연말이다 신나게 놀아보장~~")
                        .whereFont(.body14regular)
                        .foregroundStyle(Color(hex: 0x6B7280))
                    Button {
                        editStep = .memo
                    } label: {
                        Image(.pencilIcon)
                            .frame(width: 12, height: 12)
                            .foregroundStyle(Color(hex: 0x6B7280))
                    }
                    
                    Spacer()
                }
                
                Spacer()
                
                Button {
                    // TODO: 모임 삭제(또는 나가기) 기능 연결
                } label: {
                    Text("모임에서 나가기")
                        .whereFont(.body16medium)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: 0xF3F4F6))
                        .clipShape(.rect(cornerRadius: 16))
                }
            }
            .presentationDetents([.fraction(0.3)])
        }
        
        var title: some View {
            VStack {
                HStack {
                    Text("모임 이름")
                        .whereFont(.subtitle18semibold)
                        .foregroundStyle(Color(hex: 0x1F2937))
                    
                    Spacer()
                    
                    Button {
                        textFieldFocused = .none
                        sheetType = .none
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                            .foregroundStyle(Color(hex: 0x030712))
                    }
                }
                
                TextField("모임 이름 입력", text: $titleText)
                    .whereFont(.body16regular)
                    .foregroundStyle(Color(hex: 0x1F2937))
                    .focused($textFieldFocused, equals: .title)
                
                Spacer()
                
                HStack {
                    Button {
                        textFieldFocused = .none
                        editStep = .entry
                    } label: {
                        Text("취소")
                            .whereFont(.body16medium)
                            .foregroundColor(Color(hex: 0x4B5563))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: 0xF3F4F6))
                            .clipShape(.rect(cornerRadius: 16))
                    }
                    
                    Button {
                        // TODO: 모임명 업데이트 기능 연결
                        textFieldFocused = .none
                        editStep = .entry
                    } label: {
                        Text("확인")
                            .whereFont(.body16medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.accent)
                            .clipShape(.rect(cornerRadius: 16))
                    }
                    .disabled(titleText.isEmpty) // 모임명은 필수 입력
                }
            }
            .onAppear {
                textFieldFocused = .title
            }
            .presentationDetents(textFieldFocused == nil ? [.medium] : [.fraction(0.2)])
        }
        
        var memo: some View {
            VStack {
                HStack {
                    Text("메모")
                        .whereFont(.subtitle18semibold)
                        .foregroundStyle(Color(hex: 0x1F2937))
                    
                    Spacer()
                    
                    Button {
                        textFieldFocused = .none
                        sheetType = .none
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                            .foregroundStyle(Color(hex: 0x030712))
                    }
                }
                
                TextField("메모 입력", text: $memoText)
                    .whereFont(.body16regular)
                    .foregroundStyle(Color(hex: 0x1F2937))
                    .focused($textFieldFocused, equals: .memo)
                
                Spacer()
                
                HStack {
                    Button {
                        textFieldFocused = .none
                        editStep = .entry
                    } label: {
                        Text("취소")
                            .whereFont(.body16medium)
                            .foregroundColor(Color(hex: 0x4B5563))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: 0xF3F4F6))
                            .clipShape(.rect(cornerRadius: 16))
                    }
                    
                    Button {
                        // TODO: 메모 업데이트 기능 연결
                        textFieldFocused = .none
                        editStep = .entry
                    } label: {
                        Text("확인")
                            .whereFont(.body16medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.accent)
                            .clipShape(.rect(cornerRadius: 16))
                    }
                }
            }
            .onAppear {
                textFieldFocused = .memo
            }
            .presentationDetents(textFieldFocused == nil ? [.medium] : [.fraction(0.2)])
        }
    }
}

#Preview {
    NavigationStack {
        MeetingInformationView()
    }
}
