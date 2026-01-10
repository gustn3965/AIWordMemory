//
//  WMTextField.swift
//  CommonUI
//
//  Created by 박현수 on 12/26/24.
//

import SwiftUI

public struct WMTextField: View {
    
    @Binding var text: String
    
    private var placeholder: String
    @FocusState private var focused: Bool
    
    public init(placeHolder: String = "입력해주세요", text: Binding<String>) {
        self.placeholder = placeHolder
        _text = text
    }
    
    public var body: some View {
        
        
        TextField(LocalizedStringKey(placeholder), text: $text)
            .padding()
            .background(Color.systemWhite)
            .overlay {
                if focused {
                    
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(lineWidth: 2)
                        .foregroundStyle(Color.shadow)
//                        .northWestShadow(radius: 3, offset: 2)
                        
                } else {
//                    RoundedRectangle(cornerRadius: 8)
//                        .stroke(lineWidth: 2)
//                        .foregroundStyle(Color.element)
//                        .northWestShadow(radius: 3, offset: 2)
                }
            }
            .focused($focused)
            .cornerRadius(8)
            .northWestShadow(radius: 3, offset: 2)
            .padding([.leading, .trailing])
    }
    
    
}

//#Preview {
//    ZStack {
//        Color.gray
//        List {
//            WMTextField(text: .constant(""))
//        }
//        .listStyle(.plain)
//    }
//}


class YourViewModel: ObservableObject {
    @Published var isLoading: Bool = false
}

struct AnimatedButtonView: View {
    @StateObject var viewModel = YourViewModel()
    @State private var speekError: Error?
    @State private var animateOverlay = false
    @State private var overlayOffset: CGFloat = 0 // 초기 오프셋을 화면 안쪽으로 조정

    var example: String = "안녕하세요 안녕하세요" // 예제 데이터

    var body: some View {
        Button {
            // 애니메이션 시작
            withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                animateOverlay = true
                overlayOffset = UIScreen.main.bounds.width // 오른쪽 끝으로 이동
            }

            Task {
                do {
                    try await Task.sleep(nanoseconds: 2_000_000_000)
                    print("작업 완료")
                    speekError = nil
                } catch {
                    speekError = error
                    viewModel.isLoading = false
                }

                // Task 완료 후 애니메이션 중지
                withAnimation {
                    animateOverlay = false
                    overlayOffset = 0 // 초기 위치로 복원
                }
            }
        } label: {
            ZStack(alignment: .leading) {
                
                
                Label {
                    Text(example)
                } icon: {
                    Image("ri_voice-ai-light", bundle: CommonUIResources.bundle)
                        .resizable()
                        .frame(width: 17, height: 17)
                }
                .overlay(
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(Color.red)
                            .frame(width: geometry.size.width)
                            .offset(x: -geometry.size.width + overlayOffset)
                    }
                        .mask(
                            Label {
                                Text(example)
                            } icon: {
                                Image("ri_voice-ai-light", bundle: CommonUIResources.bundle)
                                    .resizable()
                                    .frame(width: 17, height: 17)
                            }
                        )
                )
            }
        }
        .disabled(viewModel.isLoading) // Task 실행 중 버튼 비활성화
    }
}


struct AnimatedButtonView_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedButtonView()
    }
}





//struct AnimatedButtonView: View {
//    @StateObject var viewModel = YourViewModel()
//    @State private var speekError: Error?
//    @State private var animateOverlay = false
//    
//    var example: ExampleType // 예제 데이터 타입에 맞게 변경하세요
//    
//    var body: some View {
//        Button(action: {
//            startAnimation()
//            performTask()
//        }) {
//            ZStack {
//                Label {
//                    Text(example.example)
//                        .foregroundColor(.black) // 기본 텍스트 색상
//                } icon: {
//                    Image("ri_voice-ai-light", bundle: CommonUIResources.bundle)
//                        .resizable()
//                        .frame(width: 17, height: 17)
//                }
//                
//                // 애니메이션 오버레이
//                if animateOverlay {
//                    let _ = print("??????????")
//                    GeometryReader { geometry in
//                        LinearGradient(gradient: Gradient(colors: [Color.red.opacity(0.5), Color.red.opacity(0.6), Color.red.opacity(0.5)]),
//                                       startPoint: .leading,
//                                       endPoint: .trailing)
//                            .frame(width: geometry.size.width * 0.3, height: geometry.size.height)
//                            .offset(x: 0)
//                            .animation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false), value: animateOverlay)
//                    }
//                    .mask(
//                        Text(example.example)
//                            .foregroundColor(.black)
//                    )
//                }
//            }
//        }
//        .disabled(viewModel.isLoading) // Task 실행 중 버튼 비활성화
//    }
//    
//    private func startAnimation() {
//        animateOverlay = true
//    }
//    
//    private func performTask() {
//        Task {
//            do {
//                try await Task.sleep(nanoseconds: 2_000_000_000)
////                try await viewModel.speek(string: NSAttributedString(string: example.example).string,
////                                          identity: example.exampleIdentity)
//                
//                speekError = nil
//            } catch {
//                speekError = error
//                viewModel.isLoading = false
//            }
//            
//            // Task 완료 후 애니메이션 중지
//            withAnimation {
//                animateOverlay = false
//            }
//        }
//    }
//}
//
//struct AnimatedButtonView_Previews: PreviewProvider {
//    static var previews: some View {
//        AnimatedButtonView(example: ExampleType.example)
//    }
//}
//
//// ExampleType 및 YourViewModel은 실제 사용 중인 타입으로 대체하세요.
//struct ExampleType {
//    var example: String
//    var exampleIdentity: String
//
//    static let example = ExampleType(example: "예제 텍스트", exampleIdentity: "identity")
//}
//
//class YourViewModel: ObservableObject {
//    @Published var isLoading: Bool = false
//
//    
//}
