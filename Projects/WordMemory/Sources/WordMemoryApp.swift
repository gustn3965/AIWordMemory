//
//  SampleApp.swift
//  Manifests
//
//  Created by 박현수 on 12/22/24.
//

import SwiftUI

import MainHome
import Review
import Search
import SentenceInspector
import Recommend
import Settings

import CommonUI
import AppCoordinatorService
import GoogleMobileAds

import StoreKitService
import StoreKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        GADMobileAds.sharedInstance().start { status in
            print(status)
            print()
        }
        
        return true
    }
}


@main
struct WordMemoryApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject var diContainer: WordMemoryDIContainer = WordMemoryDIContainer.create()
    @StateObject var appCoordinator: AppCoordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            ContentView(diContainer: diContainer,
                        appCoordinator: appCoordinator,
                        serverStatus: diContainer.serverStatus,
                        storeKit: diContainer.storeKit,
                        admobID: $diContainer.serverStatus.admobBannerId
                        )
            
        }
    }
}




struct ContentView: View {
    // MARK: - Types
    enum MainAppTab: Hashable {
        case main, review, search, recommend, setting
    }
    
    // MARK: - Properties
    @ObservedObject var diContainer: WordMemoryDIContainer
    @ObservedObject var appCoordinator: AppCoordinator
    @ObservedObject var serverStatus: ServerStatus
    @ObservedObject var storeKit: StoreKitManager
    
    @StateObject private var rewardViewModel = RewardedViewModel()
    @StateObject private var bannerViewModel = BannerViewModel()
    
    @State private var selectedTab: MainAppTab = .main
    @State private var errorMessage: String = ""
    @State private var needRewardError: Bool = false
    @State private var successPurchaseAlert: Bool = false
    @State private var needUpdateAppAlert: Bool = false
    
    @Binding var admobID: String
    
    @AppStorage("checkedAppUpdateVersion") var checkedAppUpdateVersion: String = ""
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            let adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(geometry.size.width)
            
