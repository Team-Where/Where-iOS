//
//  KakaoShareService.swift
//  Where
//
//  Created by Swain Yun on 5/13/25.
//

import Foundation
import Combine
import KakaoSDKCommon
import KakaoSDKShare
import KakaoSDKTemplate

protocol KakaoShareServiceProtocol {
    func share(inviter: User, meeting: Meeting) -> AnyPublisher<URL, MeetingCoreError>
}

final class KakaoShareService {
    private let inviterNameKey = "USER"
    private let meetingTitleKey = "NAME"
    private let inviteCodeKey = "INVITE_CODE"
    private let templateID: Int64 = 119538
    
    private func makeArgs(_ nickname: String, _ title: String, _ code: String) -> [String: String] {
        [
            inviterNameKey: nickname,
            meetingTitleKey: title,
            inviteCodeKey: code
        ]
    }
}

// MARK: - KakaoShareServiceProtocol Conformation
extension KakaoShareService: KakaoShareServiceProtocol {
    func share(inviter: User, meeting: Meeting) -> AnyPublisher<URL, MeetingCoreError> {
        guard let nickname = inviter.nickname,
              let shareLink = meeting.shareLink,
              let code = shareLink.pathComponents.last
        else { return Fail(error: .notSupported).eraseToAnyPublisher() }
        
        let args = makeArgs(nickname, meeting.title, code)
        
        return Future<URL, MeetingCoreError> { promise in
            guard ShareApi.isKakaoTalkSharingAvailable() else {
                guard let url = ShareApi.shared.makeCustomUrl(templateId: self.templateID, templateArgs: args) else {
                    return promise(.failure(.notSupported))
                }
                return promise(.success(url))
            }
            
            ShareApi.shared.shareCustom(templateId: self.templateID, templateArgs: args) { result, error in
                if let error = error {
                    print(error)
                    return promise(.failure(.networkingError(error)))
                }
                
                if let result = result {
                    return promise(.success(result.url))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
