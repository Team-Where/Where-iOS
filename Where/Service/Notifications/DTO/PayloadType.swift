//
//  PayloadType.swift
//  Where
//
//  Created by BOMBSGIE on 7/6/25.
//

import Foundation

protocol PayloadType {
    var id: UInt64 { get }
    var title: String { get }
    var content: String { get }
    
    init?(userInfo: [AnyHashable : Any])
}
