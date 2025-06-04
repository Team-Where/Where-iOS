//
//  CreateMeetingViewModel.swift
//  Where
//
//  Created by Swain Yun on 4/4/25.
//

import Foundation
import Combine
import Swinject

protocol BasicInformationPerformable {
    var isImageSelected: Bool { get }
    
    func setBasicInfo(title: String, description: String, imageData: Data?)
}

protocol InvitationStatePerformable {
    typealias FriendCellDataSource = CreateMeetingViewModel.FriendCellDataSource
    
    var selectedParticipantIDs: Set<UInt64> { get }
    var friendsDataSource: [FriendCellDataSource] { get }
    
    func toggleInvitationState(by index: Int)
    func createMeeting()
}

@Observable
final class CreateMeetingViewModel {
    private(set) var step: MeetingCreationStep = .basicInformation
    private(set) var isImageSelected: Bool = false
    private(set) var tempMeetingInfo = TemporaryMeetingInfo.initialize()
    private(set) var friendsDataSource = [FriendCellDataSource]()
    private(set) var selectedParticipantIDs = Set<UInt64>()
    private(set) var floaterItem: FloaterItem?
    
    let cancellableBag = CancellableBag()
    var viewRoutingPublisher: AnyPublisher<(sheet: MainSheetType?, cover: MainFullScreenCoverType), Never> { viewRoutingSubject.eraseToAnyPublisher() }
    
    
    private let communityCore: CommunityCoreProtocol
    private let meetingCore: MeetingCoreProtocol
    
    private let viewRoutingSubject = PassthroughSubject<(sheet: MainSheetType?, cover: MainFullScreenCoverType), Never>()
    
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
                
            } receiveValue: { [weak self] dataSource in
                self?.friendsDataSource = dataSource
            }
            .store(in: cancellableBag, key: "Friends")
        
        meetingCore.createdMeeting
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.viewRoutingSubject.send((nil, .completeCreation($0)))
            }
            .store(in: cancellableBag, key: "CreatedMeeting")
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

// MARK: - BasicInformationPerformable Conformation
extension CreateMeetingViewModel: BasicInformationPerformable {
    func setBasicInfo(title: String, description: String, imageData: Data?) {
        
        tempMeetingInfo = tempMeetingInfo.setBasicInfo(title: title, description: description, image: imageData)
        step = .inviteFriends
    }
}

// MARK: - InvitationStatePerformable Conformation
extension CreateMeetingViewModel: InvitationStatePerformable {
    func toggleInvitationState(by index: Int) {
        var targetItem = friendsDataSource[index]
        targetItem.isInvited.toggle()
        friendsDataSource[index] = targetItem
        
        if targetItem.isInvited {
            selectedParticipantIDs.insert(targetItem.friend.id)
            floaterItem = .invite(friend: targetItem.friend)
        } else {
            selectedParticipantIDs.remove(targetItem.friend.id)
        }
    }
    
    func createMeeting() {
        if selectedParticipantIDs.isEmpty == false {
            tempMeetingInfo = tempMeetingInfo.setInvitedFriends(selectedParticipantIDs)
        }
        
        meetingCore.createMeeting(info: tempMeetingInfo)
            .sink { completion in
                switch completion {
                case .finished: return
                case .failure(let error):
                    #if DEBUG
                    print("\(#function) Error: \(error)")
                    #endif
                }
            } receiveValue: { _ in }
            .store(in: cancellableBag, key: "\(#function)")
    }
}

// MARK: Interfaces
extension CreateMeetingViewModel {
    
}
