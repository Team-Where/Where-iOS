//
//  HistoryReminderView.swift
//  Where
//
//  Created by Swain Yun on 1/3/25.
//

import SwiftUI

struct HistoryReminderView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            ProfilesArea(
                user: .init(nickname: "Swain", isFavorite: false),
                opponentUser: .init(nickname: "상대방", isFavorite: true)
            )
            
            Rectangle()
                .fill(Color(hex: 0xF3F4F6))
                .frame(height: 8)
            
            ScrollView(.vertical) {
                HistoryArea()
            }
            .padding(.horizontal)
            .scrollIndicators(.hidden)
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                backButton
            }
            
            ToolbarItem(placement: .principal) {
                Text("모임활동")
                    .whereFont(.subtitle18semibold)
                    .padding(.vertical, 14)
            }
        }
    }
    
    private var backButton: some View {
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
}

// MARK: Nested Types
extension HistoryReminderView {
    struct ProfilesArea: View {
        let user: User
        let opponentUser: User
        
        var body: some View {
            VStack {
                ZStack {
                    profile(user, isMine: true)
                        .padding(.trailing, 80)
                    
                    profile(opponentUser, isMine: false)
                        .padding(.leading, 80)
                }
                
                Text("\(opponentUser.nickname)님과 함께한 모임을 확인해보세요.")
                    .whereFont(.body14regular)
                    .foregroundStyle(Color(hex: 0x4B5563))
                    .padding(.vertical, 8)
            }
        }
        
        @ViewBuilder private func profile(_ user: User, isMine: Bool) -> some View {
            VStack {
                AsyncImage(url: user.imageURL)
                    .frame(width: 100, height: 100)
                    .clipShape(.circle)
                    .overlay(
                        Circle()
                            .stroke(.white, lineWidth: isMine ? 0 : 3)
                    )
                
                Text(isMine ? "나" : user.nickname)
                    .whereFont(.body16semibold)
                    .foregroundStyle(isMine ? Color(hex: 0x495057) : .black)
                    .padding(.top, 8)
            }
        }
    }
    
    struct HistoryArea: View {
        var body: some View {
            section()
        }
        
        @ViewBuilder private func section() -> some View {
            Section {
                LazyVStack {
                    ForEach(1...12, id: \.self) { month in
                        cell(month)
                    }
                }
            } header: {
                HStack {
                    Text("2024")
                        .whereFont(.title24semibold)
                    
                    Spacer()
                    
                    Text("3개월 지난 모임은 포함되지 않습니다.")
                        .whereFont(.caption12regular)
                        .foregroundStyle(Color(hex: 0x6B7280))
                }
            }
            .padding(.top)
        }
        
        @ViewBuilder private func cell(_ month: Int) -> some View {
            HStack {
                VStack {
                    HStack {
                        Circle()
                            .fill(.accent)
                            .frame(width: 6, height: 6)
                            .background(
                                Circle()
                                    .fill(Color(hex: 0xEEF2FF))
                                    .frame(width: 10, height: 10)
                            )
                        
                        Text("\(month)월")
                            .whereFont(.body16medium)
                    }
                    
                    Rectangle()
                        .fill(Color(hex: 0xD1D5DB))
                        .frame(maxWidth: 1)
                }
                
                VStack {
                    HStack {
                        AsyncImage(url: nil)
                            .frame(width: 65, height: 65)
                            .clipShape(.rect(cornerRadius: 12))
                            .padding(.trailing, 10)
                        
                        VStack(alignment: .leading) {
                            Text("2024.11.26")
                            
                            Text("2024 연말파티")
                                .whereFont(.body16semibold)
                                .foregroundStyle(Color(hex: 0x111827))
                            
                            Text("벌써 연말이다 신나게 놀아보장~~")
                        }
                        .whereFont(.caption12regular)
                        .foregroundStyle(Color(hex: 0x6B7280))
                        
                        Spacer()
                    }
                    .padding(.bottom, 10)
                    
                    NavigationLink {
                        // TODO: 모임정보 화면으로 이동
                    } label: {
                        Text("자세히 보기")
                            .whereFont(.body14medium)
                            .foregroundColor(Color(hex: 0x343A40))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.white)
                                    .strokeBorder(Color(hex: 0xDEE2E6))
                            )
                            .clipShape(.rect(cornerRadius: 8))
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: 0xEEF2FF))
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        HistoryReminderView()
    }
}
