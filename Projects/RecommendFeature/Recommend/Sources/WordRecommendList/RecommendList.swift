//
//  RecommendList.swift
//  Recommend
//
//  Created by 박현수 on 2/15/25.
//

import SwiftUI
import CommonUI

struct RecommendListView: View {
    @State private var orientation = UIDeviceOrientation.unknown
    @StateObject var viewModel: RecommendListViewModel
    @Namespace var namespace
    @State private var currentPage = 0
    @State private var cardHeight: CGFloat = 64
    
    
    @State var errorAlert: Bool = false
    @State var aiSearchErrorMessage: String = ""
    
    @State var saveAlert: Bool = false
    @State var saveAlertMessage: String = ""
    
    private let bottomTabPadding = 20.0
    
    public init(viewModel: RecommendListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0) {
                    recommendCount
                    listView
                        .padding(.bottom, 15)
                    
                    moreRecommandButton
                }
                .padding()
                .allowsHitTesting(!viewModel.isLoading)
                
                if viewModel.isLoading {
                    loadingView
                        .ignoresSafeArea(.all, edges: .all)
                }
            }
            
        }
        .alert(LocalizedStringKey(aiSearchErrorMessage), isPresented: $errorAlert,
               presenting: aiSearchErrorMessage) { errorMessage in
            
        } message: { errorMessage in
            
        }
        .alert(LocalizedStringKey(saveAlertMessage), isPresented: $saveAlert,
               presenting: saveAlert) { errorMessage in
            
        } message: { errorMessage in
            
        }
        .task {
            do {
                try await viewModel.firstLoadDB()
            } catch {
                
            }
            
            if viewModel.items.isEmpty {
                do {
                    try await viewModel.fetchRecommend()
                } catch {
                    errorAlert = true
                    aiSearchErrorMessage = error.localizedDescription
                }
            }
        }
        .onRotate { newOrientation in
            orientation = newOrientation
        }
    }
    
    
    private var recommendCount: some View {
        HStack {
            Spacer()
            Text("추천된 단어 \(viewModel.items.count)개")
        }
        
    }
    
    private var listView: some View {
        ZStack {
            BackgroundView()
            GeometryReader { geometry in
                let isWideView = UIDevice.current.userInterfaceIdiom == .pad || orientation.isLandscape
                let maxWidth = isWideView ? geometry.size.width / 2 - 80 : geometry.size.width - 40
                let columns = isWideView ? [GridItem(.flexible()), GridItem(.flexible())] : [GridItem(.flexible())]

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.items) { item in
                            CardView2(cardItem: item, saveAction: {
                                Task {
                                    do {
                                        try await viewModel.saveToWordDB(item: item)
                                        saveAlertMessage = "저장완료"
                                        saveAlert = true
                                    } catch {
                                        saveAlertMessage = error.localizedDescription
                                        saveAlert = true
                                    }
                                }
                            }, speekAction: {
                                Task {
                                    do {
                                        try await viewModel.speechAppleTTS(content: item.word)
                                    } catch {
                                        // 에러 처리
                                    }
                                }
                            })
                            .frame(maxWidth: maxWidth)
                        }
                    }
                    .padding()
                }
            }

            // ✅ 흠, tabView & page일때, 한페이지내에서 카드가 서로 다른 높이일떄 계속 호출돼서 앱이먹통됌...
            
