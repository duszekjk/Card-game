//
//  LoadPostacieView.swift
//  tomekgrastycznen25
//
//  Created by Jacek Kałużny on 06/02/2025.
//


import SwiftUI

struct LoadPostacieView: View {
    @Binding var gra: Dictionary<String, Any>
    @Binding var selectedFile: String?
    var playerId: Int // 1 for Player1, 2 for Player2

    @State private var postacieFiles: [String] = []

    var body: some View {
        VStack {
            Menu {
                Picker("Wybierz postać", selection: $selectedFile) {
                    Text("Wybierz postać").tag(String?.none) // Placeholder
                    ForEach(postacieFiles, id: \.self) { file in
                        Text(file).tag(file as String?)
                    }
                }
                .labelsHidden() // Hide Picker label inside Menu
            } label: {
                Text(selectedFile ?? "Wybierz")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .foregroundColor(.primary)
                    .onTapGesture {
                        refreshPostacieFiles()
                    }
            }
            .onChange(of: selectedFile) { newValue in
                if let file = newValue {
                    let fileURL = getPostacieDirectory().appendingPathComponent(file)
                    if let loadedCharacter = loadPlayer(jsonPath: fileURL, id: playerId) {
                        if(!loadedCharacter.isEmpty)
                        {
                            DispatchQueue.main.async {
                                let key = playerId == 1 ? "Player1" : "Player2"
                                gra[key] = loadedCharacter
                                
                                print("Loaded \(key): \(loadedCharacter)")
                                
                                var fileName = file
                                fileName = fileName.replacingOccurrences(of: ".json", with: "").replacingOccurrences(of: ".JSON", with: "")
                                gra["\(key)Nazwa"] = fileName
                            }
                        }
                    }
                }
                refreshPostacieFiles()
            }
            .onAppear {
                ensureDefaultPostacieExist()
                refreshPostacieFiles()
                if let file = selectedFile {
                    let fileURL = getPostacieDirectory().appendingPathComponent(file)
                    if let loadedCharacter = loadPlayer(jsonPath: fileURL, id: playerId) {
                        if(!loadedCharacter.isEmpty)
                        {
                            DispatchQueue.main.async {
                                let key = playerId == 0 ? "Player1" : "Player2"
                                gra[key] = loadedCharacter
                                
                                print("Reloaded \(key): \(loadedCharacter)")
                                
                                var fileName = file
                                fileName = fileName.replacingOccurrences(of: ".json", with: "").replacingOccurrences(of: ".JSON", with: "")
//                                gra["\(key)Nazwa"] = fileName
                            }
                        }
                    }
                }
            }
            .onTapGesture {
                refreshPostacieFiles()
            }
        }
        .padding()
    }

    private func refreshPostacieFiles() {
        postacieFiles = listPostacieFiles()
        print("Postacie files: \(postacieFiles)")
    }
}
