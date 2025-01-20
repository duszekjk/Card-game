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
        "opis": "1 ❤️‍🔥, \nPacyfizm: Przeciwnik 🃏",
        "postacie": ["Mag Światła", "Mag Krwii"]
    ],
    [
        "koszt": 3,
        "akcjaRzucaneZaklęcie": "@PlayerMe.ilośćKart = @PlayerMe.ilośćKart + 3",
        "akcjaOdrzuconeZaklęcie": "",
        "pacyfizm": "@PlayerYou.ilośćKart = @PlayerYou.ilośćKart + 1",
        "opis": "3 🃏, \nPacyfizm: Przeciwnik 🃏",
        "postacie": ["Mag Światła", "Mag Krwii"]
    ],
    [
        "koszt": 4,
        "akcjaRzucaneZaklęcie": "@PlayerYou.życie = @PlayerYou.życie - ( @Zaklęcie.koszt / 4 )",
        "akcjaOdrzuconeZaklęcie": "",
        "opis": "1 ❤️‍🔥 za każde 4 many, które kosztuje to zaklęcie",
        "postacie": ["Mag Światła", "Mag Krwii"]
    ],
    [
        "koszt": 4,
        "akcjaRzucaneZaklęcie": "@PlayerYou.ilośćKart = 0 & @PlayerMe.ilośćKart = 0",
        "akcjaOdrzuconeZaklęcie": "",
        "pacyfizm": "",
        "opis": "Wszyscy gracze ❌ wszystkie 🃏",
        "postacie": ["Mag Światła"]
    ],
    [
        "koszt": 5,
        "akcjaRzucaneZaklęcie": "@PlayerYou.ilośćKart = @PlayerYou.ilośćKart - 3 & if @PlayerYou.ilośćKart == 0 : @PlayerYou.życie = @PlayerYou.życie - 1",
        "akcjaOdrzuconeZaklęcie": "",
        "pacyfizm": "",
        "opis": "Przeciwnik ❌ 3 🃏, następnie jeśli nie ma on kart 1 ❤️‍🔥",
        "postacie": ["Mag Światła", "Mag Krwii"]
    ],
    [
        "koszt": 1,
        "akcjaRzucaneZaklęcie": "@PlayerYou.życie = @PlayerYou.życie - 2",
        "akcjaOdrzuconeZaklęcie": "",
        "pacyfizm": "@PlayerYou.ilośćKart = @PlayerYou.ilośćKart + 1 & @PlayerYou.mana = @PlayerYou.mana + 2",
        "opis": "2 ❤️‍🔥, \nPacyfizm: Przeciwnik 1 🃏 i 2 🔋",
        "postacie": ["Mag Światła", "Mag Krwii"]
    ],
]
struct TaliaView: View {
    @Binding var gra: Dictionary<String, Any>
    @Binding var talia: Array<Dictionary<String, Any>>
    
    var nazwa = "Talia"
    var isDragEnabled: Bool = true
    var isDropEnabled: Bool = true

    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray)
                    .frame(width: 120, height: 180)
                    .shadow(radius: 5)

                VStack{
                Text(nazwa)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                Text("\(talia.count) kart")
                    .foregroundColor(.white)
                    .padding()
                    
                }
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

struct TaliaContainerView: View {
    @Binding var gra: Dictionary<String, Any>
    @Binding var talia: Array<Dictionary<String, Any>>
    @Binding var lastPlayed: String
    @Binding var activePlayer : Int
    @Binding var gameRound : Int
    let containerKey: String // Key in `gra` (e.g., "Zaklęcie", "Lingering")
    var isDragEnabled: Bool = true
    var isDropEnabled: Bool = true
    var size:CGFloat = 3
    var sizeFullAction : (String, Array<Dictionary<String, Any>>) -> Void = { selectedContainerKey, kards in
        
    }
    @State public var kartyCount = 3
    var body: some View {
        VStack {
            Text("Karty z talii \(containerKey)")
                .font(.headline)
                .padding()
            ScrollView(.horizontal, showsIndicators: false) {
                VStack {
                    let columns = Array(repeating: GridItem(.flexible()), count: Int(max(1, min(5, talia.count))))
                    LazyVGrid(columns: columns, spacing: 5) {
                        ForEach(talia.indices, id: \.self) { index in
                            let karta = talia[index]
                            KartaView(karta: karta)
                                .onDrag {
                                    NSItemProvider(object: isDragEnabled ? "\(containerKey)|\(index)" as NSString : "" as NSString)
                                }
                        }
                    }
                }
                .frame(minWidth: size*111)
                .onAppear()
                {
                    kartyCount = talia.count
                }
                .onChange(of: talia.count)
                {
                    kartyCount = talia.count
                }

            }
            .frame(minWidth: size*111, idealWidth: size*112, maxWidth: size*113, minHeight: 140 , idealHeight: 140 * (roundl(CGFloat(kartyCount)/CGFloat(size)))+5, maxHeight: 460, alignment: .center)
//            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 2))
            .onDrop(of: [UTType.text], isTargeted: nil) { providers in
                guard isDropEnabled else { return false }
                return handleDrop(providers: providers)
            }
        }
        .scaleEffect(UIDevice.current.userInterfaceIdiom == .phone ? 0.75 : 1.0)
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { (data, error) in
                guard error == nil, let data = data as? Data, let identifier = String(data: data, encoding: .utf8) else {
                    return
                }

                DispatchQueue.main.async {
                    let parts = identifier.split(separator: "|")
                    guard parts.count == 2,
                          let sourceKey = parts.first,
                          let sourceIndex = Int(parts.last ?? "") else { return }

                    moveCard(from: String(sourceKey), at: sourceIndex, to: containerKey)
                    lastPlayed = String(sourceKey)
                    if let container = gra[containerKey] as? Dictionary<String, Any>
                    {
                        let kartyLoad = container["karty"] as? Array<Dictionary<String, Any>> ?? []
                        if(CGFloat(kartyLoad.count) == size)
                        {
                            print("Running spell bc \(CGFloat(kartyLoad.count)) == \(size)")
                            sizeFullAction(containerKey, kartyLoad)
                        }
                        else {
                            gameRound += 1
                            activePlayer = gameRound % playersList.count
                        }
                    }
                }
            }
        }
        return true
    }

    private func moveCard(from sourceKey: String, at sourceIndex: Int, to destinationKey: String) {
        var sourceCards = Array<Dictionary<String, Any>>()
        var sourceIndexCorrected = sourceIndex
        if(gra[sourceKey] == nil)
        {
            sourceCards = talia
            sourceIndexCorrected = Int.random(in: 0..<talia.count)
        }
        else
        {
            sourceCards = (gra[sourceKey] as! Dictionary<String, Any>)["karty"] as? Array<Dictionary<String, Any>> ?? []
        }
        guard sourceIndexCorrected >= 0, sourceIndexCorrected < sourceCards.count else { return }

        let card = sourceCards.remove(at: sourceIndexCorrected)
        if var playerData = gra[sourceKey] as? [String: Any] {
            playerData["karty"] = sourceCards
            gra[sourceKey] = playerData
        }

        var destinationCards = (gra[destinationKey] as! Dictionary<String, Any>)["karty"] as? Array<Dictionary<String, Any>> ?? []
        destinationCards.append(card)
        if var playerData = gra[destinationKey] as? [String: Any] {
            playerData["karty"] = destinationCards
            gra[destinationKey] = playerData
        }
    }
}
