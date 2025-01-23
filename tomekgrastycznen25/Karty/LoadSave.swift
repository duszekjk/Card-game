//
//  LoadSave.swift
//  tomekgrastycznen25
//
//  Created by Jacek Kałużny on 23/01/2025.
//

import Foundation
let requiredKeysForCard = [
    "koszt", "akcjaRzucaneZaklęcie", "akcjaOdrzuconeZaklęcie", "pacyfizm",
    "wandering", "lingering", "opis", "postacie"
]
func sortedJSONData(from dictionary: [String: Any]) -> Data? {
    let sortedDictionary = dictionary.sorted { $0.key < $1.key }
    let sortedDictionaryAsObject = Dictionary(uniqueKeysWithValues: sortedDictionary)
    
    return try? JSONSerialization.data(withJSONObject: sortedDictionaryAsObject, options: .prettyPrinted)
}
func sortedJSONData(fromArray array: [[String: Any]]) -> Data? {
    let sortedArray = array.map { dictionary -> [String: Any] in
        let sortedDictionary = dictionary.sorted { $0.key < $1.key }
        return Dictionary(uniqueKeysWithValues: sortedDictionary)
    }
    
    return try? JSONSerialization.data(withJSONObject: sortedArray, options: .prettyPrinted)
}

func getDecksDirectory() -> URL {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let decksDirectory = documentsDirectory.appendingPathComponent("decks")
    if !FileManager.default.fileExists(atPath: decksDirectory.path) {
        try? FileManager.default.createDirectory(at: decksDirectory, withIntermediateDirectories: true)
    }
    return decksDirectory
}
func saveDeck(_ deck: [[String: Any]], withName name: String) {
    let completeDeck = completeDeck(deck)
    let fileURL = getDecksDirectory().appendingPathComponent("\(name).json")
    if let data = sortedJSONData(fromArray: completeDeck) {
        do {
            try data.write(to: fileURL)
            print("Deck saved to \(fileURL.path)")
        } catch {
            print("Failed to save deck: \(error)")
        }
    }
}
func loadDeck(fromFile name: String) -> [[String: Any]]? {
    let fileURL = getDecksDirectory().appendingPathComponent(name)
    do {
        let data = try Data(contentsOf: fileURL)
        if let deck = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
            return completeDeck(deck) // Validate and complete the deck
        }
    } catch {
        print("Failed to load deck: \(error)")
    }
    return nil
}
func loadDefaultDeck() -> [[String: Any]]? {
    if let fileURL = Bundle.main.url(forResource: "defaultDeck", withExtension: "json"),
       let data = try? Data(contentsOf: fileURL),
       let deck = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
        return completeDeck(deck) // Validate and complete the default deck
    }
    return nil
}

func listDeckFiles() -> [String] {
    let decksDirectory = getDecksDirectory()
    do {
        let files = try FileManager.default.contentsOfDirectory(atPath: decksDirectory.path)
        return files.filter { $0.hasSuffix(".json") }
    } catch {
        print("Failed to list deck files: \(error)")
        return []
    }
}


func validateAndCompleteCard(_ card: [String: Any]) -> ([String: Any], [String]) {
    
    var updatedCard = card
    var missingKeys: [String] = []

    for key in requiredKeysForCard {
        if updatedCard[key] == nil {
            missingKeys.append(key)
            updatedCard[key] = key == "postacie" ? [] : NSNull()
        }
    }
    return (updatedCard, missingKeys)
}


func completeCard(_ card: [String: Any]) -> [String: Any] {
    var updatedCard = card

    for key in requiredKeysForCard {
        if updatedCard[key] == nil {
            // Add missing key with default value (null for JSON, empty for arrays)
            updatedCard[key] = key == "postacie" ? [] : NSNull()
        }
    }
    return updatedCard
}

// Function to process the entire deck
func completeDeck(_ deck: [[String: Any]]) -> [[String: Any]] {
    return deck.map { completeCard($0) }
}



import SwiftUI

struct SaveDeckView: View {
    @State private var deckName: String = ""
    @Binding var deck: [[String: Any]] // Pass the current deck

    var body: some View {
        VStack {
            Text("Save Deck")
                .font(.headline)
            TextField("Enter deck name", text: $deckName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("Save") {
                if !deckName.isEmpty {
                    saveDeck(deck, withName: deckName)
                }
            }
            .disabled(deckName.isEmpty)
        }
        .padding()
    }
}
struct LoadDeckView: View {
    @Binding var deck: [[String: Any]] // Pass the current deck

    @State private var deckFiles: [String] = []

    var body: some View {
        VStack {
            Text("Load Deck")
                .font(.headline)
            List(deckFiles, id: \.self) { file in
                Button(file) {
                    if let loadedDeck = loadDeck(fromFile: file) {
                        deck = loadedDeck
                    }
                }
            }
            .onAppear {
                deckFiles = listDeckFiles()
            }
        }
        .padding()
    }
}
