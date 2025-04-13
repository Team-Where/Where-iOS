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
    @Published var totalMeetingsCount = Int.zero
    @Published var isLoginViewPresented: Bool = false
    
    var isLoginNeeded: Bool { authCore.isLoginNeeded }
    
    private let authCore: AuthentificationCoreProtocol
    private let meetingCore: MeetingCoreProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(
        authCore: AuthentificationCoreProtocol,
        meetingCore: MeetingCoreProtocol
    ) {
        self.authCore = authCore
        self.meetingCore = meetingCore
        subscribe()
    }
    
    private func subscribe() {
        authCore.userSubject
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
        
        meetingCore.meetingsSubject
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
            } receiveValue: { [weak self] dict in
                self?.totalMeetingsCount = dict.values.count
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
