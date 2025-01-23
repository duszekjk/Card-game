//
//  Card.swift
//  tomekgrastycznen25
//
//  Created by Jacek Kałużny on 23/01/2025.
//
let samplePostacie = ["Mag Światła", "Mag Krwii", "Mag Ognia", "Mag Wody"]

let sampleCard = Card(
    opis: "1 ❤️‍🔥, \nPacyfizm: Przeciwnik 🃏",
    koszt: 0,
    postacie: ["Mag Światła", "Mag Krwii"],
    akcjaRzucaneZaklęcie: "@PlayerYou.życie = @PlayerYou.życie - 1",
    akcjaOdrzuconeZaklęcie: "",
    wandering: "",
    lingering: "",
    pacyfizm: "@PlayerYou.ilośćKart = @PlayerYou.ilośćKart + 1"
)


import SwiftUI

import Foundation

struct Card: Identifiable, Codable {
    let id = UUID()
    var opis: String
    var koszt: Int
    var postacie: [String]
    var akcjaRzucaneZaklęcie: String
    var akcjaOdrzuconeZaklęcie: String
    var wandering: String
    var lingering: String
    var pacyfizm: String
}


extension Card {
    static func load(from json: String) -> Card? {
        print(json)
        guard let data = json.data(using: .utf8) else {
            print("error1")
            return nil }
        print("2")
        do
        {
            var ret = try JSONDecoder().decode(Card.self, from: data)
            return ret
        }
        catch
        {
            print("Decoding error: \(error)")
            return nil
        }
    }
    
    func save() -> String? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}


struct CardEditorView: View {
    @Binding var gra: Dictionary<String, Any>
    @Binding var jsonText: String?
    @State private var postacie = ["Mag Światła", "Mag Krwii"]
    @State private var card: Card
    
    @State private var showAkcjaRzucaneZaklęcie: Bool = false
    init(gra:Binding<Dictionary<String, Any>>, jsonText: Binding<String?>) {
        _gra = gra
        _jsonText = jsonText
        _card = State(initialValue: Card.load(from: jsonText.wrappedValue!) ?? Card(
            opis: "",
            koszt: 0,
            postacie: [],
            akcjaRzucaneZaklęcie: "",
            akcjaOdrzuconeZaklęcie: "",
            wandering: "",
            lingering: "",
            pacyfizm: ""
        ))
    }
    
    var body: some View {
        Form {
            Section(header: Text("Opis")) {
                TextEditor(text: $card.opis)
                    .frame(height: 100)
                    .border(Color.gray)
            }
            
            Section(header: Text("Koszt")) {
                Stepper(value: $card.koszt, in: 0...100) {
                    Text("Koszt: \(card.koszt)")
                }
            }
            
            Section(header: Text("Akcje")) {
                Button("akcjaRzucaneZaklęcie")
                {
                    showAkcjaRzucaneZaklęcie = true
                }
                .sheet(isPresented: $showAkcjaRzucaneZaklęcie)
                {
                    ActionEditorView(gra: $gra)
                }
            }
            Section(header: Text("Postacie")) {
                ForEach(postacie, id: \.self) { postać in
                    Toggle(postać, isOn: Binding(
                        get: { card.postacie.contains(postać) },
                        set: { isSelected in
                            if isSelected {
                                card.postacie.append(postać)
                            } else {
                                card.postacie.removeAll { $0 == postać }
                            }
                        }
                    ))
                }
            }
            
            Button("Save") {
                if let updatedJSON = card.save() {
                    jsonText = updatedJSON
                }
            }
        }
        .onAppear()
        {
            card = Card.load(from: jsonText!)!
        }
        .onChange(of: jsonText)
        {
            card = Card.load(from: jsonText!)!
        }
        .navigationTitle("Edit Card")
    }
}
