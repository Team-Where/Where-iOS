//
//  NewMeetinSheet2View.swift
//  Where
//
//  Created by LHH on 1/9/25.
//

import SwiftUI

struct NewMeetingSheet2View: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showCompleteView = false
    @State private var showMessage = false
    @State private var isInvited = false
    @State private var invitedFriendName: String? = nil
    @State private var friends = [
        ("친구1", "2번 만남", "person"),
        ("친구2", "3번 만남", "person"),
        ("친구3", "5번 만남", "person"),
        ("친구4", "1번 만남", "person"),
        ("친구5", "2번 만남", "person"),
        ("친구6", "4번 만남", "person")
    ]  // 이 부분은 나중에 변경
    @Binding var newMeetImage: UIImage?
    @Binding var text: String
    @Binding var showNewMeeting: Bool
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text("새 모임 만들기(2/2)")
                        .whereFont(.body14regular)
                        .foregroundStyle(Color(hex: 0x4F46E5))
                    
                    Text("파티원을 초대해요!")
                        .whereFont(.title24semibold)
                        .padding(.top, 10)
                }
                
                // 카카오톡 초대 버튼 추가
                Button {
                    // 카카오톡 공유 기능 추가 예정
                } label: {
                    HStack {
                        Spacer()
                        Image(systemName: "message.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.black)
                        
                        Text("카톡으로 초대하기")
                            .whereFont(.body16medium)
                            .foregroundStyle(.black)
                        
                        Spacer()
                        
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(Color(hex: 0xF9E000))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                //                    .padding(.top, 32)
                
                Text("최근 만난 친구")
                    .whereFont(.body14semibold)
                    .padding(.top, 20)
                
                // 최근 만난 친구 스크롤뷰
                ScrollView {
                    ForEach(friends, id: \.0) { friend in
                        NewFriendListView(showMessage: $showMessage, invitedFriendName: $invitedFriendName, friendName: friend.0, meetingCount: friend.1, imageName: friend.2)
                    }
                }
                .frame(height: 190)
                
                HStack(spacing: 2) {
                    Text("친구")
                        .whereFont(.body14semibold)
                    
                    Text("\(friends.count)") // 친구목록 숫자 표시
                        .whereFont(.body14semibold)
                        .foregroundStyle(Color(hex: 0x4F46E5))
                }
                .padding(.top, 24)
                
                // 전체 친구 스크롤뷰
                ScrollView {
                    ForEach(friends, id: \.0) { friend in
                        NewFriendListView(showMessage: $showMessage, invitedFriendName: $invitedFriendName, friendName: friend.0, meetingCount: friend.1, imageName: friend.2)
                    }
                }
                .frame(height: 190)
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            if showMessage {
                HStack {
                    Image(systemName: "checkmark")
                        .whereFont(.body14medium)
                        .foregroundStyle(Color(hex: 0x6366F1))
                        .padding(.leading)
                    
                    Text("'\(invitedFriendName!)'님을 초대했습니다.")
                        .whereFont(.body14medium)
                        .foregroundStyle(.white)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color(hex: 0x353941))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(hex: 0x353941))
                )
                .padding(.horizontal, 20)
                .opacity(0.8)
            }
        }
        
        // 다음 버튼
        Button {
            showCompleteView = true
        } label: {
            Text("다음")
                .frame(maxWidth: .infinity)
                .padding()  // 버튼 내부 여백
                .background(Color(hex: 0x4F46E5))
                .foregroundStyle(.white)
                .bold()
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.horizontal, 20)
        .padding(.vertical)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.black)
                }
            }
        }
        .fullScreenCover(isPresented: $showCompleteView) {
            NewMeetingCompleteView(newMeetImage: $newMeetImage, text: $text, showNewMeeting: $showNewMeeting)
        }
    }
}

#Preview {
    NavigationStack {
        NewMeetingSheet2View(
            newMeetImage: .constant(UIImage(systemName: "person")!),
            text: .constant("테스트 모임"),
            showNewMeeting: .constant(true)
        )
    }
}
