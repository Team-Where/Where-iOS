//
//  PlaceCore.swift
//  Where
//
//  Created by Swain Yun on 4/9/25.
//

import Foundation
import Combine

protocol PlaceCoreProtocol {
    /// 장소 목록
    var places: AnyPublisher<[UInt64: Place], PlaceCoreError> { get }
    /// 최근 찾은 장소 정보
    var currentPlace: AnyPublisher<Place, PlaceCoreError> { get }
    /// 장소별 코멘트 목록
    /// - Note:
    ///     - Key: 장소 식별자
    ///     - Value: 해당 장소의 코멘트들
    ///     - Error: `PlaceCoreError`
    var currentComments: AnyPublisher<[UInt64: [Comment]], PlaceCoreError> { get }
    
    /// 장소 생성
    /// - Parameters:
    ///     - meetingID: 모임 식별자
    ///     - name: 장소명
    ///     - address: 장소 주소
    func createPlace(meetingID: UInt64, name: String, address: String)
    /// 장소 조회
    func readPlaces(meetingID: UInt64)
    /// 장소 삭제
    func deletePlace(id: UInt64)
    /// 장소 선택
    func pickPlace(id: UInt64)
    /// 장소 좋아요 변경
    func togglePlaceLike(id: UInt64)
    /// 장소에 대한 코멘트 작성
    /// - Parameters:
    ///     - placeID: 장소 식별자
    ///     - description: 코멘트 내용
    func createComment(placeID: UInt64, description: String)
    /// 장소에 대한 코멘트 조회
    /// - Parameters:
    ///     - placeID: 장소 식별자
    func readComments(placeID: UInt64)
    /// 장소에 대한 코멘트 수정
    func updateComment(id: UInt64, description: String)
    /// 장소에 대한 코멘트 삭제
    func deleteComment(id: UInt64)
    /// 최근 본 장소 정보
    func readCurrentPlace(id: UInt64)
    /// 사용자가 작성한 코멘트 여부 확인
    func isMyComment(comment: Comment) -> Bool
}

enum PlaceCoreError: Error {
    
}

final class PlaceCore {
    @Published private var _places = [UInt64: Place]()
    @Published private var _currentPlace: Place?
    @Published private var _currentComments = [UInt64: [Comment]]()
    
    private var userID: UInt64?
    
    private let tokenStorage: TokenStorageProtocol
    private let authCore: AuthentificationCoreProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(
        tokenStorage: TokenStorageProtocol,
        authCore: AuthentificationCoreProtocol
    ) {
        self.tokenStorage = tokenStorage
        self.authCore = authCore
        subscribe()
    }
    
    private func subscribe() {
        authCore.user
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    #if DEBUG
                    print(error)
                    #endif
                }
            } receiveValue: { [weak self] user in
                guard let id = user?.id else {
                    self?._places.removeAll()
                    self?.userID = nil
                    return
                }
                self?.userID = id
            }
            .store(in: &cancellables)
        
        $_currentPlace
            .sink { [weak self] place in
                guard let id = place?.id else {
                    self?._currentComments.removeAll()
                    return
                }
                self?.readComments(placeID: id)
            }
            .store(in: &cancellables)
    }
}

// MARK: - PlaceCoreProtocol Confirmation
extension PlaceCore: PlaceCoreProtocol {
    var places: AnyPublisher<[UInt64: Place], PlaceCoreError> {
        $_places
            .setFailureType(to: PlaceCoreError.self)
            .eraseToAnyPublisher()
    }
    
    var currentPlace: AnyPublisher<Place, PlaceCoreError> {
        $_currentPlace
            .compactMap { $0 }
            .setFailureType(to: PlaceCoreError.self)
            .eraseToAnyPublisher()
    }
    
    var currentComments: AnyPublisher<[UInt64: [Comment]], PlaceCoreError> {
        $_currentComments
            .setFailureType(to: PlaceCoreError.self)
            .eraseToAnyPublisher()
    }
    
    func createPlace(meetingID: UInt64, name: String, address: String) {
        
    }
    
    func readPlaces(meetingID: UInt64) {
        
    }
    
    func deletePlace(id: UInt64) {
        
    }
    
    func pickPlace(id: UInt64) {
        
    }
    
    func togglePlaceLike(id: UInt64) {
        
    }
    
    func createComment(placeID: UInt64, description: String) {
        
    }
    
    func readComments(placeID: UInt64) {
        
    }
    
    func updateComment(id: UInt64, description: String) {
        
    }
    
    func deleteComment(id: UInt64) {
        
    }
    
    func readCurrentPlace(id: UInt64) {
        
    }
    
    func isMyComment(comment: Comment) -> Bool {
        comment.writerId == userID
    }
}
