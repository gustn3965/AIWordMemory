//
//  Banner.swift
//  WordMemoryApp
//
//  Created by 박현수 on 1/10/25.
//

import Foundation
import SwiftUI
import GoogleMobileAds

@MainActor class BannerViewModel: ObservableObject {
    @Published var adLoaded = false
    
    var bannerCoordinator: BannerCoordinator?
    
    func load(adSize: GADAdSize, adUnitID: String) async {
        self.bannerCoordinator = BannerCoordinator(adSize: adSize, viewModel: self, adUnitID: adUnitID)
        print("# \(#file) \(#function) \(adUnitID)")
    }
}

struct BannerView: UIViewRepresentable {
    let adSize: GADAdSize
    
    let bannaerView: GADBannerView
    init(_ adSize: GADAdSize, bannaerView: GADBannerView) {
        self.adSize = adSize
        self.bannaerView = bannaerView
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.addSubview(bannaerView)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        bannaerView.adSize = adSize
    }

}

@MainActor class BannerCoordinator: NSObject, GADBannerViewDelegate {
    private(set) var bannerView: GADBannerView
    
    let adSize: GADAdSize
    weak var viewModel: BannerViewModel?
    
    init(adSize: GADAdSize, viewModel: BannerViewModel?, adUnitID: String) {
        self.adSize = adSize
        self.viewModel = viewModel
        
        let banner = GADBannerView(adSize: adSize)
        bannerView = banner
        
        super.init()
        
        banner.adUnitID = adUnitID
        banner.load(GADRequest())
        banner.delegate = self
    }
    
    
    
    nonisolated func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("bannerViewDidReceiveAd")
        Task {
            await MainActor.run {
                viewModel?.adLoaded = true
            }
        }
    }

    nonisolated func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        Task {
            await MainActor.run {
                viewModel?.adLoaded = false
            }
        }
    }
    
    nonisolated func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
      print("bannerViewDidRecordImpression")
    }

    nonisolated func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillPresentScreen")
    }

    nonisolated func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillDIsmissScreen")
    }

    nonisolated func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewDidDismissScreen")
    }
}
