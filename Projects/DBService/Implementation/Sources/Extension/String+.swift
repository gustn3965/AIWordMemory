//
//  String+.swift
//  DBImplementation
//
//  Created by 박현수 on 12/29/24.
//

import Foundation

public func generateRandomString(minLength: Int = 5, maxLength: Int? = 10, characterSet: String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789") -> String {
    // 최소 길이가 1 이상인지 확인
    let min = max(minLength, 1)
    
    // 최대 길이가 최소 길이보다 큰지 확인
    let max: Int
    if let maxLength = maxLength, maxLength >= min {
        max = maxLength
    } else {
        max = min
    }
    
    // 문자열의 최종 길이 결정
    let length = max == min ? min : Int.random(in: min...max)
    
    // 랜덤 문자열 생성
    let randomString = String((0..<length).compactMap { _ in characterSet.randomElement() })
    
    return randomString
}
