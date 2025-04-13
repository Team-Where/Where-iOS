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
    var placesSubject: CurrentValueSubject<[UInt64: Place], PlaceCoreError> { get }
    /// 최근 찾은 장소 정보
    var currentPlaceSubject: CurrentValueSubject<Place?, PlaceCoreError> { get }
    /// 장소별 코멘트 목록
    /// - Note:
    ///     - Key: 장소 식별자
    ///     - Value: 해당 장소의 코멘트들
    ///     - Error: `PlaceCoreError`
    var currentCommentsSubject: CurrentValueSubject<[Comment], PlaceCoreError> { get }
    
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
    
    private var userID: UInt64?
    
    private let tokenStorage: TokenStorageProtocol
    private let authCore: AuthentificationCoreProtocol
    let placesSubject = CurrentValueSubject<[UInt64 : Place], PlaceCoreError>([:])
    let currentPlaceSubject = CurrentValueSubject<Place?, PlaceCoreError>(nil)
    let currentCommentsSubject = CurrentValueSubject<[Comment], PlaceCoreError>([])
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
        authCore.userSubject
            .sink { [weak self] completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    switch error {
                    case .loginFailed, .notSupported, .socialAuthProviderAuthorizationFailed, .unknown, .userInfoFetchFailed:
                        self?.userID = nil
                        self?._places.removeAll()
                    case .logoutFailed:
                        break
                    @unknown default: break
                    }
                }
            } receiveValue: { [weak self] user in
                self?.userID = user?.id
            }
            .store(in: &cancellables)
        
        placesSubject
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    // TODO: 에러 핸들링 강화
                    break
                }
            } receiveValue: { [weak self] dict in
                self?._places = dict
            }
            .store(in: &cancellables)
    }
}

// MARK: - PlaceCoreProtocol Confirmation
extension PlaceCore: PlaceCoreProtocol {
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
        Task { @MainActor in
            currentCommentsSubject.send(PreviewHelper.shared.mockComments)
        }
    }
    
    func updateComment(id: UInt64, description: String) {
        
    }
    
    func deleteComment(id: UInt64) {
        
    }
    
    func readCurrentPlace(id: UInt64) {
        if let place = _places[id] {
            currentPlaceSubject.send(place)
        }
    }
    
    func isMyComment(comment: Comment) -> Bool {
        comment.writerId == userID
    }
}
