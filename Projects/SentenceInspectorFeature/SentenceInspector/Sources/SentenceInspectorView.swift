//
//  SentenceInspectorView.swift
//  SentenceInspector
//
//  Created by 박현수 on 2/11/25.
//

import SwiftUI
import CommonUI


public struct SentenceInspectorView: View {
    
    @State private var orientation = UIDeviceOrientation.unknown
    @StateObject var viewModel: SentenceInspectorViewModel
    @FocusState private var field: Field?
    
    @State var aiSearchErrorMessage: String = ""
    @State var searchButtonEnable: Bool = false
    
    
    @AppStorage("aiSearchLanguageCodeType") private var aiUserLanguageCodeType = Locale.current.language.languageCode?.identifier ?? "en"
    
    @AppStorage("showOnBoardingSentenceInspec") private var showOnboarding = true
    @State private var onboardingHintType: OnboardingHintType? = .explanationLanguage
    // MARK: - Layout
    @State private var offsets = OffsetValues()
    
    public init(diContainer: SentenceInspectorDependencyInjection) {
        _viewModel = StateObject(wrappedValue: SentenceInspectorViewModel(diContainer: diContainer))
    }
    
    var isIphoneLandScape: Bool {
        UIDevice.current.userInterfaceIdiom != .pad && orientation.isLandscape
    }
    public var body: some View {
        GeometryReader { geometry in
 
            ZStack {
                VStack {
                    Spacer()
                    HStack {
                        userLanguagePicker
                        Spacer()
                        textCount
                    }
                    .padding(.bottom, 5)
                    
                    sentenceInputView
                        .frame(height: isIphoneLandScape ? 50 : 150)
                        .padding([.leading, .trailing, .bottom])
                    
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
                                    .padding()
                            }
                        }
                    }
                    
                    Spacer()
                    
                    searchButton
                    //                        .padding()
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
                
                if showOnboarding {
                    
                    tooltipOverlay(geometry: geometry)
                }
            }
            .onRotate { newOrientation in
                orientation = newOrientation
            }
            // App에서 탭으로 전환하고있어서 .onAppear이 searchView랑 충돌나서..일단뺌..
//            .onAppear {
//                if showOnboarding == false {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
//                        field = .word
//                    }
//                }
//            }
            .task {
                viewModel.updateUserDefaultUserLanguageCode(code: aiUserLanguageCodeType)
            }
        }
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
            }
            Spacer()
        }
        .background(offsetReader(for: \.explanationLanguage))
        
    }
    
    private var textCount: some View {
        Text("\(viewModel.wordCount)/\(viewModel.maxWordCount)")
            .font(.footnote)
            .padding(.trailing)
            .foregroundStyle(field == .word ? Color.systemBlack : Color.gray)
    }
    
    private var sentenceInputView: some View {
        ZStack {
            BackgroundView()
            TextEditor(text: $viewModel.searchSentence)
//                .frame(height: 100) // 높이를 조정 가능
            //                        .border(Color.gray, width: 1)
                .lineSpacing(5) // 줄 간격 설정
                .padding(10)
                .focused($field, equals: .word)
                .overlay(
                    VStack {
                        Text("검사할 문장을 입력하세요.")
                            .foregroundColor(.gray)
                            .padding(15)
                            .opacity(viewModel.searchSentence.isEmpty ? 1 : 0)
                            .onTapGesture {
                                field = .word
                            }
                        Spacer()
                    },
                    alignment: .leading
                )
                .onSubmit {
                    Task {
                        do {
                            field = nil
                            try await searchAI()
                        } catch {
                            aiSearchErrorMessage = error.localizedDescription
                        }
                    }
                }
                .onChange(of: viewModel.searchSentence) { oldValue, newValue in
                    updateWordCount(oldValue: oldValue, newValue: newValue)
                    
                    searchButtonEnable = !(viewModel.searchSentence.isEmpty || viewModel.searchSentence.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .onTapGesture {
                    
                }
                .background(offsetReader(for: \.inputField))
        }
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
            BackgroundView()
            
            examplesMeaningScrollView()
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
                                Text("올바른 문장:")
                                    .font(.headline)
                                Text(aiResponse.correctSentence)
                                    .font(.body)
                                    .contextMenu(ContextMenu(menuItems: {
                                        Button("Copy", action: {
                                          UIPasteboard.general.string = aiResponse.correctSentence
                                        })
                                      }))
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
            Text("AI 문장 검사")
        }
        .disabled(!searchButtonEnable)
        .frame(height: 50)
        .buttonStyle(WMButtonStyle(isDisabled: !searchButtonEnable))
        .focusable(interactions: .activate)
        .padding(.bottom, orientation.isLandscape ? 0 : 10)
        .background(offsetReader(for: \.searchButton))
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
    
    
    // MARK: - Method
    
    private func searchAI() async throws {
        try await viewModel.search()
    }
    
    
    private func updateWordCount(oldValue: String, newValue: String) {
        if newValue.count > viewModel.maxWordCount {
            viewModel.searchSentence = oldValue
            viewModel.wordCount = oldValue.count
        } else {
            viewModel.wordCount = newValue.count
        }
    }
}



extension SentenceInspectorView {
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
        case .explanationLanguage: return "1. 검사결과에서 설명하는 언어를 설정합니다."
        case .inputField: return "2. 검사하고자하는 문장을 입력합니다."
        case .searchButton: return "3. AI 문장검사를 시작합니다!"
        case .none: return ""
        }
    }
    
    private var tooltipYPosition: CGFloat {
        switch onboardingHintType {
        case .explanationLanguage: return offsets.explanationLanguage
        case .inputField: return offsets.inputField
        case .searchButton: return offsets.searchButton
        case .none: return 0
        }
    }
    
    struct OffsetValues {
        var explanationLanguage: CGFloat = 0
        var inputField: CGFloat = 0
        var searchButton: CGFloat = 0
    }
    
    enum OnboardingHintType: Int {
        case explanationLanguage
        case inputField
        case searchButton
        
        var nextHintType: OnboardingHintType? {
            return OnboardingHintType(rawValue: self.rawValue + 1)
        }
    }
}

struct PlaceholderStyle: ViewModifier {
    let placeholder: String
    @Binding var text: String

    func body(content: Content) -> some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
            }
            content
                .padding(4)
        }
    }
}

extension View {
    func placeholder(_ placeholder: String, text: Binding<String>) -> some View {
        self.modifier(PlaceholderStyle(placeholder: placeholder, text: text))
    }
}

struct TextWrapper: UIViewRepresentable {
  var text: String
  var textStyle: UIFont.TextStyle
  
  init(_ text: String, textStyle: Font.TextStyle) {
      self.text = text
      self.textStyle = textStyle == .body ? .body : .body
  }
  
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = .brown
        textView.font = UIFont.preferredFont(forTextStyle: textStyle)
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        textView.textContainerInset = .zero
        return textView
      }
  
  func updateUIView(_ textView: UITextView, context: Context) {
    textView.text = text
    textView.sizeToFit()
    textView.layoutIfNeeded()
  }
  
}

struct SentenceInspectorView_Preview: PreviewProvider {
    
    static var previews: some View {
        SentenceInspectorView(diContainer: SentenceInspectorMockDIContainer())
    }
}

