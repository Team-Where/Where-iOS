//
//  NewMeetingCompleteView.swift
//  Where
//
//  Created by 이현호 on 1/11/25.
//

import SwiftUI

struct NewMeetingCompleteView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var newMeetImage: UIImage?
    @Binding var text: String
    @Binding var showNewMeeting: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Text("새 모임이 생성되었어요!")
                    .whereFont(.body16medium)
                    .foregroundStyle(Color(hex: 0x4F46E5))
                
                Text(text)
                    .whereFont(.title28semibold)
                    .padding(.top, 16)
                
                if let image = newMeetImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 154, height: 154)
                        .clipShape(RoundedRectangle(cornerSize: .init(width: 16, height: 16)))
                        .padding(.top, 20)
                }
                
                Spacer()
                
                RoundedRectangle(cornerSize: .init(width: 10, height: 10))
                    .overlay {
                        HStack {
                            Image("NewMeetText")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 19.2)
                                .padding(.leading, 20)
                            
                            Text("친구들과 자유롭게 장소를 공유해보세요!")
                                .whereFont(.body14regular)
                                .foregroundStyle(.black)
                            
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .foregroundStyle(Color(hex: 0xF1F3F5))
                    .transition(.opacity)
                    
                // 모임방으로 이동 버튼
                Button {
                    
                } label: {
                    Text("모임방으로 이동")
                        .frame(maxWidth: .infinity)
                        .padding()  // 버튼 내부 여백
                        .background(Color(hex: 0x4F46E5))
                        .foregroundStyle(.white)
                        .bold()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.bottom)
                .padding(.top, 26)
            }
            .padding(.horizontal, 20)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showNewMeeting = false
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.black)
                    }
                }
            }
            .navigationBarBackButtonHidden()
        }
    }
}

#Preview {
    NewMeetingCompleteView(
        newMeetImage: .constant(UIImage(systemName: "person")!),
        text: .constant("테스트 모임"),
        showNewMeeting: .constant(true)
    )
}
