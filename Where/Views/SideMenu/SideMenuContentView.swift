//
//  SideMenuContentView.swift
//  Where
//
//  Created by 이현호 on 2/8/25.
//

import SwiftUI

struct SideMenuContentView: View {
    @Binding var isSideMenu: Bool // 사이드 메뉴 상태
    
    // 기기별 Safe Area 상단 여백을 계산
    private func safeAreaTopPadding() -> CGFloat {
        guard let window = UIApplication.shared.windows.first else { return 0 }
        return window.safeAreaInsets.top // 안전 영역 + 추가 여백
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isSideMenu = false
                    }
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                        .padding()
                }

                Spacer()

                Button {
                    // 설정 버튼 액션
                } label: {
                    Text("설정")
                        .whereFont(.body16medium)
                        .foregroundStyle(Color(hex: 0x4F46E5))
                        .padding(.trailing, 16)
                }
            }
            .padding(.top, safeAreaTopPadding())
            
            // 프로필 섹션
            HStack {
                VStack(alignment: .leading) {
                    Text("로그인 해주세요")
                        .whereFont(.title24semibold)
                    Button {
                        // 로그인 로직
                    } label: {
                        Text("로그인")
                            .whereFont(.body14medium)
                            .foregroundStyle(Color(hex: 0x4F46E5))
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 50)
                            .stroke(Color(hex: 0xDEE2E6), lineWidth: 1)
                            .frame(width: 68, height: 33)
                    )
                    .padding(.top, 16)
                    .padding(.horizontal)
                }
                
                Spacer()
                
                Image("DefaultProfile")
                    .resizable()
                    .frame(width: 80, height: 80)
            }
            .padding(.top, 16)
            .padding(.horizontal)

            // 구분선
            VStack {
                Rectangle()
                    .foregroundStyle(Color(hex: 0xF1F3F5))
                    .frame(maxWidth: .infinity)
                    .frame(height: 8)
                    .padding(.top, 31)
                    .padding(.bottom, 40)
            }
            
            // 메뉴 리스트
            VStack(alignment: .leading, spacing: 0) {
                SideMenuItem(icon: "bell", title: "알림")
                SideMenuItem(icon: "bubble", title: "FAQ")
                SideMenuItem(icon: "square.and.pencil", title: "1:1 문의")
                SideMenuItem(icon: "megaphone", title: "공지사항")
            }
            .padding(.horizontal)

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
    }
}

// 사이드 메뉴 아이템
struct SideMenuItem: View {
    var icon: String
    var title: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.black)
                .frame(width: 18, height: 18)
            
            Text(title)
                .whereFont(.body16regular)
                .foregroundStyle(.black)
            
            Spacer()
        }
        .padding(.bottom, 32)
    }
}
