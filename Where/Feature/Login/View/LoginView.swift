//
//  LoginView.swift
//  Where
//
//  Created by Swain Yun on 12/30/24.
//

import SwiftUI
import AuthenticationServices
import Swinject

struct LoginView: View {
    @State private var viewModel: LoginViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isRegistrationTermViewPresented: Bool = false
    @State private var isSignInViewPresented: Bool = false
    
    private let resolver: Resolver
    
    init(
        resolver: Resolver
    ) {
        self.viewModel = resolver.resolve(LoginViewModel.self)!
        self.resolver = resolver
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("약속을 새롭게 정의하다")
                    .whereFont(.subtitle18semibold)
                    .padding()
                
                Image(.logo)
                
                Spacer()
                
                Image(.glassfyingCharacter)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                Spacer()
                
                VStack(spacing: 20) {
                    // Start With Naver Button
                    Button {
                        viewModel.loginWithNaver()
                    } label: {
                        Image(.startWithNaver)
                            .resizable()
                            .scaledToFit()
                    }
                    .frame(width: 350, height: 48)
                    .onOpenURL { url in
                        viewModel.handleOpenURL(.naver, url: url)
                    }
                    
                    // Start With Kakao Button
                    Button {
                        viewModel.loginWithKakao()
                    } label: {
                        Image(.startWithKakao)
                            .resizable()
                            .scaledToFit()
                    }
                    .frame(width: 350, height: 48)
                    .onOpenURL { url in
                        viewModel.handleOpenURL(.kakao, url: url)
                    }
                    
                    SignInWithAppleButton(.continue) { request in
                        request.requestedScopes = [.email]
                        request.nonce = UUID().uuidString
                    } onCompletion: { result in
                        switch result {
                        case .failure(let error):
                            print("Error ccured from SignInWithAppleButton: \(error)")
                        case .success(let auth):
                            viewModel.loginWithApple(auth: auth)
                        }
                    }
                    .frame(width: 350, height: 48)
                    .clipShape(.rect(cornerRadius: 10))
                    
                    // Start With E-mail Button
                    NavigationLink {
                        RegistrationTermView($isRegistrationTermViewPresented, resolver: resolver)
                    } label: {
                        Text("이메일로 시작하기")
                            .whereFont(.body16semibold)
                            .frame(height: 48)
                    }
                    .frame(width: 350)
                    .buttonStyle(.whereRoundedProminent())
                    
                    HStack {
                        Text("이미 계정 있나요?")
                            .whereFont(.body14medium)
                        
                        NavigationLink {
                            SignInView($isSignInViewPresented, resolver: resolver)
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
        .onChange(of: viewModel.isLoginCompleted) { _, isCompleted in
            guard isCompleted else { return }
            dismiss()
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
    LoginView(resolver: PreviewHelper.shared.resolver)
}
