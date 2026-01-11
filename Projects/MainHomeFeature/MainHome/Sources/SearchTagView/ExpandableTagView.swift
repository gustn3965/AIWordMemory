//
//  File.swift
//  MainHome
//
//  Created by 박현수 on 1/2/25.
//

import Foundation
import SwiftUI
import CommonUI


public struct SearchExpandableTagview: View {
    @ObservedObject var viewModel: ExpandableTagViewModel
    @State private var expandTagView: Bool = false

    init(viewModel: ExpandableTagViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 헤더 (탭하면 펼침/접힘)
            HStack(spacing: 10) {
                ZStack(alignment: .leading) {
                    Button {
                        viewModel.selectAllItem()
                    } label: {
                        Image(systemName: "tag.circle.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundStyle(Color.systemBlack)
                    }
                    .versioned { view in
                        if #available(iOS 26.0, *) {
                            view.buttonStyle(.glass)
                        } else {
                            view
                        }
                    }
                    .zIndex(2)
                    .padding(.leading, 16)
                    
                    
                    // 선택된 태그들 가로로 표시
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
                        .offset(x: 37 + 16)
                        .padding(.trailing, 37 + 16)
                        
                    }
                    .zIndex(1)
                }
            }
            .padding(.horizontal, 0)
            .padding(.vertical, 10)
//            .background(Color(.secondarySystemGroupedBackground))
//            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

//            // 펼쳐진 태그 목록
//            if expandTagView {
//                VStack(alignment: .leading, spacing: 12) {
//                    // 한 줄 수평 스크롤
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack(spacing: 8) {
//                            ForEach(viewModel.items) { item in
//                                TagChip(
//                                    title: item.title,
//                                    isSelected: viewModel.isSelecteditem(item: item)
//                                ) {
//                                    viewModel.setSelectedItem(item: item)
//                                }
//                            }
//                        }
//                        .padding(.horizontal, 16)
//                    }
//
//                    // 모든 태그 선택 버튼
//                    Button {
//                        viewModel.selectAllItem()
//                    } label: {
//                        HStack(spacing: 6) {
//                            Image(systemName: viewModel.isAllSelected() ? "checkmark.circle.fill" : "circle")
//                                .foregroundStyle(viewModel.isAllSelected() ? Color.accentColor : Color(.tertiaryLabel))
//                            Text("모든 태그 선택")
//                                .font(.subheadline)
//                                .foregroundStyle(Color.primary)
//                        }
//                    }
//                    .padding(.horizontal, 16)
//                    .padding(.bottom, 4)
//                }
//                .padding(.vertical, 12)
//                .background(Color(.secondarySystemGroupedBackground))
//                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
//                .padding(.top, 8)
//                .transition(.opacity.combined(with: .move(edge: .top)))
//            }
        }
        .padding(.vertical, 8)
        .runOnceTask {
            do {
                try await viewModel.fetch()
            } catch {
            }
        }
    }
}

// 헤더에 표시되는 선택된 태그 뱃지
private struct SelectedTagBadge: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.subheadline)
            .foregroundStyle(Color.accentColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.accentColor.opacity(0.15))
            .clipShape(Capsule())
    }
}

// iOS 스타일 태그 칩 (체크마크 포함)
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
        .disabled(action == nil)
    }
}

#Preview {
    VStack {
        SearchExpandableTagview(viewModel: ExpandableTagViewModel(dbService: MainHomeMockDIContainer().makeDBImplementation()))
        Spacer()
    }
}
