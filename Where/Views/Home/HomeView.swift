//
//  HomeView.swift
//  Where
//
//  Created by 이현호 on 1/5/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("내모임")
                        .whereFont(.title24semibold)
                        
                    Spacer()
                }
                .padding(.leading, 20)
                
                Spacer()
                
                Image("HomeCharacter")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 81.45, height: 87)
                
                Text("아직 모임이 없어요")
                    .whereFont(.body16regular)
                    .foregroundStyle(Color(hex: 0xADB5BD))
                    .padding(.top, 16)
                
                Button {
                    
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray, lineWidth: 1)  // 회색 테두리
                            .frame(width: 144, height: 40)  // 높이를 설정
                            .padding(.horizontal)
                        HStack {
                            Image(systemName: "plus")
                                .whereFont(.body16regular)
                                .foregroundStyle(Color(hex: 0x4F46E5))
                            
                            Text("모임 추가 방법")  // 가운데 글씨
                                .whereFont(.body16regular)
                                .foregroundStyle(Color(hex: 0x4F46E5))
                        }
                    }
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .padding(.top, 40)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image("HomeLogo")
                        
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // 햄버거 메뉴
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .foregroundStyle(.black)
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