            ZStack {
                
                tabView(adSize: adSize)

                if rewardViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                }
            }
            .onChange(of: appCoordinator.showReviewTab, { _, newValue in handleShowReviewTab(newValue) })
            .onChange(of: serverStatus.admobBannerId, { _, newValue in loadBanner(adSize: adSize, id: newValue) })
            .onChange(of: appCoordinator.showRewordAd, { _, newValue in  handleShowRewardAd(newValue) })
            .onChange(of: storeKit.purchasedProducts, { _, newValue in handlePurchasedProducts(newValue) })
            .onChange(of: serverStatus.needUpdateApp, { _, _ in handleAppUpdate()})
            .alert(LocalizedStringKey(errorMessage), isPresented: $needRewardError, presenting: errorMessage) { _ in }
            .alert(LocalizedStringKey("구매완료!"), isPresented: $successPurchaseAlert, presenting: "") { _ in }
            .alert(LocalizedStringKey("업데이트 안내"), isPresented: $needUpdateAppAlert, presenting: "") { _ in
                goToAppstoreButton()
            } message: { _ in Text(serverStatus.needUpdateApp) }
        }
    }
    
    // MARK: - Views
    private func tabView(adSize: GADAdSize) -> some View {
        Group {
            if #available(iOS 18.0, *) {
                TabView(selection: $selectedTab) {
                    Tab("홈", image: "ph_list-fill", value: .main) {
                        mainTab(adSize: adSize)
                    }
                    Tab("리뷰", image: "material-symbols_rate-review-rounded", value: .review) {
                        reviewTab()
                    }
                    Tab("AI검색", image: "mingcute_search-ai-fill-light", value: .search) {
                        searchTab
                    }
                    Tab("AI단어추천", image: "bxs_collection-light", value: .recommend) {
                        recommendWordTab
                    }
                    Tab("설정", systemImage: "gearshape.fill", value: .setting) {
                        settingsTab()
                    }
//                    searchWordTab()
//                    searchSentenceInspectorTab()x
                }
                .tabViewStyle(.sidebarAdaptable)
                .tint(Color.gray)
                .edgesIgnoringSafeArea(.all)
            } else {
                TabView(selection: $selectedTab) {
                    mainTab(adSize: adSize)
                        .tabItem {
                            VStack {
                                Image("ph_list-fill", bundle: CommonUIResources.bundle)
                                    .foregroundColor(selectedTab == .main ? .blue : .gray)
                                Text("홈")
                                    .foregroundColor(selectedTab == .main ? .blue : .gray)
                            }
                        }
                    reviewTab()
                        .tabItem {
                            VStack {
                                Image("material-symbols_rate-review-rounded", bundle: CommonUIResources.bundle)
                                Text("리뷰")
                            }
                        }
                    searchTab
                        .tabItem {
                            VStack {
                                Image("mingcute_search-ai-fill-light", bundle: CommonUIResources.bundle)
                                Text("AI검색")
                            }
                        }
                    recommendWordTab
                        .tabItem {
                            VStack {
                                Image("bxs_collection-light", bundle: CommonUIResources.bundle)
                                Text("AI단어추천")
                            }
                        }
                    settingsTab()
                        .tabItem {
                            Label("설정", systemImage: "gearshape")
                        }
                }
                .tint(.systemBlack)
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
    
    private func mainTab(adSize: GADAdSize) -> some View {
        VStack {
            MainHomeContentView(diContainer: diContainer, appCoordinator: appCoordinator)
            
            if let bannerView = bannerViewModel.bannerCoordinator?.bannerView, bannerViewModel.adLoaded {
                BannerView(adSize, bannaerView: bannerView)
                    .frame(height: adSize.size.height)
            }
        }
        .tag(MainAppTab.main)
    }
    
    private func reviewTab() -> some View {
        ReviewContentView(diContainer: diContainer, appCoordinator: appCoordinator)
            .tag(MainAppTab.review)
    }
    
    @State var searchType: SearchType = .word
    private var searchTab: some View {
        VStack(spacing: 0) {
            // 세그먼트 탭바
            HStack(spacing: 4) {
                ForEach(SearchType.allCases) { type in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            searchType = type
                        }
                    } label: {
                        Text(LocalizedStringKey(type.name))
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(searchType == type ? Color.systemWhite : Color.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                searchType == type
                                    ? Color.systemBlack
                                    : Color.clear
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(4)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .background(Color(.systemGroupedBackground))

            // 콘텐츠
            ZStack {
                searchWordTab
                    .id("searchWordTab")
                    .opacity(searchType == .word ? 1 : 0)
                searchSentenceInspectorTab
                    .id("searchSentenceTab")
                    .opacity(searchType == .word ? 0 : 1)
            }
        }
        .background(Color(.systemGroupedBackground))
        .tag(MainAppTab.search)
    }
    
    private var searchWordTab: some View {
        SearchContentView(diContainer: diContainer, appCoordinator: appCoordinator)
    }
    
    
    private var searchSentenceInspectorTab: some View {
        SentenceInspectorContentView(diContainer: diContainer, appCoordinator: appCoordinator)

    }
    
    
    private var recommendWordTab: some View {
        RecommendContentView(diContainer: diContainer, appCoordinator: appCoordinator)
            .tag(MainAppTab.recommend)
            
    }
    
    private func settingsTab() -> some View {
        SettingsContentView(diContainer: diContainer, appCoordinator: appCoordinator)
            .tag(MainAppTab.setting)
    }
    
    private func goToAppstoreButton() -> some View {
        return Button {
            AppCoordinator.showAppStore()
        } label: {
            Text("앱스토어 바로가기")
        }
    }
    
    // MARK: - Methods
    private func handleShowReviewTab(_ newValue: Bool) {
        if newValue {
            selectedTab = .review
            appCoordinator.showReviewTab = false
        }
    }
    
    private func loadBanner(adSize: GADAdSize, id: String) {
        Task {
            await bannerViewModel.load(adSize: adSize, adUnitID: id)
        }
    }
    
    private func handleShowRewardAd(_ newValue: Bool) {
        guard newValue else { return }
        
        Task {
            do {
                try await rewardViewModel.loadAd(adUnitID: serverStatus.admobRewardID)
                rewardViewModel.rewardedAd?.present(fromRootViewController: nil) {
                    let reward = rewardViewModel.rewardedAd?.adReward.amount.intValue ?? 1
                    updateAccountAfterReward(reward: reward)
                }
            } catch {
                needRewardError = true
                errorMessage = "광고를 불러오는데 실패했습니다."
            }
            appCoordinator.showRewordAd = false
        }
    }
    
    private func updateAccountAfterReward(reward: Int) {
        Task {
            var account = try await diContainer.makeAccountImplementation().account()
            account.chatGPTChances += diContainer.rewardChatGPTChances() * reward
            account.ttsChances += diContainer.rewardTTSChances() * reward
            try await diContainer.makeAccountImplementation().updateAccount(account)
        }
    }
    
    private func handlePurchasedProducts(_ newValue: [Product]) {
        Task {
            var account = try await diContainer.accountService.account()
            account.chatGPTChances += diContainer.storeKit.purchaseChatGPTChances
            account.ttsChances += diContainer.storeKit.purchaseTTSChances
            try await diContainer.accountService.updateAccount(account)
            successPurchaseAlert.toggle()
        }
    }
    
    private func handleAppUpdate() {
        Task {
            try await Task.sleep(nanoseconds: 1_500_000_000)
            
            // 이미 업데이트해야하는 상황이고, 얼럿을 이미 한번 본건지.
            if let currentAppVersion = Bundle.main.releaseVersionNumber {
                if currentAppVersion.compareVersion(to: checkedAppUpdateVersion) == .orderedDescending {
                    checkedAppUpdateVersion = currentAppVersion
                    needUpdateAppAlert.toggle()
                }
            }
        }
    }
    
    
    enum SearchType: Int, Identifiable, CaseIterable {
        var id: String { return String(rawValue)}
        case word
        case sentence
        
        var name: String {
            switch self {
            case .word:
                return "단어검색"
            case .sentence:
                return "문장검사"
            }
        }
    }
}


struct ContentView_Preview: PreviewProvider {
    
    static var previews: some View {
        ContentView(diContainer: WordMemoryDIContainer.create(),
                    appCoordinator: AppCoordinator(),
                    serverStatus: ServerStatus(),
                    storeKit: StoreKitManager(purcahaseChatGPTChances: 100, purchaseTTSChances: 00),
                    admobID: .constant("")
                    )
    }
}