//            GeometryReader { geometry in
//                let isWideView = UIDevice.current.userInterfaceIdiom == .pad || orientation.isLandscape
//                
//                let itemsPerPage = max(1, Int((geometry.size.height - bottomTabPadding) / (cardHeight + 20))) * (isWideView ? 2 : 1) // cardHeight + 간격
//                
//                let maxWidth = isWideView ? geometry.size.width / 2 - 80 : geometry.size.width - 40
//                let gridItems = isWideView ? [GridItem(.flexible(maximum: maxWidth)), GridItem(.flexible(maximum: maxWidth))] : [GridItem(.adaptive(minimum: 100, maximum: .infinity))]
////                let _ = print("????? \(currentPage)")
//                VStack {
//                    Color.clear.frame(height: 10)
//                    TabView(selection: $currentPage) {
//                        ForEach(0..<(viewModel.items.count + itemsPerPage - 1) / itemsPerPage, id: \.self) { pageIndex in
//                            VStack {
////                                let _ = print("????? \(pageIndex)")
//                                LazyVGrid(columns: gridItems, spacing: 20) {
//                                    ForEach(viewModel.items[pageIndex * itemsPerPage..<min((pageIndex + 1) * itemsPerPage, viewModel.items.count)]) { item in
//                                        CardView2(cardItem: item, saveAction: {
//                                            Task {
//                                                do {
//                                                    try await viewModel.saveToWordDB(item: item)
//                                                    saveAlertMessage = "저장완료"
//                                                    saveAlert = true
//                                                } catch {
//                                                    saveAlertMessage = error.localizedDescription
//                                                    saveAlert = true
//                                                }
//                                                
//                                            }
//                                        }, speekAction: {
//                                            Task {
//                                                do {
//                                                    try await viewModel.speechAppleTTS(content: item.word)
//                                                } catch {
//                                                    
//                                                }
//                                            }
//                                        })
////                                        .reportHeight()
//                                            
//                                    }
//                                }
//                                Spacer()
//                            }
//                            .tag(pageIndex)
//                            
//                        }
//                                            .padding(.bottom, bottomTabPadding)
//                    }
//                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
//                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
////                    Color.clear.frame(height: 10)
//                }
//                
//            }
        }
        .padding(EdgeInsets(top: 15, leading: 0, bottom: 0, trailing: 0))
        .onPreferenceChange(CardHeightPreferenceKey.self) { height in
            MainActor.assumeIsolated() {
                if self.cardHeight != height {
                    self.cardHeight = height
                }
            }
        }
    }
    
    private var moreRecommandButton: some View {
        Button {
            print("검색")
            Task {
                do {
//                    field = nil
//                    try await searchAI()
                    try await viewModel.fetchRecommend()
                } catch {
                    errorAlert = true
                    aiSearchErrorMessage = error.localizedDescription
                }
            }
            
            
        } label: {
            Text("AI 추천받기")
        }
        .frame(height: 50)
        .buttonStyle(WMButtonStyle())
        .padding(.bottom, orientation.isLandscape ? 0 : 10)
//        .background(offsetReader(for: \.searchButton))
    }
    
    private var loadingView: some View {
        ZStack {
            Color.black.opacity(0.3)
                .frame(width: 250, height: 250)
                .cornerRadius(20)
            Color.systemWhite.opacity(0.7)
                .frame(width: 200, height: 200)
                .cornerRadius(20)
            
            VStack {
                Text("AI 생성중입니다...")
                    .font(.headline)
                Image("ph_open-ai-logo-light", bundle: CommonUIResources.bundle)
                    .resizable()
                    .frame(width: 25, height: 25)
                    .rotationEffect(Angle(degrees: viewModel.shouldAnimateLogo ? 360 : 0))
                    .animation(viewModel.shouldAnimateLogo ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: viewModel.shouldAnimateLogo)
            }
        }
    }
}


fileprivate struct CardView2: View {
    
    var item: RecommendWordModel
    var saveAction: (() -> Void)
    var speekAction: (() -> Void)
    init(cardItem: RecommendWordModel, saveAction: @escaping (() -> Void), speekAction: @escaping (() -> Void)) {
        self.item = cardItem
        self.saveAction = saveAction
        self.speekAction = speekAction
    }
    
    var body: some View {
        
        ZStack {
            Color.element
                .cornerRadius(20)
                .northWestShadow(radius:1, offset: 2)
            HStack {
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.word)
                            .foregroundStyle(Color.systemBlack)
                            .font(.headline)
                            .lineLimit(5)
                        Text(item.meaning)
                            .foregroundStyle(Color.systemBlack)
                            .font(.body)
                            .lineLimit(5)
                    }
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    speekAction()
                }
                Button {
                    saveAction()
                } label: {
                    Image(systemName: "square.and.arrow.down")
                        .frame(width: 20, height: 20)
                }
            }
            .padding(EdgeInsets.init(top: 7, leading: 15, bottom: 7, trailing: 15))
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
            let _ = print(geometry.size.height)
            Color.clear.preference(key: CardHeightPreferenceKey.self, value: geometry.size.height)
        })
    }
}




struct RecommendListView_Preview: PreviewProvider {
    
    static var previews: some View {
        RecommendListView(viewModel: RecommendListViewModel.makeMock())
    }
}
