//
//  WMChipButton.swift
//  CommonUI
//
//  Created by 박현수 on 12/26/24.
//

import SwiftUI

public struct WMChipButton: View {
    
    
    var title: String
    var action: @MainActor () -> Void
    var isEnabled: Bool
    let isSelected: Bool
    var padding: EdgeInsets
    
    public init(title: String,
                isSelected: Bool,
                isEnabled: Bool = true,
                padding: EdgeInsets = EdgeInsets.init(top: 2, leading: 10, bottom: 2, trailing: 10),
                action: @escaping @MainActor () -> Void) {
        
        self.title = title
        self.action = action
        self.isEnabled = isEnabled
        self.isSelected = isSelected
        self.padding = padding
    }
    
    
    @State var buttonSelected: Bool = false 
    
    public var body: some View {
        Button {
                buttonSelected.toggle()
                action()
            } label: {
                ZStack {
                    if isSelected {
                        Color.selectChip
                            .cornerRadius(10)
                            .northWestShadow(radius: 1, offset: 1)
                    } else {
                        Color.unselectChip
                            .cornerRadius(10)
                            .northWestShadow(radius: 2, offset: 2)
                    }
                    
                    Text(LocalizedStringKey(title))
                        .foregroundStyle(Color.systemBlack)
                        .padding(padding)
                }
            }
            .buttonStyle(BlackButton())
            .disabled(!isEnabled)
            .contentShape(Rectangle())
//        .padding([.top, .bottom])
    }
}


private struct BlackButton: ButtonStyle {
    public init() {}
    
    func makeBody(configuration: Configuration) -> some View {
      
            configuration.label
            .foregroundStyle(Color.systemBlack)
                .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
            //            .frame(width: width, height: height)
                .opacity(configuration.isPressed ? 0.2 : 1)
//                
//        }
    }
}

struct CustomView: View {
    @State var isSelected = false
    var body: some View {
        WMChipButton(title: "zzzzz", isSelected: isSelected) {
            isSelected.toggle()
        }
    }
}

#Preview {
    List {
        CustomView()
//        WMChipButton(title: "안녕하세요", isSelected: .constant(false), action: {
//            print("-----")
//        })
            .listRowSeparator(.hidden)
    }
    .listStyle(.plain)
}
