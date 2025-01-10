//
//  NewMeetingSheetView.swift
//  Where
//
//  Created by 이현호 on 1/5/25.
//

import SwiftUI

struct NewMeetingSheet1View: View {
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var shouldNavigate = false
    @State private var isValid = false
    @State private var showMessage = true
    @State private var newMeetImage: UIImage? = nil
    @State private var showPopup = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Text("새 모임 만들기(1/2)")
                            .whereFont(.body14regular)
                            .foregroundStyle(Color(hex: 0x4F46E5))
                        
                        Text("어떤 모임인가요?")
                            .whereFont(.title24semibold)
                            .padding(.top, 16)
                    }
                    .padding(.bottom, 40)
                    
                    HStack {
                        Spacer()
                        
                        Button {
                            withAnimation {
                                showPopup = true
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerSize: .init(width: 16, height: 16))
                                    .overlay {
                                        if let image = newMeetImage {
                                             Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 120, height: 120)
                                                .clipShape(RoundedRectangle(cornerSize: .init(width: 16, height: 16)))
                                        } else {
                                            VStack {
                                                Image(systemName: "camera.fill")
                                                    .resizable()
                                                    .foregroundStyle(Color(hex: 0xCED4DA))
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 36, height: 30)
                                                
                                                Text("사진추가")
                                                    .foregroundStyle(Color(hex: 0x868E96))
                                                    .padding(.top, 5)
                                            }
                                        }
                                    }
                                    .frame(width: 120, height: 120)
                                    .foregroundStyle(Color(hex: 0xF1F3F5))
                            }
                        }
                        
                        Spacer()
                    }
                    
                    VStack(alignment: .leading) {
                        TextField(
                            "",
                            text: $text,
                            prompt: Text(verbatim: "모임이름을 입력해주세요")
                                .foregroundStyle(Color(hex: 0x868E96))
                        )
                        .whereFont(.body16regular)
                        .foregroundStyle(.black)
                        .onChange(of: text) { oldValue, newValue in
                            text = String(newValue.prefix(16)) // 텍스트 글자수 제한
                            isValid = text.count >= 1 // 1글자 이상이면 유효
                        }
                        
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color(hex: 0xE9ECEF))
                        
                        CounterView(text: $text)
                            .padding(.top, 5)
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                    
                    VStack {
                        if showMessage {
                            RoundedRectangle(cornerSize: .init(width: 10, height: 10))
                                .overlay {
                                    Text("모임 이름과 사진은 생성 후에도 변경할 수 있어요.")
                                        .whereFont(.body14medium)
                                        .foregroundStyle(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .foregroundStyle(Color(hex: 0x353941))
                                .transition(.opacity)
                        }
                        
                        Button {
                            shouldNavigate = true
                        } label: {
                            Text("다음")
                                .frame(maxWidth: .infinity)
                                .padding()  // 버튼 내부 여백
                                .background(isValid ? Color(hex: 0x4F46E5) : Color(.systemGray5))  // 유효성 검사에 따라 배경색 변경
                                .foregroundStyle(.white)
                                .bold()
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .padding(.vertical)
                        .disabled(!isValid)  // 유효성 검사 통과 시에만 활성화
                        .navigationDestination(isPresented: $shouldNavigate) {
                            NewMeetingSheet2View()
                        }
                    }
                }
                .padding(.horizontal, 20)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing ) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundStyle(.black)
                        }
                    }
                }
                
                if showPopup {
                    NewImagePopupView(showPopup: $showPopup, newMeetImage: $newMeetImage)
                }
            }
        }
        // 스낵바 3초 유지
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeOut) {
                    showMessage = false
                }
            }
        }
    }
}

// 글자수 카운트
struct CounterView: View {
    @Binding var text: String
    var counter: Int = 0
    
    init(text: Binding<String>) {
        self._text = text
        counter = self._text.wrappedValue.count
    }
    
    var body: some View {
        Text("(\(counter)/16)")
            .whereFont(.body14regular)
            .foregroundStyle(Color(hex: 0x495057))
    }
}


#Preview {
    NewMeetingSheet1View()
}
