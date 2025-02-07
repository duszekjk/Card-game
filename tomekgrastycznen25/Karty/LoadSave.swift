//
//  LoadSave.swift
//  tomekgrastycznen25
//
//  Created by Jacek Kałużny on 23/01/2025.
//

import Foundation
import SwiftUI
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
    print(completeDeck)
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
            print("loading \(name)")
            return completeDeck(deck)
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
        return completeDeck(deck)
    }
    return nil
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
            updatedCard[key] = key == "postacie" ? [] : NSNull()
        }
    }
    return updatedCard
}

func completeDeck(_ deck: [[String: Any]]) -> [[String: Any]] {
    return deck.map { completeCard($0) }
}
struct SaveDeckView: View {
    @State private var deckName: String = ""
    @Binding var gra: Dictionary<String, Any>
    @Binding var selectedFile: String?

    var body: some View {
        HStack {
            TextField("Enter deck name", text: $deckName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("Zapisz") {
                if !deckName.isEmpty {
                    if let deck = gra["Talia"] as? [[String: Any]]
                    {
                        saveDeck(deck, withName: deckName)
                        gra["TaliaNazwa"] = deckName
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2)
                        {
                            selectedFile = deckName
                            deckName = "Zapisano!"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2)
                            {
                                deckName = ""
                            }
                        }
                        
                    }
                }
            }
            .disabled(deckName.isEmpty)
        }
    }
}
func listDeckFiles(failed: Bool = false, completion: @escaping ([String]) -> Void) {
    let decksDirectory = getDecksDirectory()
    do {
        let files = try FileManager.default.contentsOfDirectory(atPath: decksDirectory.path)
        print("files:\n\(files)")
        
        let filteredFiles = files.filter { $0.hasSuffix(".json") || $0.hasSuffix(".JSON") }
        
        if filteredFiles.isEmpty, !failed {
            print("No JSON files found. Creating Default deck.")
            var df = loadDefaultDeck()!
            saveDeck(df, withName: "Default")
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
                listDeckFiles(failed: true, completion: completion)
            }
        } else {
            completion(filteredFiles)
        }
    } catch {
        if !failed {
            print("Failed to access directory. Creating Default deck.")
            var df = loadDefaultDeck()!
            saveDeck(df, withName: "Default")
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
                listDeckFiles(failed: true, completion: completion)
            }
        } else {
            print("Failed to list deck files: \(error)")
            completion([])
        }
    }
}

struct LoadDeckView: View {
    @Binding var gra: Dictionary<String, Any>
    @Binding var selectedFile: String?

    @State private var deckFiles: [String] = []

    var body: some View {
        VStack {
            Menu {
                Picker("Select a Deck", selection: $selectedFile) {
                    Text("Select a deck").tag(String?.none) // Placeholder option
                    ForEach(deckFiles, id: \.self) { file in
                        Text(file).tag(file as String?)
                    }
                    .onAppear {
                        listDeckFiles { files in
                            print("Deck files: \(files)")
                            let filesload = files
                            print("Deck files load: \(files)")
                            deckFiles = filesload
                        }
                    }
                }
                .labelsHidden() // Hide the Picker's label inside the Menu
            } label: {
                Text(selectedFile ?? "Wybierz")
                    .padding()
                    .frame(maxWidth: .infinity) // Full-width clickable area
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .foregroundColor(.primary)
                    .onTapGesture {
                        listDeckFiles { files in
                            print("Deck files: \(files)")
                            let filesload = files
                            print("Deck files load: \(files)")
                            deckFiles = filesload
                        }
                    }
            }
            .onChange(of: selectedFile) { newValue in
                if let file = newValue, let loadedDeck = loadDeck(fromFile: file) {
                    
                    DispatchQueue.main.async()
                    {
                        gra["Talia"] = loadedDeck
                        
                        print("\((gra["Talia"]! as! [Any]))")
                        var fileName: String = file
                        fileName = fileName.replacingOccurrences(of: ".json", with: "").replacingOccurrences(of: ".JSON", with: "")
                        gra["TaliaNazwa"] = fileName
                    }
                }
                
                listDeckFiles { files in
                    print("Deck files: \(files)")
                    let filesload = files
                    print("Deck files load: \(files)")
                    deckFiles = filesload
                }
            }
            .onAppear {
                listDeckFiles { files in
                    print("Deck files: \(files)")
                    let filesload = files
                    print("Deck files load: \(files)")
                    deckFiles = filesload
                }
                if(selectedFile != nil)
                {
                    if let file = selectedFile, let loadedDeck = loadDeck(fromFile: file) {
                        print("Reloaded \(file)")
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2)
                        {
                            gra["Talia"] = loadedDeck
                            print("Reloaded \((gra["Talia"]! as! [Any]).count) = \((loadedDeck).count)")
                            print("\((gra["Talia"]! as! [Any]))")
                            
                            var fileName: String = file
                            fileName = fileName.replacingOccurrences(of: ".json", with: "").replacingOccurrences(of: ".JSON", with: "")
                            gra["TaliaNazwa"] = fileName
                        }
                    }
                }
            }
            .onTapGesture {
                listDeckFiles { files in
                    print("Deck files: \(files)")
                    let filesload = files
                    print("Deck files load: \(files)")
                    deckFiles = filesload
                }
            }
        }
        .padding()
    }
}
struct ManageDecksView: View {
    @Binding var gra: Dictionary<String, Any> // Assuming `gra` is passed for managing the loaded deck
    @Binding var selectedFile: String?
    @State private var deckFiles: [String] = []
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showRenameSheet = false
    @State private var editingFile: String? // For rename or duplicate actions
    @State private var newFileName: String = ""

