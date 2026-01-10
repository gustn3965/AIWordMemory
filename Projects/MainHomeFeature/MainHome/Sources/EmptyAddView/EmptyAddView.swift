//
//  EmptyAddView.swift
//  MainHome
//
//  Created by 박현수 on 1/1/25.
//

import SwiftUI
import CommonUI

public struct EmptyAddView: View {
    
    @Binding var showAddSheet: Bool
    
    public var body: some View {
        
        ZStack {
            BackgroundView()
            
            VStack(alignment: .center) {
                Text("외우고자 하는 단어를 추가해주세요.")
                    .font(.headline)
                    .padding(EdgeInsets.init(top: 10, leading:0, bottom: 0, trailing: 0))
                
                Button {
                    showAddSheet.toggle()
                } label: {
                    ZStack {
                        Color.element
                            .cornerRadius(10)
                            .northWestShadow(radius:1, offset: 2)
                        Image(systemName: "plus")
                            
                        .padding(EdgeInsets.init(top: 20, leading: 30, bottom: 20, trailing: 30))
                    }
                }
                
                .frame(width: 100, height: 100)
//                .scrollDisabled(true)
            }
            .padding(.bottom, 10)
        }
        .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
        
    }
}

#Preview {
    List {
        EmptyAddView(showAddSheet: .constant(false))
            .listRowSeparator(.hidden)
    }
    .listStyle(.plain)
}
