//
//  MainHomeView.swift
//  MainHome
//
//  Created by 박현수 on 12/25/24.
//

import SwiftUI
import CommonUI
import AppCoordinatorService

public struct MainHomeView: View {
    // MARK: - Properties
    @ObservedObject var appCoordinator: AppCoordinator
    @StateObject private var viewModel: MainHomeViewModel
    @Environment(\.isSearching) private var isSearching
    
    private let diContainer: any MainHomeDependencyInjection
    
    
    // MARK: - Initialization
    public init(diContainer: any MainHomeDependencyInjection, appCoordinates: AppCoordinator) {
        self.diContainer = diContainer
        self.appCoordinator = appCoordinates
        _viewModel = StateObject(wrappedValue: MainHomeViewModel(dbService: diContainer.makeDBImplementation()))
    }
    
    // MARK: - Body
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                NavigationStack {
                    mainList(geometry: geometry)
                        .searchable(text: $viewModel.searchText,
                                    placement: .navigationBarDrawer(displayMode: .automatic),
                                    prompt: "작성한 단어, 뜻을 검색해보세요.")
                        .navigationDestination(for: CardItem.self) { cardItem in
                            DetailView(diContainer: diContainer, wordIdentity: cardItem.id, appCoordinator: appCoordinator)
                        }
                        .listStyle(.plain)
                        .navigationTitle("AI Word")
                        .onChange(of: viewModel.searchText, { _, newValue in handleSearchTextChange(newValue: newValue) })
                        .onSubmit(of: .search, { handleSearchSubmit() })
                        .overlay(alignment: .bottomTrailing) {
                            addButton
                        }
                    
                    
                }
            }
            .onAppear {
//                addWriteButtonFocus = true
            }
        }
        .sheet(isPresented: $viewModel.addWordSheet) {
            WriteView(diContainer: diContainer)
        }
        .sheet(isPresented: $viewModel.showAddViewSheet) {
            WriteView(diContainer: diContainer)
        }
        .sheet(isPresented: $appCoordinator.showWriteView) {
            WriteView(diContainer: diContainer)
        }
        .runOnceTask(perform: setupViewModel)
        
    }
    
    // MARK: - Subviews
    private func mainList(geometry: GeometryProxy) -> some View {
        List {
            if viewModel.needEmptyAddView {
                EmptyAddView(showAddSheet: $viewModel.showAddViewSheet)
                    .listRowSeparator(.hidden)
            } else {
                if viewModel.needTopExpandableTagView {
                    SearchExpandableTagview(viewModel: viewModel.tagViewModel)
                        .listRowSeparator(.hidden)
                }
                
                WordCardView2(viewModel: viewModel.wordCardviewModel)
                    .listRowSeparator(.hidden)
                    .frame(height: geometry.size.height * 0.7)
            }
        }
    }
    
    private var addButton: some View {
        ZStack {
            Capsule()
                .inset(by: 3)
                .fill(Color.element)
                .southEastShadow(radius: 1, offset: 2)
            
            Button(action: { viewModel.addWordSheet.toggle() }) {
                VStack {
                    Text("+")
                        .font(.title)
//                    if UIDevice.current.userInterfaceIdiom == .pad {
//                        Text("(enter)")
//                            .font(.caption)
//                    }
                }
            }
            .buttonStyle(WMButtonStyle())
            .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 80 : 60, height: UIDevice.current.userInterfaceIdiom == .pad ? 80 : 60)
            .focusable(interactions: .activate)
//            .focused($addWriteButtonFocus)
////            .focusEffectDisabled()
//            .onKeyPress(.tab) {
//                debugPrint("key: tab!!!!!!!!")
//                Task {
//                    await MainActor.run {
//                        viewModel.addWordSheet.toggle() // Button의 action을 실행합니다
//                    }
//                }
//                return .handled // 이벤트를 처리했음을 나타냅니다
//            }
        }
        .frame(width: 65, height: 65)
        .padding(.trailing, 20)
        .padding(.bottom, 20)
    }
    
    // MARK: - Helper Methods
    private func handleSearchTextChange(newValue: String) {
        if newValue.isEmpty {
            Task {
                try? await viewModel.fetch()
            }
        }
    }
    
    private func handleSearchSubmit() {
        Task {
            try? await viewModel.fetch()
        }
    }
    
    private func setupViewModel() {
        Task {
            try? await viewModel.setup()
        }
    }
}


struct MainTabTagView: View {
    var body: some View {
        ZStack {
            Color.systemWhite
                .cornerRadius(10)
                .northWestShadow(radius:1, offset: 1)
            Text("hihi")
        }
        
    }
}

#Preview {
//    MainTabTagView()
//        .frame(width: 300, height: 50)
//    MainHomeView(diContainer: MainHomeDIContainer())
    
    
    
    // 처음설치시
//    MainHomeView(diContainer: MainHomeMockDIContainer(isEmptyTags: true,
//                                                      isEmptyWord: true))
    
    // 단어만 추가한경우
//    MainHomeView(diContainer: MainHomeMockDIContainer(isEmptyTags: true,
//                                                      isEmptyWord: false))
    
    // 단어&태그 추가한경우
    TabView {
        MainHomeView(diContainer: MainHomeMockDIContainer(), appCoordinates: AppCoordinator())
            .tabItem {
                Button {
                    print()
                } label: {
                    Image(systemName: "house")
                }
            }
    }
    
}
