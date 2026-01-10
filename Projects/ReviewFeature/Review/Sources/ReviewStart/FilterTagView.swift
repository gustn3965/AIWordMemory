//
//  FilterTagView.swift
//  Review
//
//  Created by 박현수 on 1/1/25.
//

import SwiftUI
import CommonUI

public struct FilterTagView: View {
    @ObservedObject var viewModel: FilterTagViewModel

    init(viewModel: FilterTagViewModel) {
        self.viewModel = viewModel
    }

    @State private var isExpanded: Bool = false

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 헤더
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "tag.fill")
                        .font(.body)
                        .foregroundStyle(Color.systemBlack)

                    // 선택된 태그들 표시
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            if viewModel.isAllSelected() {
                                Text("모든 태그")
                                    .font(.body)
                                    .foregroundStyle(Color.secondary)
                            } else {
                                ForEach(viewModel.selectedItems) { item in
                                    SelectedTagBadge(title: item.title)
                                }
                            }
                        }
                    }

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color(.tertiaryLabel))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .buttonStyle(.plain)

            // 펼쳐진 태그 목록
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    // 태그 목록 (수평 스크롤)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(viewModel.items) { item in
                                TagChip(
                                    title: item.title,
                                    isSelected: viewModel.isSelecteditem(item: item)
                                ) {
                                    viewModel.setSelectedItem(item: item)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    // 모든 태그 선택 버튼
                    Button {
                        viewModel.selectAllItem()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("모든 태그 선택")
                                .font(.subheadline)
                        }
                        .foregroundStyle(Color.systemBlack)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 4)
                }
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .padding(.top, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .task {
            do {
                try await viewModel.fetch()
            } catch {
            }
        }
    }
}

// 선택된 태그 뱃지 (헤더용)
private struct SelectedTagBadge: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.subheadline)
            .foregroundStyle(Color.systemBlack)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.systemBlack.opacity(0.15))
            .clipShape(Capsule())
    }
}

// 태그 칩 (선택용)
private struct TagChip: View {
    let title: String
    let isSelected: Bool
    var action: (() -> Void)? = nil

    var body: some View {
        Button {
            action?()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.subheadline)
                Text(title)
                    .font(.subheadline)
            }
            .foregroundStyle(isSelected ? Color.systemWhite : Color.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.systemBlack : Color(.tertiarySystemFill))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack {
        FilterTagView(viewModel: FilterTagViewModel(dbService: ReviewMockDIContainer().makeDBImplementation()))
            .padding()
        Spacer()
    }
}
