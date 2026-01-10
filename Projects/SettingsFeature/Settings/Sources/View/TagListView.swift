//
//  TagListView.swift
//  Settings
//
//  Created by 박현수 on 1/4/25.
//

import SwiftUI
import CommonUI
import DBInterface
import AppEntity
import Combine

struct TagItem: Identifiable {
    var name: String
    var identity: String
    var id: String { identity }
}

@MainActor class TagListViewModel: ObservableObject {

    @Published var tagItems: [TagItem] = []

    var dbService: DataBaseProtocol
    var cancellables: Set<AnyCancellable> = []

    init(dbService: DataBaseProtocol) {
        self.dbService = dbService
        dbService.updatePulbisher
            .sink { [weak self] _ in
                Task {
                    try await self?.fetchAllTag()
                }
            }
            .store(in: &cancellables)
    }

    func fetchAllTag() async throws {
        let allTags = try await dbService.fetchAllTags()
        self.tagItems = allTags.map { TagItem(name: $0.name, identity: $0.identity) }
    }

    func deleteTag(tag: TagItem) async throws {
        try await dbService.deleteTag(identity: tag.identity)
    }

    func editTag(tag: TagItem) async throws {
        try await dbService.editTag(tag: WordTag(identity: tag.identity, name: tag.name))
    }
}

struct TagListView: View {

    @StateObject var viewModel: TagListViewModel
    var menu: SettingMenuList

    init(diContainer: SettingsDependencyInjection, menu: SettingMenuList) {
        _viewModel = StateObject(wrappedValue: TagListViewModel(dbService: diContainer.makeDBImplementation()))
        self.menu = menu
    }

    var body: some View {
        Group {
            if viewModel.tagItems.isEmpty {
                emptyView
            } else {
                tagList
            }
        }
        .navigationTitle(LocalizedStringKey(menu.name))
        .task {
            do {
                try await viewModel.fetchAllTag()
            } catch {
            }
        }
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(.tertiarySystemFill))
                    .frame(width: 80, height: 80)
                Image(systemName: "tag.slash")
                    .font(.system(size: 32))
                    .foregroundStyle(Color.secondary)
            }

            Text("태그가 없습니다")
                .font(.headline)
                .foregroundStyle(Color.primary)

            Text("단어 작성 시 태그를 추가할 수 있습니다")
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    private var tagList: some View {
        List {
            Section {
                ForEach(viewModel.tagItems) { tagItem in
                    TagRow(tagItem: tagItem, viewModel: viewModel)
                }
            } header: {
                Text("\(viewModel.tagItems.count)개의 태그")
            } footer: {
                Text("태그를 탭하여 이름을 수정하거나 삭제할 수 있습니다.")
            }
        }
        .listStyle(.insetGrouped)
    }
}

private struct TagRow: View {
    var tagItem: TagItem
    @State private var editedName: String = ""
    @ObservedObject var viewModel: TagListViewModel
    @State private var showDeleteAlert: Bool = false
    @FocusState private var isFocused: Bool

    init(tagItem: TagItem, viewModel: TagListViewModel) {
        self.tagItem = tagItem
        self.viewModel = viewModel
        _editedName = State(initialValue: tagItem.name)
    }

    var body: some View {
        HStack(spacing: 12) {
            // 태그 아이콘
            ZStack {
                Circle()
                    .fill(Color.systemBlack.opacity(0.1))
                    .frame(width: 32, height: 32)
                Image(systemName: "tag.fill")
                    .font(.caption)
                    .foregroundStyle(Color.systemBlack)
            }

            // 태그 이름 텍스트필드
            TextField("태그 이름", text: $editedName)
                .font(.body)
                .focused($isFocused)
                .onSubmit {
                    saveIfNeeded()
                }

            Spacer()

            // 삭제 버튼
            Button {
                showDeleteAlert = true
            } label: {
                Image(systemName: "trash")
                    .font(.subheadline)
                    .foregroundStyle(Color.red)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
        .onChange(of: isFocused) { _, newValue in
            if !newValue {
                saveIfNeeded()
            }
        }
        .alert("태그 삭제", isPresented: $showDeleteAlert) {
            Button("삭제", role: .destructive) {
                Task {
                    try? await viewModel.deleteTag(tag: tagItem)
                }
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("'\(tagItem.name)' 태그를 삭제하시겠습니까?")
        }
    }

    private func saveIfNeeded() {
        guard tagItem.name != editedName, !editedName.isEmpty else {
            editedName = tagItem.name
            return
        }
        Task {
            var updatedTag = tagItem
            updatedTag.name = editedName
            do {
                try await viewModel.editTag(tag: updatedTag)
            } catch {
//                editedName = tagItem.name
                print(error)
                
            }
        }
    }
}

#Preview {
    NavigationStack {
        TagListView(diContainer: SettingsMockDIContainer(), menu: .tag)
    }
}
