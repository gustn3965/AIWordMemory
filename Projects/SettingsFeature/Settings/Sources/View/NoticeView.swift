//
//  NoticeView.swift
//  Settings
//
//  Created by 박현수 on 1/6/25.
//

import SwiftUI


struct NoticeView: View {
    @State var isLoading: Bool = true
    var menu: SettingMenuList
    
    var isKorean: Bool {
        let languageCode = Locale.current.language.languageCode?.identifier
        return languageCode == "ko"
    }
    
    var body: some View {
        ZStack {
            WebView(urlString: isKorean ? "https://gustn3965.github.io/WordMemoryNotice/" : "https://gustn3965.github.io/WordMemoryNotice/en", isLoading: $isLoading)
            
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
        NoticeView(menu: .notice)
    }
}
