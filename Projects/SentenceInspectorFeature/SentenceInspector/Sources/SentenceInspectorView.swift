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
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // 헤더
                        if !isIphoneLandScape {
                            headerSection
                        }

                        // 설정 카드
                        settingsCard

                        // 문장 입력
                        sentenceInputCard

                        // AI 응답
                        if viewModel.isLoading {
                            loadingView
                        } else if let _ = viewModel.aiResponse {
                            aiResponseCard
                        } else if !aiSearchErrorMessage.isEmpty {
                            errorCard
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                }
                .safeAreaInset(edge: .bottom) {
                    searchButton
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial)
                }
                .coordinateSpace(name: "VStack")
                .contentShape(Rectangle())
                .onTapGesture {
                    field = nil
                }
//                .allowsHitTesting(!showOnboarding)

//                if showOnboarding {
//                    tooltipOverlay(geometry: geometry)
//                }
            }
        }
        .onRotate { newOrientation in
            orientation = newOrientation
        }
        .task {
            viewModel.updateUserDefaultUserLanguageCode(code: aiUserLanguageCodeType)
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.systemBlack.opacity(0.1))
                    .frame(width: 56, height: 56)

                Image("ph_open-ai-logo-light", bundle: CommonUIResources.bundle)
                    .resizable()
                    .frame(width: 28, height: 28)
                    .rotationEffect(Angle(degrees: viewModel.shouldAnimateLogo ? 360 : 0))
                    .animation(viewModel.shouldAnimateLogo ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: viewModel.shouldAnimateLogo)
            }

            Text("문장 검사")
                .font(.title2.bold())
                .foregroundStyle(Color.primary)

            Text("AI가 문장의 문법과 표현을 검사합니다")
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Settings Card
    private var settingsCard: some View {
        VStack(spacing: 0) {
            HStack {
                Label {
                    Text("설명 언어")
                        .font(.body)
                        .foregroundStyle(Color.primary)
                } icon: {
                    Image(systemName: "text.bubble")
                        .font(.body)
                        .foregroundStyle(Color.systemBlack)
                }

                Spacer()

                Picker("", selection: $viewModel.userLanguage) {
                    ForEach(viewModel.languageList) { language in
                        Text(LocalizedStringKey(language.name))
                            .tag(language)
                    }
                }
                .tint(Color.systemBlack)
                .pickerStyle(.menu)
                .onChange(of: viewModel.userLanguage) { _, newValue in
                    aiUserLanguageCodeType = newValue.rawValue
                    viewModel.updateUserDefaultUserLanguageCode(code: aiUserLanguageCodeType)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(offsetReader(for: \.explanationLanguage))
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Sentence Input Card
    private var sentenceInputCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("검사할 문장")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.primary)
                Spacer()
                Text("\(viewModel.wordCount)/\(viewModel.maxWordCount)")
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
            }

            ZStack(alignment: .topLeading) {
                TextEditor(text: $viewModel.searchSentence)
                    .frame(height: isIphoneLandScape ? 60 : 120)
                    .padding(10)
                    .scrollContentBackground(.hidden)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .focused($field, equals: .word)
                    .onChange(of: viewModel.searchSentence) { oldValue, newValue in
                        updateWordCount(oldValue: oldValue, newValue: newValue)
                        searchButtonEnable = !(viewModel.searchSentence.isEmpty || viewModel.searchSentence.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }

                if viewModel.searchSentence.isEmpty {
                    Text("검사할 문장을 입력하세요")
                        .foregroundStyle(Color(.placeholderText))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 18)
                        .allowsHitTesting(false)
                }
            }
            .background(offsetReader(for: \.inputField))
        }
    }

    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ForEach(0..<2, id: \.self) { _ in
                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.tertiarySystemFill))
                        .frame(width: 80, height: 14)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.tertiarySystemFill))
                        .frame(height: 16)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.tertiarySystemFill))
                        .frame(width: 200, height: 16)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .redacted(reason: .placeholder)
        .shimmering()
    }

    // MARK: - AI Response Card
    private var aiResponseCard: some View {
        VStack(spacing: 12) {
            if let aiResponse = viewModel.aiResponse {
                // 부연설명
                ResponseSection(
                    title: String(localized: "부연설명"),
                    content: aiResponse.explanation,
                    icon: "doc.text"
                )

                // 올바른 문장
                ResponseSection(
                    title: String(localized: "올바른 문장"),
                    content: aiResponse.correctSentence,
                    icon: "checkmark.circle"
                )
            }
        }
    }

    // MARK: - Error Card
    private var errorCard: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 50, height: 50)
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title3)
                    .foregroundStyle(Color.red)
            }

            Text(LocalizedStringKey(aiSearchErrorMessage))
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Search Button
    private var searchButton: some View {
        Button {
            Task {
                do {
                    field = nil
                    aiSearchErrorMessage = ""
                    try await searchAI()
                } catch {
                    aiSearchErrorMessage = error.localizedDescription
                }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                Text("AI 문장 검사")
            }
            .font(.headline)
            .foregroundStyle(Color.systemWhite)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(searchButtonEnable ? Color.systemBlack : Color.gray)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .disabled(!searchButtonEnable)
        .background(offsetReader(for: \.searchButton))
    }

    // MARK: - Helper Methods
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

// MARK: - Response Section
private struct ResponseSection: View {
    let title: String
    let content: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.secondary)
            } icon: {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
            }

            Text(content)
                .font(.body)
                .foregroundStyle(Color.primary)
                .textSelection(.enabled)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Supporting Types
extension SentenceInspectorView {
    enum Field: Hashable {
        case word

        var nextField: Field? {
            switch self {
            case .word: return nil
            }
        }
    }

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

// MARK: - Shimmer Effect
private extension View {
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
                            Color.white.opacity(0.4),
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
    SentenceInspectorView(diContainer: SentenceInspectorMockDIContainer())
}
