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
    
    @State var expandTagView: Bool = false
    let gridItems: [GridItem] = [GridItem(.flexible(minimum: 10, maximum: 10))]
    
    let vGridItems: [GridItem] = [ GridItem(.adaptive(minimum: 100, maximum: 2000), spacing: 10)]
    
    
    init(viewModel: ExpandableTagViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        
//        VStack {
            ZStack {
                BackgroundView()
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    HStack {
                        Image("gridicons_tag-light", bundle: CommonUIResources.bundle)
                        .padding(EdgeInsets.init(top: 5, leading:20, bottom: 5, trailing: 0))
                        
                        if viewModel.isAllSelected() {
                            Text("모든 태그 & 태그없음")
                                .font(.callout)
                                .padding(.leading, 10)
                            Spacer()
                        } else {
                            ScrollView(.horizontal) {
                                LazyHGrid(rows: gridItems, spacing: 10) {
                                    ForEach(viewModel.selectedItems) { item in
                                        WMChipButton(title: item.title,
                                                     isSelected: true,
                                                     isEnabled: false) {
//                                            viewModel.setSelectedItem(item: item)
                                        }
                                    }
                                }
                                .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                            }
                            .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        
                        Button {
                            expandTagView.toggle()
                        } label: {
                            Image(systemName: "ellipsis.circle.fill")
                        }
                        .buttonStyle(PlainButtonStyle())
                        .foregroundStyle(Color.systemBlack)
                        .padding(.trailing, 10)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        expandTagView.toggle()
                    }
                    
                    if expandTagView {
//                        ScrollView {
                        VStack {
                            LazyVGrid(columns: vGridItems, alignment: .leading, spacing: 10) {
                                ForEach(viewModel.items) { item in
                                    WMChipButton(title: item.title,
                                                 isSelected: viewModel.isSelecteditem(item: item)) {
                                        viewModel.setSelectedItem(item: item)
                                    }
                                    //                                    Text(item.title)
                                    
                                                 .frame(height: 40)
                                    
                                    //                                                 .fixedSize()
                                    
                                }
                            }
//                            .padding(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 10))
                            //                        }
                            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                            
                            HStack {
                                Button {
                                    print("확인")
                                    viewModel.selectAllItem()
//                                    viewModel.showAlertNewAddTag.toggle()
                                } label: {
                                    Text("모든 태그")
                                }
                                .buttonStyle(WMButtonStyle())
                                .frame(height:40)
                            }
                            .padding()
                        }
                    }
                    
                }
//                .animation(.easeIn, value: expandTagView)
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
            }
            .padding(EdgeInsets(top: 20, leading: 0, bottom: 10, trailing: 0))
            .runOnceTask {
                do {
//                    if viewModel.items.isEmpty {
                        try await viewModel.fetch()
//                    }
                    
                } catch {
                    
                }
            }
//        }
    }
    
    mutating func toggleSelectButton(_ item: SearchTagItem) {
        //        item.selected = true
    }
}

#Preview {
    List {
        Text("hihi")
            .listRowSeparator(.hidden)
        SearchExpandableTagview(viewModel: ExpandableTagViewModel(dbService: MainHomeMockDIContainer().makeDBImplementation()))
            .listRowSeparator(.hidden)
        //            .frame(width: 300, height: 140)
        
    }
    .listStyle(.plain)
    
    
}
