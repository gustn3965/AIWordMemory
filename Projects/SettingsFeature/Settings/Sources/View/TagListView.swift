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
    
    @Published var tagItems: [TagItem] = [
        TagItem(name: "SwiftUI", identity: "SwiftUI"),
        TagItem(name: "zxcvzxcv", identity: "asdfssdf"),
        ]
    
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
        print("# \(#file) \(#function)")
        let allTags = try await dbService.fetchAllTags()
        self.tagItems = allTags.map { TagItem(name: $0.name, identity: $0.identity)}
    }
    
    func deleteTag(tag: TagItem) async throws {
        try await dbService.deleteTag(identity: tag.identity)
    }
    
    func editTag(tag: TagItem) async throws {
        try await dbService.editTag(tag: WordTag(identity: tag.identity, name: tag.name))
    }
    
}
struct TagListView: View {
    
    
    var tagItems: [TagItem] = [
        TagItem(name: "SwiftUI", identity: "SwiftUI"),
        TagItem(name: "zxcvzxcv", identity: "asdfssdf"),
    ]
    
    @StateObject var viewModel: TagListViewModel
    var menu: SettingMenuList
    
    init(diContainer: SettingsDependencyInjection, menu: SettingMenuList) {
        _viewModel = StateObject(wrappedValue: TagListViewModel(dbService: diContainer.makeDBImplementation()))
        self.menu = menu
    }

    @State var textField: String = "asdfasdf"
    var body: some View {
        
        ZStack {
            Color.systemWhite
                .cornerRadius(15)
                .northWestShadow(radius: 5, offset: 5)
            
            if viewModel.tagItems.isEmpty {
                Text("태그가 없습니다.")
            } else {
                List(viewModel.tagItems) { (tagItem: TagItem) in
                    TagTextField(tagItem: tagItem, viewModel: viewModel)
                    .padding([.top, .bottom], 10)
    //                .listRowSeparator(.hidden)
                }
                .padding()
                .listStyle(.plain)
            }
        }
        .padding(.all, 30)
        .navigationTitle(LocalizedStringKey(menu.name))
        .task {
            do {
                try await viewModel.fetchAllTag()
            } catch {
                
            }
        }

    }
}

struct TagTextField: View {
    var tagItem: TagItem
    @State var textField: String = ""
    @ObservedObject var viewModel: TagListViewModel
    @State var needAlert: Bool = false
    @FocusState var focusState: Bool
    init(tagItem: TagItem, viewModel: TagListViewModel) {
        _textField = State(initialValue: tagItem.name)
        self.tagItem = tagItem
        self.viewModel = viewModel
    }
    var body: some View {
        HStack {
            Image("gridicons_tag-light", bundle: CommonUIResources.bundle)
//                    Text(tagItem.name)
            TextField("", text: $textField)
                .focused($focusState)
            Spacer()
            Button {
                needAlert = true
            } label: {
                Image("material-symbols_delete-rounded", bundle: CommonUIResources.bundle)
            }
            .buttonStyle(PlainButtonStyle())
            .onChange(of: focusState) { oldValue, newValue in
                if newValue == false {
                    if tagItem.name != textField {
                        Task {
                            var tagItem = self.tagItem
                            tagItem.name = textField
                            do {
                                try await viewModel.editTag(tag: tagItem)
                            } catch {
                                textField = self.tagItem.name
                            }
                        }
                    }
                }
            }
            
        }
        .alert("삭제하시겠습니까?", isPresented: $needAlert, presenting: viewModel) { _ in
            Button("Yes", role: .destructive) {
                Task {
                    do {
                        try await viewModel.deleteTag(tag: tagItem)
                    } catch {
                        
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TagListView(diContainer: SettingsMockDIContainer(), menu: .tag)
                .environment(\.locale, .init(identifier: "en"))
            
        }
    }
    
}
