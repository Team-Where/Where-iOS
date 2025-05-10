//
//  CreateMeetingViewModel.swift
//  Where
//
//  Created by Swain Yun on 4/4/25.
//

import Foundation
import Combine
import Swinject

final class CreateMeetingViewModel: ObservableObject {
    @Published private(set) var step: MeetingCreationStep = .basicInformation
    @Published var isPopupPresented: Bool = false
    @Published var isFloaterPresented: Bool = false
    @Published var floaterItem: FloaterItem?
    @Published var selectedImage: Data?
    @Published private(set) var isImageSelected: Bool = false
    @Published var titleFieldText = String()
    @Published var descriptionFieldText = String()
    @Published private(set) var tempMeetingInfo: TemporaryMeetingInfo?
    @Published private(set) var friendsDataSource = [FriendCellDataSource]()
    @Published private(set) var selectedParticipantIDs = Set<UInt64>()
    
    var disabled: Bool { titleFieldText.isEmpty }
    
    private let communityCore: CommunityCoreProtocol
    private let meetingCore: MeetingCoreProtocol
    private let cancellableBag = CancellableBag()
    
    init(resolver: Resolver) {
        self.communityCore = resolver.resolve(CommunityCoreProtocol.self)!
        self.meetingCore = resolver.resolve(MeetingCoreProtocol.self)!
        subscribe()
    }
    
    private func subscribe() {
        communityCore.friends
            .combineLatest(
                meetingCore.relatedMeetingIDs,
                meetingCore.meetingSummaries
            )
            .map { [weak self] friends, relatedMeetings, summaries in
                guard let self else { return [] }
                
                var dataSource = [FriendCellDataSource]()
                let now = Date.now
                
                for friend in friends.values {
                    let friendID = friend.id
                    let sharedMeetingIDs = relatedMeetings[friendID] ?? []
                    let count = sharedMeetingIDs.count
                    let isInvited = self.selectedParticipantIDs.contains(friendID)
                    let isRecent = sharedMeetingIDs.contains {
                        guard let summary = summaries[$0] else { return false }
                        return summary.finishedAt.isRecent(compareTo: now)
                    }
                    let item = FriendCellDataSource(
                        id: friendID,
                        friend: friend,
                        meetingCount: count,
                        isInvited: isInvited,
                        isRecent: isRecent
                    )
                    dataSource.append(item)
                }
                
                dataSource.sort {
                    $0.isRecent == $1.isRecent ? $0.friend.nickname < $1.friend.nickname : $0.isRecent
                }
                
                return dataSource
            }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                // TODO: 에러 핸들링
            } receiveValue: { [weak self] dataSource in
                self?.friendsDataSource = dataSource
            }
            .store(in: cancellableBag, key: "Friends")
    }
}

// MARK: - Nested Types
extension CreateMeetingViewModel {
    /// 모임 생성 단계
    enum MeetingCreationStep: Int {
        /// 기본 정보 설정 단계
        case basicInformation = 1
        /// 친구 초대 단계
        case inviteFriends
        
        var turn: Int { self.rawValue }
        
        var navigationTitle: String {
            switch self {
            case .basicInformation: "어떤 모임인가요?"
            case .inviteFriends: "파티원을 초대해요!"
            }
        }
    }
    
    enum FloaterItem: FloaterContent {
        case invite(friend: FriendRelationship)
        
        var title: String {
            switch self {
            case .invite(let friend): return "'\(friend.nickname)'님을 초대했습니다."
            }
        }
    }
    
    struct FriendCellDataSource: Identifiable {
        /// 친구 식별자
        let id: UInt64
        /// 친구 정보
        let friend: FriendRelationship
        /// 함께한 모임의 횟수
        let meetingCount: Int
        /// 해당 모임의 초대 여부
        var isInvited: Bool
        /// 최근 만난 친구 상태
        let isRecent: Bool
    }
}

// MARK: Interfaces
extension CreateMeetingViewModel {
    func flush() {
        step = .basicInformation
        isPopupPresented = false
        isFloaterPresented = false
        selectedImage = nil
        isImageSelected = false
        titleFieldText.removeAll()
        descriptionFieldText.removeAll()
        tempMeetingInfo = nil
        selectedParticipantIDs.removeAll()
    }
    
    func setBasicInfo() {
        tempMeetingInfo = tempMeetingInfo?.setBasicInfo(title: titleFieldText, description: descriptionFieldText, image: selectedImage)
        step = .inviteFriends
    }
    
    func setInvitedFriends() {
        tempMeetingInfo = tempMeetingInfo?.setInvitedFriends(selectedParticipantIDs.sorted())
    }
    
    func toggleInvitationState(for friendID: UInt64) {
        guard let index = friendsDataSource.firstIndex(where: { $0.id == friendID }) else { return }
        
        var updatedDataSource = friendsDataSource
        var targetItem = updatedDataSource[index]
        targetItem.isInvited.toggle()
        updatedDataSource[index] = targetItem
        
        if targetItem.isInvited {
            selectedParticipantIDs.insert(friendID)
            floaterItem = .invite(friend: targetItem.friend)
        } else {
            selectedParticipantIDs.remove(friendID)
        }
        
        friendsDataSource = updatedDataSource
    }
    
    func createMeeting() {
        guard let tempMeeting = tempMeetingInfo else { return }
    }
}
