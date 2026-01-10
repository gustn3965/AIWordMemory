//
//  TESTResetGPTChancesView.swift
//  Settings
//
//  Created by 박현수 on 1/10/25.
//

import Foundation
import SwiftUI

struct TESTResetGPTChancesView: View {
    
    var diContainer: SettingsDependencyInjection
    var menu: SettingMenuList
    @State var resultString: String = "초기화중"
    
    init(diContainer: SettingsDependencyInjection, menu: SettingMenuList) {
        self.diContainer = diContainer
        self.menu = menu
    }
    var body: some View {
        VStack {
            Text(menu.name)
                .font(.body)

            Text("\(resultString)")
                .font(.headline)
        }
        .task {
            do {
                var account = try await diContainer.makeAccountImplementation().account()
                account.chatGPTChances = 0
                account.ttsChances = 0
                try await diContainer.makeAccountImplementation().updateAccount(account)
                resultString = "0으로 초기화완료."
            } catch {
                
            }
        }
    }
    
}

#Preview {
    TESTResetGPTChancesView(diContainer: SettingsMockDIContainer(), menu: .cbtResetGPTChances)
}
