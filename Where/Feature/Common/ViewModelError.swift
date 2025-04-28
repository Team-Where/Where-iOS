//
//  ViewModelError.swift
//  Where
//
//  Created by Swain Yun on 4/27/25.
//

import Foundation

enum ViewModelError: Error {
    case authentificationError(AuthentificationCoreError)
    case communityError(CommunityCoreError)
    case meetingError(MeetingCoreError)
    case placeError(PlaceCoreError)
    case supportError(SupportCoreError)
    case notificationError(NotificationCoreError)
}
