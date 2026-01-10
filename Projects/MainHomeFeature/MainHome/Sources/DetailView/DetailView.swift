//
//  DetailView.swift
//  MainHome
//
//  Created by 박현수 on 12/27/24.
//

import SwiftUI
import CommonUI
import AppCoordinatorService
struct DetailView: View {
    
    @ObservedObject var appCoordinator: AppCoordinator
    @StateObject var viewModel: DetailViewModel
    
    @Environment(\.dismiss) var dismiss
    let gridItems: [GridItem] = [GridItem(.flexible(minimum: 10, maximum: 10))]
    var diContainer: MainHomeDependencyInjection
    init(diContainer: MainHomeDependencyInjection, wordIdentity: String, appCoordinator: AppCoordinator) {
        self.diContainer = diContainer
        _viewModel = StateObject(wrappedValue: DetailViewModel(dbService: diContainer.makeDBImplementation(), wordIdentity: wordIdentity, appleSpeechService: diContainer.makeSpecchAppleVoiceImplementation()))
        self.appCoordinator = appCoordinator
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            ZStack {
                BackgroundView()
                
                VStack {
                    VStack {
                        ScrollView {
                            Text("\(viewModel.correctCount)번 맞춤")
                                .font(.callout)
                                .padding(.bottom, 10)
                            
                            Spacer()
                            Text(viewModel.word)
                                .font(.title)
                                .padding(.bottom, 10)
                                .onTapGesture {
                                    print("-----------")
                                    Task {
                                        try? await viewModel.speechAppleTTS(content: viewModel.word)
                                    }
                                }
                            
                            Text(viewModel.meaning)
                                .font(.title3)
                                .padding(.bottom, 10)
                            
                            HStack {
                                if viewModel.tags.isEmpty == false {
                                    Image("gridicons_tag-light", bundle: CommonUIResources.bundle)
                                        .padding(EdgeInsets.init(top: 0, leading:0, bottom: 5, trailing: 0))
                                    ScrollView(.horizontal) {
                                        LazyHGrid(rows: gridItems, spacing: 10) {
                                            ForEach(viewModel.tags.indices, id: \.self) { (index: Int) in
                                                WMChipButton(title: viewModel.tags[index],
                                                             isSelected: true,
                                                             isEnabled: false) {
                                                    
                                                }
                                            }
                                        }
                                        .padding(EdgeInsets(top: 5, leading: 5, bottom: 15, trailing: 5))
                                    }
                                    .frame(maxWidth: geometry.size.width * 0.75)
                                    .fixedSize(horizontal: true, vertical: true)
                                }
                            }
                            
                            
                            if viewModel.sentences.isEmpty {
                                
                                Text("생성된 문장이 없습니다.")
                                    .font(.body)
                                    .padding(.top, 30)
                                Text("리뷰를 하시면 AI가 생성해줘요.")
                                    .font(.body)
                                Button {
                                    appCoordinator.showReviewTab = true
                                } label: {
                                    Label {
                                        Text("리뷰하러 가기")
                                    } icon: {
                                        Image("material-symbols_rate-review-rounded", bundle: CommonUIResources.bundle)
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                    }
                                }
                                .buttonStyle(WMButtonStyle())
                                .fixedSize()
                                .frame(height: 30)
                                .padding(.top, 10)
                                
                            } else {
                                
                                HStack {
                                    Image("ph_open-ai-logo-light", bundle: CommonUIResources.bundle)
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                    Text("AI 문장 학습")
                                        .font(.headline)
                                    Spacer()
                                }
                                .padding(.top, 10)
                                .padding([.leading, .trailing], 7)
                                //                            .frame(width: geometry.size.width * 0.85)
                                
                                ScrollView {
                                    ForEach(viewModel.sentences) { (sentence: DetailViewModel.Sentence) in
                                        HStack {
                                            Text(sentence.example)
                                                .font(.headline)
                                            Spacer()
                                        }
                                        HStack {
                                            Text(sentence.translation)
                                                .font(.body)
                                            Spacer()
                                        }
                                        Divider()
                                    }
                                }
                                .scrollBounceBehavior(.basedOnSize)
                                .padding([.leading, .trailing], 7)
                                //                            .frame(width: geometry.size.width * 0.85)
                            }
                        }
                    }
                    
                    HStack(spacing: 20) {
                        Button {
                            viewModel.deleteAlert.toggle()
                        } label: {
                            
                            Image("material-symbols_delete-rounded", bundle: CommonUIResources.bundle)
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                        .buttonStyle(WMButtonStyle())
                        
                        
                        Button {
                            viewModel.editSheet.toggle()
                        } label: {
                            Image("icon-park-solid_edit-light", bundle: CommonUIResources.bundle)
                                .resizable()
                                .frame(width: 22, height: 22)
                        }
                        .buttonStyle(WMButtonStyle())
                        
                    }
                    .frame(height: 30)
                    .padding([.leading, .trailing, .bottom])
                }
                .padding()
            }
            
        }
        .padding(.all, 30)
        //        .background()
        .alert("삭제하시겠습니까?",
               isPresented: $viewModel.deleteAlert,
               presenting: viewModel) { viewModel in
            Button(role: .destructive) {
                Task {
                    try await viewModel.deleteWord()
                    dismiss()
                }
                
                
            } label: {
                Text("삭제")
            }
            
            Button(role: .cancel) {
                
            } label: {
                Text("취소")
            }
        } message: { _ in
            
        }
        .sheet(isPresented: $viewModel.editSheet) {
            EditView(diContainer: diContainer, wordIdentity: viewModel.wordIdentity)
        }
        .runOnceTask {
            do {
                try await viewModel.fetch()
            } catch {
                
            }
        }
        
    }
    
}

#Preview {
    TabView {
        NavigationStack {
            DetailView(diContainer: MainHomeMockDIContainer(),
                       wordIdentity: "be used to", appCoordinator: AppCoordinator())
            //                       wordIdentity: "apparently", appCoordinator: AppCoordinator())
//                                wordIdentity: "헌법재판소", appCoordinator: AppCoordinator())
            
            .navigationBarItems(leading: Button("Setting") { print() })
            .navigationTitle("asdfasdf")
        }
        .tabItem {
            Label("asdfsadf", systemImage: "person")
        }
    }
}
