//
//  SearchView.swift
//  Search
//
//  Created by 박현수 on 2/5/25.
//

import Foundation
import SwiftUI
import CommonUI


public struct SearchView: View {
    @State private var orientation = UIDeviceOrientation.unknown
    
    @StateObject var viewModel: SearchViewModel
    @FocusState private var field: Field?
    @State var aiSearchErrorMessage: String = ""
    @State var searchButtonEnable: Bool = false
    @State var wordSaveAlert: Bool = false
    @State var wordSaveErrorMessage: String = ""
    @State var didSuccessSaveWord: Bool = false
    
    @AppStorage("aiSearchLanguageCodeType") private var aiUserLanguageCodeType = Locale.current.language.languageCode?.identifier ?? "en"
    @AppStorage("aiSearchSearchLanguageCodeType") private var aiSearchLanguageCodeType = "ko"
    
    @AppStorage("showOnBoardingSearch") private var showOnboarding = true
    @State private var onboardingHintType: OnboardingHintType? = .explanationLanguage
    // MARK: - Layout
    @State private var offsets = OffsetValues()
    
    public init(diContainer: SearchDependencyInjection) {
        _viewModel = StateObject(wrappedValue: SearchViewModel(diContainer: diContainer))
    }
    
    var isIphoneLandScape: Bool {
        UIDevice.current.userInterfaceIdiom != .pad && orientation.isLandscape
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 0) {
                        userLanguagePicker
                        searchLanguagePicker
                            .padding(.bottom, 5)
                        wordInputTextField
                    }
                    .padding(.bottom, 10)
                    
                    if isIphoneLandScape == false {
                        aiLogo
                    }
                    
                    if viewModel.isLoading {
                        placeholderText(geometry: geometry)
                            .padding()
                            
                    } else {
                        if viewModel.aiResponse != nil {
                            aiResponseView
                                .padding()
                        } else {
                            
                            if aiSearchErrorMessage.isEmpty == false {
                                Text(LocalizedStringKey(aiSearchErrorMessage))
                                    .font(.headline)
                                    .padding(.top)
                            }
                        }
                    }
                    
                    Spacer()
                    searchButton
                }
                .coordinateSpace(name: "VStack")
                .padding()
                .contentShape(Rectangle())
                .transition(.opacity.combined(with: .scale))
                .animation(.easeInOut(duration: 0.5), value: viewModel.isLoading)
                .onTapGesture {
                    field = nil
                }
                .allowsHitTesting(!showOnboarding)
            }
            
            if showOnboarding {
                
                tooltipOverlay(geometry: geometry)
            }
           
        }
        .onRotate { newOrientation in
            orientation = newOrientation
        }
        
        // App에서 탭으로 전환하고있어서 .onAppear이 searchView랑 충돌나서..일단뺌..
//        .onAppear {
//            if showOnboarding == false {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
//                    field = .word
//                }
//            }
//        }
        .task {
            viewModel.updateUserDefaultUserLanguageCode(code: aiUserLanguageCodeType)
            viewModel.updateUserDefaultSearchLanguageCode(code: aiSearchLanguageCodeType)
        }
        
        // Test Code
