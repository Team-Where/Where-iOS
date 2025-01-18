//
//  NewFriendListView.swift
//  Where
//
//  Created by LHH on 1/10/25.
//

import SwiftUI

struct NewFriendListView: View {
    @Binding var showMessage: Bool
    @Binding var invitedFriendName: String?
    
    var friendName: String
    var meetingCount: String
    var imageName: String
    
    @State private var isInvited = false
    
    var body: some View {
        HStack(alignment: .center) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading) {
                Text(friendName)
                    .whereFont(.body16medium)
                    .padding(.bottom, -5)
                
                Text(meetingCount)
                    .whereFont(.caption11regular)
                    .foregroundStyle(Color(hex: 0x9CA3AF))
            }
            
            Spacer()
            
            Button {
                if !isInvited {
                    isInvited = true
                    showMessage = true
                    invitedFriendName = friendName
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation(.easeOut) {
                            showMessage = false
                        }
                    }
                }
            } label: {
                if isInvited {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark")
                            .whereFont(.body14medium)
                            .foregroundStyle(Color(hex: 0x4F46E5))
                        
                        Text("완료")
                            .whereFont(.body14medium)
                            .foregroundStyle(Color(hex: 0x4F46E5))
                    }
                    .frame(width: 72, height: 32)
                    .background(Color(hex: 0xF1F3F5))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: 0xE2E6E9), lineWidth: 1)
                    )
                } else {
                    RoundedRectangle(cornerSize: .init(width: 8, height: 8))
                        .stroke(Color(hex: 0xE2E6E9), lineWidth: 1)
                        .overlay {
                            Text("초대")
                                .whereFont(.body14medium)
                                .foregroundStyle(Color(hex: 0x4F46E5))
                        }
                        .frame(width: 52, height: 32)
                }
            }
            .disabled(isInvited)
        }
        .padding(.top, 16)
    }
}

