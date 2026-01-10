//
//  ReviewCardView.swift
//  Review
//
//  Created by 박현수 on 12/27/24.
//

import SwiftUI
import CommonUI
import AppEntity
import Combine

struct ReviewCardView: View {
    @State private var orientation = UIDeviceOrientation.unknown
    
    // MARK: - Properties
    @StateObject private var viewModel: ReviewCardViewModel
    @Binding var memoryActionPublisher: PassthroughSubject<Void, Never>
    @State private var aiGenerationError: Error?
    
    
    @AppStorage("showOnBoardingReviewCard") private var showOnboarding = true
    @State private var onboardingHintType: OnboardingHintType? = .answerType
    
    // MARK: - Layout
    @State private var offsets = OffsetValues()
    
    var showOnboaringWithFetched: Bool {
        return showOnboarding && viewModel.examples.isEmpty == false
    }
    
    
    
    // MARK: - Initialization
    init(diContainer: ReviewDependencyInjection,
         wordMemory: WordMemory,
         reviewType: ReviewStartFilter.ReviewType,
         aiSentenceType: ReviewStartFilter.AISentenceType,
         memoryActionPublisher: Binding<PassthroughSubject<Void, Never>>) {
        _memoryActionPublisher = memoryActionPublisher
        _viewModel = StateObject(wrappedValue: ReviewCardViewModel(diContainer: diContainer, wordMemory: wordMemory, reviewType: reviewType, aiSentenceType: aiSentenceType))
    }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                cardBackground
                
