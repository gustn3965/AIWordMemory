//
//  Reward.swift
//  WordMemoryApp
//
//  Created by 박현수 on 1/10/25.
//

import Foundation
@preconcurrency import GoogleMobileAds



@MainActor class RewardedViewModel: NSObject, ObservableObject,
                                         GADFullScreenContentDelegate {
    @Published var coins = 0
    var rewardedAd: GADRewardedAd?
    @Published var isLoading: Bool = false
    
    func loadAd(adUnitID: String) async throws {
        do {
        print("# \(#file) \(#function)")
            isLoading = true
            rewardedAd = try await GADRewardedAd.load(
                withAdUnitID: adUnitID, request: GADRequest())
            
            rewardedAd?.fullScreenContentDelegate = self
            isLoading = false
        } catch {
            isLoading = false
            print("# didFailToReceiveAdWithError \(#file) \(#function) \(error.localizedDescription) ")
            throw error
        }
        
        
    }
    nonisolated func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
        Task {
            await MainActor.run {
                isLoading = false
            }
        }
    }
    
    nonisolated func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
    }
    
    nonisolated func ad(
        _ ad: GADFullScreenPresentingAd,
        didFailToPresentFullScreenContentWithError error: Error
    ) {
        print("\(#function) called")
        Task {
            await MainActor.run {
                rewardedAd = nil
                isLoading = false
            }
        }
    }
    
    nonisolated func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
    }
    
    nonisolated func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
    }
    
    nonisolated func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
        // Clear the rewarded ad.
        Task {
            await MainActor.run {
                isLoading = false
                rewardedAd = nil
            }
        }
        
    }
}
