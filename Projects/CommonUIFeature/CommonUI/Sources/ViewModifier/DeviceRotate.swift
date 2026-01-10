//
//  DeviceRotate.swift
//  CommonUI
//
//  Created by 박현수 on 2/5/25.
//

import SwiftUI
extension View {
    public func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}
// Custom view modifier to detect rotation
public struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void
    
    public init(action: @escaping (UIDeviceOrientation) -> Void) {
        self.action = action
    }
    
    public func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}