    var body: some View {
        VStack {
            List(deckFiles, id: \.self) { file in
                HStack {
                    Button(action: { selectFile(file) }) {
                        Text(file)
                            .lineLimit(1)
                            .foregroundColor(file == selectedFile ? .blue : .primary)
                    }
                    Spacer()
                    Button(action: { prepareRename(file) }) {
                        Image(systemName: "pencil")
                    }
                    .padding(8)
                    .buttonStyle(BorderlessButtonStyle())

                    Button(action: {
                        if file != selectedFile {
                            removeFile(file)
                        } else {
                            alertMessage = "Cannot remove the currently loaded file."
                            showAlert = true
                        }
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(file == selectedFile ? .gray : .red)
                    }
                    .padding(8)
                    .buttonStyle(BorderlessButtonStyle())
                    .disabled(file == selectedFile)

                    Button(action: { duplicateFile(file) }) {
                        Image(systemName: "doc.on.doc")
                    }
                    .padding(8)
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
            .onAppear {
                refreshDeckFiles()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("File Operation"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showRenameSheet) {
            VStack {
                Text("Rename File")
                    .font(.headline)
                    .padding()

                TextField("New file name", text: $newFileName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                HStack {
                    Button("Cancel") {
                        showRenameSheet = false
                    }
                    .padding()

                    Spacer()

                    Button("Rename") {
                        renameFile()
                        showRenameSheet = false
                    }
                    .padding()
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
    private func refreshDeckFiles() {
        listDeckFiles { files in
            deckFiles = files
        }
    }
    private func selectFile(_ file: String) {
        selectedFile = file
        if let loadedDeck = loadDeck(fromFile: file) {
            gra["Talia"] = loadedDeck
            gra["TaliaNazwa"] = file.replacingOccurrences(of: ".json", with: "")
        }
    }
    private func prepareRename(_ file: String) {
        editingFile = file
        newFileName = file // Pre-fill the text field with the current file name
        showRenameSheet = true
    }
    private func renameFile() {
        guard let selectedFile = editingFile else { return }
        let directory = getDecksDirectory()
        let oldPath = directory.appendingPathComponent(selectedFile)
        let newPath = directory.appendingPathComponent(newFileName)

        do {
            try FileManager.default.moveItem(at: oldPath, to: newPath)
            alertMessage = "File renamed to \(newFileName)"
            if selectedFile == self.selectedFile {
                self.selectedFile = newFileName
            }
            refreshDeckFiles()
        } catch {
            alertMessage = "Failed to rename file: \(error)"
        }
        showAlert = true
    }
    private func removeFile(_ file: String) {
        let directory = getDecksDirectory()
        let filePath = directory.appendingPathComponent(file)

        do {
            try FileManager.default.removeItem(at: filePath)
            alertMessage = "File \(file) removed successfully"
            refreshDeckFiles()
        } catch {
            alertMessage = "Failed to remove file: \(error)"
        }
        showAlert = true
    }
    private func duplicateFile(_ file: String) {
        let newName = file.replacingOccurrences(of: ".json", with: "_copy.json")
        let directory = getDecksDirectory()
        let oldPath = directory.appendingPathComponent(file)
        let newPath = directory.appendingPathComponent(newName)

        do {
            try FileManager.default.copyItem(at: oldPath, to: newPath)
            alertMessage = "File duplicated as \(newName)"
            refreshDeckFiles()
        } catch {
            alertMessage = "Failed to duplicate file: \(error)"
        }
        showAlert = true
    }
}
