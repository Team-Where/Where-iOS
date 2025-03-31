//
//  SideMenuContentViewModel.swift
//  Where
//
//  Created by Swain Yun on 3/31/25.
//

import Foundation
import Combine

final class SideMenuContentViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoginViewPresented: Bool = false
    
    var isLoginNeeded: Bool { auth.isLoginNeeded }
    
    private let auth: any AuthentificationCoreProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(auth: any AuthentificationCoreProtocol) {
        self.auth = auth
        subscribe()
    }
    
    private func subscribe() {
        auth.user
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
#if DEBUG
                    print(error.localizedDescription)
#endif
                }
            } receiveValue: { [weak self] user in
                self?.user = user
            }
            .store(in: &cancellables)
    }
}

// MARK: Interfaces
extension SideMenuContentViewModel {
    func login() {
        isLoginViewPresented = true
    }
}
