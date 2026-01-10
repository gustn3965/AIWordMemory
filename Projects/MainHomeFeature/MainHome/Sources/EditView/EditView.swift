//
//  EditView.swift
//  MainHome
//
//  Created by 박현수 on 1/3/25.
//

import Foundation

import SwiftUI
import CommonUI



struct EditView: View {
    
    enum Field: Hashable {
        case word
        case meaning
        
        var nextField: Field? {
            switch self {
            case .word:
                return .meaning
            case .meaning:
                return nil
            }
        }
    }
    
    let items = ["동사", "명사", "형용사"]
    @FocusState var field: Field?
    @StateObject var viewModel: EditViewModel
    private var diContainer: MainHomeDependencyInjection
    
    init(diContainer: MainHomeDependencyInjection, wordIdentity: String) {
        self.diContainer = diContainer

        _viewModel = StateObject(wrappedValue: EditViewModel(dbService: diContainer.makeDBImplementation(), wordIdentity: wordIdentity,
                                                             maxWordCount: diContainer.maxWordLength(),
                                                             maxWordMeaning: diContainer.maxMeaningLength()))
    }
    
    
    var body: some View {
            VStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("단어")
                                .font(.headline)
                                .padding(.leading)
                                .foregroundStyle(field == .word ? Color.systemBlack : Color.gray)
                            Spacer()
                            Text("\(viewModel.wordCount)/\(viewModel.maxWordCount)")
                                .font(.footnote)
                                .padding(.trailing)
                                .foregroundStyle(field == .word ? Color.systemBlack : Color.gray)
                        }
                        
                        WMTextField(placeHolder: "단어를 입력해주세요.", text: $viewModel.word)
                            .focused($field, equals: .word)
                            .onSubmit {
                                field = .meaning
                            }
                            .onChange(of: viewModel.word, { oldValue, newValue in
                                if newValue.count > viewModel.maxWordCount {
                                    viewModel.word = oldValue
                                    viewModel.wordCount = oldValue.count
                                } else {
                                    viewModel.wordCount = newValue.count
                                }
                                
                            })
                    }
                    .padding(.bottom, 10)
                    
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("뜻")
                                .font(.headline)
                                .padding(.leading)
                                .foregroundStyle(field == .meaning ? Color.systemBlack : Color.gray)
                            Spacer()
                            Text("\(viewModel.meaningCount)/\(viewModel.maxWordMeaning)")
                                .font(.footnote)
                                .padding(.trailing)
                                .foregroundStyle(field == .word ? Color.systemBlack : Color.gray)
                            
                        }
                        WMTextField(placeHolder: "단어를 입력해주세요.", text: $viewModel.meaning)
                            .focused($field, equals: .meaning)
                            .onChange(of: viewModel.meaning, { oldValue, newValue in
                                if newValue.count > viewModel.maxWordMeaning {
                                    viewModel.meaning = oldValue
                                    viewModel.meaningCount = oldValue.count
                                } else {
                                    viewModel.meaningCount = newValue.count
                                }
                            })
                    }
                    .padding(.bottom, 10)
                    
                    
                    EditSelectExpandableTagView(viewModel: viewModel.editTagViewModel)
                    //                    .frame(height:150)
                        .padding([.leading, .trailing])
                }
                .scrollBounceBehavior(.basedOnSize)
                ConfirmButton(viewModel: viewModel)
            }
            .padding()
            .task {
                
                field = .word
                do {
                    try await viewModel.fetchWord()
                } catch {
                    
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    HStack {
                        Spacer()   
                        Button("확인") {
                            field = field?.nextField
                        }
                    }
                }
            }
            .onTapGesture {
                field = nil
            }
        }
}

private struct ConfirmButton: View {
    @ObservedObject var viewModel: EditViewModel
    @Environment(\.dismiss) var dismiss
    @State var needAlert: Bool = false
    @State var errorMessage: String = ""
    
    init(viewModel: EditViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Button {
            print("수정")
            Task {
                do {
                    try viewModel.checkRequiredWord()
                    try await viewModel.save()
                    dismiss()
                } catch {
                    needAlert = true
                    errorMessage = error.localizedDescription
                }
            }
            
        } label: {
            Text("확인")
        }
        .frame(height: 50)
        .buttonStyle(WMButtonStyle())
        .alert(LocalizedStringKey(errorMessage),
               isPresented: $needAlert,
               presenting: errorMessage) { errorMessage in
            
        } message: { errorMessage in
//            Text("\(errorMessage)")
        }
        .focusable(interactions: .activate)
    }
}




#Preview {
    EditView(diContainer: MainHomeMockDIContainer(), wordIdentity: "be used to")
}
