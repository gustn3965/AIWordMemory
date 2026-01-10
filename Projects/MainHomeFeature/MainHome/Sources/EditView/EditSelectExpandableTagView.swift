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
    
    let gridItems: [GridItem] = [GridItem(.flexible(minimum: 10, maximum: 10))]
    
    let vGridItems: [GridItem] = [ GridItem(.adaptive(minimum: 100, maximum: 2000), spacing: 10)]
    
    
    init(viewModel: EditSelectExpandableTagViewModel) {
        self.viewModel = viewModel
//        _viewModel = StateObject(wrappedValue: WriteSelectExpandableTagViewModel(dbService: diContainer.makeDBImplementation()))
    }
    
    public var body: some View {
        
        ZStack {
            BackgroundView()
            
            VStack(alignment: .leading, spacing: 10) {
                
                HStack(alignment: .center) {
                    Image("gridicons_tag-light", bundle: CommonUIResources.bundle)
                        .padding(EdgeInsets.init(top: 5, leading:20, bottom: 5, trailing: 0))
                    
                    if viewModel.selectedItems.isEmpty {
                        Text("선택된 태그가 없습니다.")
                            .font(.callout)
                            .padding(.leading, 10)
                        Spacer()
                    } else {
                        ScrollView(.horizontal) {
                            LazyHGrid(rows: gridItems, spacing: 10) {
                                ForEach(viewModel.selectedItems) { (item: EditTagItem) in
                                    WMChipButton(title: item.name,
                                                 isSelected: true,
                                                 isEnabled: false) {
                                        viewModel.setSelectedItem(item: item)
                                    }
                                }
                            }
                            .padding(EdgeInsets(top: 13, leading: 5, bottom: 15, trailing: 5))
                        }
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    
                    Button {
                        viewModel.needExpanding.toggle()
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundStyle(Color.systemBlack)
                    .padding(.trailing, 10)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.needExpanding.toggle()
                }
                
                if viewModel.needExpanding {
                    //                        ScrollView {
                    VStack {
                        LazyVGrid(columns: vGridItems, alignment: .leading, spacing: 10) {
                            ForEach(viewModel.items) { (item: EditTagItem) in
                                WMChipButton(title: item.name,
                                             isSelected: viewModel.isSelecteditem(item: item)) {
                                    viewModel.setSelectedItem(item: item)
                                }
                                .frame(height: 40)
                                
                            }
                        }
//                        .padding(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 10))
                        //                        }
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        
                        Button {
                            print("확인")
                            viewModel.showAlertNewAddTag.toggle()
                        } label: {
                            Text("+")
                        }
                        //                            .frame(height: 50)
                        .buttonStyle(WMButtonStyle())
                        .frame(height: 40)
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
                        } message: {
                            
                        }
                        .alert(LocalizedStringKey(viewModel.errorMessage), isPresented: $viewModel.showErrorAlertTag) {
                            Button("확인", role: .cancel) {}
                        } message: {
//                            Text("Invalid input. Please try again.")
                        }
                        .padding()
                    }
                }
                
                
            }
            
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
        }
        .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
        .task {
            do {
                try await viewModel.fetch()
            } catch {
                
            }
        }
    }
    
}

#Preview {
    List {
        Text("hihi")
            .listRowSeparator(.hidden)
        EditSelectExpandableTagView(viewModel: EditSelectExpandableTagViewModel(dbService: MainHomeMockDIContainer().makeDBImplementation(), wordIdentity: "be used to"))
            .listRowSeparator(.hidden)
        //            .frame(width: 300, height: 140)
        
    }
    .listStyle(.plain)
    
    
}
