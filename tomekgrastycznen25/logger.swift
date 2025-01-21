//
//  logger.swift
//  tomekgrastycznen25
//
//  Created by Jacek Kałużny on 21/01/2025.
//
import Foundation

class Logger: ObservableObject {
    static let shared = Logger()
    @Published private(set) var logs: [String] = []

    private init() {}

    func log(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .long)
        let logEntry = "[\(timestamp)] \(message)"
        logs.append(logEntry)
        print(logEntry) // Also print to the console
    }
}
