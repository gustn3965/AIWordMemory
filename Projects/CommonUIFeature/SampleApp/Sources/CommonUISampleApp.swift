//
//  SampleApp.swift
//  Manifests
//
//  Created by 박현수 on 12/22/24.
//

import SwiftUI
import CommonUI

@main
struct CommonUISampleApp: App {
    var body: some Scene {
        WindowGroup {
            CommonUIContentView(diContainer: CommonUIMockDIContainer())
        }
    }
}
