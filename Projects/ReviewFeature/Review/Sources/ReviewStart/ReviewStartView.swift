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
        UISegmentedControl.appearance().backgroundColor = UIColor(Color.element)
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    scrollContent(geometry: geometry)
                    startReviewButton
                }
                .coordinateSpace(name: "VStack")
                .padding()
                .allowsHitTesting(!showOnboarding)
                
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
                
                
                if showOnboarding {
                    
                    tooltipOverlay(geometry: geometry)
                }
            }
        }
    }
    
    // MARK: - Subviews
    private func scrollContent(geometry: GeometryProxy) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                sortTypeSection
                reviewTypeSection
                aiSentenceTypeSection
                if viewModel.needFilterTagView {
                    FilterTagView(viewModel: viewModel.filterTagViewModel)
                }
            }
            .padding()
        }
        .scrollBounceBehavior(.basedOnSize)
        .frame(height: geometry.size.height * 0.7)
    }
    
    private var sortTypeSection: some View {
        VStack {
            Text(LocalizedStringKey(viewModel.sortDescription))
                .font(.headline)
                .padding(.bottom, 20)
                
            Picker("", selection: $viewModel.sortType) {
                ForEach(ReviewStartFilter.SortType.allCases) { sortType in
                    Text(LocalizedStringKey(sortType.name)).tag(sortType)
                }
            }
            .background(offsetReader(for: \.sortType))
            .pickerStyle(.segmented)
            
        }
    }
    
    private var reviewTypeSection: some View {
        VStack {
            Text(LocalizedStringKey(viewModel.reviewDescription))
                .font(.headline)
                .padding(.bottom, 20)
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
        VStack {
            Text(LocalizedStringKey(viewModel.aiSentenceDescription))
                .font(.headline)
                .padding(.bottom, 20)
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
            Text(LocalizedStringKey(viewModel.reviewStartButtonName))
        }
        .buttonStyle(WMButtonStyle())
        .background(offsetReader(for: \.reviewStartType))
        .frame(height: 50)
        .padding(.bottom, 30)
    }
    
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
