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

    @State var infoAlert: Bool = false
    let infoText: String = "AI에서 추천하는 단어로써 단어가 부족할 수 있습니다. 참고용으로 사용하세요."

    public init(diContainer: RecommendDependencyInjection) {
        _viewModel = StateObject(wrappedValue: WordCollectionViewModel(diContainer: diContainer))
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // 헤더
                    headerSection

                    // 설명 언어 설정
                    settingsCard

                    // 언어 탭
                    languageTabSection

                    // 레벨 리스트
                    levelListCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("AI단어추천")
                        .font(.headline)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        infoAlert.toggle()
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundStyle(Color.systemBlack)
                    }
                }
            }
            .alert(LocalizedStringKey(infoText), isPresented: $infoAlert,
                   presenting: infoText) { _ in
                Button {
                    aiRecommendInfoOnboarding = false
                } label: {
                    Text("확인")
                }
            }
            .navigationDestination(item: $viewModel.selectLanguageLevelType) { menu in
                if let listViewModel = viewModel.makeRecommendListViewModel() {
                    RecommendListView(viewModel: listViewModel)
                        .navigationTitle(LocalizedStringKey(viewModel.selectLanguageLevelType?.levelFullName ?? ""))
                } else {
                    Text("")
                }
            }
            .task {
                if aiRecommendInfoOnboarding {
                    infoAlert.toggle()
                }
                viewModel.updateUserDefaultUserLanguageCode(code: aiUserLanguageCodeType)
            }
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
            }

            Text("레벨별 단어 추천")
                .font(.title2.bold())
                .foregroundStyle(Color.primary)

            Text("AI가 레벨에 맞는 단어를 추천합니다")
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
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Language Tab Section
    private var languageTabSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(viewModel.languageTabList) { language in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.selectLanguageTab = language
                        }
                    } label: {
                        Text(LocalizedStringKey(language.name))
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(viewModel.selectLanguageTab == language ? Color.systemWhite : Color.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                viewModel.selectLanguageTab == language
                                    ? Color.systemBlack
                                    : Color.clear
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(4)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    // MARK: - Level List Card
    private var levelListCard: some View {
        VStack(spacing: 0) {
            // 헤더
            HStack {
                Text(LocalizedStringKey(viewModel.selectLanguageTab.name))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.secondary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()
                .padding(.leading, 16)

            // 레벨 리스트
            ForEach(Array(viewModel.selectLanguageTab.levelTypes.enumerated()), id: \.element.id) { index, item in
                Button {
                    viewModel.selectLanguageLevelType = item
                } label: {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(LocalizedStringKey(item.levelFullName))
                                .font(.body.weight(.medium))
                                .foregroundStyle(Color.primary)
                            Text(LocalizedStringKey(item.levelDescription))
                                .font(.caption)
                                .foregroundStyle(Color.secondary)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color(.tertiaryLabel))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if index != viewModel.selectLanguageTab.levelTypes.count - 1 {
                    Divider()
                        .padding(.leading, 16)
                }
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct WordCollectionView_Preview: PreviewProvider {

    static var previews: some View {
        WordCollectionView(diContainer: RecommendMockDIContainer())
    }
}
