//
//  ReviewStartView.swift
//  Review
//
//  Created by 박현수 on 12/27/24.
//

import SwiftUI
import CommonUI
import AppCoordinatorService

struct ReviewStartView: View {
    // MARK: - Properties
    @ObservedObject var appCoordinator: AppCoordinator
    @StateObject private var viewModel: ReviewStartViewModel
    @State private var needWriteView: Bool = false

    private let diContainer: ReviewDependencyInjection

    @AppStorage("showOnBoardingReview") private var showOnboarding = true
    @State private var onboardingHintType: OnboardingHintType? = .sortType

    // MARK: - Layout
    @State private var offsets = OffsetValues()

    // MARK: - Initialization
    init(diContainer: ReviewDependencyInjection, appCoordinator: AppCoordinator) {
        self.appCoordinator = appCoordinator
        self.diContainer = diContainer
        _viewModel = StateObject(wrappedValue: ReviewStartViewModel(dbService: diContainer.makeDBImplementation()))
    }

    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ScrollView {
                    VStack(spacing: 16) {
                        // 헤더
                        headerSection

                        // 설정 카드
                        settingsCard

                        // 태그 필터
                        if viewModel.needFilterTagView {
                            FilterTagView(viewModel: viewModel.filterTagViewModel)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }
                .safeAreaInset(edge: .bottom) {
                    startReviewButton
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial)
                }
                .coordinateSpace(name: "VStack")
                .allowsHitTesting(!showOnboarding)

                if showOnboarding {
                    tooltipOverlay(geometry: geometry)
                }
            }
        }
        .fullScreenCover(isPresented: $viewModel.startReview) {
            ReviewDeckView(diContainer: diContainer,
                           reviewStartFilter: viewModel.makeReviewStartFilter())
        }
        .alert("작성된 단어장이 없습니다.",
               isPresented: $needWriteView,
               presenting: "") { _ in
            Button("작성하기") {
                appCoordinator.showWriteView = true
            }
        }
        .task {
            try? await viewModel.setup()
        }
    }

    // MARK: - Subviews
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 50))
                .foregroundStyle(Color.systemBlack)

            Text("리뷰 설정")
                .font(.title2.bold())
                .foregroundStyle(Color.primary)

            Text("단어 학습 방식을 선택하세요")
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    private var settingsCard: some View {
        VStack(spacing: 20) {
            sortTypeSection

            Divider()

            reviewTypeSection

            Divider()

            aiSentenceTypeSection
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var sortTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.up.arrow.down.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Color.systemBlack)
                Text("어떤 단어부터 시작할까요?")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.primary)
            }

//            Text(LocalizedStringKey(viewModel.sortDescription))
//                .font(.caption)
//                .foregroundStyle(Color.secondary)

            Picker("", selection: $viewModel.sortType) {
                ForEach(ReviewStartFilter.SortType.allCases) { sortType in
                    Text(LocalizedStringKey(sortType.name)).tag(sortType)
                }
            }
            .pickerStyle(.segmented)
            .background(offsetReader(for: \.sortType))
        }
    }

    private var reviewTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "questionmark.app.fill")
                    .font(.title3)
                    .foregroundStyle(Color.systemBlack)
                Text("어떤걸로 리뷰할까요?")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.primary)
            }

//            Text(LocalizedStringKey(viewModel.reviewDescription))
//                .font(.caption)
//                .foregroundStyle(Color.secondary)

            Picker("", selection: $viewModel.reviewType) {
                ForEach(ReviewStartFilter.ReviewType.allCases) { reviewType in
                    Text(LocalizedStringKey(reviewType.name)).tag(reviewType)
                }
            }
            .pickerStyle(.segmented)
            .background(offsetReader(for: \.reviewType))
        }
    }

    private var aiSentenceTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.title3)
                    .foregroundStyle(Color.systemBlack)
                Text("어떤 형식으로 AI가 만들어드릴까요?")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.primary)
            }

//            Text(LocalizedStringKey(viewModel.aiSentenceDescription))
//                .font(.caption)
//                .foregroundStyle(Color.secondary)

            Picker("", selection: $viewModel.aiSentenceType) {
                ForEach(ReviewStartFilter.AISentenceType.allCases) { reviewType in
                    Text(LocalizedStringKey(reviewType.name)).tag(reviewType)
                }
            }
            .pickerStyle(.segmented)
            .background(offsetReader(for: \.aiSentenceType))
        }
    }

    private var startReviewButton: some View {
        Button(action: handleStartReview) {
            HStack(spacing: 8) {
                Image(systemName: "play.fill")
                Text(LocalizedStringKey(viewModel.reviewStartButtonName))
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.systemBlack)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .background(offsetReader(for: \.reviewStartType))
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

    // MARK: - Helper Methods
    private func offsetReader(for keyPath: WritableKeyPath<OffsetValues, CGFloat>) -> some View {
        GeometryReader { geo -> Color in
            DispatchQueue.main.async {
                let offset = geo.frame(in: .named("VStack")).minY
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
        }
    }

    // MARK: - Computed Properties
    private var tooltipText: String {
        switch onboardingHintType {
        case .sortType: return "1. 리뷰할 단어들의 순서를 정합니다"
        case .reviewType: return "2. 리뷰에 단어 또는 뜻이 나오도록 정합니다"
        case .aiSentenceType: return "3. AI가 생성하는 문장의 타입을 정합니다."
        case .reviewStartType: return "4. 리뷰를 시작합니다"
        case .none: return ""
        }
    }

    private var tooltipYPosition: CGFloat {
        switch onboardingHintType {
        case .sortType: return offsets.sortType
        case .reviewType: return offsets.reviewType
        case .aiSentenceType: return offsets.aiSentenceType
        case .reviewStartType: return offsets.reviewStartType
        case .none: return 0
        }
    }

    // MARK: - Helper Methods
    private func handleStartReview() {
        viewModel.debouncer.debounce(interval: 0.3) {
            Task {
                do {
                    let result = try await viewModel.checkEmptyDB()
                    if result {
                        needWriteView.toggle()
                    } else {
                        viewModel.startReview.toggle()
                    }
                } catch {
                    // Handle error
                }
            }
        }
    }
}

extension ReviewStartView {
    
    struct OffsetValues {
        var sortType: CGFloat = 0
        var reviewType: CGFloat = 0
        var aiSentenceType: CGFloat = 0
        var reviewStartType: CGFloat = 0
    }
    
    enum OnboardingHintType: Int {
        case sortType
        case reviewType
        case aiSentenceType
        case reviewStartType
        
        var nextHintType: OnboardingHintType? {
            return OnboardingHintType(rawValue: self.rawValue + 1)
        }
    }
}

#Preview {
    VStack {
        ReviewStartView(diContainer: ReviewMockDIContainer(), appCoordinator: AppCoordinator())
    }
    
}
