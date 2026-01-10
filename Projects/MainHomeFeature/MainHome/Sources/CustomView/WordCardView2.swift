//
//  WordCardView2.swift
//  MainHome
//
//  Created by 박현수 on 2/9/25.
//

import SwiftUI
import CommonUI


public struct WordCardView2: View {
    
    init(viewModel: WordCardViewModel) {
        self.viewModel = viewModel
    }
    @State private var orientation = UIDeviceOrientation.unknown
    
    @ObservedObject var viewModel: WordCardViewModel
    @State private var currentPage = 0
    @State private var cardHeight: CGFloat = 0
    @State private var viewType: WordCardViewType = .all
    
    private let bottomTabPadding = 20.0
    public var body: some View {
        ZStack {
            BackgroundView()
            
            VStack(alignment: .leading) {
                HStack(spacing: 0) {
                    Text("단어 목록")
                        .font(.headline)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
                    
                    wordFilterPickerView
                    sortFilterPickerView
                    
                    Spacer()
                }
                
                GeometryReader { geometry in
                    let isWideView = UIDevice.current.userInterfaceIdiom == .pad || orientation.isLandscape
                    
                    let itemsPerPage = max(1, Int((geometry.size.height - bottomTabPadding) / (cardHeight + 20))) * (isWideView ? 2 : 1) // cardHeight + 간격
                    let _ = print(itemsPerPage)
                    let maxWidth = isWideView ? geometry.size.width / 2 - 80 : geometry.size.width - 40
                    let gridItems = isWideView ? [GridItem(.flexible(maximum: maxWidth)), GridItem(.flexible(maximum: maxWidth))] : [GridItem(.flexible(maximum: maxWidth))]
                    
                    
                    TabView(selection: $currentPage) {
                        ForEach(0..<(viewModel.items.count + itemsPerPage - 1) / itemsPerPage, id: \.self) { pageIndex in
                            VStack {
                                LazyVGrid(columns: gridItems, spacing: 20) {
                                    ForEach(viewModel.items[pageIndex * itemsPerPage..<min((pageIndex + 1) * itemsPerPage, viewModel.items.count)]) { item in
                                        NavigationLink(value: item) {
                                            CardView2(cardItem: item, viewType: viewType)
                                                .reportHeight()
                                        }
                                    }
                                }
                                Spacer()
                            }
                            .tag(pageIndex)
                            
                        }
                        .padding(.bottom, bottomTabPadding)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                    
                }
            }
            .padding(EdgeInsets(top: 15, leading: 0, bottom: 0, trailing: 0))
            .onPreferenceChange(CardHeightPreferenceKey.self) { height in
                MainActor.assumeIsolated() {
                    self.cardHeight = height
                    print("-----------", height)
                }
            }
            .onRotate { newOrientation in
                        orientation = newOrientation
                    }
        }
        .runOnceTask {
            
            print("# \(#file) \(#function)")
            do {
                try await viewModel.fetchWords(filter: viewModel.filter)
            } catch {
                
            }
        }
    }
    
    private var wordFilterPickerView: some View {
        Picker("", selection: $viewType) {
            ForEach(WordCardViewType.allCases) { (viewType: WordCardViewType) in
                Text(LocalizedStringKey(viewType.rawValue)).tag(viewType)
            }
        }
        .tint(Color.systemBlack)
        .pickerStyle(.menu)
        .fixedSize()
        
    }
    
    private var sortFilterPickerView: some View {
        Picker("", selection: $viewModel.sortType) {
            ForEach(WordCardSortFilter.allCases) { (viewType: WordCardSortFilter) in
                Text(LocalizedStringKey(viewType.name)).tag(viewType)
            }
        }
        .tint(Color.systemBlack)
        .pickerStyle(.menu)
        .fixedSize()
        .onChange(of: viewModel.sortType) { _, newValue in
            Task {
                do {
                    try await viewModel.fetchWords(filter: viewModel.filter)
                } catch {
                    
                }
            }
        }
    }
    
}
struct CardHeightPreferenceKey: PreferenceKey {
    nonisolated(unsafe) static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

extension View {
    func reportHeight() -> some View {
        self.background(GeometryReader { geometry in
            Color.clear.preference(key: CardHeightPreferenceKey.self, value: geometry.size.height)
        })
    }
}



fileprivate struct CardView2: View {
    
    var item: CardItem
    
    var viewType: WordCardViewType
    
    init(cardItem: CardItem, viewType: WordCardViewType) {
        self.item = cardItem
        self.viewType = viewType
    }
    
    var body: some View {
        
        ZStack {
            Color.element
                .cornerRadius(30)
                .northWestShadow(radius:1, offset: 2)
            VStack {
                switch viewType {
                case .all:
                    Text(item.word)
                        .foregroundStyle(Color.systemBlack)
                        .font(.headline)
                        .lineLimit(1)
                    Text(item.meaning)
                        .foregroundStyle(Color.systemBlack)
                        .font(.body)
                        .lineLimit(1)
                case .word:
                    Text(item.word)
                        .foregroundStyle(Color.systemBlack)
                        .font(.headline)
                        .lineLimit(1)
                case .meaning:
                    Text(item.meaning)
                        .foregroundStyle(Color.systemBlack)
                        .font(.body)
                        .lineLimit(1)
                }
                
                
            }
            .padding(EdgeInsets.init(top: 7, leading: 10, bottom: 7, trailing: 10))
        }
    }
}


#Preview {
    NavigationStack {
        List {
            Text("hihi")
            
            WordCardView2(viewModel: WordCardViewModel(dbService: MainHomeMockDIContainer().makeDBImplementation()))
                .frame(height: 400)
            
        }
    }
    
}
