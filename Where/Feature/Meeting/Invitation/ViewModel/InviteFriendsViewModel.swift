//
//  InviteFriendsViewModel.swift
//  Where
//
//  Created by Swain Yun on 1/9/25.
//

import Foundation
import Combine
import Swinject

final class InviteFriendsViewModel: ObservableObject {
    @Published var friends = [FriendRelationship]()
    @Published var searchedFriends = [FriendRelationship]()
    @Published var isFloaterPresented: Bool = false
    @Published var isSearching: Bool = false
    @Published var searchingText: String = String()
    @Published var invitedFriends = [MeetingInvitationState]()
    @Published var pendingFriends = [MeetingInvitationState]()
    @Published private var _meetingID: UInt64!
    
    
    var invitationStates: [MeetingInvitationState] {
        invitedFriends + pendingFriends
    }
    
    private let communityCore: CommunityCoreProtocol
    private let meetingCore: MeetingCoreProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(resolver: Resolver) {
        self.communityCore = resolver.resolve(CommunityCoreProtocol.self)!
        self.meetingCore = resolver.resolve(MeetingCoreProtocol.self)!
        subscribe()
    }
    
    private func subscribe() {
        $searchingText
            .removeDuplicates()
            .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                guard text.isEmpty == false,
                      let filtered = self?.friends.filter({ $0.nickname.contains(text) })
                else {
                    self?.searchedFriends.removeAll()
                    return
                }
                
                self?.searchedFriends = filtered
            }
            .store(in: &cancellables)
        
        communityCore.friends
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    #if DEBUG
                    print("Error: \(error)")
                    #endif
                }
            } receiveValue: { [weak self] dict in
                self?.friends = dict.values.sorted { $0.nickname < $1.nickname }
            }
            .store(in: &cancellables)
        
        meetingCore.invitationStatus
            .mapError { ViewModelError.meetingError($0) }
            .combineLatest($_meetingID.setFailureType(to: ViewModelError.self))
            .compactMap { (dict, id) -> [MeetingInvitationState]? in
                guard let id = id else { return nil }
                return dict[id]
            }
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error): print(error)
                }
            } receiveValue: { [weak self] status in
                self?.invitedFriends = status.filter { $0.isInvited }
                self?.pendingFriends = status.filter { !$0.isInvited }
            }
            .store(in: &cancellables)

    }
}

// MARK: - Interfaces
extension InviteFriendsViewModel {
    func inviteFriend(_ friend: FriendRelationship) {
        isFloaterPresented.toggle()
        meetingCore.inviteParticipant(id: _meetingID, guest: friend)
    }
    
    func setMeeting(id: UInt64) {
        self._meetingID = id
    }
}
