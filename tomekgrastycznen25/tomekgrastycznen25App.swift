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
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        #if os(macOS)
        _ = DeviceOrientationManager.shared
        #endif
    }
    var body: some Scene {

        WindowGroup {
            ContentView(yourName: yourName)
        }
        .modelContainer(sharedModelContainer)
    }
}
