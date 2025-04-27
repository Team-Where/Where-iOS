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
    /// 특정 장소에 대한 코멘트 목록
    var comments: AnyPublisher<[UInt64: Comment], PlaceCoreError> { get }
    
    /// 장소 생성
    /// - Parameters:
    ///     - meetingID: 모임 식별자
    ///     - name: 장소명
    ///     - address: 장소 주소
    func createPlace(meetingID: UInt64, name: String, address: String)
    /// 특정 장소의 상세 정보 조회
    func readSpecificPlace(id: UInt64)
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
    /// 장소에 대한 코멘트 수정
    func updateComment(comment: Comment, description: String)
    /// 장소에 대한 코멘트 삭제
    func deleteComment(comment: Comment)
    /// 사용자가 작성한 코멘트 여부 확인
    func isMyComment(comment: Comment) -> Bool
}

protocol PlaceMediationProtocol {
    /// 특정 모임의 장소 목록 로드를 지시, 중재자에 의해 호출됨
    func loadPlaces(meetingID: UInt64)
    /// 현재 사용자 식별자를 설정, 중재자에 의해 호출됨
    func setCurrentUserID(_ id: UInt64?)
}

enum PlaceCoreError: Error {
    case networkingError(Error)
    case userIDNotSet
}

final class PlaceCore {
    weak var mediator: Notifiable?
    
    private var currentUserID: UInt64?
    
    private let placesSubject = CurrentValueSubject<[UInt64: Place], PlaceCoreError>([:])
    private let commentsSubject = CurrentValueSubject<[UInt64: Comment], PlaceCoreError>([:])
    
    private let apiService: APIServable
    private var cancellables = Set<AnyCancellable>()
    
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
    var places: AnyPublisher<[UInt64 : Place], PlaceCoreError> {
        placesSubject.eraseToAnyPublisher()
    }
    
    var comments: AnyPublisher<[UInt64 : Comment], PlaceCoreError> {
        commentsSubject.eraseToAnyPublisher()
    }
    
    func createPlace(meetingID: UInt64, name: String, address: String) {
        guard let userID = currentUserID else {
            placesSubject.send(completion: .failure(.userIDNotSet))
            return
        }
        
        let dto = CreatePlaceDTO.Request(meetingID: meetingID, userID: userID, name: name, address: address)
        
        apiService
            .requestPublisher(Endpoint.createPlace(dto: dto), CreatePlaceDTO.Response.self)
            .sink { completion in
                // TODO: 에러 핸들링
            } receiveValue: { [weak self] response in
                let place = response.toEntity()
                guard var places = self?.placesSubject.value else { return }
                places[place.id] = place
                self?.placesSubject.send(places)
            }
            .store(in: &cancellables)
    }
    
    func readSpecificPlace(id: UInt64) {
        apiService
            .requestPublisher(Endpoint.readComments(placeID: id), ReadCommentsDTO.Response.self)
            .map { response -> [UInt64: Comment] in
                response
                    .map { $0.toEntity() }
                    .reduce(into: [:]) { $0[$1.id] = $1 }
            }
            .sink { completion in
                // TODO: 에러 핸들링
            } receiveValue: { [weak self] comments in
                self?.commentsSubject.send(comments)
            }
            .store(in: &cancellables)
    }
    
    func deletePlace(id: UInt64) {
        guard let userID = currentUserID else {
            placesSubject.send(completion: .failure(.userIDNotSet))
            return
        }
        
        let dto = DeletePlaceDTO.Request(id: id, userID: userID)
        
        apiService
            .requestPublisher(Endpoint.deletePlace(dto: dto), EmptyDTO.Response.self)
            .sink { completion in
                // TODO: 에러 핸들링
            } receiveValue: { [weak self] _ in
                guard var places = self?.placesSubject.value else { return }
                places[id] = nil
                self?.placesSubject.send(places)
            }
            .store(in: &cancellables)
    }
    
