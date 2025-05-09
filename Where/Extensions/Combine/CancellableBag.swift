//
//  CancellableBag.swift
//  Where
//
//  Created by Swain Yun on 5/9/25.
//

import Foundation
import Combine

final class CancellableBag {
    private let lock = NSLock()
    private var cancellables = [String: AnyCancellable]()
    
    subscript(_ key: String) -> AnyCancellable? {
        get {
            lock.lock()
            defer { lock.unlock() }
            return cancellables[key]
        }
        
        set {
            lock.lock()
            defer { lock.unlock() }
            cancellables[key]?.cancel()
            guard let newValue = newValue else {
                cancellables.removeValue(forKey: key)
                return
            }
            cancellables[key] = newValue
        }
    }
    
    init() { }
    
    deinit { cancelAll() }
    
    func insert(_ cancellable: AnyCancellable, key: String) {
        lock.lock()
        defer { lock.unlock() }
        cancellables[key]?.cancel()
        cancellables[key] = cancellable
    }
    
    func cancel(_ key: String) {
        lock.lock()
        cancellables[key]?.cancel()
        cancellables.removeValue(forKey: key)
        lock.unlock()
    }
    
    func cancelAll() {
        lock.lock()
        cancellables.forEach { $0.value.cancel() }
        cancellables.removeAll()
        lock.unlock()
    }
}
