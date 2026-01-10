//
//  WordCollectionView.swift
//  Recommend
//
//  Created by 박현수 on 2/14/25.
//

import SwiftUI
import CommonUI

public struct WordCollectionView: View {
    
    @StateObject var viewModel: WordCollectionViewModel
    @AppStorage("aiSearchLanguageCodeType") private var aiUserLanguageCodeType = Locale.current.language.languageCode?.identifier ?? "en"
    @AppStorage("aiRecommendInfoOnboarding") private var aiRecommendInfoOnboarding = true
    @Namespace var namespace
    
    @State var infoAlert: Bool = false
    let infoText: String = "AI에서 추천하는 단어로써 단어가 부족할 수 있습니다. 참고용으로 사용하세요.☺️"
    
    public init(diContainer: RecommendDependencyInjection) {
        _viewModel = StateObject(wrappedValue: WordCollectionViewModel(diContainer: diContainer))
    }
    
    public var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    VStack {
                        userLanguagePicker
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.bottom, 10)
                        languageTab
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.bottom, 10)
                        
                        levelListView
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                    }
                    .padding(20)
                }
                
                .scrollBounceBehavior(.basedOnSize)
//                .navigationTitle("AI단어추천")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack {
                            Text("AI단어추천")
                                .font(.headline)
                            Button(action: {
                                infoAlert.toggle()
                            }) {
                                Image(systemName: "info.circle")
                            }
                        }
                    }
                }
                .alert(LocalizedStringKey(infoText), isPresented: $infoAlert,
                       presenting: infoText) { errorMessage in
                    Button {
                        aiRecommendInfoOnboarding = false
                    } label: {
                        Text("확인")
                    }
                }
                .navigationDestination(item: $viewModel.selectLanguageLevelType, destination: { menu in
                    if let listViewModel = viewModel.makeRecommendListViewModel() {
                        RecommendListView(viewModel: listViewModel)
                            .navigationTitle(LocalizedStringKey(viewModel.selectLanguageLevelType?.levelFullName ?? ""))
                    } else {
                        Text("")
                    }
                    
                })
                .task {
                    if aiRecommendInfoOnboarding {
                        infoAlert.toggle()
                    }
                    viewModel.updateUserDefaultUserLanguageCode(code: aiUserLanguageCodeType)
                    
                }
            }
        }
        
    }
    
    private var userLanguagePicker: some View {
        ZStack {
            BackgroundView()
            
            
            HStack {
                Text("설명 언어:")
                    .padding(.leading)
                Picker("", selection: $viewModel.userLanguage) {
                    ForEach(viewModel.languageList) { (language) in
                        Text(LocalizedStringKey(language.name))
                            .tag(language)
                            .font(.headline)
                    }
                }
                .tint(Color.systemBlack)
                .pickerStyle(.menu)
                .onChange(of: viewModel.userLanguage) { _, newValue in
                    // 여기에 선택이 변경될 때 실행할 코드를 작성합니다.
                    aiUserLanguageCodeType = newValue.rawValue
                }
                Spacer()
            }
            .padding(10)
//            .background(offsetReader(for: \.explanationLanguage))
            
        }
    }
    
    private var languageTab: some View {
        ZStack {
            BackgroundView()
            
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(viewModel.languageTabList) { language in
                        TabBarItemView(tabBarName: language.name,
                                       isSelected: viewModel.selectLanguageTab == language,
                                       namespace: namespace) {
                            viewModel.selectLanguageTab = language
                            print("select :\(language.name)")
                        }
                    }
                    Spacer()
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.hidden)
        }
    }
    
    private var levelListView: some View {
        
        ZStack {
            BackgroundView()
            
            
            
            VStack {
                Color.clear.frame(height: 10)
                Text(LocalizedStringKey(viewModel.selectLanguageTab.name))
                    .font(.headline)
                ForEach(Array(viewModel.selectLanguageTab.levelTypes.enumerated()), id: \.element.id) { index, item in
                    VStack(alignment: .leading) {
                        
                        Button {
                            viewModel.selectLanguageLevelType = item
                            //                            onItemTap?(item)
                            //                            print("on Tap Cell \(item.name )")
                        } label: {
                            HStack {
                                
                                VStack(alignment: .leading) {
                                    Text(LocalizedStringKey(item.levelFullName))
                                        .font(.headline)
                                    Text(LocalizedStringKey(item.levelDescription))
                                        .font(.body)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .lineLimit(10)
                                }
                                Spacer() // 버튼으로바꾸거나해야겠다.
                                
                                Image(systemName: "chevron.right")
                            }
                            .contentShape(Rectangle())
                        }
                        
                        .buttonStyle(WMPressedStyle(doNotChangeBackground: true))
                        .padding(10)
                        if index != viewModel.selectLanguageTab.levelTypes.count - 1 {
                            Divider()
                                .padding([.leading, .trailing], 10)
                        }
                    }
                    .padding([.leading, .trailing], 20)
                    .onTapGesture {
                        //                            onItemTap?(item)
                    }
                }
                Color.clear.frame(height: 10)
            }
            
        }
//        .animation(.easeIn, value: viewModel.selectLanguageTab)
    }
}

struct TabBarItemView: View {
    var tabBarName: String
    var isSelected: Bool
    let namespace: Namespace.ID
    var action: (() -> Void)
    
    var body: some View {
        VStack {
            Button {
                action()
            } label: {
                Text(LocalizedStringKey(tabBarName))
                    .font(.headline)
            }
            .buttonStyle(WMPressedStyle())
            .padding([.top], 13)
            .padding(.bottom, 3)
            .padding([.trailing, .leading], 20)
            
            Group {
                if isSelected {
                    Color.systemBlack
                        .frame(height: 2.5)
                        .matchedGeometryEffect(id: "underline", in: namespace.self)
                        .opacity(isSelected ? 1 : 0)
                } else {
                    Color.clear
                        .frame(height: 2.5)
                }
            }
            .padding([.leading, .trailing], 7)
            .padding(.bottom, 10)
        }
        .fixedSize()
        .animation(.spring(), value: isSelected)
    }
}



struct WordCollectionView_Preview: PreviewProvider {
    
    static var previews: some View {
        WordCollectionView(diContainer: RecommendMockDIContainer())
    }
}
