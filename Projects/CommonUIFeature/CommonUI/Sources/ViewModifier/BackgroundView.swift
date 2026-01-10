//
//  BackgroundView.swift
//  CommonUI
//
//  Created by 박현수 on 1/12/25.
//

import SwiftUI

public struct BackgroundView: View {
    public init() {}
    public var body: some View {
        Color.systemWhite
            .cornerRadius(10)
            .northWestShadow(radius: 3, offset: 3)
    }
}

#Preview {
    BackgroundView()
        .padding()
}
