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
            VStack(alignment: .leading) {
                Text("내모임")
                    .whereFont(.title24semibold)
                    .padding(.top, 40)
                
                Spacer()
                
                VStack {
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
                                .stroke(Color.gray, lineWidth: 1)
                                .frame(width: 144, height: 40)
                                .padding(.horizontal)
                            HStack(spacing: 8) {
                                Image(systemName: "plus")
                                    .whereFont(.body16regular)
                                    .foregroundStyle(Color(hex: 0x4F46E5))
                            
                                Text("모임 추가 방법")
                                    .whereFont(.body16regular)
                                    .foregroundStyle(Color(hex: 0x4F46E5))
                            }
                        }
                    }
                    .padding(.top, 20)
                }
                .frame(maxWidth: .infinity)
                
                Spacer()
            }
            .padding(.horizontal, 20)
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
