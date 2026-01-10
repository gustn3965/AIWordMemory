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
                ScrollView {
                    VStack(spacing: 16) {
                        wordSection
                        meaningSection
                        tagSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 26)
                    .padding(.bottom, 80)
                }
                .safeAreaInset(edge: .bottom) {
                    confirmButton
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial)
                }
                .coordinateSpace(name: "VStack")
                .task(onTask)
                .toolbar { keyboardToolbar }
                .onTapGesture { field = nil }
                .allowsHitTesting(!showOnboarding)

                if showOnboarding {
                    tooltipOverlay(geometry: geometry)
                }
            }
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
                .background(offsetReader(for: \.word))
                .focused($field, equals: .word)
                .onChange(of: viewModel.word) { oldValue, newValue in
                    updateWordCount(oldValue: oldValue, newValue: newValue)
                }
                .onSubmit { field = .meaning }
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
                .background(offsetReader(for: \.meaning))
                .focused($field, equals: .meaning)
                .onChange(of: viewModel.meaning) { oldValue, newValue in
                    updateMeaningCount(oldValue: oldValue, newValue: newValue)
                }
        }
    }

    private var tagSection: some View {
        WriteSelectExpandableTagView(viewModel: viewModel.writeTagViewModel)
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
                .onTapGesture {
                    withAnimation {
                        updateHintType()
                    }
                }
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
            save()
        } label: {
            Text("저장")
                .font(.headline)
                .foregroundStyle(Color.systemWhite)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
//                .background(Color.systemBlack)
//                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .alert(LocalizedStringKey(errorMessage), isPresented: $needAlert,
               presenting: errorMessage) { _ in
        } message: { _ in
        }
        .focusable(interactions: .activate)
        .versioned { view in
            if #available(iOS 26.0, *) {
                view.glassEffect(.regular.tint(Color.systemBlack))
            } else {
                view
            }
        }
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
