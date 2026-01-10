//
//  EditSelectExpandableTagView.swift
//  MainHome
//
//  Created by 박현수 on 1/3/25.
//
import SwiftUI
import CommonUI

public struct EditSelectExpandableTagView: View {
    @ObservedObject var viewModel: EditSelectExpandableTagViewModel

    init(viewModel: EditSelectExpandableTagViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 헤더
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    viewModel.needExpanding.toggle()
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "tag.fill")
                        .font(.body)
                        .foregroundStyle(Color.systemBlack)

                    // 선택된 태그들 표시
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            if viewModel.selectedItems.isEmpty {
                                Text("태그 선택 (선택사항)")
                                    .font(.body)
                                    .foregroundStyle(Color.secondary)
                            } else {
                                ForEach(viewModel.selectedItems) { item in
                                    EditTagBadge(title: item.name)
                                }
                            }
                        }
                    }

                    Image(systemName: viewModel.needExpanding ? "chevron.up" : "chevron.down")
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
            if viewModel.needExpanding {
                VStack(alignment: .leading, spacing: 12) {
                    // 태그 목록 (수평 스크롤)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(viewModel.items) { item in
                                EditTagChip(
                                    title: item.name,
                                    isSelected: viewModel.isSelecteditem(item: item)
                                ) {
                                    viewModel.setSelectedItem(item: item)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    // 태그 추가 버튼
                    Button {
                        viewModel.showAlertNewAddTag.toggle()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                            Text("새 태그 추가")
                                .font(.subheadline)
                        }
                        .foregroundStyle(Color.systemBlack)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 4)
                    .alert("태그를 추가해주세요.", isPresented: $viewModel.showAlertNewAddTag) {
                        TextField("태그 입력", text: $viewModel.titleForNewTag)
                        Button("확인") {
                            Task {
                                do {
                                    try await viewModel.addNewTag()
                                } catch {
                                    viewModel.errorMessage = error.localizedDescription
                                    viewModel.showErrorAlertTag.toggle()
                                }
                            }
                        }
                        Button("취소", role: .cancel) {}
                    }
                    .alert(LocalizedStringKey(viewModel.errorMessage), isPresented: $viewModel.showErrorAlertTag) {
                        Button("확인", role: .cancel) {}
                    }
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
private struct EditTagBadge: View {
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
private struct EditTagChip: View {
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
            .foregroundStyle(isSelected ? .white : Color.primary)
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
        EditSelectExpandableTagView(viewModel: EditSelectExpandableTagViewModel(dbService: MainHomeMockDIContainer().makeDBImplementation(), wordIdentity: "be used to"))
            .padding()
        Spacer()
    }
}
