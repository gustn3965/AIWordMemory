//
//  CardView.swift
//  MainHome
//
//  Created by 박현수 on 12/26/24.
//

import SwiftUI
import CommonUI

public struct WordCardView: View {

    @ObservedObject var viewModel: WordCardViewModel
    
    init(viewModel: WordCardViewModel) {
        self.viewModel = viewModel
    }
    
    let gridItems: [GridItem] = [GridItem(.adaptive(minimum: 140, maximum: 140), spacing: 20)]
    public var body: some View {
        
        ZStack {
            BackgroundView()
            
            VStack(alignment: .leading) {
                Text("단어 목록")
                    .font(.headline)
                    .padding(EdgeInsets.init(top: 15, leading:20, bottom: 0, trailing: 0))
                
                ScrollView {
                    LazyVGrid(columns: gridItems, spacing: 20) {
                        ForEach(viewModel.items) { item in
                            NavigationLink(value: item) {
                                CardView(cardItem: item)
                            }
                        }
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 20))
                    
                }
//                .scrollDisabled(true)
            }
        }
        .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
        .runOnceTask {
            
            print("# \(#file) \(#function)")
                do {
                    try await viewModel.fetchWords(filter: viewModel.filter)
                } catch {
                    
                }
        }
    }
}



#Preview {
    NavigationStack {
        List {
            Text("hihi")
            
            WordCardView(viewModel: WordCardViewModel(dbService: MainHomeMockDIContainer().makeDBImplementation()))
                        .frame(width: 320, height: 400)
            
        }
    }
        
}

struct CardView: View {
    
    var item: CardItem
    
    init(cardItem: CardItem) {
        self.item = cardItem
    }
    
    var body: some View {
        
        ZStack {
            Color.element
                .cornerRadius(30)
                .northWestShadow(radius:1, offset: 2)
            VStack {
                Text(item.word)
                    .foregroundStyle(Color.systemBlack)
                    .font(.title3)
                Text(item.meaning)
                    .foregroundStyle(Color.systemBlack)
                    .font(.callout)
                
            }
            .padding(EdgeInsets.init(top: 20, leading: 30, bottom: 20, trailing: 30))
        }
    }
}
