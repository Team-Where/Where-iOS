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
    var places: AnyPublisher<[UInt64: Place], Never> { get }
    /// 특정 장소에 대한 코멘트 목록
    var comments: AnyPublisher<[UInt64: Comment], Never> { get }
    
    /// 장소 생성
    /// - Parameters:
    ///     - meetingID: 모임 식별자
    ///     - name: 장소명
    ///     - address: 장소 주소
    func createPlace(meetingID: UInt64, name: String, address: String) -> AnyPublisher<Place, PlaceCoreError>
    /// 특정 장소의 상세 정보 조회
    func readSpecificPlace(id: UInt64)
    /// 장소 삭제
    func deletePlace(id: UInt64) -> AnyPublisher<Void, PlaceCoreError>
    /// 장소 선택
    func pickPlace(id: UInt64) -> AnyPublisher<Void, PlaceCoreError>
    /// 장소 좋아요 변경
    func togglePlaceLike(id: UInt64) -> AnyPublisher<Void, PlaceCoreError>
    /// 장소에 대한 코멘트 작성
    /// - Parameters:
    ///     - placeID: 장소 식별자
    ///     - description: 코멘트 내용
    func createComment(placeID: UInt64, description: String) -> AnyPublisher<Comment, PlaceCoreError>
    /// 장소에 대한 코멘트 수정
    func updateComment(comment: Comment, description: String) -> AnyPublisher<Void, PlaceCoreError>
    /// 장소에 대한 코멘트 삭제
    func deleteComment(comment: Comment) -> AnyPublisher<Void, PlaceCoreError>
}

protocol PlaceMediationProtocol {
    /// 특정 모임의 장소 목록 로드를 지시, 중재자에 의해 호출됨
    func loadPlaces(meetingID: UInt64)
    /// 현재 사용자 식별자를 설정, 중재자에 의해 호출됨
    func setCurrentUserID(_ id: UInt64?)
    /// 사용자 로그아웃 시 작업 수행을 지시, 중재자에 의해 호출됨
    func userDidLogout()
}

enum PlaceCoreError: Error {
    case networkingError(Error)
    case userIDNotSet
}

final class PlaceCore {
    weak var mediator: Notifiable?
    
    private var currentUserID: UInt64?
    
    private let placesSubject = CurrentValueSubject<[UInt64: Place], Never>([:])
    private let commentsSubject = CurrentValueSubject<[UInt64: Comment], Never>([:])
    
    private let apiService: APIServable
    private let cancellableBag = CancellableBag()
    
    init(
        apiService: APIServable
    ) {
        self.apiService = apiService
        subscribe()
    }
    
    private func subscribe() {
        
    }
}

// MARK: - PlaceCoreProtocol Confirmation
extension PlaceCore: PlaceCoreProtocol {
    var places: AnyPublisher<[UInt64 : Place], Never> {
        placesSubject.eraseToAnyPublisher()
    }
    
    var comments: AnyPublisher<[UInt64 : Comment], Never> {
        commentsSubject.eraseToAnyPublisher()
    }
    
    func createPlace(meetingID: UInt64, name: String, address: String) -> AnyPublisher<Place, PlaceCoreError> {
        guard let userID = currentUserID else {
            return Fail(error: .userIDNotSet).eraseToAnyPublisher()
        }
        
        let dto = CreatePlaceDTO.Request(meetingID: meetingID, userID: userID, name: name, address: address)
        return apiService.requestPublisher(Endpoint.createPlace(dto: dto), CreatePlaceDTO.Response.self)
            .mapError { PlaceCoreError.networkingError($0) }
            .map { [weak self] in
                let newPlace = $0.toEntity()
                guard var places = self?.placesSubject.value else { return newPlace }
                places[newPlace.id] = newPlace
                self?.placesSubject.send(places)
                return newPlace
            }
            .eraseToAnyPublisher()
    }
    
