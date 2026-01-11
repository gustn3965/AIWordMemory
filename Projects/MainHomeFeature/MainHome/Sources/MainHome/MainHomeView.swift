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
    @Namespace private var namespace
    @State private var viewType: WordCardViewType = .all

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
                                    placement: .toolbar,
                                    prompt: "작성한 단어, 뜻을 검색해보세요.")
                        
                        .navigationDestination(for: CardItem.self) { cardItem in
                            DetailView(diContainer: diContainer, wordIdentity: cardItem.id, appCoordinator: appCoordinator)
                        }
                        .listStyle(.plain)
//                        .navigationTitle("AI Word")
                        .versioned { view in
                            if #available(iOS 26.0, *) {
                                view
                                    .searchToolbarBehavior(.minimize)
                                    .toolbar {
//                                        DefaultToolbarItem(kind: .search, placement: .topBarLeading)
                                        ToolbarItem(placement: .topBarLeading) {
                                                // 보기 필터
                                                Menu {
                                                    ForEach(WordCardViewType.allCases) { type in
                                                        Button {
                                                            viewType = type
                                                        } label: {
                                                            Label(LocalizedStringKey(type.rawValue), systemImage: viewType == type ? "checkmark" : "")
                                                        }
                                                    }
                                                } label: {
                                                    Image(systemName: "eye.circle.fill")
                                                        .font(.body)
                                                        .foregroundStyle(Color.systemBlack)
                                                }
                                        }
//                                        ToolbarSpacer(.fixed, placement: .topBarLeading)
                                        ToolbarItem(placement: .topBarLeading) {
                                                // 정렬 필터
                                                Menu {
                                                    ForEach(WordCardSortFilter.allCases) { type in
                                                        Button {
                                                            viewModel.wordCardviewModel.sortType = type
                                                        } label: {
                                                            Label(LocalizedStringKey(type.name), systemImage: viewModel.wordCardviewModel.sortType == type ? "checkmark" : "")
                                                        }
                                                    }
                                                } label: {
                                                    Image(systemName: "arrow.up.arrow.down.circle.fill")
                                                        .font(.body)
                                                        .foregroundStyle(Color.systemBlack)
                                                }
                                        }
                                    }
                            } else {
                                view
                                    .toolbar {
                                        ToolbarItem(placement: .topBarTrailing) {
                                                // 보기 필터
                                                Menu {
                                                    ForEach(WordCardViewType.allCases) { type in
                                                        Button {
                                                            viewType = type
                                                        } label: {
                                                            Label(LocalizedStringKey(type.rawValue), systemImage: viewType == type ? "checkmark" : "")
                                                        }
                                                    }
                                                } label: {
                                                    Image(systemName: "eye.circle.fill")
                                                        .font(.body)
                                                        .foregroundStyle(Color.systemBlack)
                                                }
                                        }
                                        
            //                            ToolbarSpacer(.fixed)
                                        ToolbarItem(placement: .topBarTrailing) {
                                                // 정렬 필터
                                                Menu {
                                                    ForEach(WordCardSortFilter.allCases) { type in
                                                        Button {
                                                            viewModel.wordCardviewModel.sortType = type
                                                        } label: {
                                                            Label(LocalizedStringKey(type.name), systemImage: viewModel.wordCardviewModel.sortType == type ? "checkmark" : "")
                                                        }
                                                    }
                                                } label: {
                                                    Image(systemName: "arrow.up.arrow.down.circle.fill")
                                                        .font(.body)
                                                        .foregroundStyle(Color.systemBlack)
                                                }
                                        }
                                    }
                            }
                        }
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
                .versioned { view in
//                    if #available(iOS 26.0, *) {
//                        view.navigationTransition(.zoom(sourceID: "add_write", in: namespace))
//                    } else {
                        view
//                    }
                }
                
        }
        .sheet(isPresented: $viewModel.showAddViewSheet) {
            WriteView(diContainer: diContainer)
                .versioned { view in
//                    if #available(iOS 26.0, *) {
//                        view.navigationTransition(.zoom(sourceID: "add_write_from_empty", in: namespace))
//                    } else {
                        view
//                    }
                }
        }
        .sheet(isPresented: $appCoordinator.showWriteView) {
            WriteView(diContainer: diContainer)
                .versioned { view in
//                    if #available(iOS 26.0, *) {
//                        view.navigationTransition(.zoom(sourceID: "add_write_from_app", in: namespace))
//                    } else {
                        view
//                    }
                }
        }
        .runOnceTask(perform: setupViewModel)
        
    }
    
    // MARK: - Subviews
    private func mainList(geometry: GeometryProxy) -> some View {
        Group {
            if viewModel.needEmptyAddView {
                List {
                    EmptyAddView(showAddSheet: $viewModel.showAddViewSheet, namespace: namespace)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
            } else {
                WordCardView2(
                    viewModel: viewModel.wordCardviewModel,
                    tagViewModel: viewModel.needTopExpandableTagView ? viewModel.tagViewModel : nil,
                    viewType: $viewType
                )
            }
        }
    }
    
    private var addButton: some View {
        Button(action: { viewModel.addWordSheet.toggle() }) {
            Image(systemName: "pencil.circle.fill")
                .versioned { view in
                    if #available(iOS 26.0, *) {
                        view
                            .resizable()
                            .foregroundStyle(Color.systemBlack)
                            .frame(width: 40, height: 40)
                        
                    } else {
                        view.font(.title2.weight(.semibold))
                            .foregroundStyle(Color.systemBlack)
                            .frame(width: 40, height: 40)
                            .background(Color.systemWhite)
                            .clipShape(Circle())
                                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                    }
                }

        }
        .versioned { view in
            if #available(iOS 26.0, *) {
                view
//                    .glassEffect(.regular.tint(Color.systemBlack))
                    .buttonStyle(.glass)
            } else {
                view
            }
        }
        .focusable(interactions: .activate)
        .padding(.trailing, 20)
        .padding(.bottom, 20)
        .versioned { view in
            if #available(iOS 26.0, *) {
                view.matchedTransitionSource(id: "add_write", in: namespace)
            } else {
                view
            }
        }
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
