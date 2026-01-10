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
        ScrollView {
            VStack(spacing: 16) {
                wordSection
                meaningSection
                EditSelectExpandableTagView(viewModel: viewModel.editTagViewModel)
            }
            .padding(.horizontal, 16)
            .padding(.top, 26)
            .padding(.bottom, 80)
        }
        .safeAreaInset(edge: .bottom) {
            ConfirmButton(viewModel: viewModel)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
        }
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

    // MARK: - Subviews
    private var wordSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("단어")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.primary)
                Spacer()
                Text("\(viewModel.wordCount)/\(viewModel.maxWordCount)")
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
            }

            TextField("단어를 입력해주세요.", text: $viewModel.word)
                .padding(14)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .focused($field, equals: .word)
                .onSubmit { field = .meaning }
                .onChange(of: viewModel.word) { oldValue, newValue in
                    if newValue.count > viewModel.maxWordCount {
                        viewModel.word = oldValue
                        viewModel.wordCount = oldValue.count
                    } else {
                        viewModel.wordCount = newValue.count
                    }
                }
        }
    }

    private var meaningSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("뜻")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.primary)
                Spacer()
                Text("\(viewModel.meaningCount)/\(viewModel.maxWordMeaning)")
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
            }

            TextField("뜻을 입력해주세요.", text: $viewModel.meaning)
                .padding(14)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .focused($field, equals: .meaning)
                .onChange(of: viewModel.meaning) { oldValue, newValue in
                    if newValue.count > viewModel.maxWordMeaning {
                        viewModel.meaning = oldValue
                        viewModel.meaningCount = oldValue.count
                    } else {
                        viewModel.meaningCount = newValue.count
                    }
                }
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
            Text("저장")
                .font(.headline)
                .foregroundStyle(Color.systemWhite)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.systemBlack)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .alert(LocalizedStringKey(errorMessage),
               isPresented: $needAlert,
               presenting: errorMessage) { _ in
        } message: { _ in
        }
        .focusable(interactions: .activate)
    }
}




#Preview {
    EditView(diContainer: MainHomeMockDIContainer(), wordIdentity: "be used to")
}
