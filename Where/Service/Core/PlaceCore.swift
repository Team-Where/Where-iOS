//
//  PlaceCore.swift
//  Where
//
//  Created by Swain Yun on 4/9/25.
//

import Foundation
import Combine

protocol PlaceCoreProtocol: CoreProtocol {
    /// 장소 목록
    var places: AnyPublisher<[UInt64: Place], PlaceCoreError> { get }
    /// 최근 찾은 장소 정보
    var currentPlace: AnyPublisher<Place?, PlaceCoreError> { get }
    /// 장소별 코멘트 목록
    /// - Note:
    ///     - Key: 장소 식별자
    ///     - Value: 해당 장소의 코멘트들
    ///     - Error: `PlaceCoreError`
    var currentPlaceComments: AnyPublisher<[Comment], PlaceCoreError> { get }
    
    /// 장소 생성
    /// - Parameters:
    ///     - meetingID: 모임 식별자
    ///     - name: 장소명
    ///     - address: 장소 주소
    func createPlace(meetingID: UInt64, name: String, address: String)
    /// 특정 장소 조회
    func fetchPlace(id: UInt64) -> Place?
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
    /// 특정 코멘트 조회
    func fetchComment(id: UInt64) -> Comment?
    /// 장소에 대한 코멘트 수정
    func updateComment(id: UInt64, description: String)
    /// 장소에 대한 코멘트 삭제
    func deleteComment(id: UInt64)
    /// 사용자가 작성한 코멘트 여부 확인
    func isMyComment(comment: Comment) -> Bool
}

protocol PlaceMediationProtocol {
    /// 특정 모임의 장소 목록 로드를 지시, 중재자에 의해 호출됨
    func loadPlaces(meetingID: UInt64)
    /// 최근 본 장소 정보 로드를 지시, 중재자에 의해 호출됨
    func loadCurrentPlace(id: UInt64)
    /// 특정 장소의 코멘트 로드를 지시, 중재자에 의해 호출됨
    func loadComments(placeID: UInt64)
    /// 현재 사용자 식별자를 설정, 중재자에 의해 호출됨
    func setCurrentUserID(_ id: UInt64?)
}

enum PlaceCoreError: Error {
    case networkingError(Error)
    case userIDNotSet
}

final class PlaceCore {
    weak var mediator: Notifiable?
    
    private var _places = [UInt64: Place]()
    private var _meetingPlaceIDs = [UInt64: Set<UInt64>]()
    private var _comments = [UInt64: Comment]()
    
    private let placesSubject = CurrentValueSubject<[UInt64 : Place], PlaceCoreError>([:])
    private let meetingPlaceIDsSubject = CurrentValueSubject<[UInt64: Set<UInt64>], PlaceCoreError>([:])
    private let commentsSubject = CurrentValueSubject<[UInt64: Comment], PlaceCoreError>([:])
    private let currentPlaceSubject = CurrentValueSubject<Place?, PlaceCoreError>(nil)
    private let currentPlaceCommentsSubject = CurrentValueSubject<[Comment], PlaceCoreError>([])
    
    private var currentUserID: UInt64?
    private let apiService: APIServable
    private var cancellables = Set<AnyCancellable>()
    
    init(
        apiService: APIServable
    ) {
        self.apiService = apiService
        subscribe()
    }
    
    private func subscribe() {
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
        
        meetingPlaceIDsSubject
            .sink { completion in
                // TODO: 에러 핸들링 강화
            } receiveValue: { [weak self] mapping in
                self?._meetingPlaceIDs = mapping
            }
            .store(in: &cancellables)
        
        currentPlaceSubject
            .sink { completion in
                // TODO: 에러 핸들링 강화
            } receiveValue: { [weak self] place in
                guard let place else {
                    self?._comments.removeAll()
                    return
                }
                self?.mediator?.notify(event: .placeSelected(id: place.id))
            }
            .store(in: &cancellables)
        
        currentPlaceSubject
            .combineLatest(commentsSubject)
            .map { place, commentsDict -> [Comment] in
                guard let place else { return [] }
                return commentsDict.values.filter { $0.placeId == place.id }
            }
            .catch { error -> AnyPublisher<[Comment], PlaceCoreError> in
                Just([])
                    .setFailureType(to: PlaceCoreError.self)
                    .mapError { _ in error }
                    .eraseToAnyPublisher()
            }
            .sink { completion in
                // TODO: 에러 핸들링 강화
            } receiveValue: { [weak self] comments in
                self?.currentPlaceCommentsSubject.send(comments)
            }
            .store(in: &cancellables)
        
        commentsSubject
            .sink { completion in
                // TODO: 에러 핸들링 강화
            } receiveValue: { [weak self] dict in
                self?._comments = dict
            }
            .store(in: &cancellables)
    }
}

// MARK: - PlaceCoreProtocol Confirmation
extension PlaceCore: PlaceCoreProtocol {
    var places: AnyPublisher<[UInt64 : Place], PlaceCoreError> {
        placesSubject.eraseToAnyPublisher()
    }
    
    var currentPlace: AnyPublisher<Place?, PlaceCoreError> {
        currentPlaceSubject.eraseToAnyPublisher()
    }
    
    var currentPlaceComments: AnyPublisher<[Comment], PlaceCoreError> {
        currentPlaceCommentsSubject.eraseToAnyPublisher()
    }
    
    func createPlace(meetingID: UInt64, name: String, address: String) {
        
    }
    
    func fetchPlace(id: UInt64) -> Place? {
        _places[id]
    }
    
    func deletePlace(id: UInt64) {
        
    }
    
    func pickPlace(id: UInt64) {
        
    }
    
    func togglePlaceLike(id: UInt64) {
        
    }
    
    func createComment(placeID: UInt64, description: String) {
        
    }
    
    func fetchComment(id: UInt64) -> Comment? {
        _comments[id]
    }
    
    func updateComment(id: UInt64, description: String) {
        
    }
    
    func deleteComment(id: UInt64) {
        
    }
    
    func isMyComment(comment: Comment) -> Bool {
        guard let userID = currentUserID else { return false }
        return comment.writerId == userID
    }
}

// MARK: - PlaceMediationProtocol Conformation
extension PlaceCore: PlaceMediationProtocol {
    func loadPlaces(meetingID: UInt64) {
        // TODO: 장소 조회 로직 구현
        // 1. 캐시 확인, 없다면 네트워크 요청
        
        // placesSubject.send(<#T##input: [UInt64 : Place]##[UInt64 : Place]#>)
    }
    
    func loadCurrentPlace(id: UInt64) {
        // TODO: 장소 상세 정보 조회 로직 구현
        // 1. 캐시 확인, 없다면 네트워크 요청
        
        // currentPlaceSubject.send(<#T##input: Place?##Place?#>)
    }
    
    func loadComments(placeID: UInt64) {
        // TODO: 코멘트 목록 조회 로직 구현
        // 1. 캐시 확인, 없다면 네트워크 요청
        
        // commentsSubject.send(<#T##input: [UInt64 : Comment]##[UInt64 : Comment]#>)
    }
    
    func setCurrentUserID(_ id: UInt64?) {
        currentUserID = id
    }
}
