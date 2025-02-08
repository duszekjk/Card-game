//
//  Postacie.swift
//  tomekgrastycznen25
//
//  Created by Jacek Kałużny on 06/02/2025.
//


import Foundation

let requiredKeysForPostacie = [
    "opisOdrzucaneZaklęcie", "akcjaRzucaneZaklęcie", "karty", "życie",
    "opisRzucaneZaklęcie", "nazwa", "id", "akcjaOdrzuconeZaklęcie",
    "tarcza", "opis", "manaMax", "mana", "ilośćKart"
]

func getPostacieDirectory() -> URL {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let postacieDirectory = documentsDirectory.appendingPathComponent("postacie")
    
    if !FileManager.default.fileExists(atPath: postacieDirectory.path) {
        try? FileManager.default.createDirectory(at: postacieDirectory, withIntermediateDirectories: true)
    }
    
    return postacieDirectory
}

func ensureDefaultPostacieExist() {
    let fileManager = FileManager.default
    let postacieDirectory = getPostacieDirectory()
    
    do {
        let existingFiles = try fileManager.contentsOfDirectory(atPath: postacieDirectory.path)

        if existingFiles.count < 3 {
            print("No character files found. Copying default characters.")

            // Get all JSON files in the bundle
            if let bundleURL = Bundle.main.resourceURL {
                let bundleContents = try fileManager.contentsOfDirectory(atPath: bundleURL.path)
                
                // Filter only "Postać " JSON files
                let postacieFiles = bundleContents.filter { $0.hasPrefix("Postać ") && $0.hasSuffix(".json") }

                for file in postacieFiles {
                    let sourceURL = bundleURL.appendingPathComponent(file)

                    // Remove the "Postać " prefix before copying
                    let newFileName = file.replacingOccurrences(of: "Postać ", with: "")
                    let destinationURL = postacieDirectory.appendingPathComponent(newFileName)

                    if !fileManager.fileExists(atPath: destinationURL.path) {
                        do {
                            try fileManager.copyItem(at: sourceURL, to: destinationURL)
                            print("Copied \(newFileName) to \(destinationURL.path)")
                        } catch {
                            print("Failed to copy \(newFileName): \(error)")
                        }
                    }
                }
            } else {
                print("Could not access bundle resource URL.")
            }
        }
    } catch {
        print("Failed to check or copy default characters: \(error)")
    }
}



func listPostacieFiles() -> [String] {
    let postacieDirectory = getPostacieDirectory()
    
    do {
        let files = try FileManager.default.contentsOfDirectory(atPath: postacieDirectory.path)
        let jsonFiles = files.filter { $0.lowercased().hasSuffix(".json") }
        let filenamesWithoutExtension = jsonFiles.map { URL(fileURLWithPath: $0).deletingPathExtension().lastPathComponent }
        return filenamesWithoutExtension
    } catch {
        print("Failed to list Postacie files: \(error)")
        return []
    }
}


func loadPlayer(jsonPath: URL, id: Int = 0) -> Dictionary<String, Any>? {
    do {
        let data = try Data(contentsOf: jsonPath)
        if var character = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            
            // Ensure required keys exist
            character = completePostacie(character)
            
            // Assign correct player ID
            character["id"] = id == 0 ? "Player1" : "Player2"
            
            return character
        }
    } catch {
        print("Failed to load player from \(jsonPath.lastPathComponent): \(error)")
    }
    
    return nil
}

// Function to ensure required keys exist in a character object
func completePostacie(_ postacie: [String: Any]) -> [String: Any] {
    var updatedPostacie = postacie

    for key in requiredKeysForPostacie {
        if updatedPostacie[key] == nil {
            updatedPostacie[key] = key == "karty" ? [] : NSNull()
        }
    }
    return updatedPostacie
}
