//
//  Version.swift
//  CommonUI
//
//  Created by 박현수 on 1/10/26.
//

import SwiftUI

extension View {
    @ViewBuilder
    public func versioned(@ViewBuilder _ content: (Self) -> some View) -> some View {
        content(self)
    }
}
