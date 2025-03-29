//
//  LoginView.swift
//  Where
//
//  Created by Swain Yun on 12/30/24.
//

import SwiftUI
import AuthenticationServices

struct LoginView<Auth: AuthentificationCoreProtocol>: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var auth: Auth
    
    var body: some View {
        VStack {
            Text("약속을 새롭게 정의하다")
                .whereFont(.subtitle18semibold)
                .padding()
            
            Image(.logo)
            
            Spacer()
            
            Image(.glassfyingCharacter)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            Spacer()
            
            VStack(spacing: 20) {
                // Start With Naver Button
                Button {
                    auth.loginWithNaver()
                } label: {
                    Image(.startWithNaver)
                        .resizable()
                        .scaledToFit()
                }
                .frame(width: 350, height: 48)
                .onOpenURL { url in
                    auth.handleOpenURL(.naver, url)
                }
                
                // Start With Kakao Button
                Button {
                    auth.loginWithKakao()
                } label: {
                    Image(.startWithKakao)
                        .resizable()
                        .scaledToFit()
                }
                .frame(width: 350, height: 48)
                .onOpenURL { url in
                    auth.handleOpenURL(.kakao, url)
                }
                
                SignInWithAppleButton(.continue) { request in
                    request.requestedScopes = [.email]
                    request.nonce = UUID().uuidString
                } onCompletion: { result in
                    switch result {
                    case .failure(let error):
                        print(error)
                    case .success(let auth):
                        self.auth.loginWithApple(auth: auth)
                    }
                }
                .frame(width: 350, height: 48)
                .clipShape(.rect(cornerRadius: 10))
                
                // Start With E-mail Button
                NavigationLink {
                    RegistrationTermView()
                } label: {
                    Text("이메일로 시작하기")
                        .whereFont(.body16semibold)
                        .frame(width: 350, height: 48)
                }
                .buttonStyle(.whereRoundedProminent())
                
                HStack {
                    Text("이미 계정 있나요?")
                        .whereFont(.body14medium)
                    
                    NavigationLink {
                        SignInView()
                    } label: {
                        Text("여기에 로그인하세요")
                            .whereFont(.body14medium)
                            .underline()
                    }
                }
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                backButton
            }
        }
    }
    
    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .frame(width: 12, height: 12)
                .padding()
                .foregroundStyle(.black)
        }
    }
}

#Preview {
    NavigationStack {
        LoginView<AuthentificationCore>()
    }
}
