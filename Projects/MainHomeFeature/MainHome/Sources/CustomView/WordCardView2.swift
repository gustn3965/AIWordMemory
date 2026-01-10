//
//  WordCardView2.swift
//  MainHome
//
//  Created by 박현수 on 2/9/25.
//

import SwiftUI
import CommonUI


public struct WordCardView2: View {

    init(viewModel: WordCardViewModel, tagViewModel: ExpandableTagViewModel? = nil, viewType: Binding<WordCardViewType>) {
        self.viewModel = viewModel
        self.tagViewModel = tagViewModel
        self._viewType = viewType
    }

    @ObservedObject var viewModel: WordCardViewModel
    var tagViewModel: ExpandableTagViewModel?
    @Binding var viewType: WordCardViewType

    public var body: some View {
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
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
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
        WordCardView2(viewModel: WordCardViewModel(dbService: MainHomeMockDIContainer().makeDBImplementation()), viewType: .constant(.all))
    }
}
