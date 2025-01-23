//
//  ActionEditorView.swift
//  tomekgrastycznen25
//
//  Created by Jacek Kałużny on 24/01/2025.
//


import SwiftUI

struct ActionEditorView: View {
    @Binding var gra: Dictionary<String, Any>
    @State private var currentAction: String = ""
    @State private var selectedTopKey: String?
    @State private var actionList: [String] = []
    
    var body: some View {
        VStack(spacing: 16) {
            // Top Row: Predefined Game Keys
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(["PlayerMe", "PlayerYou", "TablePlayer1", "TablePlayer2", "Lingering", "Extra", "Zaklęcie"], id: \.self) { key in
                        Button(key) {
                            appendToAction("@\(key)")
                            selectedTopKey = key
                        }
                        .padding()
                        .background(selectedTopKey == key ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    }
                }
            }
            
            // Dynamic Sub-Keys
            if let selectedKey = selectedTopKey, let dictionary = gra[selectedKey] as? Dictionary<String, Any> {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(dictionary.keys.sorted(), id: \.self) { subKey in
                            Button(".\(subKey)") {
                                appendToAction(".\(subKey)")
                            }
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                        }
                    }
                }
            }
            
            // Operators
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(["=", "+", "-", "&", "if", ":", "."], id: \.self) { operatorSymbol in
                        Button(operatorSymbol) {
                            appendToAction(" \(operatorSymbol) ")
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    }
                }
            }
            
            // Current Action Preview
            Text("Current Action: \(currentAction)")
                .padding()
                .border(Color.gray)
            
            // Preview of Actions
            List {
                ForEach(Array(actionList.enumerated()), id: \.offset) { index, action in
                    HStack {
                        Text(action)
                        Spacer()
                        Button("Select") {
                            currentAction = action
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            
            // Add Action Button
            Button("Add Action") {
                if !currentAction.isEmpty {
                    actionList.append(currentAction)
                    currentAction = ""
                }
            }
            .padding()
            .background(Color.green.opacity(0.2))
            .cornerRadius(8)
        }
        .padding()
        .navigationTitle("Edit Actions")
    }
    
    private func appendToAction(_ text: String) {
        currentAction += text
    }
}
