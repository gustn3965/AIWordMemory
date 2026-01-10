//
//  FeedbackView.swift
//  Settings
//
//  Created by 박현수 on 1/6/25.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let urlString: String
    @Binding var isLoading: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
//        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//            parent.isLoading = true
//        }
//        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }
    }
}

struct FeedbackView: View {
    @State var isLoading: Bool = true
    var menu: SettingMenuList
    
    var isKorean: Bool {
        let languageCode = Locale.current.language.languageCode?.identifier
        return languageCode == "ko"
    }
    
    var body: some View {
        ZStack {
            WebView(urlString: isKorean ? "https://docs.google.com/forms/d/e/1FAIpQLScTvSnChhqMHmP7R1DHNCibE5fU0yAz2kgy_a2CRzp5Ma5K8A/viewform?usp=header"
                    : "https://docs.google.com/forms/d/e/1FAIpQLScTvSnChhqMHmP7R1DHNCibE5fU0yAz2kgy_a2CRzp5Ma5K8A/viewform?usp=header&hl=en"
                    , isLoading: $isLoading)
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
            }
        }
        .navigationTitle(LocalizedStringKey(menu.name))
    }
}

#Preview {
    NavigationStack {
        FeedbackView(menu: .feedback)
    }
}
