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
                // 카드 배경
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.12), radius: 20, x: 0, y: 8)

                VStack(spacing: 0) {
                    // 단어/정답 영역
                    wordAnswerSection(geometry: geometry)

                    // AI 예문 영역
                    aiExamplesSection(geometry: geometry)

                    // 액션 버튼
                    UserActionButton(viewModel: viewModel, memoryActionPublisher: $memoryActionPublisher)
                        .background(offsetReader(for: \.userAction))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                }
                .coordinateSpace(name: "VStack")
//                .allowsHitTesting(showOnboaringWithFetched == false)

                // 제거 안해도충분할듯, 그것보다 우측에 삐져나가는게 싫음.
//                if showOnboaringWithFetched {
//                    tooltipOverlay(geometry: geometry)
//                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .gesture(cardTapGesture)
            .task(fetchAIExamples)
            .onDisappear(perform: cancelTask)
            .onRotate { newOrientation in
                orientation = newOrientation
            }
        }
    }

    // MARK: - Word/Answer Section
    private func wordAnswerSection(geometry: GeometryProxy) -> some View {
        ZStack {
            // 배경 그라데이션
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: viewModel.showAnswer
                            ? [Color.systemBlack.opacity(0.05), Color.systemBlack.opacity(0.1)]
                            : [Color(.systemGray6), Color(.systemGray5).opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: 16) {
                // 상태 인디케이터
                HStack {
                    if viewModel.showAnswer {
                        Label("정답", systemImage: "checkmark.circle.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.systemBlack)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.systemBlack.opacity(0.1))
                            .clipShape(Capsule())
                    } else {
                        Label("탭하여 확인", systemImage: "hand.tap.fill")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color.secondary)
                    }
                }

                // 단어 또는 정답
                Text(viewModel.showAnswer ? viewModel.answer : viewModel.word)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.6)
                    .background(offsetReader(for: \.answerType))
                    .animation(.easeInOut(duration: 0.2), value: viewModel.showAnswer)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
        .frame(height: geometry.size.height * 0.22)
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    // MARK: - AI Examples Section
    private func aiExamplesSection(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // 헤더
            HStack(spacing: 10) {
                // AI 아이콘
                ZStack {
                    Circle()
                        .fill(Color.systemBlack.opacity(0.1))
                        .frame(width: 40, height: 40)

                    Image("ph_open-ai-logo-light", bundle: CommonUIResources.bundle)
                        .resizable()
                        .frame(width: 25, height: 25)
                        .rotationEffect(Angle(degrees: viewModel.isLoading ? 360 : 0))
                        .animation(viewModel.isLoading ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: viewModel.isLoading)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("AI 문장 학습")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.primary)
                    Text("예문을 터치하면 읽어줍니다")
                        .font(.caption2)
                        .foregroundStyle(Color.secondary)
                }

                Spacer()

                // 새로고침 버튼
                Button(action: refreshAIExamples) {
                    Image(systemName: "arrow.clockwise")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.systemBlack)
                        .frame(width: 36, height: 36)
                        .background(Color(.tertiarySystemFill))
                        .clipShape(Circle())
                }
                .background(offsetReader(for: \.gptType))
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)

            // 구분선
            Rectangle()
                .fill(Color(.separator).opacity(0.3))
                .frame(height: 1)
                .padding(.horizontal, 20)

            // 예문 목록
            if aiGenerationError == nil {
                examplesScrollView(geometry: geometry)
            } else {
                errorView
                    .frame(maxWidth: .infinity)
                    .padding(20)
            }
        }
    }

    private func examplesScrollView(geometry: GeometryProxy) -> some View {
        ScrollView {
            VStack(spacing: 10) {
                if viewModel.examples.isEmpty {
                    placeholderView
                } else {
                    ForEach(Array(viewModel.examples.enumerated()), id: \.element.id) { index, example in
                        AIExampleCard(
                            viewModel: viewModel,
                            example: example,
                            index: index + 1,
                            offsets: $offsets
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    private var placeholderView: some View {
        VStack(spacing: 12) {
            ForEach(0..<2, id: \.self) { _ in
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color(.tertiarySystemFill))
                        .frame(width: 28, height: 28)

                    VStack(alignment: .leading, spacing: 6) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.tertiarySystemFill))
                            .frame(height: 16)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.tertiarySystemFill))
                            .frame(width: 180, height: 12)
                    }
                }
                .padding(14)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
        .redacted(reason: .placeholder)
        .shimmering()
    }

    private var errorView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 60, height: 60)

                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundStyle(Color.red.opacity(0.8))
            }

            Text("문장 생성에 실패했습니다")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.primary)

            Button {
                refreshAIExamples()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise")
                    Text("다시 시도")
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.systemWhite)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.systemBlack)
                .clipShape(Capsule())
            }
        }
        .padding(.vertical, 20)
    }

    // MARK: - Gestures
    private var cardTapGesture: some Gesture {
        TapGesture().onEnded { _ in
            if showOnboaringWithFetched == false {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
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
            Color.clear
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        updateHintType()
                    }
                }

            GeometryReader { _ in
                WMTooltipView(text: tooltipText,
                              location: .centerBottom,
                              opacity: 0.9) {
                    updateHintType()
                }
                .position(x: tooltipPosition.0,
                          y: tooltipPosition.1)
            }
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

// MARK: - Supporting Types
extension ReviewCardView {

    struct OffsetValues {
        var answerType: (CGFloat, CGFloat) = (0, 0)
        var gptType: (CGFloat, CGFloat) = (0, 0)
        var speakingType: (CGFloat, CGFloat) = (0, 0)
        var hintType: (CGFloat, CGFloat) = (0, 0)
        var userAction: (CGFloat, CGFloat) = (0, 0)
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

// MARK: - AI Example Card
private struct AIExampleCard: View {
    @ObservedObject var viewModel: ReviewCardViewModel
    @ObservedObject var example: ReviewCardViewModel.AIExample
    @State private var speekError: Error? = nil
    @State private var isSpeaking: Bool = false
    let index: Int
    @Binding var offsets: ReviewCardView.OffsetValues

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 예문 (TTS 버튼 포함)
            Button {
                Task {
                    isSpeaking = true
                    do {
                        try await viewModel.speek(string: NSAttributedString(example.example).string,
                                                  identity: example.exampleIdentity)
                        speekError = nil
                    } catch {
                        speekError = error
                        viewModel.isLoading = false
                    }
                    isSpeaking = false
                }
            } label: {
                HStack(alignment: .top, spacing: 10) {
                    // 번호 + 스피커 아이콘
                    ZStack {
                        Circle()
                            .fill(isSpeaking ? Color.systemBlack : Color.systemBlack.opacity(0.1))
                            .frame(width: 28, height: 28)

                        if isSpeaking {
                            Image(systemName: "waveform")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Color.systemWhite)
                        } else {
                            Text("\(index)")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Color.systemBlack)
                        }
                    }
                    .animation(.easeInOut(duration: 0.2), value: isSpeaking)

                    Text(example.example)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.primary)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(4)
                }
            }
            .buttonStyle(.plain)
            .background(offsetReader(for: \.speakingType))

            // 번역/힌트
            HStack(alignment: .top, spacing: 10) {
                Color.clear
                    .frame(width: 28)

                if example.showAnswer {
                    Text(example.answer)
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                        .lineSpacing(3)
                } else {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            example.setShowTranslation()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            if example.showTranslation {
                                Text(example.translation)
                                    .font(.caption)
                                    .foregroundStyle(Color.secondary)
                                    .lineSpacing(3)
                            } else {
                                Image(systemName: "eye.slash")
                                    .font(.caption)
                                Text("힌트 보기")
                                    .font(.caption.weight(.medium))
                            }
                        }
                        .foregroundStyle(example.showTranslation ? Color.secondary : Color.systemBlack)
                        .padding(.horizontal, example.showTranslation ? 0 : 10)
                        .padding(.vertical, example.showTranslation ? 0 : 6)
                        .background(example.showTranslation ? Color.clear : Color(.tertiarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .background(offsetReader(for: \.hintType))
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
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
        .animation(.easeInOut, value: example.showTranslation)
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

// MARK: - User Action Button
private struct UserActionButton: View {
    @ObservedObject var viewModel: ReviewCardViewModel
    @Binding var memoryActionPublisher: PassthroughSubject<Void, Never>

    var body: some View {
        HStack(spacing: 12) {
            // 틀림 버튼
            Button {
                viewModel.debouncer.debounce(interval: 0.3) {
                    do {
                        try await viewModel.editMemoryAction(.bad)
                        memoryActionPublisher.send()
                    } catch {
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "xmark")
                        .font(.title2.weight(.bold))
                    Text("틀림")
                        .font(.caption.weight(.medium))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        colors: [Color.red.opacity(0.9), Color.red],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }

            // 맞음 버튼
            Button {
                viewModel.debouncer.debounce(interval: 0.3) {
                    do {
                        try await viewModel.editMemoryAction(.good)
                        memoryActionPublisher.send()
                    } catch {
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark")
                        .font(.title2.weight(.bold))
                    Text("맞음")
                        .font(.caption.weight(.medium))
                }
                .foregroundStyle(Color.systemWhite)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        colors: [Color.systemBlack.opacity(0.85), Color.systemBlack],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }
}

// MARK: - Toast View
private struct ToastView: View {
    let message: String

    var body: some View {
        Text(LocalizedStringKey(message))
            .font(.caption)
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.85))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

// MARK: - Shimmer Effect
extension View {
    @ViewBuilder
    func shimmering() -> some View {
        self.modifier(ShimmerModifier())
    }
}

private struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.systemBlack.opacity(0.4),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: -geometry.size.width + (geometry.size.width * 2 * phase))
                }
                .mask(content)
            }
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

#Preview {
    ZStack {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()

        ReviewCardView(diContainer: ReviewMockDIContainer(),
                       wordMemory: WordMemory(identity: "identity",
                                              word: "expect",
                                              meaning: "기대하다", createAt: .now),
                       reviewType: .meaning,
                       aiSentenceType: .description,
                       memoryActionPublisher: .constant(PassthroughSubject()))
    }
}