//        .task {
//            try? await Task.sleep(nanoseconds: 1_000_000_000)
//            viewModel.searchWord = "asdfsadf"
//            try? await Task.sleep(nanoseconds: 1_000_000_000)
//            
//            do {
//                try await viewModel.search()
//            } catch {
//                aiSearchErrorMessage = error.localizedDescription
//            }
//        }
        
    }
    
    // MARK: - Subviews
    
    private var userLanguagePicker: some View {
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
                viewModel.updateUserDefaultUserLanguageCode(code: aiUserLanguageCodeType)
            }
            Spacer()
        }
        .background(offsetReader(for: \.explanationLanguage))
        
    }
    
    private var searchLanguagePicker: some View {
        HStack {
            Text("찾고자 하는 언어:")
                .padding(.leading)
            Picker("", selection: $viewModel.searchLanguage) {
                ForEach(viewModel.languageList) { (language) in
                    Text(LocalizedStringKey(language.name))
                        .tag(language)
                        .font(.headline)
                }
            }
            .tint(Color.systemBlack)
            .pickerStyle(.menu)
            .onChange(of: viewModel.searchLanguage) { _, newValue in
                // 여기에 선택이 변경될 때 실행할 코드를 작성합니다.
                aiSearchLanguageCodeType = newValue.rawValue
                viewModel.updateUserDefaultSearchLanguageCode(code: aiSearchLanguageCodeType)
            }
            Spacer()
            
            textCount
        }
        .background(offsetReader(for: \.searchLanguage))
    }
    
    private var textCount: some View {
        Text("\(viewModel.wordCount)/\(viewModel.maxWordCount)")
            .font(.footnote)
            .padding(.trailing)
            .foregroundStyle(field == .word ? Color.systemBlack : Color.gray)
    }
    
    private var wordInputTextField: some View {
        WMTextField(placeHolder: "검색할 단어를 입력하세요.", text: $viewModel.searchWord)
        //                .background(offsetReader(for: \.word))
            .focused($field, equals: .word)
            .onChange(of: viewModel.searchWord) { oldValue, newValue in
                updateWordCount(oldValue: oldValue, newValue: newValue)
                
                searchButtonEnable = !(viewModel.searchWord.isEmpty || viewModel.searchWord.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                
            }
            .onSubmit {
                Task {
                    do {
                        field = nil
                        try await searchAI()
                    } catch {
                        aiSearchErrorMessage = error.localizedDescription
                        print("?????????????")
                    }
                }
            }
            .background(offsetReader(for: \.inputField))
    }
    
    private var aiLogo: some View {
        Image("ph_open-ai-logo-light", bundle: CommonUIResources.bundle)
            .resizable()
            .frame(width: 25, height: 25)
            .rotationEffect(Angle(degrees: viewModel.shouldAnimateLogo ? 360 : 0))
            .animation(viewModel.shouldAnimateLogo ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: viewModel.shouldAnimateLogo)
    }
    
    private var aiResponseView: some View {
        
        ZStack {
            cardBackground
            
            switch viewModel.aiResponse?.searchType {
            case .meaning:
                examplesMeaningScrollView()
            case .translate:
                examplesTranslateScrollView()
            case nil:
                Text("")
            }
            
        }
    }
    
    
    private func examplesMeaningScrollView() -> some View {
        return Group {
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        if let aiResponse = viewModel.aiResponse {
                            VStack(alignment: .leading) {
                                Text("부연설명:")
                                    .font(.headline)
                                Text(aiResponse.explanation)
                                    .font(.body)
                                    .contextMenu(ContextMenu(menuItems: {
                                        Button("Copy", action: {
                                          UIPasteboard.general.string = aiResponse.explanation
                                        })
                                      }))
                            }
                            VStack(alignment: .leading) {
                                Text("예시:")
                                    .font(.headline)
                                Text(aiResponse.sentence)
                                    .font(.body)
                                    .contextMenu(ContextMenu(menuItems: {
                                        Button("Copy", action: {
                                          UIPasteboard.general.string = aiResponse.sentence
                                        })
                                      }))
                            }
                            VStack(alignment: .leading) {
                                Text("해석:")
                                    .font(.headline)
                                Text(aiResponse.sentenceTranslation)
                                    .font(.body)
                                    .contextMenu(ContextMenu(menuItems: {
                                        Button("Copy", action: {
                                          UIPasteboard.general.string = aiResponse.sentenceTranslation
                                        })
                                      }))
                            }
                            VStack(alignment: .leading) {
                                Text("뜻:")
                                    .font(.headline)
                                Text(aiResponse.meaning)
                                    .font(.body)
                                    .contextMenu(ContextMenu(menuItems: {
                                        Button("Copy", action: {
                                          UIPasteboard.general.string = aiResponse.meaning
                                        })
                                      }))
                            }
                            
                            if didSuccessSaveWord == false {
                                saveButton
                            }
                        }
                    }
                    .padding()
                }
                .scrollBounceBehavior(.basedOnSize)
//                .frame( height: geometry.size.height * (orientation.isLandscape ? 0.3 : 0.3))
            }
        }
    }
    
    private func examplesTranslateScrollView() -> some View {
        return Group {
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        if let aiResponse = viewModel.aiResponse {
                            VStack(alignment: .leading) {
                                Text("단어 설명:")
                                    .font(.headline)
                                Text(aiResponse.explanation)
                                    .font(.body)
                                    .contextMenu(ContextMenu(menuItems: {
                                        Button("Copy", action: {
                                          UIPasteboard.general.string = aiResponse.explanation
                                        })
                                      }))
                            }
                            VStack(alignment: .leading) {
                                Text("예시:")
                                    .font(.headline)
                                Text(aiResponse.sentence)
                                    .font(.body)
                                    .contextMenu(ContextMenu(menuItems: {
                                        Button("Copy", action: {
                                          UIPasteboard.general.string = aiResponse.sentence
                                        })
                                      }))
                            }
                            VStack(alignment: .leading) {
                                Text("해석:")
                                    .font(.headline)
                                Text(aiResponse.sentenceTranslation)
                                    .font(.body)
                                    .contextMenu(ContextMenu(menuItems: {
                                        Button("Copy", action: {
                                          UIPasteboard.general.string = aiResponse.sentenceTranslation
                                        })
                                      }))
                            }
                            VStack(alignment: .leading) {
                                Text("단어:")
                                    .font(.headline)
                                Text(aiResponse.meaning)
                                    .font(.body)
                                    .contextMenu(ContextMenu(menuItems: {
                                        Button("Copy", action: {
                                          UIPasteboard.general.string = aiResponse.meaning
                                        })
                                      }))
                            }
                            
                            if didSuccessSaveWord == false {
                                saveButton
                            }
                        }
                    }
                    .padding()
                }
                .scrollBounceBehavior(.basedOnSize)
