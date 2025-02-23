//
//  ListaSymboli.swift
//  tomekgrastycznen25
//
//  Created by Jacek Kałużny on 05/02/2025.
//

import Foundation
import SwiftUI

var emojiSymbols : [String:any Shape] = [
    "🃏": CardsIn(),
    "🎇": CardsOut(),
    "❤️‍🔥": FlamingHeart(), // takes opponent life/health
    "❤️": Heart(), // gains life/health
    "🛡️": ShieldIn(), // adds shield
    "🔋": ManaIn(),
    "🪫": ManaOut(),
]

