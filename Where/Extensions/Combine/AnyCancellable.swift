//
//  AnyCancellable.swift
//  Where
//
//  Created by Swain Yun on 5/9/25.
//

import Combine

// MARK: - AnyCancellable+CancellableBag
extension AnyCancellable {
    func store(in bag: CancellableBag, key: String) {
        bag[key] = self
    }
}
