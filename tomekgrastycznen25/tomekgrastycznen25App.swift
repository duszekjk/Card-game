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
    @State public var backgroundImage: UIImage = generateFilmGrain(size: CGSize(width: 1024, height: 1024))!

    init() {
        #if os(macOS)
        _ = DeviceOrientationManager.shared
        #endif
    }
    var body: some Scene {

        WindowGroup {
            ZStack {
                Image(uiImage: backgroundImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: UIScreen.main.bounds.size.width, maxHeight: UIScreen.main.bounds.size.height) // Ensures full coverage
                    .ignoresSafeArea() // Extends beyond safe area
                
                ContentView(yourName: yourName)
            }
            .background(Color("TableColor"))
        }
    }
}
