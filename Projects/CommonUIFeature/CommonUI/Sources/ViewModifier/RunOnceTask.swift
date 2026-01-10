//
//  RunOnceTask.swift
//  CommonUI
//
//  Created by 박현수 on 1/3/25.
//

import SwiftUI


struct RunOnceTask: ViewModifier {
    @State private var hasRun = false
    let task: () async -> Void

    func body(content: Content) -> some View {
        content.task {
            guard !hasRun else { return }
            hasRun = true
            await task()
        }
    }
}
extension View {
    public func runOnceTask(perform task: @escaping () async -> Void) -> some View {
        modifier(RunOnceTask(task: task))
    }
}
