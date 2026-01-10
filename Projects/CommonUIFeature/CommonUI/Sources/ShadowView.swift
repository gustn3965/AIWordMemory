//
//  ShadowView.swift
//  CommonUI
//
//  Created by 박현수 on 12/25/24.
//

import Foundation

import SwiftUI

extension View {
  public func northWestShadow(radius: CGFloat = 16, offset: CGFloat = 6) -> some View {
    return self
      .shadow(
        color: .highlight, radius: radius, x: -offset,
        y: -offset)
      .shadow(
        color: .shadow, radius: radius, x: offset, y: offset)
  }
  
 public func southEastShadow(
    radius: CGFloat = 16,
    offset: CGFloat = 6
  ) -> some View {
    return self
      .shadow(
          color: .shadow, radius: radius, x: -offset, y: -offset)
      .shadow(
        color: .highlight, radius: radius, x: offset, y: offset)
  }
}

