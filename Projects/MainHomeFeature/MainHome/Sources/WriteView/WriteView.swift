//
//  WriteView.swift
//  MainHome
//
//  Created by 박현수 on 12/26/24.
//

import SwiftUI
import CommonUI


struct WriteView: View {
    // MARK: - Properties
    @StateObject private var viewModel: WriteViewModel
    @FocusState private var field: Field?
    
    // MARK: - UI State
    @AppStorage("showOnBoardingWrite") private var showOnboarding = true
    @State private var onboardingHintType: OnboardingHintType? = .word
    
    // MARK: - Layout
    @State private var offsets = OffsetValues()
    
    // MARK: - Initialization
    init(diContainer: MainHomeDependencyInjection) {
        _viewModel = StateObject(wrappedValue: WriteViewModel(dbService: diContainer.makeDBImplementation(),
                                                              maxWordCount: diContainer.maxWordLength(),
                                                              maxWordMeaning: diContainer.maxMeaningLength()))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    ScrollView {
                        VStack(alignment: .leading) {
                            wordSection
                            meaningSection
                            tagSection
                        }
                        .padding(.top, 10)
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    
                    confirmButton
                }
                .coordinateSpace(name: "VStack")
                .padding()
                .task(onTask)
                .toolbar { keyboardToolbar }
                .onTapGesture { field = nil }
                //                }
                .allowsHitTesting(!showOnboarding)
                
                if showOnboarding {
                    tooltipOverlay(geometry: geometry)
                }
            }
        }
    }
    
    // MARK: - Subviews
    private var wordSection: some View {
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
                .background(offsetReader(for: \.word))
                .focused($field, equals: .word)
                .onChange(of: viewModel.word) { oldValue, newValue in
                    updateWordCount(oldValue: oldValue, newValue: newValue)
                }
                .onSubmit { field = .meaning }
        }
        .padding(.bottom, 10)
    }
    
    private var meaningSection: some View {
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
                    .foregroundStyle(field == .meaning ? Color.systemBlack : Color.gray)
            }
            WMTextField(placeHolder: "뜻을 입력해주세요.", text: $viewModel.meaning)
                .background(offsetReader(for: \.meaning))
                .focused($field, equals: .meaning)
                .onChange(of: viewModel.meaning) { oldValue, newValue in
                    updateMeaningCount(oldValue: oldValue, newValue: newValue)
                }
        }
        .padding(.bottom, 10)
    }
    
    private var tagSection: some View {
        WriteSelectExpandableTagView(viewModel: viewModel.writeTagViewModel)
            .padding([.leading, .trailing])
            .background(offsetReader(for: \.tag))
    }
    
    private var confirmButton: some View {
        ConfirmButton(viewModel: viewModel)
            .background(offsetReader(for: \.done))
    }
    
    private func tooltipOverlay(geometry: GeometryProxy) -> some View {
        Group {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            WMTooltipView(text: tooltipText, location: .centerBottom) {
                updateHintType()
            }
            .position(x: geometry.size.width / 2, y: tooltipYPosition)
        }
    }
    
    // MARK: - Helper Methods
    private func offsetReader(for keyPath: WritableKeyPath<OffsetValues, CGFloat>) -> some View {
        GeometryReader { geo -> Color in
            DispatchQueue.main.async {
                let offset = geo.frame(in: .named("VStack")).minY
                if offset != offsets[keyPath: keyPath] {
                    offsets[keyPath: keyPath] = offset
                }
            }
            return Color.clear
        }
    }
    
    private func updateWordCount(oldValue: String, newValue: String) {
        if newValue.count > viewModel.maxWordCount {
            viewModel.word = oldValue
            viewModel.wordCount = oldValue.count
        } else {
            viewModel.wordCount = newValue.count
        }
    }
    
    private func updateMeaningCount(oldValue: String, newValue: String) {
        if newValue.count > viewModel.maxWordMeaning {
            viewModel.meaning = oldValue
            viewModel.meaningCount = oldValue.count
        } else {
            viewModel.meaningCount = newValue.count
        }
    }
    
    private func updateHintType() {
        onboardingHintType = onboardingHintType?.nextHintType
        if onboardingHintType == nil {
            showOnboarding = false
            field = .word
        }
    }
    
    private func onTask() async {
        if showOnboarding == false {
            field = .word
        }
    }
    
    // MARK: - Computed Properties
    private var tooltipText: String {
        switch onboardingHintType {
        case .word: return "1. 공부할 단어를 입력합니다"
        case .meaning: return "2. 단어의 뜻을 입력합니다"
        case .tag: return "3. 태그로 분류하여 필터링이 가능합니다"
        case .done: return "4. 저장합니다"
        case .none: return ""
        }
    }
    
    private var tooltipYPosition: CGFloat {
        switch onboardingHintType {
        case .word: return offsets.word
        case .meaning: return offsets.meaning
        case .tag: return offsets.tag
        case .done: return offsets.done
        case .none: return 0
        }
    }
    
    private var keyboardToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            HStack {
                Spacer()
                Button("확인") {
                    field = field?.nextField
                }
            }
        }
    }
}

// MARK: - Supporting Types
extension WriteView {
    enum Field: Hashable {
        case word
        case meaning
        
        var nextField: Field? {
            switch self {
            case .word: return .meaning
            case .meaning: return nil
            }
        }
    }
    
    struct OffsetValues {
        var word: CGFloat = 0
        var meaning: CGFloat = 0
        var tag: CGFloat = 0
        var done: CGFloat = 0
    }
    
    enum OnboardingHintType {
        case word
        case meaning
        case tag
        case done
            
        var nextHintType: OnboardingHintType? {
            switch self {
            case .word:
                return .meaning
            case .meaning:
                return .tag
            case .tag:
                return .done
            case .done:
                return nil
            }
        }
    }
}

struct ViewPositionKey: PreferenceKey {
    nonisolated(unsafe) static var defaultValue: CGRect = .zero
    nonisolated static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}




private struct ConfirmButton: View {
    @ObservedObject var viewModel: WriteViewModel
    @Environment(\.dismiss) var dismiss
    @State var needAlert: Bool = false
    @State var errorMessage: String = ""
    
    init(viewModel: WriteViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Button {
            print("확인")
            save()
            
        } label: {
            Text("확인")
        }
        .frame(height: 50)
        .buttonStyle(WMButtonStyle())
        .alert(LocalizedStringKey(errorMessage), isPresented: $needAlert,
               presenting: errorMessage) { errorMessage in
            
        } message: { errorMessage in
            //            Text("\(errorMessage)")
        }
        .focusable(interactions: .activate)
//        .keyboardShortcut(.return)
//        .keyboardShortcut(.return, modifiers: [])
    }
    
    func save() {
        Task {
            do {
                try viewModel.checkRequiredWord()
                try await viewModel.save()
                dismiss()
            } catch {
                needAlert = true
                errorMessage = error.localizedDescription
                print(errorMessage)
            }
        }
    }
}




#Preview {
    WriteView(diContainer: MainHomeMockDIContainer())
    //    TooltipView(text: "태그를 선택하여 단어를 분류해보세요! 단어를 분류해보세요!") {
    //        hasShownTagViewTooltip = true
    //    }
}
