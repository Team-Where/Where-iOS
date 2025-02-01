//
//  PlaceDetail.swift
//  Where
//
//  Created by 이현호 on 1/18/25.
//

import SwiftUI

struct PlaceDetail: View {
    @State private var isPlacePick = false
    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack(alignment: .topLeading) {
                    // 장소 정보
                    PlaceInfo(imageName: "ExampleImage", name: "무드서울", address: "서울 용산구 한강대로21길 18 1층")
                    
                    RoundedRectangle(cornerSize: .init(width: 17, height: 17))
                        .overlay {
                            HStack {
                                Text("같이 찾은 장소")
                                    .whereFont(.caption11regular)
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(width: 71, height: 19)
                        .foregroundStyle(Color(hex: 0x4F46E5))
                        .padding(.leading, 10)
                        .padding(.top, 10)
                }
                
                HStack {
                    // 코멘트
                    HStack(spacing: 1) {
                        Image(systemName: "message")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 12, height: 12)
                        
                        Text("코멘트")
                            .whereFont(.body14medium)
                            .padding(.leading, 4)
                        
                        Text("4")
                            .whereFont(.body14medium)
                            .padding(.leading, 2)
                    }
                    .foregroundStyle(Color(hex: 0x868E96))
                    .padding(.top, 12)
                    
                    //  좋아요
                    HStack(spacing: 1) {
                        Image(systemName: "heart.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 12, height: 12)
                        
                        Text("코멘트")
                            .whereFont(.body14medium)
                            .padding(.leading, 4)
                        
                        Text("1")
                            .whereFont(.body14medium)
                            .padding(.leading, 2)
                    }
                    .foregroundStyle(Color(hex: 0x4F46E5))
                    .padding(.top, 12)
                    .padding(.leading, 12)
                }
                
                HStack {
                    // 네이버 지도 버튼
                    Button {
                        // 네이버 지도 이동
                    } label: {
                        HStack {
                            Spacer()
                            Image("NaverMapLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            
                            Text("네이버지도")
                                .whereFont(.body14regular)
                                .foregroundStyle(.black)
                            
                            Spacer()
                            
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color(hex: 0xE3E4E9), lineWidth: 1)
                        )
                    }
                    
                    // 카카오맵 버튼
                    Button {
                        // 카카오맵 이동
                    } label: {
                        HStack {
                            Spacer()
                            Image("KakaoMapLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            
                            Text("카카오맵")
                                .whereFont(.body14regular)
                                .foregroundStyle(.black)
                            
                            Spacer()
                            
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color(hex: 0xE3E4E9), lineWidth: 1)
                        )
                    }
                }
                
                RoundedRectangle(cornerSize: .init(width: 16, height: 16))
                    .overlay {
                        ZStack {
                            HStack {
                                HStack {
                                    Text("이 장소로 ")
                                        .foregroundStyle(.black)
                                    + Text("Pick")
                                        .foregroundStyle(Color(hex: 0x4F46E5))
                                    + Text("할까요?")
                                        .foregroundStyle(.black)
                                }
                                .whereFont(.body16medium)
                                .foregroundStyle(.black)
                                
                                Spacer()
                                
                                Button {
                                    withAnimation {
                                        isPlacePick.toggle()
                                    }
                                } label: {
                                    if isPlacePick {
                                        Image(systemName: "checkmark.circle.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 32, height: 32)
                                            .foregroundStyle(Color(hex: 0x4F46E5))
                                    } else {
                                        Image(systemName: "checkmark.circle.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 32, height: 32)
                                            .foregroundStyle(Color(hex: 0xDEE2E6))
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            
                            if !isPlacePick {
                                Image("PickTooltip")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 230, height: 42)
                                    .padding(.top, 80)
                                    .padding(.leading, 87)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .foregroundStyle(Color(hex: 0xF9FAFB))
                    .transition(.opacity)
                    .padding(.top, 32)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 32)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    BackButton()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("삭제")
                            .whereFont(.body16medium)
                    }
                }
            }
            
            VStack {
                Rectangle()
                    .foregroundStyle(Color(hex: 0xF1F3F5))
                    .frame(maxWidth: .infinity)
                    .frame(height: 8)
                    .padding(.top, 31)
            }
            
            // 코멘트 Part
            CommentView()
        }
    }
}

#Preview {
    PlaceDetail()
}
