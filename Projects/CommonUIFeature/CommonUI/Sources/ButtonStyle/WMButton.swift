//
//  WMButton.swift
//  CommonUI
//
//  Created by 박현수 on 12/26/24.
//

import SwiftUI

public struct WMButtonStyle: ButtonStyle {
    var backgroundColor: Color
    var disabledColor: Color
    var isDisabled: Bool
    
    public init(backgroundColor: Color = .element, disabledColor: Color = .highlight, isDisabled: Bool = false) {
        self.backgroundColor = backgroundColor
        self.disabledColor = disabledColor
        self.isDisabled = isDisabled
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        ZStack {
            ZStack {
                Group {
                    if configuration.isPressed {
                        if isDisabled {
                            Capsule()
                                .fill(backgroundColor)
                                .northWestShadow(radius: 1, offset: 2)
                        } else {
                            Capsule()
                                .fill(isDisabled ? backgroundColor : backgroundColor.opacity(0.7))
                                .southEastShadow(radius: 1, offset: 2)
                        }
                    } else {
                        Capsule()
                            .fill(backgroundColor)
                            .northWestShadow(radius: 1, offset: 2)
                    }
                }
            }
            
            configuration.label
                .font(.headline)
                .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                .opacity(configuration.isPressed ? isDisabled ? 1 : 0.2 : 1)
        }
        .opacity(isDisabled ? 0.5 : 1) // 비활성화 시 전체적인 투명도 조절
    }
}

#Preview {
    List {
        Button {
            
        } label: {
            Text("hihihi")
        }
//        .frame(width: 200, height: 80)
        .buttonStyle(WMButtonStyle(isDisabled: true))
        
        .listRowSeparator(.hidden)
        
    }
    .listStyle(.plain)
}
