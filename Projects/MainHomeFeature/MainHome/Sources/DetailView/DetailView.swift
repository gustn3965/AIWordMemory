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
    
    @State var isClicked: Bool = false
    @State private var speakingIdentity: String? = nil
    var diContainer: MainHomeDependencyInjection
    init(diContainer: MainHomeDependencyInjection, wordIdentity: String, appCoordinator: AppCoordinator) {
        self.diContainer = diContainer
        _viewModel = StateObject(wrappedValue: DetailViewModel(
            dbService: diContainer.makeDBImplementation(),
            wordIdentity: wordIdentity,
            appleSpeechService: diContainer.makeSpecchAppleVoiceImplementation(),
            speechVoiceService: diContainer.makeSpeechVoiceImplementation()
        ))
        self.appCoordinator = appCoordinator
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 단어 카드
                wordCard

                // 태그 섹션
                if !viewModel.tags.isEmpty {
                    tagsSection
                }

                // AI 문장 섹션
                sentencesSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 100)
        }
        .safeAreaInset(edge: .bottom) {
            actionButton()
        }
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

    // MARK: - Subviews
    private var wordCard: some View {
        VStack(spacing: 12) {
            // 맞춘 횟수
            Text("\(viewModel.correctCount)번 맞춤")
                .font(.caption)
                .foregroundStyle(Color.systemWhite)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.systemBlack)
                .clipShape(Capsule())

            // 단어
            Button {
                Task {
                    try? await viewModel.speechAppleTTS(content: viewModel.word)
                }
            } label: {
                HStack(spacing: 8) {
                    Text(viewModel.word)
                        .font(.largeTitle.bold())
                        .foregroundStyle(Color.primary)
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.title3)
                        .foregroundStyle(Color.systemBlack)
                }
            }

            // 뜻
            Text(viewModel.meaning)
                .font(.title3)
                .foregroundStyle(Color.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "tag.fill")
                    .font(.subheadline)
                    .foregroundStyle(Color.systemBlack)
                Text("태그")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.primary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.subheadline)
                            .foregroundStyle(Color.systemBlack)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.systemBlack.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var sentencesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if viewModel.sentences.isEmpty {
                // 빈 상태
                VStack(spacing: 12) {
                    Image(systemName: "text.bubble")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.secondary)

                    Text("생성된 문장이 없습니다")
                        .font(.headline)
                        .foregroundStyle(Color.primary)

                    Text("리뷰를 하시면 AI가 생성해줘요")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)

                    Button {
                        appCoordinator.showReviewTab = true
                    } label: {
                        Label("리뷰하러 가기", systemImage: "arrow.right.circle.fill")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.systemWhite)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.systemBlack)
                            .clipShape(Capsule())
                    }
                    .padding(.top, 4)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                // 헤더
                HStack(spacing: 8) {
                    Image("ph_open-ai-logo-light", bundle: CommonUIResources.bundle)
                        .resizable()
                        .frame(width: 20, height: 20)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("AI 문장 학습")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.primary)
                        Text("예문을 터치하면 읽어줍니다")
                            .font(.caption2)
                            .foregroundStyle(Color.secondary)
                    }
                    Spacer()
                }

                // 문장 목록
                ForEach(viewModel.sentences) { sentence in
                    SentenceCard(
                        sentence: sentence,
                        isSpeaking: speakingIdentity == sentence.exampleIdentity,
                        onSpeak: {
                            speakingIdentity = sentence.exampleIdentity
                            defer { speakingIdentity = nil }
                            try await viewModel.speechTTS(content: sentence.example, identity: sentence.exampleIdentity)
                        }
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    @Namespace var namespace
    @ViewBuilder
    func actionButton() -> some View {
        if #available(iOS 26.0, *) {
            HStack {
                Spacer()
                GlassEffectContainer {
                    VStack(spacing: 12) {
                        if isClicked {
                            // 삭제 버튼
                            Button {
                                viewModel.deleteAlert.toggle()
                            } label: {
                                Image(systemName: "trash.circle.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundStyle(.red)
                            }
                            .buttonStyle(.glass)
                            .glassEffectID("editButton1", in: namespace)
                            
                            // 수정 버튼
                            Button {
                                viewModel.editSheet.toggle()
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "pencil.circle.fill")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                }
                                .font(.headline)
                                .foregroundStyle(Color.systemBlack)
                                .frame(width: 40, height: 40)
                            }
//                            .buttonStyle(.glass)
                            .buttonStyle(.glass)
                            .glassEffectID("editButton2", in: namespace)
                        }
                        
                        // 수정 버튼
                        
                        Button {
                            withAnimation {
                                isClicked.toggle()
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: isClicked ? "xmark.circle.fill" : "ellipsis.circle.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                            }
                            .font(.headline)
                            .foregroundStyle(Color.systemBlack)
                        }
                        .buttonStyle(.glass)
                        .glassEffectID("editButton", in: namespace)
                        .glassEffectTransition(.matchedGeometry)

                        
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
//            .background(.ultraThinMaterial)
        } else {
            // Fallback on earlier versions
            HStack(spacing: 12) {
                // 삭제 버튼
                Button {
                    viewModel.deleteAlert.toggle()
                } label: {
                    Image(systemName: "trash")
                        .font(.title3)
                        .foregroundStyle(.red)
                        .frame(width: 50, height: 50)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .versioned { view in
                    if #available(iOS 26.0, *) {
                        view.glassEffect()
                    } else {
                        view
                    }
                }
                
                // 수정 버튼
                Button {
                    viewModel.editSheet.toggle()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "pencil")
                        Text("수정")
                    }
                    .font(.headline)
                    .foregroundStyle(Color.systemWhite)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    //                .background(Color.systemBlack)
                    //                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .versioned { view in
                    if #available(iOS 26.0, *) {
                        view.glassEffect(.regular.tint(Color.systemBlack))
                    } else {
                        view
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
                    
        }
        
    }
}

// MARK: - Sentence Card
private struct SentenceCard: View {
    let sentence: DetailViewModel.Sentence
    let isSpeaking: Bool
    let onSpeak: () async throws -> Void

    @State private var speakError: Error? = nil

    var body: some View {
        Button {
            Task {
                do {
                    try await onSpeak()
                    speakError = nil
                } catch {
                    speakError = error
                }
            }
        } label: {
            HStack(alignment: .top, spacing: 10) {
                // 스피커 아이콘
                ZStack {
                    Circle()
                        .fill(isSpeaking ? Color.systemBlack : Color.systemBlack.opacity(0.1))
                        .frame(width: 28, height: 28)

                    if isSpeaking {
                        Image(systemName: "waveform")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.systemWhite)
                    } else {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Color.systemBlack)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: isSpeaking)

                VStack(alignment: .leading, spacing: 4) {
                    Text(sentence.example)
                        .font(.body.weight(.medium))
                        .foregroundStyle(Color.primary)
                        .multilineTextAlignment(.leading)
                    Text(sentence.translation)
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                        .multilineTextAlignment(.leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color(.tertiarySystemFill))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
        .overlay {
            if speakError != nil {
                ToastView(message: speakError?.localizedDescription ?? "")
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                speakError = nil
                            }
                        }
                    }
            }
        }
        .animation(.easeInOut, value: speakError != nil)
    }
}

// MARK: - Toast View
private struct ToastView: View {
    let message: String

    var body: some View {
        Text(LocalizedStringKey(message))
            .font(.caption)
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.85))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
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
