//
//  tomekgrastycznen25App.swift
//  tomekgrastycznen25
//
//  Created by Jacek Kałużny on 18/01/2025.
//

import SwiftUI
import SwiftData


@main
struct tomekgrastycznen25App: App {
    @AppStorage("yourName") var yourName = randomString(length: 8)

    init() {
        #if os(macOS)
        _ = DeviceOrientationManager.shared
        #endif
    }
    var body: some Scene {

        WindowGroup {
            ContentView(yourName: yourName)
        }
    }
}
