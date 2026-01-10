
import Foundation
import UIKit


@MainActor public class AppCoordinator: ObservableObject {
    
    public init() {}
    
    @Published public var showWriteView = false
    @Published public var showReviewTab = false
    @Published public var showRewordAd = false
    
    static public func showAppStore() {
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id6740163477") {
            UIApplication.shared.open(url)
        }
    }
}
