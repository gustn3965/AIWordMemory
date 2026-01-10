//
//  SpeechCacheManager.swift
//  SpeechVoiceImplementation
//
//  Created by 박현수 on 1/3/25.
//

import Foundation

final class SpeechCacheManager {
    
    // 캐시 디렉토리 경로
    private let cacheDirectory: URL
    
    // 초기화 메서드
    init() {
        print("# \(#file) \(#function)")
        // 사용자의 캐시 디렉토리를 가져옵니다.
        if let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            cacheDirectory = cacheDir.appendingPathComponent("SpeechCache", isDirectory: true)
        } else {
            // 기본 캐시 디렉토리가 없을 경우, 문서 디렉토리를 사용합니다.
            cacheDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("SpeechCache", isDirectory: true)
        }
        
        // 캐시 디렉토리가 존재하지 않으면 생성
        if !FileManager.default.fileExists(atPath: cacheDirectory.path) {
            do {
                try FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
                
                
                print("#### speech cache directory: \(cacheDirectory)")
            } catch {
                print("캐시 디렉토리 생성 실패: \(error)")
            }
        } else {
            print("#### speech cache directory: \(cacheDirectory)")
        }
    }
    
    /// 데이터를 캐시에 저장합니다.
    /// - Parameters:
    ///   - data: 저장할 데이터
    ///   - key: 데이터를 식별할 키 (UUID 기반)
    func saveData(_ data: Data, forKey key: String) {
        let fileURL = cacheDirectory.appendingPathComponent(key)
        
        do {
            try data.write(to: fileURL)
            print("데이터가 성공적으로 저장되었습니다: \(fileURL.path)")
        } catch {
            print("데이터 저장 실패: \(error)")
        }
    }
    
    /// 캐시에서 데이터를 불러옵니다.
    /// - Parameter key: 불러올 데이터의 키
    /// - Returns: 해당 키에 해당하는 데이터 또는 nil
    func loadData(forKey key: String) -> Data? {
        let fileURL = cacheDirectory.appendingPathComponent(key)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                let data = try Data(contentsOf: fileURL)
                print("데이터가 성공적으로 불러와졌습니다: \(fileURL.path)")
                return data
            } catch {
                print("데이터 불러오기 실패: \(error)")
                return nil
            }
        } else {
            print("해당 키에 대한 데이터가 존재하지 않습니다: \(key)")
            return nil
        }
    }
    
    /// 캐시에서 특정 키의 데이터를 삭제합니다.
    /// - Parameter key: 삭제할 데이터의 키
    func removeData(forKey key: String) {
        let fileURL = cacheDirectory.appendingPathComponent(key)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(at: fileURL)
                print("데이터가 성공적으로 삭제되었습니다: \(fileURL.path)")
            } catch {
                print("데이터 삭제 실패: \(error)")
            }
        } else {
            print("삭제할 데이터가 존재하지 않습니다: \(key)")
        }
    }
    
    /// 캐시 전체를 정리합니다.
    func clearCache() {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil, options: [])
            for fileURL in fileURLs {
                try FileManager.default.removeItem(at: fileURL)
                print("캐시 파일 삭제됨: \(fileURL.path)")
            }
            print("캐시가 성공적으로 정리되었습니다.")
        } catch {
            print("캐시 정리 실패: \(error)")
        }
    }
}