//                .frame( height: geometry.size.height * (orientation.isLandscape ? 0.3 : 0.3))
            }
        }
    }
    
    private func placeholderText(geometry: GeometryProxy) -> some View {
        let width = geometry.size.width
        let placeholderString: String
        
        if width < 375 {
            placeholderString = "짧은 예시 문장입니다.긴 예시 문장입니다. 가장 큰 화면에서 표시되며, 더 많은 내용과 설명을 포함할 수 있습니다.중간 길이의 예시 문장입니다. 더 많은 내용을 포함합니다.긴 예시 문장입니다. 가장 큰 화면에서 표시되며, 더 많은 내용과 설명을 포함할 수 있습니다.중간 길이의 예시 문장입니다. 더 많은 내용을 포함합니다.긴 예시 문장입니다. 가장 큰 화면에서 표시되며, 더 많은 내용과 설명을 포함할 수 있습니"
        } else if width < 414 {
            placeholderString = "중간 길이의 예시 문장입니다. 더 많은 내용을 포함합니다.긴 예시 문장입니다. 가장 큰 화면에서 표시되며, 더 많은 내용과 설명을 포함할 수 있습니다.중간 길이의 예시 문장입니다. 더 많은 내용을 포함합니다.긴 예시 문장입니다. 가장 큰 화면에서 표시되며, 더 많은 내용과 설명을 포함할 수 있습니다"
        } else if width < 700 {
            placeholderString = "긴 예시 문장입니다. 가장 큰 화면에서 표시되며, 더 많은 내용과 설명을 포함할 수 있습니다.긴 예시 문장입니다. 가장 큰 화면에서 표시되며, 더 많은 내용과 설명을 포함할 수 있습니다.긴 예시 문장입니다. 가장 큰 화면에서 표시되며, 더 많은 내용과 설명을 포함할 수 있습니다.긴 예시 문장입니다. 가장 큰 화면에서 표시되며, 더 많은 내용과 설명을 포함할 수 있습니다."
        } else {
            placeholderString = "긴 예시 문장입니다. 가장 큰 화면에서 표시되며, 더 많은 내용과 설명을 포함할 수 있습니다.긴 예시 문장입니다. 가장 큰 화면에서 표시되며, 더 많은 내용과 설명을 포함할 수 있습니다.긴 예시 문장입니다. 가장 큰 화면에서 표시되며, 더 많은 내용과 설명을 포함할 수 있습니다.긴 예시 문장입니다. 가장 큰 화면에서 표시되며, 더 많은 내용과 설명을 포함할 수 있습니다.긴 예시 문장입니다. 가장 큰 화면에서 표시되며, 더 많은 내용과 설명을 포함할 수 있습니다.긴 예시 문장입니다. 가장 큰 화면에서 표시되며, 더 많은 내용과 설명을 포함할 수 있습니다.긴 예시 문장입니다. 가장 큰 화면에서 표시되며, 더 많은 내용과 설명을 포함할 수 있습니다.긴 예시 문장입니다. 가장 큰 화면에서 표시되며, 더 많은 내용과 "
        }
        
        return Text(placeholderString)
            .font(.title3)
            .redacted(reason: .placeholder)
    }
    
    private var cardBackground: some View {
        Color.systemWhite
            .cornerRadius(20)
            .northWestShadow(radius: 5, offset: 5)
    }
    
    private var saveButton: some View {
        Button {
            Task {
                do {
                    try await viewModel.saveToWord()
                    didSuccessSaveWord = true
                } catch {
                    wordSaveErrorMessage = error.localizedDescription
                    wordSaveAlert = true
                    didSuccessSaveWord = false
                }
                
            }
            
        } label: {
            Text("단어 저장하기")
        }
        .frame(height: 30)
        .buttonStyle(WMButtonStyle())
        .alert(LocalizedStringKey(wordSaveErrorMessage), isPresented: $wordSaveAlert,
               presenting: wordSaveErrorMessage) { errorMessage in
            
        } message: { errorMessage in
            //            Text("\(errorMessage)")
        }
        .focusable(interactions: .activate)
        .padding()
    }
    
    private var searchButton: some View {
        Button {
            print("검색")
            Task {
                do {
                    field = nil
                    try await searchAI()
                } catch {
                    aiSearchErrorMessage = error.localizedDescription
                    print("?????????????")
                }
            }
            
            
        } label: {
            Text("AI검색")
        }
        .disabled(!searchButtonEnable)
        .frame(height: 50)
        .buttonStyle(WMButtonStyle(isDisabled: !searchButtonEnable))
        .focusable(interactions: .activate)
        .padding(.bottom, orientation.isLandscape ? 0 : 10)
        .background(offsetReader(for: \.searchButton))
    }
    
    
    
    private func searchAI() async throws {
        didSuccessSaveWord = false
        try await viewModel.search()
    }
    
    private func updateWordCount(oldValue: String, newValue: String) {
        if newValue.count > viewModel.maxWordCount {
            viewModel.searchWord = oldValue
            viewModel.wordCount = oldValue.count
        } else {
            viewModel.wordCount = newValue.count
        }
    }
}

