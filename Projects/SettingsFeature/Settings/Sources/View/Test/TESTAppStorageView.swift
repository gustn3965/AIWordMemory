//
//  TESTAppStorageView.swift
//  Settings
//
//  Created by 박현수 on 1/18/25.
//

import SwiftUI


struct TESTAppStorageView: View {
    
    var diContainer: SettingsDependencyInjection
    var menu: SettingMenuList
    @State var resultString: String = "초기화중"
    
    @AppStorage("showOnBoardingWrite") private var showOnBoardingWrite = true
    @AppStorage("showOnBoardingReview") private var showOnBoardingReview = true
    @AppStorage("showOnBoardingReviewCard") private var showOnBoardingReviewCard = true
    @AppStorage("showOnBoardingSearch") private var showOnBoardingSearch = true
    @AppStorage("showOnBoardingSentenceInspec") private var showOnBoardingSentenceInspec = true
    @AppStorage("aiRecommendInfoOnboarding") private var aiRecommendInfoOnboarding = true
    
    @AppStorage("checkedAppUpdateVersion") private var checkedAppUpdateVersion = ""
    
    
    
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
            showOnBoardingWrite = true
            showOnBoardingReview = true
            showOnBoardingReviewCard = true
            showOnBoardingSearch = true
            showOnBoardingSentenceInspec = true
            aiRecommendInfoOnboarding = true
            checkedAppUpdateVersion = ""
            
            do {
                var account = try await diContainer.makeAccountImplementation().account()
                account.chatGPTChances = 100
                account.ttsChances = 100
                try await diContainer.makeAccountImplementation().updateAccount(account)
            } catch {
                
            }
        }
    }
    
}

#Preview {
    TESTAppStorageView(diContainer: SettingsMockDIContainer(), menu: .cbtResetGPTChances)
}
