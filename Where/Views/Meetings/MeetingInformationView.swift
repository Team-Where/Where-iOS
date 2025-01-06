//
//  MeetingInformationView.swift
//  Where
//
//  Created by Swain Yun on 1/4/25.
//

import SwiftUI

struct MeetingInformationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var sheetType: SheetType?
    @State private var fullScreenCoverType: FullScreenCoverType? = .editMeetingDate
    @State private var selectedDate: Date?
    
    var body: some View {
        SelectionTab(selection: [.meetingInfo, .placeInfo])
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.backward")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 12)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 6)
                            .foregroundStyle(.black)
                    }
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
            .fullScreenCover(item: $fullScreenCoverType) { type in
                switch type {
                case .editMeetingDate:
                    EditMeetingDateFullScreenCover(selectedDate: $selectedDate)
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
            case .placeInfo: ScrollView { Text("hi") }
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
        @State private var detentSelection: PresentationDetent = .fraction(0.3)
        @State private var detents: Set<PresentationDetent> = [.fraction(0.2), .fraction(0.3), .medium]
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
                .presentationDetents(detents, selection: $detentSelection)
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
                        detentSelection = .medium
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
                        detentSelection = .medium
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
                        detentSelection = .fraction(0.3)
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
                        detentSelection = .fraction(0.3)
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
                        detentSelection = .fraction(0.3)
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
                        detentSelection = .fraction(0.3)
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
        }
    }
}

// MARK: FullScreenCover
extension MeetingInformationView {
    /// 모임정보 화면에서 라우팅 가능한 풀스크린커버의 종류
    enum FullScreenCoverType: Identifiable {
        /// 모임 일정 편집
        case editMeetingDate
        
        var id: String { String(describing: self) }
    }
    
    // MARK: 모임일정 편집 화면에서 라우팅 가능한 시트의 종류
    enum EditMeetingDateSheetType: Identifiable {
        case date, time
        
        var id: String { String(describing: self) }
    }
    
    struct EditMeetingDateFullScreenCover: View {
        @State private var sheetType: EditMeetingDateSheetType? = .date
        @Binding var selectedDate: Date?
        
        var body: some View {
            VStack(spacing: 24) {
                HStack {
                    Image(systemName: "xmark")
                        .hidden()
                    
                    Spacer()
                    
                    Text("일정 등록")
                        .whereFont(.subtitle18semibold)
                    
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                .foregroundStyle(Color(hex: 0x1F2937))
                .padding(.vertical)
                
                Divider()
                
                HStack {
                    Text("만나는 날짜")
                        .whereFont(.body16medium)
                    
                    Spacer()
                    
                    Button {
                        sheetType = .date
                    } label: {
                        HStack(spacing: 8) {
                            AsyncDateView(date: $selectedDate, format: .yyyyMMddKorean, prompt: "날짜를 선택해주세요")
                                .whereFont(.body14regular)
                            
                            Image(.polygonDown)
                        }
                        .foregroundStyle(Color(hex: 0x6B7280))
                        
                    }
                }
                
                Divider()
                
                HStack {
                    Text("만나는 시간")
                        .whereFont(.body16medium)
                    
                    Spacer()
                    
                    Button {
                        sheetType = .time
                    } label: {
                        HStack(spacing: 8) {
                            Text("시간을 선택해주세요")
                                .whereFont(.body14regular)
                            
                            Image(.polygonDown)
                        }
                        .foregroundStyle(Color(hex: 0x6B7280))
                        
                    }
                }
                
                Spacer()
                
                Button {
                    
                } label: {
                    Text("확인")
                        .whereFont(.body16medium)
                        .padding()
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.accent)
                        )
                }
            }
            .padding()
            .sheet(item: $sheetType) { type in
                switch type {
                case .date:
                    EditMeetingDateSheet(
                        sheetType: $sheetType,
                        selectedDate: $selectedDate
                    )
                case .time:
                    Text("time")
                }
            }
        }
    }
    
    struct EditMeetingDateSheet: View {
        @Binding var sheetType: EditMeetingDateSheetType?
        @Binding var selectedDate: Date?
        @State private var temporalSelectedDate: Date?
        
        var body: some View {
            VStack(spacing: 10) {
                HStack {
                    Text("날짜 선택")
                    
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
                .padding([.top, .horizontal])
                
                Divider()
                
                CalendarView(selectedDate: $temporalSelectedDate)
                
                Button {
                    selectedDate = temporalSelectedDate
                    sheetType = .none
                } label: {
                    HStack {
                        AsyncDateView(date: $temporalSelectedDate, format: .MMddEEKorean, prompt: "날짜를 선택해주세요")
                        
                        if let _ = temporalSelectedDate {
                            Rectangle()
                                .frame(width: 1, height: 16)
                            
                            Text("선택")
                        }
                    }
                    .whereFont(.body16medium)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(temporalSelectedDate == nil ? Color(hex: 0xD1D5DB) : .accent)
                    )
                }
                .padding(.horizontal)
                .disabled(temporalSelectedDate == nil)
            }
            .presentationDetents([.fraction(0.6)])
        }
    }
    
    struct EditMeetingTimeSheet: View {
        @Binding var sheetType: EditMeetingDateSheetType?
        @Binding var selectedTime: Date?
        @State private var temporalSelectedTime: Date?
        
        var body: some View {
            VStack {
                HStack {
                    Text("날짜 선택")
                    
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
                .padding([.top, .horizontal])
                
                Divider()
            }
        }
    }
}

#Preview {
    NavigationStack {
        MeetingInformationView()
    }
}