                //                ScrollView {
                VStack {
                    Spacer()
                    wordOrAnswerText
                    Spacer()
                    aiLearningSection(geometry: geometry)
                    examplesSection(geometry: geometry)
                    UserActionButton(viewModel: viewModel, memoryActionPublisher: $memoryActionPublisher)
                        .background(offsetReader(for: \.userAction))
                }
                .coordinateSpace(name: "VStack")
                .padding()
                .allowsHitTesting(showOnboaringWithFetched == false)
                //                }
                
                
                
                
                if showOnboaringWithFetched {
                    tooltipOverlay(geometry: geometry)
                }
            }
            .padding()
            .gesture(cardTapGesture)
            .task(fetchAIExamples)
            .onDisappear(perform: cancelTask)
            .onRotate { newOrientation in
                orientation = newOrientation
            }
        }
    }
    
    // MARK: - Subviews
    private var cardBackground: some View {
        Color.systemWhite
            .cornerRadius(20)
            .northWestShadow(radius: 5, offset: 5)
    }
    
    private var wordOrAnswerText: some View {
        Text(viewModel.showAnswer ? viewModel.answer : viewModel.word)
            .font(.title)
            .background(offsetReader(for: \.answerType))
    }
    
    private func aiLearningSection(geometry: GeometryProxy) -> some View {
        HStack {
            aiLogo
            Text("AI 문장 학습").font(.headline)
            Spacer()
            refreshButton
                .background(offsetReader(for: \.gptType))
        }
        .frame(width: geometry.size.width * 0.8)
    }
    
    private var aiLogo: some View {
        Image("ph_open-ai-logo-light", bundle: CommonUIResources.bundle)
            .resizable()
            .frame(width: 25, height: 25)
            .rotationEffect(Angle(degrees: viewModel.isLoading ? 360 : 0))
            .animation(viewModel.isLoading ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: viewModel.isLoading)
    }
    
    private var refreshButton: some View {
        Button(action: refreshAIExamples) {
            Image("fluent_arrow-repeat-all-24-regular-light", bundle: CommonUIResources.bundle)
                .resizable()
                .frame(width: 20, height: 20)
                .padding(.leading, 5)
            
        }
    }
    
    private func examplesSection(geometry: GeometryProxy) -> some View {
        Group {
            if aiGenerationError == nil {
                examplesScrollView(geometry: geometry)
            } else {
                errorView
            }
        }
    }
    
    private func examplesScrollView(geometry: GeometryProxy) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if viewModel.examples.isEmpty {
                    placeholderText(geometry: geometry)
                } else {
                    examplesList
                }
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .frame(width: geometry.size.width * 0.8, height: geometry.size.height * (orientation.isLandscape ? 0.4 : 0.5))
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
    
    
    private var examplesList: some View {
        ForEach(viewModel.examples) { example in
            HStack {
                AIExampleView(viewModel: viewModel, example: example, offsets: $offsets)
                    .background(offsetReader(for: \.speakingType))
                Spacer()
            }
            Divider()
        }
    }
    
    private var errorView: some View {
        VStack {
            Spacer()
            Text(LocalizedStringKey(aiGenerationError?.localizedDescription ?? "생성에 실패했습니다. 다음에 시도해주세요."))
            Spacer()
        }
    }
    
    // MARK: - Gestures
    private var cardTapGesture: some Gesture {
        TapGesture().onEnded { _ in
            
            if showOnboaringWithFetched == false {
                withAnimation(.easeInOut) {
                    viewModel.setShowAnswer()
                }
            }
        }
    }
    
    // MARK: - Methods
    private func refreshAIExamples() {
        Task {
            do {
                try await viewModel.fetchAIExamples(force: true)
                aiGenerationError = nil
            } catch {
                aiGenerationError = error
                viewModel.isLoading = false
            }
        }
    }
    
    private func fetchAIExamples() {
        viewModel.task = Task {
            do {
                try await viewModel.fetchAIExamples()
                aiGenerationError = nil
            } catch {
                aiGenerationError = error
                viewModel.isLoading = false
            }
        }
    }
    
    private func cancelTask() {
        viewModel.task?.cancel()
    }
    
    
    private func tooltipOverlay(geometry: GeometryProxy) -> some View {
        Group {
            
            //            let mid = geometry.size.width / 2
            //            LazyVStack {
            GeometryReader { tooltipGeometry in
                
                WMTooltipView(text: tooltipText,
                              location: .centerBottom,
                              opacity: 0.9) {
                    updateHintType()
                }
                              .position(x: tooltipPosition.0,
                                        y: tooltipPosition.1)
            }
            //            }
        }
    }
    
    // MARK: - Helper Methods
    private func offsetReader(for keyPath: WritableKeyPath<ReviewCardView.OffsetValues, (CGFloat, CGFloat)>) -> some View {
        GeometryReader { geo -> Color in
            
            DispatchQueue.main.async {
                let offsetY = geo.frame(in: .named("VStack")).minY - 20
                let offsetX = geo.frame(in: .named("VStack")).midX
                if (offsetX, offsetY) != offsets[keyPath: keyPath] {
                    offsets[keyPath: keyPath] = (offsetX, offsetY)
                }
            }
            return Color.clear
        }
    }
    
    private func updateHintType() {
        onboardingHintType = onboardingHintType?.nextHintType
        if onboardingHintType == nil {
            showOnboarding = false
        }
    }
    
    // MARK: - Computed Properties
    private var tooltipText: String {
        switch onboardingHintType {
        case .answerType: return "1. 터치하면 정답을 볼 수 있습니다"
        case .gptType: return "2. 터치하면 다시 생성해줍니다"
        case .speakingType: return "3. 터치하면 AI가 읽어줍니다"
        case .hintType: return "4. 터치하면 정답의 힌트를 얻을 수 있습니다"
        case .userAction: return "5. 맞췄다면 O 틀렸다면 X를 누르고 넘어갑니다"
        case .none: return ""
        }
    }
    
    private var tooltipPosition: (CGFloat, CGFloat) {
        switch onboardingHintType {
        case .answerType: return offsets.answerType
        case .gptType: return offsets.gptType
        case .speakingType: return offsets.speakingType
        case .hintType: return offsets.hintType
        case .userAction: return offsets.userAction
        case .none: return (0, 0)
        }
    }
}

extension ReviewCardView {
    
    struct OffsetValues {
        var answerType: (CGFloat, CGFloat) = (0,0)
        var gptType: (CGFloat, CGFloat) = (0,0)
        var speakingType: (CGFloat, CGFloat) = (0,0)
        var hintType: (CGFloat, CGFloat) = (0,0)
        var userAction: (CGFloat, CGFloat) = (0,0)
    }
    
    enum OnboardingHintType: Int {
        case answerType
        case gptType
        case speakingType
        case hintType
        case userAction
        
