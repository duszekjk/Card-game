//
//  TaliaView.swift
//  tomekgrastycznen25
//
//  Created by Jacek Kałużny on 19/01/2025.
//


import SwiftUI
import UniformTypeIdentifiers
var taliaBase : Array<Dictionary<String, Any>> = [
    [
        "koszt": 0, //price in mana. If mana is 0, then 1 mana = 1 card. You can pay with card you have in karty and it will also decrease ilośćKart. As last resort you can use życie. 1 życie = 1 mana
        "akcjaRzucaneZaklęcie": "@PlayerYou.życie = @PlayerYou.życie - 1",
        "akcjaOdrzuconeZaklęcie": "",
        "pacyfizm": "@PlayerYou.ilośćKart = @PlayerYou.ilośćKart + 1",
        "opis": "1 ❤️‍🔥, \nPacyfizm: Przeciwnik 🃏"
    ],
    [
        "koszt": 3,
        "akcjaRzucaneZaklęcie": "@PlayerMe.ilośćKart = @PlayerMe.ilośćKart - 1",
        "akcjaOdrzuconeZaklęcie": "",
        "pacyfizm": "@PlayerYou.ilośćKart = @PlayerYou.ilośćKart + 1",
        "opis": "3 🃏, \nPacyfizm: Przeciwnik 🃏"
    ],
    [
        "koszt": 4,
        "akcjaRzucaneZaklęcie": "@PlayerYou.życie = @PlayerYou.życie - ( @Zaklęcie.koszt / 4 )",
        "akcjaOdrzuconeZaklęcie": "",
        "opis": "1 ❤️‍🔥 za każde 4 many, które kosztuje to zaklęcie"
    ],
    [
        "koszt": 4,
        "akcjaRzucaneZaklęcie": "@PlayerYou.ilośćKart = 0 & @PlayerMe.ilośćKart = 0",
        "akcjaOdrzuconeZaklęcie": "",
        "pacyfizm": "",
        "opis": "Wszyscy gracze ❌ wszystkie 🃏"
    ],
    [
        "koszt": 5,
        "akcjaRzucaneZaklęcie": "@PlayerYou.ilośćKart = @PlayerYou.ilośćKart - 3 & if @PlayerYou.ilośćKart == 0 : @PlayerYou.życie = @PlayerYou.życie - 1",
        "akcjaOdrzuconeZaklęcie": "",
        "pacyfizm": "",
        "opis": "Przeciwnik ❌ 3 🃏, następnie jeśli nie ma on kart 1 ❤️‍🔥"
    ],
    [
        "koszt": 1,
        "akcjaRzucaneZaklęcie": "@PlayerYou.życie = @PlayerYou.życie - 2",
        "akcjaOdrzuconeZaklęcie": "",
        "pacyfizm": "@PlayerYou.ilośćKart = @PlayerYou.ilośćKart + 1 & @PlayerYou.mana = @PlayerYou.mana + 2",
        "opis": "2 ❤️‍🔥, \nPacyfizm: Przeciwnik 1 🃏 i 2 🔋"
    ],
    
]
struct TaliaView: View {
    @Binding var gra: Dictionary<String, Any>
    @Binding var talia: Array<Dictionary<String, Any>> 
    var isDragEnabled: Bool = true
    var isDropEnabled: Bool = true

    var body: some View {
        VStack {
            Text("Talia")
                .font(.headline)

            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray)
                    .frame(width: 120, height: 180)
                    .shadow(radius: 5)

                Text("Talia")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .onDrag {
                guard isDragEnabled, !talia.isEmpty else { return NSItemProvider() }
                let randomIndex = Int.random(in: 0..<talia.count)
                return NSItemProvider(object: "Talia|\(randomIndex)" as NSString)
            }
            .onDrop(of: [UTType.text], isTargeted: nil) { providers in
                guard isDropEnabled else { return false }
                return handleDrop(providers: providers)
            }
        }
        .padding()
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { (data, error) in
                guard error == nil, let data = data as? Data, let identifier = String(data: data, encoding: .utf8) else {
                    return
                }

                DispatchQueue.main.async {
                    let parts = identifier.split(separator: "|")
                    guard parts.count == 2, parts.first == "Talia" else { return }

                    // Dropped card's source key and index (use for other sources too)
                    if let sourceKey = parts.first, let sourceIndex = Int(parts.last ?? "") {
                        moveCardToTalia(from: String(sourceKey), at: sourceIndex)
                    }
                }
            }
        }
        return true
    }

    private func moveCardToTalia(from sourceKey: String, at sourceIndex: Int) {
        // Handle adding card back to the talia.
        if sourceKey == "Talia" { return } // Prevent adding to the same talia.

        // Retrieve card from source
        if var sourceCards = gra[sourceKey] as? [String: Any],
           var karty = sourceCards["karty"] as? Array<Dictionary<String, Any>> {
            guard sourceIndex >= 0, sourceIndex < karty.count else { return }
            let card = karty.remove(at: sourceIndex)
            sourceCards["karty"] = karty
            gra[sourceKey] = sourceCards

            // Add card back to talia
            talia.append(card)
        }
    }
}
