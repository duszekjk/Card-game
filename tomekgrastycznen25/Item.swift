//
//  Item.swift
//  tomekgrastycznen25
//
//  Created by Jacek Kałużny on 18/01/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
