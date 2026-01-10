//
//  TESTSpeechChangeView.swift
//  Settings
//
//  Created by 박현수 on 1/4/25.
//

import SwiftUI

struct TESTSpeechChangeView: View {
    
    var diContainer: SettingsDependencyInjection
    var menu: SettingMenuList
    @State var speechModel: String = ""
    
    init(diContainer: SettingsDependencyInjection, menu: SettingMenuList) {
        self.diContainer = diContainer
        self.menu = menu
    }
    var body: some View {
        VStack {
            Text(menu.name)
                .font(.body)
            
            Text(speechModel)
                .font(.headline)
            
            Text("으로 변경됌")
                .font(.body)
        }
        .task {
            speechModel = diContainer.changeSpeechImplementation()
        }
    }
    
}

#Preview {
    TESTSpeechChangeView(diContainer: SettingsMockDIContainer(), menu: .cbtChagneSpeechImplementation)
}
