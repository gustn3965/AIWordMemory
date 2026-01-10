//
//  Debouncer.swift
//  DBInterface
//
//  Created by 박현수 on 1/3/25.
//

import Foundation


@MainActor public class DebounceObject: ObservableObject {
    private var task: Task<Void, Never>?
    
    
    public init() { }
    public func debounce(interval: TimeInterval, action: @escaping () async -> Void) {
        task?.cancel()
        task = Task {
            try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            if !Task.isCancelled {
                await action()
            }
        }
    }
}
