//
//  SettingView.swift
//  Where
//
//  Created by Swain Yun on 1/20/25.
//

import SwiftUI

struct SettingView: View {
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(pinnedViews: .sectionHeaders) {
                Section {
                    NavigationLink {
                        // TODO: 비밀번호 변경
                    } label: {
                        HStack {
                            Text("비밀번호 변경")
                                .whereFont(.body16medium)
                                .foregroundStyle(.black)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 12)
                                .foregroundStyle(Color(hex: 0xADB58D))
                        }
                    }
                    .frame(width: 350, height: 50)
                    
                    NavigationLink {
                        // TODO: 로그아웃
                    } label: {
                        HStack {
                            Text("로그아웃")
                                .whereFont(.body16medium)
                                .foregroundStyle(.black)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 12)
                                .foregroundStyle(Color(hex: 0xADB58D))
                        }
                    }
                    .frame(width: 350, height: 50)
                    
                    Toggle(isOn: .constant(true)) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("알림")
                                .whereFont(.body16medium)
                                .foregroundStyle(.black)
                            
                            Text("어디에서 진행되는 소식과 정보를 알려드려요.")
                                .whereFont(.body14regular)
                                .foregroundStyle(Color(hex: 0x868E96))
                        }
                    }
                    .tint(.accent)
                    .frame(width: 350, height: 50)
                } header: {
                    HStack {
                        Text("계정 설정")
                            .whereFont(.subtitle18semibold)
                        
                        Spacer()
                    }
                    .frame(width: 350, height: 45)
                    .background(.white)
                }
                .padding()
                
                Rectangle()
                    .fill(Color(hex: 0xF3F4F6))
                
                Section {
                    NavigationLink {
                        // TODO: 개인정보처리방침
                    } label: {
                        HStack {
                            Text("개인정보처리방침")
                                .whereFont(.body16medium)
                                .foregroundStyle(.black)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 12)
                                .foregroundStyle(Color(hex: 0xADB58D))
                        }
                    }
                    .frame(width: 350, height: 50)
                    
                    NavigationLink {
                        // TODO: 서비스 이용약관
                    } label: {
                        HStack {
                            Text("서비스 이용약관")
                                .whereFont(.body16medium)
                                .foregroundStyle(.black)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 12)
                                .foregroundStyle(Color(hex: 0xADB58D))
                        }
                    }
                    .frame(width: 350, height: 50)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("버전 정보")
                                .whereFont(.body16medium)
                                .foregroundStyle(.black)
                            
                            Text("1.0.0")
                                .whereFont(.body14regular)
                                .foregroundStyle(Color(hex: 0x495057))
                        }
                        
                        Spacer()
                        
                        Text("최신버전")
                            .whereFont(.body16regular)
                            .foregroundStyle(Color(hex: 0x495057))
                    }
                    .frame(width: 350, height: 50)
                } header: {
                    HStack {
                        Text("고객지원")
                            .whereFont(.subtitle18semibold)
                        
                        Spacer()
                    }
                    .frame(width: 350, height: 45)
                    .background(.white)
                }
                .padding()
            }
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbarVisibility(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton()
            }
            
            ToolbarItem(placement: .principal) {
                Text("설정")
                    .whereFont(.subtitle18semibold)
                    .foregroundStyle(Color(hex: 0x1F2937))
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingView()
    }
}
