//
//  ReviewDeckView.swift
//  Review
//
//  Created by 박현수 on 12/27/24.
//

import SwiftUI
import CommonUI

struct ReviewDeckView: View {
    @State private var orientation = UIDeviceOrientation.unknown

    @StateObject var viewModel: ReviewDeckViewModel

    @Environment(\.dismiss) var dismiss
    @State var needAlert: Bool = false
    @State var errorMessage: String = ""

    private let diContainer: ReviewDependencyInjection

    init(diContainer: ReviewDependencyInjection, reviewStartFilter: ReviewStartFilter) {
        self.diContainer = diContainer
        _viewModel = StateObject(wrappedValue: ReviewDeckViewModel(diContainer: diContainer, reviewStartFilter: reviewStartFilter))
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // 상단 헤더
                headerSection

                // 카드 영역
                ScrollViewReader { proxy in
                    ZStack {
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHGrid(rows: [GridItem()], spacing: 0) {
                                ForEach(viewModel.reviewList.indices, id: \.self) { index in
                                    ReviewCardView(diContainer: diContainer,
                                                   wordMemory: viewModel.reviewList[index],
                                                   reviewType: viewModel.reviewStartFilter.reviewType,
                                                   aiSentenceType: viewModel.reviewStartFilter.aiSentenceType,
                                                   memoryActionPublisher: $viewModel.memoryActionPublisher)
                                    .frame(width: geometry.size.width)
                                }
                            }
                        }
                        .scrollDisabled(true)
                        .onChange(of: viewModel.currentIndex) { _, newIndex in
                            withAnimation(.easeInOut(duration: 0.3)) {
                                proxy.scrollTo(newIndex, anchor: .center)
                            }
                        }

                        // 좌우 네비게이션 버튼
                        navigationButtons
                    }
                }
                .layoutPriority(1)
            }
        }
        .background(Color(.systemGroupedBackground))
        .runOnceTask {
            do {
                try await viewModel.makeDeck()
            } catch {
                needAlert = true
                errorMessage = error.localizedDescription
            }
        }
        .onChange(of: viewModel.shouldClose) { _, shouldClose in
            if shouldClose {
                dismiss()
            }
        }
        .alert(LocalizedStringKey(errorMessage),
               isPresented: $needAlert,
               presenting: errorMessage) { _ in
            Button {
                dismiss()
            } label: {
                Text("확인")
            }
        }
        .onRotate { newOrientation in
            orientation = newOrientation
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            // 닫기 버튼
            Button {
                dismiss()
            } label: {
                HStack {
                    Image(systemName: "xmark")
                        .font(.body.weight(.medium))
                        .foregroundStyle(Color.white)
                        .frame(width: 36, height: 36)
                        .background(Color.systemBlack)
                        .clipShape(Circle())
                    
                    Text("리뷰종료")
                        .font(.subheadline.weight(.medium))
                }
            }

            Spacer()

            // 진행 상황
            if !viewModel.reviewList.isEmpty {
                HStack(spacing: 8) {
                    Text("\(viewModel.currentIndex + 1)")
                        .font(.headline)
                        .foregroundStyle(Color.systemBlack)
                    Text("/")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                    Text("\(viewModel.reviewList.count)")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.tertiarySystemFill))
                .clipShape(Capsule())
            }

            Spacer()

            // 플레이스홀더 (좌우 균형)
            Color.clear
                .frame(width: 36, height: 36)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        HStack {
            // 이전 버튼
            if viewModel.currentIndex > 0 {
                Button {
                    viewModel.moveAction(.before)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color.systemBlack)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
            }

            Spacer()

            // 다음 버튼
            if viewModel.currentIndex < viewModel.searchedIndex {
                Button {
                    viewModel.moveAction(.after)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color.systemBlack)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Bottom Section
    private var bottomSection: some View {
        Button {
            dismiss()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                Text("리뷰 종료")
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.systemBlack)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, orientation.isLandscape ? 8 : 20)
        .padding(.top, 8)
    }
}

#Preview {
    VStack {
        ReviewDeckView(diContainer: ReviewMockDIContainer(),
                       reviewStartFilter: ReviewStartFilter(sortType: .correctAscending, reviewType: .meaning, aiSentenceType: .description, selectedTagItem: []))
    }
}
