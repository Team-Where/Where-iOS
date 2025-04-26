//
//  CompleteCreationView.swift
//  Where
//
//  Created by Swain Yun on 3/28/25.
//

import SwiftUI

struct CompleteCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isCompleteCreationViewPresented: Bool
    
    let meeting: Meeting
    
    var body: some View {
        VStack(spacing: 20) {
            dismissButton
            
            Spacer()
            
            VStack(spacing: 20) {
                Text("새 모임이 생성되었어요!")
                    .whereFont(.body16medium)
                    .foregroundStyle(.accent)
                
                Text(meeting.title)
                    .whereFont(.title28semibold)
                    .foregroundStyle(.where(.gray900))
                
                AsyncImage(url: meeting.imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 154, height: 154)
                            .background {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.where(.gray200))
                            }
                    case .success(let image):
                        image
                            .frame(width: 154, height: 154)
                            .clipShape(.rect(cornerRadius: 16))
                    case .failure(let error):
                        Text(error.localizedDescription)
                            .frame(width: 154, height: 154)
                            .background {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.where(.gray200))
                            }
                    @unknown default:
                        ProgressView()
                            .frame(width: 154, height: 154)
                            .background {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.where(.gray200))
                            }
                    }
                }
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Image(.colorInvitedFriendsIcon)
                    .padding(.leading)
                
                Text("친구들과 자유롭게 장소를 공유해보세요!")
                    .whereFont(.body14regular)
                    .foregroundStyle(.where(.gray700))
                    .padding(.vertical)
                
                Spacer()
            }
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.where(.gray100))
            }
            
            NavigationLink {
                
            } label: {
                Text("모임방으로 이동")
                    .whereFont(.body16semibold)
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.whereRoundedProminent())
        }
        .padding()
    }
    
    private var dismissButton: some View {
        HStack {
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(.where(.gray800))
            }
        }
        .padding(.top)
    }
}
