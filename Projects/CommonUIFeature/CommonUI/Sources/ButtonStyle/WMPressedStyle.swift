//
//  WMPressedStyle.swift
//  CommonUI
//
//  Created by 박현수 on 1/4/25.
//

import SwiftUI

public struct WMPressedStyle: ButtonStyle {
    
//    let width: CGFloat
//    let height: CGFloat
//
//    public init(width: CGFloat, height: CGFloat) {
//        self.width = width
//        self.height = height
//    }
    
    private let doNotChangeBackground: Bool
    public init(doNotChangeBackground: Bool = false) {
        self.doNotChangeBackground = doNotChangeBackground
    }
    var backgroundColor: Color = .element
    
//    public init(backgroundColor: Color = .element) {
//        self.backgroundColor = backgroundColor
//    }
    
    public func makeBody(configuration: Configuration) -> some View {
//        ZStack {
            if configuration.isPressed {
//                backgroundColor.opacity(0.7)
//                Capsule()
//                    .fill(backgroundColor.opacity(0.7))
//                    .southEastShadow(radius: 1, offset: 1)
            } else {
//                Capsule()
//                    .fill(backgroundColor)
//                    .northWestShadow(radius: 1, offset: 1)
            }
            
            configuration.label
            .background(configuration.isPressed ? doNotChangeBackground ? .clear : backgroundColor.opacity(0.9) : .clear)
//                .font(.headline)
//                .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
//            //            .frame(width: width, height: height)
//                .opacity(configuration.isPressed ? 0.2 : 1)
                
//        }
    }
}

#Preview {
    List {
        Button {
            
        } label: {
            Text("hihihi")
        }
//        .frame(width: 200, height: 80)
        .buttonStyle(WMPressedStyle())
        
        .listRowSeparator(.hidden)
        
    }
    .listStyle(.plain)
}
