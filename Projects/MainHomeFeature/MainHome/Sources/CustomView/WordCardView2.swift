//
//  WordCardView2.swift
//  MainHome
//
//  Created by 박현수 on 2/9/25.
//

import SwiftUI
import CommonUI


public struct WordCardView2: View {

    init(viewModel: WordCardViewModel, tagViewModel: ExpandableTagViewModel? = nil) {
        self.viewModel = viewModel
        self.tagViewModel = tagViewModel
    }

    @ObservedObject var viewModel: WordCardViewModel
    var tagViewModel: ExpandableTagViewModel?
    @State private var viewType: WordCardViewType = .all

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 헤더
            VStack(spacing: 12) {
                // 상단: 제목 + 개수
                HStack {
                    Text("단어 목록")
                        .font(.title2.bold())

                    Spacer()

                    Text("\(viewModel.items.count)개")
                        .font(.subheadline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.accentColor)
                        .clipShape(Capsule())
                }

                // 하단: 필터 버튼들
                HStack(spacing: 8) {
                    FilterButton(
                        icon: "eye",
                        title: viewType.rawValue,
                        menu: {
                            ForEach(WordCardViewType.allCases) { type in
                                Button {
                                    viewType = type
                                } label: {
                                    Label(LocalizedStringKey(type.rawValue), systemImage: viewType == type ? "checkmark" : "")
                                }
                            }
                        }
                    )

                    FilterButton(
                        icon: "arrow.up.arrow.down",
                        title: viewModel.sortType.name,
                        menu: {
                            ForEach(WordCardSortFilter.allCases) { type in
                                Button {
                                    viewModel.sortType = type
                                } label: {
                                    Label(LocalizedStringKey(type.name), systemImage: viewModel.sortType == type ? "checkmark" : "")
                                }
                            }
                        }
                    )

                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            // 단어 리스트
            ScrollView {
                LazyVStack(spacing: 0) {
                    // 태그 필터
                    if let tagVM = tagViewModel {
                        SearchExpandableTagview(viewModel: tagVM)
                    }

                    // 단어 목록
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.items) { item in
                            NavigationLink(value: item) {
                                WordRowView(item: item, viewType: viewType)
                            }
                        }
                    }
                }
            }
        }
        .onChange(of: viewModel.sortType) { _, _ in
            Task {
                try? await viewModel.fetchWords(filter: viewModel.filter)
            }
        }
        .runOnceTask {
            do {
                try await viewModel.fetchWords(filter: viewModel.filter)
            } catch {
            }
        }
    }
    
}

// 필터 버튼 컴포넌트
private struct FilterButton<MenuContent: View>: View {
    let icon: String
    let title: String
    @ViewBuilder let menu: () -> MenuContent

    var body: some View {
        Menu {
            menu()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(LocalizedStringKey(title))
                    .font(.subheadline)
                Image(systemName: "chevron.down")
                    .font(.caption2)
            }
            .foregroundStyle(Color.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.tertiarySystemFill))
            .clipShape(Capsule())
        }
    }
}
fileprivate struct WordRowView: View {

    var item: CardItem
    var viewType: WordCardViewType

    init(item: CardItem, viewType: WordCardViewType) {
        self.item = item
        self.viewType = viewType
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                switch viewType {
                case .all:
                    Text(item.word)
                        .font(.body.weight(.medium))
                        .foregroundStyle(Color.primary)
                    Text(item.meaning)
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                case .word:
                    Text(item.word)
                        .font(.body.weight(.medium))
                        .foregroundStyle(Color.primary)
                case .meaning:
                    Text(item.meaning)
                        .font(.body)
                        .foregroundStyle(Color.primary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color(.tertiaryLabel))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}


#Preview {
    NavigationStack {
        WordCardView2(viewModel: WordCardViewModel(dbService: MainHomeMockDIContainer().makeDBImplementation()))
    }
}
