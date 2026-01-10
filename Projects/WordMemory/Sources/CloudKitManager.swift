//
//  CloudKitManager.swift
//  WordMemoryApp
//
//  Created by 박현수 on 1/4/25.
//

import Foundation

import CloudKit

struct CloudKitResponse: Sendable {
    var chatGPTModel: String
    var openAIKey: String
    var ttsModel: String
    var maxResponseToken: Int
    var availableServer: Int
    var admobBannerID: String
    var admobRewardID: String
    var admobRewardAvailable: Int
    
    var updateAppDescriptionKR: String
    var updateAppDescriptionEN: String
}

class CloudKitManager {
    
    private let container: CKContainer
    private let publicDatabase: CKDatabase
    
    init() {
        container = CKContainer(identifier: "iCloud.aiWordMemory")
        publicDatabase = container.publicCloudDatabase
    }
    
    func fetchAPIKey() async throws -> CloudKitResponse {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "APIKey", predicate: predicate)
        
        let (matchResults, _) = try await publicDatabase.records(matching: query)
        
        print("# \(#file) \(#function)")
        
        var response: CloudKitResponse?
        for result in matchResults {
            switch result.1 {
            case .success(let record):
                print(record)
                let valid = record["valid"] as? Int ?? 0
                if valid == 1 {
                    guard let gptmodel = record["model"] as? String,
                          let gptkey = record["key"] as? String,
                          let maxResponse = record["maxresponse"] as? Int,
                          let ttsModel = record["ttsmodel"] as? String,
                          let availableServer = record["availableserver"] as? Int,
                          let admobbanner = record["admobbanner"] as? String,
                          let admobreward = record["admobreward"] as? String,
                          let admobRewardAvailable = record["admobRewardAvailable"] as? Int, // 1.0.0 ~ 1.2.0
                          let updateAppDescriptionKR = record["updateAppDescriptionKR"] as? String,
                          let updateAppDescriptionEN = record["updateAppDescriptionEN"] as? String // 1.2.5
                    else  {
                        continue
                    }
                    
                    response = CloudKitResponse(chatGPTModel: gptmodel, openAIKey: gptkey, ttsModel: ttsModel, maxResponseToken: maxResponse, availableServer: availableServer, admobBannerID: admobbanner, admobRewardID: admobreward, admobRewardAvailable: admobRewardAvailable, updateAppDescriptionKR: updateAppDescriptionKR, updateAppDescriptionEN: updateAppDescriptionEN)
                }
                
            case .failure(let error):
                print(error)
            }
        }
        guard let response = response else {
            throw NSError(domain: "APIKeyError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid API key data"])
        }
        
        print("👍👍👍 CloudKit success!👍👍👍 \(response)")
        return response
    }
    
    
    func isNeedUpdateApp() async -> (needUpdate: Bool, updateVersion: String) {
        do  {
            let currentVersion = Bundle.main.releaseVersionNumber ?? ""
            let appstoreVersion = try await fetchLatestAppVersion()
            
            let result = appstoreVersion.compareVersion(to: currentVersion)
            if result == .orderedDescending {
                return (true, appstoreVersion)
            } else {
                return (false, appstoreVersion)
            }
            
        } catch {
            return (false, "")
        }
    }
    
    func fetchLatestAppVersion() async throws -> String {
        
        var bundleId = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String
        
        #if DEBUG
        bundleId = "com.hyunsu.WordMemoryApp"
        #endif
        if let bundleId = bundleId {
            let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleId)")!
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let results = json["results"] as? [[String: Any]],
               let firstResult = results.first,
               let version = firstResult["version"] as? String {
                return version
            }
            
            throw NSError(domain: "AppVersionError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch app version"])
        } else {
            throw NSError(domain: "AppVersionError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch app version"])
        }
        
    }
    
    
}


extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}

extension String {
    func compareVersion(to otherVersion: String) -> ComparisonResult {
        return self.compare(otherVersion, options: .numeric)
    }
}
