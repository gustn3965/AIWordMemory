//
//  ReviewDeckView.swift
//  Review
//
//  Created by 박현수 on 12/27/24.
//

import SwiftUI
import CommonUI

struct ReviewDeckView: View {
    @State private var orientation = UIDeviceOrientation.unknown
    
    @StateObject var viewModel: ReviewDeckViewModel

    @Environment(\.dismiss) var dismiss
    @State var needAlert: Bool = false
    @State var errorMessage: String = ""
    
    private let diContainer: ReviewDependencyInjection
    init(diContainer: ReviewDependencyInjection, reviewStartFilter: ReviewStartFilter) {
        self.diContainer = diContainer
        _viewModel = StateObject(wrappedValue: ReviewDeckViewModel(diContainer: diContainer, reviewStartFilter: reviewStartFilter))
    }
    
    var body: some View {
        GeometryReader { geometry in
            
            VStack(spacing: 0) {
                Text( viewModel.reviewList.isEmpty ? "" : "\(viewModel.currentIndex + 1)/\(viewModel.reviewList.count)")
                    .font(.callout)
                    .layoutPriority(0.05)
                ScrollViewReader { proxy in
                    ZStack {
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHGrid(rows: [GridItem()], spacing: 0) {
                                ForEach(viewModel.reviewList.indices, id: \.self) { index in
                                    ReviewCardView(diContainer: diContainer,
                                                   wordMemory: viewModel.reviewList[index],
                                                   reviewType: viewModel.reviewStartFilter.reviewType,
                                                   aiSentenceType: viewModel.reviewStartFilter.aiSentenceType,
                                                   memoryActionPublisher: $viewModel.memoryActionPublisher)
                                    
                                    .padding([.leading, .trailing, .bottom])
                                    .padding(.top, orientation.isLandscape ? 0 : 20)
                                        .frame(width: geometry.size.width)
                                }
                            }
                        }
                        .scrollDisabled(true)
                        .onChange(of: viewModel.currentIndex) { _, newIndex in
                            withAnimation {
                                proxy.scrollTo(newIndex, anchor: .center)
                            }
                        }

                        HStack {
                            if viewModel.currentIndex > 0 {
                                Button(action: {
                                    viewModel.moveAction(.before)
                                }) {
                                    Text("<")
                                }
                                .buttonStyle(WMButtonStyle())
                                .frame(width: 50, height: 50)
                                
                                
                            }
                            
                            Spacer()
                            
                            if viewModel.currentIndex < viewModel.searchedIndex {
                                Button(action: {
                                    viewModel.moveAction(.after)
                                }) {
                                    Text(">")
                                }
                                .buttonStyle(WMButtonStyle())
                                .frame(width: 50, height: 50)
                            }
                        }
                        .padding()
                    }

                }
                .layoutPriority(1)
                
                Button {
                    dismiss()
                } label: {
                    Text("리뷰 종료")
                }
                .buttonStyle(WMButtonStyle())
                .frame(height: 50)
                .padding([.leading, .trailing], 20)
                .padding(.bottom, orientation.isLandscape ? 0 : 20)
                .layoutPriority(0.1)
                .onRotate { newOrientation in
                            orientation = newOrientation
                        }
            }
        }
        .runOnceTask {
//            Task {
                do {
                    try await viewModel.makeDeck()
                } catch {
                    needAlert = true
                    errorMessage = error.localizedDescription
                }
//            }
        }
        .onChange(of: viewModel.shouldClose) { _, shouldClose in
            if shouldClose {
                dismiss()
            }
        }
        .alert(LocalizedStringKey(errorMessage),
               isPresented: $needAlert,
               presenting: errorMessage) { errorMessage in
            Button {
                dismiss()
            } label: {
                Text("확인")
            }
            
        }
    }
}

#Preview {
    VStack {
        ReviewDeckView(diContainer: ReviewMockDIContainer(),
                       reviewStartFilter: ReviewStartFilter(sortType: .correctAscending, reviewType: .meaning, aiSentenceType: .description, selectedTagItem: []))
        
        //        Spacer(minLength: 40)
        //
        //        Button {
        //            print("---")
        //        } label: {
        //            Text("리뷰 종료")
        //        }
        //        .buttonStyle(WMButtonStyle())
        //        .frame(height: 50)
        //        .padding()
    }
    
}