    func pickPlace(id: UInt64) {
        guard let userID = currentUserID else {
            placesSubject.send(completion: .failure(.userIDNotSet))
            return
        }
        
        let dto = PickPlaceDTO.Request(id: id, userID: userID)
        
        apiService
            .requestPublisher(Endpoint.pickPlace(dto: dto), PickPlaceDTO.Response.self)
            .sink { completion in
                // TODO: 에러 핸들링
            } receiveValue: { [weak self] response in
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
                    isSimulaneouslyShared: oldPlace.isSimulaneouslyShared,
                )
                places[response.id] = newPlace
                self?.placesSubject.send(places)
            }
            .store(in: &cancellables)
    }
    
    func togglePlaceLike(id: UInt64) {
        guard let userID = currentUserID else {
            placesSubject.send(completion: .failure(.userIDNotSet))
            return
        }
        
        let dto = TogglePlaceLikeDTO.Request(id: id, userID: userID)
        
        apiService
            .requestPublisher(Endpoint.togglePlaceLike(dto: dto), TogglePlaceLikeDTO.Response.self)
            .sink { completion in
                // TODO: 에러 핸들링
            } receiveValue: { [weak self] response in
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
                    isSimulaneouslyShared: oldPlace.isSimulaneouslyShared,
                )
                places[response.id] = newPlace
                self?.placesSubject.send(places)
            }
            .store(in: &cancellables)
    }
    
    func createComment(placeID: UInt64, description: String) {
        guard let userID = currentUserID else {
            commentsSubject.send(completion: .failure(.userIDNotSet))
            return
        }
        
        let dto = CreateCommentDTO.Request(placeID: placeID, userID: userID, description: description)
        
        apiService
            .requestPublisher(Endpoint.createComment(dto: dto), CreateCommentDTO.Response.self)
            .sink { completion in
                // TODO: 에러 핸들링
            } receiveValue: { [weak self] response in
                guard var comments = self?.commentsSubject.value else { return }
                
                let comment = Comment(
                    id: response.commentID,
                    placeId: placeID,
                    description: response.description,
//                    writerId: userID
                    createdAt: .now
                )
                
                comments[comment.id] = comment
                self?.commentsSubject.send(comments)
            }
            .store(in: &cancellables)
    }
    
    func updateComment(comment: Comment, description: String) {
        guard let userID = currentUserID else {
            commentsSubject.send(completion: .failure(.userIDNotSet))
            return
        }
        
        let dto = UpdateCommentDTO.Request(id: comment.id, userID: userID, description: description)
        
        apiService
            .requestPublisher(Endpoint.updateComment(dto: dto), UpdateCommentDTO.Response.self)
            .sink { completion in
                // TODO: 에러 핸들링
            } receiveValue: { [weak self] response in
                guard var comments = self?.commentsSubject.value,
                      let oldComment = comments[response.commentID]
                else { return }
                
                let newComment = Comment(
                    id: oldComment.id,
                    placeId: oldComment.placeId,
                    description: response.description,
//                    writerId: oldComment.writerId
                    createdAt: oldComment.createdAt
                )
                comments[response.commentID] = newComment
                self?.commentsSubject.send(comments)
            }
            .store(in: &cancellables)
    }
    
    func deleteComment(comment: Comment) {
        guard let userID = currentUserID else {
            commentsSubject.send(completion: .failure(.userIDNotSet))
            return
        }
        
        let dto = DeletePlaceDTO.Request(id: comment.id, userID: userID)
        
        apiService
            .requestPublisher(Endpoint.deleteComment(dto: dto), EmptyDTO.Response.self)
            .sink { completion in
                // TODO: 에러 핸들링
            } receiveValue: { [weak self] _ in
                guard var comments = self?.commentsSubject.value else { return }
                comments[comment.id] = nil
                self?.commentsSubject.send(comments)
            }
            .store(in: &cancellables)
    }
    
    func isMyComment(comment: Comment) -> Bool {
        // TODO: 로직 보완하기
        guard let userID = currentUserID else { return false }
        return true
    }
}

// MARK: - PlaceMediationProtocol Conformation
extension PlaceCore: PlaceMediationProtocol {
    func loadPlaces(meetingID: UInt64) {
        guard let userID = currentUserID else {
            placesSubject.send(completion: .failure(.userIDNotSet))
            return
        }
        
        apiService
            .requestPublisher(Endpoint.readPlaceDetail(userID: userID, meetingID: meetingID), ReadPlaceDetailDTO.Response.self)
            .sink { completion in
                // TODO: 에러 핸들링
            } receiveValue: { [weak self] response in
                let places = response.map { $0.toEntity() }
                let placesDict = places.reduce(into: [:]) { $0[$1.id] = $1 }
                self?.placesSubject.send(placesDict)
            }
            .store(in: &cancellables)
    }
    
    func setCurrentUserID(_ id: UInt64?) {
        currentUserID = id
    }
}
