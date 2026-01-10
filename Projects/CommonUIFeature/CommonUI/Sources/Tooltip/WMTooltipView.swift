//
//  WMTooltipView.swift
//  CommonUI
//
//  Created by 박현수 on 1/18/25.
//

import SwiftUI

public struct WMTooltipView: View {
    let text: String
    var location: Location
    let action: () -> Void
    
    private let opacity: Double
    
    private let screenSize = UIScreen.main.bounds.size
    
    @State private var contentFrame: CGRect = .zero
    
    public init(text: String, location: Location, opacity: Double = 0.7, action: @escaping () -> Void) {
        self.text = text
        self.location = location
        self.opacity = opacity
        self.action = action
    }
    
    public enum Location: Sendable {
        case centerTop
        case centerBottom
        case rightBottom
    }
    
    public var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                // 삼각형 (위쪽)
                if location == .centerTop {
                    Triangle(location: .centerTop, contentWidth: contentFrame.width)
                        .fill(Color.systemBlack.opacity(opacity))
                        .frame(width: 20, height: 10)
                }
                
                // 본문 내용 (텍스트와 배경)
                VStack {
                    HStack {
                        Text(LocalizedStringKey(text))
                            .foregroundStyle(Color.systemWhite)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .background(Color.systemBlack.opacity(opacity))
                    .cornerRadius(5)
                    .overlay(
                        GeometryReader { geometry in
                            let frame2 = geometry.frame(in: .global)
                            
                            Group {
                                
                            }
                            .onAppear {
                                let frame = geometry.frame(in: .global)
//                                    print(frame)
                                if frame.isEmpty { return }
                                if frame.size.width == 0 { return }
                                if frame.size.height == 0 { return }
                                let _ = print(frame2)
                                self.contentFrame = frame2
                            }
//                            print(frame2)
                            Color.clear
//                                .onAppear {
//                                    let frame = geometry.frame(in: .global)
////                                    print(frame)
//                                    if frame.isEmpty { return }
//                                    if frame.size.width == 0 { return }
//                                    if frame.size.height == 0 { return }
//                                    self.contentFrame = frame
//                                }
                        }
                    )
                    
                }
                
                // 삼각형 (아래쪽)
                if location == .centerBottom {
                    Triangle(location: .centerBottom, contentWidth: contentFrame.size.width)
                        .fill(Color.systemBlack.opacity(opacity))
                        .frame(width: 20, height: 10)
                } else if location == .rightBottom {
                    Triangle(location: .rightBottom, contentWidth: contentFrame.size.width)
                        .fill(Color.systemBlack.opacity(opacity))
                        .frame(width: 20, height: 10)
                }
            }
        }
        .background(Color.clear)
        .foregroundStyle(Color.clear)
        .buttonStyle(WMPressedStyle(doNotChangeBackground: true))
        .offset(calculateOffset())
    }
    
    // MARK: - Offset Calculation
    private func calculateOffset() -> CGSize {
//        if contentFrame.maxX + 20 > screenSize.width {
//            return CGSize(width: screenSize.width - (contentFrame.maxX + 20), height: 0)
//        } else if contentFrame.minX - 20 <= 0 {
//            return CGSize(width: abs(contentFrame.minX) + 20, height: 0)
//        } else {
//            return CGSize(width: 0, height: 0)
//        }
        print(contentFrame)
        let xOffset = max(min(screenSize.width - contentFrame.width / 2 - 20, screenSize.width / 2),
                          contentFrame.width / 2 + 20) - screenSize.width / 2
        return CGSize(width: xOffset, height: 0)
    }
}

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct Triangle: Shape {
    var location: WMTooltipView.Location
    var contentWidth: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        switch location {
        case .centerBottom:
            path.move(to: CGPoint(x: rect.midX - 10, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.midX + 10, y: rect.minY))
        case .centerTop:
            path.move(to: CGPoint(x: rect.midX - 10, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX + 10, y: rect.maxY))
        case .rightBottom:
            path.move(to: CGPoint(x: contentWidth - 7, y: rect.minY))
            path.addLine(to: CGPoint(x: contentWidth - 0, y: rect.maxY))
            path.addLine(to: CGPoint(x: contentWidth + 7, y: rect.minY))
        }
        path.closeSubpath()
        return path
    }
}

struct SizePreferenceKey: PreferenceKey {
    nonisolated(unsafe) static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

#Preview {
    ZStack {
        Color.yellow
        VStack {
            WMTooltipView(text: "헬로우헬로우", location: .centerBottom) {
                
            }
            WMTooltipView(text: "헬로우헬로우", location: .centerTop) {
                
            }
            WMTooltipView(text: "헬로우헬로우", location: .rightBottom) {
                
            }
        }
    }
}