    func readSpecificPlace(id: UInt64) {
        cancellableBag[#function] = apiService
            .requestPublisher(Endpoint.readComments(placeID: id), ReadCommentsDTO.Response.self)
            .map { response -> [UInt64: Comment] in
                response
                    .map { $0.toEntity() }
                    .reduce(into: [:]) { $0[$1.id] = $1 }
            }
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error): print(error)
                }
            } receiveValue: { [weak self] comments in
                self?.commentsSubject.send(comments)
            }
    }
    
    func deletePlace(id: UInt64) -> AnyPublisher<Void, PlaceCoreError> {
        guard let userID = currentUserID else {
            return Fail(error: .userIDNotSet).eraseToAnyPublisher()
        }
        
        let dto = DeletePlaceDTO.Request(id: id, userID: userID)
        return apiService.requestPublisher(Endpoint.deletePlace(dto: dto), EmptyDTO.Response.self)
            .mapError { PlaceCoreError.networkingError($0) }
            .map { [weak self] _ in
                guard var places = self?.placesSubject.value else { return }
                places[id] = nil
                self?.placesSubject.send(places)
            }
            .eraseToAnyPublisher()
    }
    
    func pickPlace(id: UInt64) -> AnyPublisher<Void, PlaceCoreError> {
        guard let userID = currentUserID else {
            return Fail(error: .userIDNotSet).eraseToAnyPublisher()
        }
        
        let dto = PickPlaceDTO.Request(id: id, userID: userID)
        return apiService.requestPublisher(Endpoint.pickPlace(dto: dto), PickPlaceDTO.Response.self)
            .mapError { PlaceCoreError.networkingError($0) }
            .map { [weak self] response in
                guard var places = self?.placesSubject.value,
                      let oldPlace = places[response.id]
                else { return }
                
                let newPlace = Place(
                    id: oldPlace.id,
                    meetingId: oldPlace.meetingId,
                    name: oldPlace.name,
                    address: oldPlace.address,
                    likesCount: response.likesCount,
                    commentsCount: oldPlace.commentsCount,
                    isLikedByMe: response.isLikedByMe,
                    sharedUserImageURLs: oldPlace.sharedUserImageURLs,
                    pickedState: PickedState(response.pickedState),
                    links: oldPlace.links,
                    isSimulaneouslyShared: oldPlace.isSimulaneouslyShared
                )
                places[response.id] = newPlace
                self?.placesSubject.send(places)
            }
            .eraseToAnyPublisher()
    }
    
    func togglePlaceLike(id: UInt64) -> AnyPublisher<Void, PlaceCoreError> {
        guard let userID = currentUserID else {
            return Fail(error: .userIDNotSet).eraseToAnyPublisher()
        }
        
        let dto = TogglePlaceLikeDTO.Request(id: id, userID: userID)
        return apiService.requestPublisher(Endpoint.togglePlaceLike(dto: dto), TogglePlaceLikeDTO.Response.self)
            .mapError { PlaceCoreError.networkingError($0) }
            .map { [weak self] response in
                guard var places = self?.placesSubject.value,
                      let oldPlace = places[response.id]
                else { return }
                
                let newPlace = Place(
                    id: oldPlace.id,
                    meetingId: oldPlace.meetingId,
                    name: oldPlace.name,
                    address: oldPlace.address,
                    likesCount: response.likesCount,
                    commentsCount: oldPlace.commentsCount,
                    isLikedByMe: response.isLikedByMe,
                    sharedUserImageURLs: oldPlace.sharedUserImageURLs,
                    pickedState: PickedState(response.pickedState),
                    links: oldPlace.links,
                    isSimulaneouslyShared: oldPlace.isSimulaneouslyShared
                )
                places[response.id] = newPlace
                self?.placesSubject.send(places)
            }
            .eraseToAnyPublisher()
    }
    
    func createComment(placeID: UInt64, description: String) -> AnyPublisher<Comment, PlaceCoreError> {
        guard let userID = currentUserID else {
            return Fail(error: .userIDNotSet).eraseToAnyPublisher()
        }
        
        let dto = CreateCommentDTO.Request(placeID: placeID, userID: userID, description: description)
        return apiService.requestPublisher(Endpoint.createComment(dto: dto), CreateCommentDTO.Response.self)
            .mapError { PlaceCoreError.networkingError($0) }
            .map { [weak self] response in
                let newComment = response.toEntity(placeID)
                guard var comments = self?.commentsSubject.value else { return newComment }
                comments[newComment.id] = newComment
                self?.commentsSubject.send(comments)
                return newComment
            }
            .eraseToAnyPublisher()
    }
    
    func updateComment(comment: Comment, description: String) -> AnyPublisher<Void, PlaceCoreError> {
        guard let userID = currentUserID else {
            return Fail(error: .userIDNotSet).eraseToAnyPublisher()
        }
        
        let dto = UpdateCommentDTO.Request(id: comment.id, userID: userID, description: description)
        return apiService.requestPublisher(Endpoint.updateComment(dto: dto), UpdateCommentDTO.Response.self)
            .mapError { PlaceCoreError.networkingError($0) }
            .map { [weak self] response in
                guard var comments = self?.commentsSubject.value,
                      let oldComment = comments[response.commentID]
                else { return }
                
                let newComment = Comment(
                    id: oldComment.id,
                    placeId: oldComment.placeId,
                    description: response.description,
                    isMyComment: true,
                    createdAt: oldComment.createdAt
                )
                comments[response.commentID] = newComment
                self?.commentsSubject.send(comments)
            }
            .eraseToAnyPublisher()
    }
    
    func deleteComment(comment: Comment) -> AnyPublisher<Void, PlaceCoreError> {
        guard let userID = currentUserID else {
            return Fail(error: .userIDNotSet).eraseToAnyPublisher()
        }
        
        let dto = DeletePlaceDTO.Request(id: comment.id, userID: userID)
        return apiService.requestPublisher(Endpoint.deleteComment(dto: dto), EmptyDTO.Response.self)
            .mapError { PlaceCoreError.networkingError($0) }
            .map { [weak self] _ in
                guard var comments = self?.commentsSubject.value else { return }
                comments[comment.id] = nil
                self?.commentsSubject.send(comments)
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - PlaceMediationProtocol Conformation
extension PlaceCore: PlaceMediationProtocol {
    func loadPlaces(meetingID: UInt64) {
        guard let userID = currentUserID else { return }
        
        cancellableBag[#function] = apiService.requestPublisher(Endpoint.readPlaceDetail(userID: userID, meetingID: meetingID), ReadPlaceDetailDTO.Response.self)
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    print(error)
                }
            } receiveValue: { [weak self] response in
                let places = response.map { $0.toEntity() }
                let placesDict = places.reduce(into: [:]) { $0[$1.id] = $1 }
                self?.placesSubject.send(placesDict)
            }
    }
    
    func setCurrentUserID(_ id: UInt64?) {
        currentUserID = id
    }
    
    func userDidLogout() {
        currentUserID = nil
        placesSubject.send([:])
        commentsSubject.send([:])
    }
}