extension SearchView {
    enum Field: Hashable {
        case word
        
        var nextField: Field? {
            switch self {
            case .word: return nil
            }
        }
    }
    
    // MARK: - Onboarding
    private func tooltipOverlay(geometry: GeometryProxy) -> some View {
        Group {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        updateHintType()
                    }
                }
            WMTooltipView(text: tooltipText, location: .centerBottom) {
                updateHintType()
            }
            .position(x: geometry.size.width / 2, y: tooltipYPosition)
        }
    }
    // MARK: - Helper Methods
    private func offsetReader(for keyPath: WritableKeyPath<OffsetValues, CGFloat>) -> some View {
        GeometryReader { geo -> Color in
            DispatchQueue.main.async {
                let offset = geo.frame(in: .named("VStack")).minY - 5
                if offset != offsets[keyPath: keyPath] {
                    offsets[keyPath: keyPath] = offset
                }
            }
            return Color.clear
        }
    }
    
    private func updateHintType() {
        onboardingHintType = onboardingHintType?.nextHintType
        if onboardingHintType == nil {
            showOnboarding = false
            field = .word
        }
    }
    
    // MARK: - Computed Properties
    private var tooltipText: String {
        switch onboardingHintType {
        case .explanationLanguage: return "1. 검색결과에서 설명하는 언어를 설정합니다."
        case .searchLanguage: return "2. 검색하고자 하는 언어를 설정합니다."
        case .inputField: return "3. 찾고자하는 단어를 원하는 언어로 입력합니다."
        case .searchButton: return "4. AI검색을 시작합니다!"
        case .none: return ""
        }
    }
    
    private var tooltipYPosition: CGFloat {
        switch onboardingHintType {
        case .explanationLanguage: return offsets.explanationLanguage
        case .searchLanguage: return offsets.searchLanguage
        case .inputField: return offsets.inputField
        case .searchButton: return offsets.searchButton
        case .none: return 0
        }
    }
    
    struct OffsetValues {
        var explanationLanguage: CGFloat = 0
        var searchLanguage: CGFloat = 0
        var inputField: CGFloat = 0
        var searchButton: CGFloat = 0
    }
    
    enum OnboardingHintType: Int {
        case explanationLanguage
        case searchLanguage
        case inputField
        case searchButton
        
        var nextHintType: OnboardingHintType? {
            return OnboardingHintType(rawValue: self.rawValue + 1)
        }
    }
}


struct SearchView_Preview: PreviewProvider {
    
    static var previews: some View {
        SearchView(diContainer: SearchMockDIContainer())
    }
}
