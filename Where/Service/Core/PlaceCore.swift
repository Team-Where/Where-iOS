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
    
    /// 카카오맵을 통해 장소 생성
    /// - Parameters:
    ///     - meetingID: 모임 식별자
    ///     - name: 장소명
    ///     - url: 카카오맵에서 제공받은 유니버셜링크
    func createPlaceByKakaomap(meetingID: UInt64, name: String, url: String) -> AnyPublisher<Void, PlaceCoreError>
    /// 네이버지도를 통해 장소 생성
    /// - Parameters:
    ///     - meetingID: 모임 식별자
    ///     - name: 장소명
    ///     - address: 장소 주소
    func createPlaceByNavermap(meetingID: UInt64, name: String, address: String) -> AnyPublisher<Void, PlaceCoreError>
    /// 특정 장소의 상세 정보 조회
    /// 현재는 코멘트 불러오는 용도
    func readSpecificPlace(id: UInt64) -> AnyPublisher<[UInt64: Comment], PlaceCoreError>
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
    func updateComment(comment: Comment, description: String) -> AnyPublisher<Comment, PlaceCoreError>
    /// 장소에 대한 코멘트 삭제
    func deleteComment(comment: Comment) -> AnyPublisher<UInt64, PlaceCoreError>
}

protocol PlaceMediationProtocol {
    /// 모임별 장소 목록 로드를 지시, 중재자에 의해 호출됨
    func loadPlaces(meetings: [UInt64: Meeting])
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
    
    func createPlaceByKakaomap(meetingID: UInt64, name: String, url: String) -> AnyPublisher<Void, PlaceCoreError> {
        guard let userID = currentUserID else {
            return Fail(error: .userIDNotSet).eraseToAnyPublisher()
        }
        
        let dto = CreatePlaceDTO.RequestForKakaomap(meetingID: meetingID, userID: userID, name: name, link: url)
        return apiService.requestPublisher(Endpoint.createPlaceByKakaomap(dto: dto), CreatePlaceDTO.Response.self)
            .handleEvents(receiveOutput: { [weak self] in
                let newPlace = $0.toEntity(meetingID: meetingID)
                guard var places = self?.placesSubject.value else { return }
                places[newPlace.id] = newPlace
                self?.placesSubject.send(places)
            })
            .map { _ in () }
            .mapError { PlaceCoreError.networkingError($0) }
            .eraseToAnyPublisher()
    }
    
    func createPlaceByNavermap(meetingID: UInt64, name: String, address: String) -> AnyPublisher<Void, PlaceCoreError> {
        guard let userID = currentUserID else {
            return Fail(error: .userIDNotSet).eraseToAnyPublisher()
        }
        
        let dto = CreatePlaceDTO.RequestForNavermap(meetingID: meetingID, userID: userID, name: name, address: address)
        return apiService.requestPublisher(Endpoint.createPlaceByNavermap(dto: dto), CreatePlaceDTO.Response.self)
            .mapError { PlaceCoreError.networkingError($0) }
            .handleEvents(receiveOutput: { [weak self] in
                let newPlace = $0.toEntity(meetingID: meetingID)
                guard var places = self?.placesSubject.value else { return }
                places[newPlace.id] = newPlace
                self?.placesSubject.send(places)
            })
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    func readSpecificPlace(id: UInt64) -> AnyPublisher<[UInt64: Comment], PlaceCoreError> {
        guard let userID = currentUserID else {
            return Fail(error: .userIDNotSet).eraseToAnyPublisher()
        }
        return apiService
            .requestPublisher(Endpoint.readComments(placeID: id, userID: userID), ReadCommentsDTO.Response.self)
            .mapError { PlaceCoreError.networkingError($0)}
            .map { response in
                return response
                    .map { $0.toEntity() }
                    .reduce(into: [:]) { $0[$1.id] = $1 }
            }
            .eraseToAnyPublisher()
    }
    
    func deletePlace(id: UInt64) -> AnyPublisher<Void, PlaceCoreError> {
        guard let userID = currentUserID else {
            return Fail(error: .userIDNotSet).eraseToAnyPublisher()
        }
        
        let dto = DeletePlaceDTO.Request(id: id, userID: userID)
        return apiService.requestVoidPublisher(Endpoint.deletePlace(dto: dto))
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
            .map { response in
                return response.toEntity(placeID)
            }
            .eraseToAnyPublisher()
    }
    
    func updateComment(comment: Comment, description: String) -> AnyPublisher<Comment, PlaceCoreError> {
        guard let userID = currentUserID else {
            return Fail(error: .userIDNotSet).eraseToAnyPublisher()
        }
        
        let dto = UpdateCommentDTO.Request(id: comment.id, userID: userID, description: description)
        return apiService.requestPublisher(Endpoint.updateComment(dto: dto), UpdateCommentDTO.Response.self)
            .mapError { PlaceCoreError.networkingError($0) }
            .map { response in
                return Comment(
                    id: comment.id,
                    placeId: comment.placeId,
                    description: response.description,
                    isMyComment: comment.isMyComment,
                    createdAt: comment.createdAt
                )
            }
            .eraseToAnyPublisher()
    }
    
    func deleteComment(comment: Comment) -> AnyPublisher<UInt64, PlaceCoreError> {
        guard let userID = currentUserID else {
            return Fail(error: .userIDNotSet).eraseToAnyPublisher()
        }
        
        let dto = DeletePlaceDTO.Request(id: comment.id, userID: userID)
        return apiService.requestVoidPublisher(Endpoint.deleteComment(dto: dto))
            .mapError { PlaceCoreError.networkingError($0) }
            .map {
                return comment.id
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - PlaceMediationProtocol Conformation
extension PlaceCore: PlaceMediationProtocol {
    func loadPlaces(meetings: [UInt64: Meeting]) {
        guard let userID = currentUserID else { return }
        
        let publishers = meetings.keys.map { meetingID in
            apiService.requestPublisher(Endpoint.readPlaceDetail(userID: userID, meetingID: meetingID), ReadPlaceDetailDTO.Response.self)
                .map { response in
                    response.map { $0.toEntity(meetingID: meetingID) }
                }
                .catch { error in
                    Just([])
                }
        }
        
        Publishers.MergeMany(publishers)
            .collect()
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    print(error)
                }
            } receiveValue: { [weak self] responses in
                guard var places = self?.placesSubject.value else { return }
                let newPlaces = responses.flatMap { $0 }
                newPlaces.forEach { places[$0.id] = $0 }
                self?.placesSubject.send(places)
            }
            .store(in: cancellableBag, key: #function)
    }
    
    func setCurrentUserID(_ id: UInt64?) {
        currentUserID = id
    }
    
    func userDidLogout() {
        currentUserID = nil
        placesSubject.send([:])
    }
}
