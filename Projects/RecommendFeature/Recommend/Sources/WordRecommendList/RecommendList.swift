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

    @State var errorAlert: Bool = false
    @State var aiSearchErrorMessage: String = ""

    @State var saveAlert: Bool = false
    @State var saveAlertMessage: String = ""

    public init(viewModel: RecommendListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // 카운트 헤더
                    HStack {
                        Text("추천된 단어")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                        Spacer()
                        Text("\(viewModel.items.count)개")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.systemBlack)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 12)

                    // 리스트
                    listView(geometry: geometry)
                }
                .allowsHitTesting(!viewModel.isLoading)

                if viewModel.isLoading {
                    loadingOverlay
                }
            }
            .safeAreaInset(edge: .bottom) {
                moreRecommendButton
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial)
            }
        }
        .alert(LocalizedStringKey(aiSearchErrorMessage), isPresented: $errorAlert,
               presenting: aiSearchErrorMessage) { _ in }
        .alert(LocalizedStringKey(saveAlertMessage), isPresented: $saveAlert,
               presenting: saveAlert) { _ in }
        .task {
            do {
                try await viewModel.firstLoadDB()
            } catch {}

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

    // MARK: - List View
    private func listView(geometry: GeometryProxy) -> some View {
        let isWideView = UIDevice.current.userInterfaceIdiom == .pad || orientation.isLandscape
        let columns = isWideView ? [GridItem(.flexible()), GridItem(.flexible())] : [GridItem(.flexible())]

        return ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(viewModel.items) { item in
                    WordCard(
                        item: item,
                        saveAction: {
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
                        },
                        speakAction: {
                            Task {
                                try? await viewModel.speechAppleTTS(content: item.word)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
    }

    // MARK: - More Recommend Button
    private var moreRecommendButton: some View {
        Button {
            Task {
                do {
                    try await viewModel.fetchRecommend()
                } catch {
                    errorAlert = true
                    aiSearchErrorMessage = error.localizedDescription
                }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                Text("AI 추천받기")
            }
            .font(.headline)
            .foregroundStyle(Color.systemWhite)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.systemBlack)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    // MARK: - Loading Overlay
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.systemBlack.opacity(0.1))
                        .frame(width: 60, height: 60)

                    Image("ph_open-ai-logo-light", bundle: CommonUIResources.bundle)
                        .resizable()
                        .frame(width: 30, height: 30)
                        .rotationEffect(Angle(degrees: viewModel.shouldAnimateLogo ? 360 : 0))
                        .animation(viewModel.shouldAnimateLogo ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: viewModel.shouldAnimateLogo)
                }

                Text("AI 생성중...")
                    .font(.headline)
                    .foregroundStyle(Color.primary)
            }
            .padding(32)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }
}

// MARK: - Word Card
private struct WordCard: View {
    let item: RecommendWordModel
    let saveAction: () -> Void
    let speakAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.word)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.primary)
                        .lineLimit(2)

                    Text(item.meaning)
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                        .lineLimit(3)
                }

                Spacer()

                HStack(spacing: 8) {
                    // 발음 버튼
                    Button {
                        speakAction()
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.subheadline)
                            .foregroundStyle(Color.systemBlack)
                            .frame(width: 36, height: 36)
                            .background(Color.systemBlack.opacity(0.1))
                            .clipShape(Circle())
                    }

                    // 저장 버튼
                    Button {
                        saveAction()
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                            .font(.subheadline)
                            .foregroundStyle(Color.systemWhite)
                            .frame(width: 36, height: 36)
                            .background(Color.systemBlack)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .contentShape(Rectangle())
        .onTapGesture {
            speakAction()
        }
    }
}

struct RecommendListView_Preview: PreviewProvider {

    static var previews: some View {
        RecommendListView(viewModel: RecommendListViewModel.makeMock())
    }
}
