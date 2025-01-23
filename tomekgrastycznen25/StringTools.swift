//
//  StringTools.swift
//  tomekgrastycznen25
//
//  Created by Jacek Kałużny on 23/01/2025.
//
import CryptoKit
func randomString(length: Int) -> String {
    let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    return String((0..<length).compactMap { _ in characters.randomElement() })
}
func hashToEmojis(_ input: String) -> String {
    let emojis = [
        "😀", "😂", "🥰", "😎", "🤩", "😇", "🤔", "🙄", "😴", "🤯",
        "😈", "🤠", "🥳", "🤖", "👻", "👽", "🔥", "🌈", "✨", "🎉",
        "🎁", "🎈", "❤️", "🍎", "🍕", "🏀", "🚗", "✈️", "🎸", "🐶",
        "🐱", "🦄", "🐼", "🐧", "🦊", "🦁", "🐙", "🦖", "🐢", "🐳",
        "🌟", "🍀", "🍔", "🍩", "🍫", "🎂", "🎮", "📱", "💻", "🖼️",
        "🏔️", "🌊", "🚀", "🛸", "🎯", "🛵", "🚲", "🎨", "📚", "🎶"
    ]
    
    // Compute SHA256 hash of the input string
    let hash = SHA256.hash(data: input.data(using: .utf8)!)
    
    // Convert the first few bytes of the hash into indices
    let bytes = Array(hash)
    var result = ""
    for i in 0..<3 {
        let index = Int(bytes[i]) % emojis.count
        result.append(emojis[index])
    }
    
    return result
}