        var nextHintType: OnboardingHintType? {
            return OnboardingHintType(rawValue: self.rawValue + 1)
        }
    }
}


struct ToastView: View {
    let message: String
    
    var body: some View {
        Text(LocalizedStringKey(message))
            .padding()
            .background(Color.black.opacity(0.7))
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

struct AIExampleView: View {
    @ObservedObject var viewModel: ReviewCardViewModel
    @ObservedObject var example: ReviewCardViewModel.AIExample
    @State private var isTapped = false
    @State var speekError: Error? = nil
    
    @Binding var offsets: ReviewCardView.OffsetValues
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 20) {
                Button {
                    Task {
                        do {
                            try await viewModel.speek(string: NSAttributedString(example.example).string,
                                                      identity: example.exampleIdentity)
                            
                            speekError = nil
                        } catch {
                            speekError = error
                            viewModel.isLoading = false
                        }
                    }
                } label: {
                    Label {
                        Text(example.example)
                    } icon: {
                        Image("ri_voice-ai-light", bundle: CommonUIResources.bundle)
                            .resizable()
                            .frame(width: 17, height: 17)
                    }
                }
                
                if example.showAnswer {
                    Text(example.answer)
                        .lineSpacing(5)
                        .background(offsetReader(for: \.speakingType))
                } else {
                    Text(example.translation)
                        .background(offsetReader(for: \.hintType))
                        .lineSpacing(5)
                        .onTapGesture {
                            example.setShowTranslation()
                            
                            print(example.showTranslation)
                            print(example.translation)
                            print("-----")
                        }
                }
            }
            
            if speekError != nil {
                ToastView(message: speekError?.localizedDescription ?? "")
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                speekError = nil
                            }
                        }
                    }
            }
        }
        .animation(.easeInOut)
        
    }
    
    // MARK: - Helper Methods
    private func offsetReader(for keyPath: WritableKeyPath<ReviewCardView.OffsetValues, (CGFloat, CGFloat)>) -> some View {
        GeometryReader { geo -> Color in
            DispatchQueue.main.async {
                let offsetY = geo.frame(in: .named("VStack")).minY - 20
                let offsetX = geo.frame(in: .named("VStack")).midX
                if (offsetX, offsetY) != offsets[keyPath: keyPath] {
                    offsets[keyPath: keyPath] = (offsetX, offsetY)
                }
            }
            return Color.clear
        }
    }
}



private struct UserActionButton: View {
    @ObservedObject var viewModel: ReviewCardViewModel
    @Binding var memoryActionPublisher: PassthroughSubject<Void, Never>
    var body: some View {
        HStack(spacing: 20) {
            Button {
                
                
                viewModel.debouncer.debounce(interval: 0.3) {
                    print("---")
                    do {
                        try await viewModel.editMemoryAction(.bad)
                        memoryActionPublisher.send()
                    } catch {
                        
                    }
                }
            } label: {
                Image("fa6-solid_xmark-red", bundle: CommonUIResources.bundle)
                    .resizable()
                    .frame(width: 22, height: 29)
            }
            .buttonStyle(WMButtonStyle())
            
            
            Button {
                
                viewModel.debouncer.debounce(interval: 0.3) {
                    print("---")
                    do {
                        try await viewModel.editMemoryAction(.good)
                        memoryActionPublisher.send()
                    } catch {
                        
                    }
                }
                
            } label: {
                Image("rivet-icons_circle", bundle: CommonUIResources.bundle)
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(WMButtonStyle())
            
        }
        .frame(height: 50)
    }
}







#Preview {
    VStack {
        ReviewCardView(diContainer: ReviewMockDIContainer(),
                       wordMemory: WordMemory(identity: "identity",
                                              word: "expect",
                                              meaning: "기대하다", createAt: .now),
                       reviewType: .meaning,
                       aiSentenceType: .description,
                       memoryActionPublisher: .constant(PassthroughSubject()))
        
        Spacer(minLength: 20)
        
        Button {
            print("---")
        } label: {
            Text("리뷰 종료")
        }
        .buttonStyle(WMButtonStyle())
        .frame(height: 50)
        .padding([.leading, .trailing, .bottom], 20)
    }
    //    .padding()
}
