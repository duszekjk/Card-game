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
        "koszt": 0,
        "akcjaRzucaneZaklęcie": "@PlayerYou.życie = @PlayerYou.życie - 1",
        "akcjaOdrzuconeZaklęcie": "",
        "pacyfizm": "@PlayerYou.ilośćKart = @PlayerYou.ilośćKart + 1",
        "wandering": "",
        "lingering": "",
        "opis": "1 ❤️‍🔥, \nPacyfizm: Przeciwnik 🃏",
        "postacie": ["Mag Światła", "Mag Krwii"]
    ],
    [
        "koszt": 3,
        "akcjaRzucaneZaklęcie": "@PlayerMe.ilośćKart = @PlayerMe.ilośćKart + 3",
        "akcjaOdrzuconeZaklęcie": "",
        "pacyfizm": "@PlayerYou.ilośćKart = @PlayerYou.ilośćKart + 1",
        "wandering": "",
        "lingering": "",
        "opis": "3 🃏, \nPacyfizm: Przeciwnik 🃏",
        "postacie": ["Mag Światła", "Mag Krwii"]
    ],
    [
        "koszt": 4,
        "akcjaRzucaneZaklęcie": "@PlayerYou.życie = @PlayerYou.życie - ( @Zaklęcie.koszt / 4 )",
        "akcjaOdrzuconeZaklęcie": "",
        "pacyfizm": "",
        "wandering": "",
        "lingering": "",
        "opis": "1 ❤️‍🔥 za każde 4 many, które kosztuje to zaklęcie",
        "postacie": ["Mag Światła", "Mag Krwii"]
    ],
    [
        "koszt": 4,
        "akcjaRzucaneZaklęcie": "@PlayerYou.ilośćKart = 0 & @PlayerMe.ilośćKart = 0",
        "akcjaOdrzuconeZaklęcie": "",
        "pacyfizm": "",
        "wandering": "",
        "lingering": "",
        "opis": "Wszyscy gracze wszystkie 🎇",
        "postacie": ["Mag Światła"]
    ],
    [
        "koszt": 5,
        "akcjaRzucaneZaklęcie": "@PlayerYou.ilośćKart = @PlayerYou.ilośćKart - 3 & if @PlayerYou.ilośćKart == 0 : @PlayerYou.życie = @PlayerYou.życie - 1",
        "akcjaOdrzuconeZaklęcie": "",
        "pacyfizm": "",
        "wandering": "",
        "lingering": "",
        "opis": "Przeciwnik 3 🎇, następnie jeśli nie ma on kart 1 ❤️‍🔥",
        "postacie": ["Mag Światła", "Mag Krwii"]
    ],
    [
        "koszt": 1,
        "akcjaRzucaneZaklęcie": "@PlayerYou.życie = @PlayerYou.życie - 2",
        "akcjaOdrzuconeZaklęcie": "",
        "pacyfizm": "@PlayerYou.ilośćKart = @PlayerYou.ilośćKart + 1 & @PlayerYou.mana = @PlayerYou.mana + 2",
        "wandering": "",
        "lingering": "",
        "opis": "2 ❤️‍🔥, \nPacyfizm: Przeciwnik 1 🃏 i 2 🔋",
        "postacie": ["Mag Światła", "Mag Krwii"]
    ],
    [
        "koszt": 4,
        "akcjaRzucaneZaklęcie": "@PlayerMe.tarcza = @PlayerMe.tarcza + 5 & @PlayerYou.tarcza = @PlayerYou.tarcza + 3",
        "akcjaOdrzuconeZaklęcie": "",
        "pacyfizm": "",
        "wandering": "",
        "lingering": "",
        "opis": "5 🛡️, \nPrzeciwnik 3 🛡️",
        "postacie": ["Mag Światła"]
    ],
    [
        "koszt": 8,
        "akcjaRzucaneZaklęcie": "@PlayerYou.życie = @PlayerYou.życie - 3 & @PlayerMe.tarcza = @PlayerMe.tarcza + 3",
        "akcjaOdrzuconeZaklęcie": "",
        "pacyfizm": "",
        "wandering": "",
        "lingering": "",
        "opis": "3 ❤️‍🔥, 3 🛡️",
        "postacie": ["Mag Światła"]
    ],
    [
        "koszt": 0,
        "akcjaRzucaneZaklęcie": "@PlayerMe.mana = @PlayerMe.mana + 1",
        "akcjaOdrzuconeZaklęcie": "",
        "pacyfizm": "@PlayerYou.mana = @PlayerYou.mana + 1",
        "wandering": "",
        "lingering": "",
        "opis": "1 🔋,\nPacyfizm: Przeciwnik 1 🔋",
        "postacie": ["Mag Światła", "Mag Krwii"]
    ],
    [
        "koszt": 3,
        "akcjaRzucaneZaklęcie": "@PlayerYou.życie = @PlayerYou.życie - 3 & @PlayerMe.mana = @PlayerMe.mana + @Zaklęcie.sacrifice",
        "akcjaOdrzuconeZaklęcie": "@PlayerMe.ilośćKart = @PlayerMe.ilośćKart - 1",
        "pacyfizm": "",
        "wandering": "",
        "lingering": "",
        "opis": "Pustka 1\n3 ❤️‍🔥,\nSacrifice: 2 🔋",
        "postacie": ["Mag Światła", "Mag Krwii"]
    ],
    [
        "koszt": 5,
        "akcjaRzucaneZaklęcie": "@PlayerYou.życie = @PlayerYou.życie - 3 & @PlayerYou.tarcza = @PlayerYou.tarcza + 3",
        "akcjaOdrzuconeZaklęcie": "",
        "pacyfizm": "",
        "wandering": "",
        "lingering": 1,
        "opis": "3 ❤️‍🔥,\nPrzeciwnik: 3 🛡️",
        "postacie": ["Mag Światła", "Mag Krwii"]
    ],
    [
        "koszt": 2,
        "akcjaRzucaneZaklęcie": "@PlayerMe.mana = @PlayerMe.mana + ( 3 * @Zaklęcie.sacrifice )",
        "akcjaOdrzuconeZaklęcie": "@PlayerMe.ilośćKart = @PlayerMe.ilośćKart - 2",
        "pacyfizm": "",
        "wandering": "",
        "lingering": 1,
        "opis": "Pustka 2\n Sacrifice: 3 🔋",
        "postacie": ["Mag Światła", "Mag Krwii"]
    ],
]
struct TaliaView: View {
    @Binding var gra: Dictionary<String, Any>
    @Binding var gameRound: Int
    
    var playerID: String
    
    var nazwa: String
    var isDragEnabled: Bool = true
    var isDropEnabled: Bool = true
    
    
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    @State var talia:[[String: Any]] = [[String: Any]]()
    
    var body: some View {
        VStack {
            ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray)
                        .frame(width: 80, height: 110)
                        .shadow(radius: 5)
                    
                    VStack{
                        Text(nazwa)
                            .frame(width: 100, height: 70)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .rotationEffect(Angle(degrees: -60))
                            .frame(width: 80, height: 30)
                            .padding()
                            .padding(.top, 15)
                            .padding(.bottom, -15)
                        Text("\(talia.count) kart")
                            .foregroundColor(.white)
                            .padding()
                        
                }
            }
            .onChange(of: gameRound)
            {
                DispatchQueue.main.async {
                    print("gameRound \(gameRound) Talia\(playerID)")
                    talia = getKarty(&gra, for: "Talia\(playerID)")
                }
            }
            .onDrag {
                // Ensure all cards in `taliaBase` are complete before exporting
                let completeDeck = completeDeck(gra["Talia"] as! [[String:Any]])

                if let data = sortedJSONData(fromArray: completeDeck),
                   let jsonString = String(data: data, encoding: .utf8) {
                    return NSItemProvider(object: jsonString as NSString)
                }
                return NSItemProvider(object: "" as NSString)
            }
            .onDrop(of: [UTType.plainText], isTargeted: nil) { providers in
                guard let provider = providers.first else { return false }
                
                provider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { (item, error) in
                    if let data = item as? Data,
                       let jsonString = String(data: data, encoding: .utf8),
                       let jsonData = jsonString.data(using: .utf8) {
                        do {
                            if let decodedDeck = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]] {
                                // Validate the deck and collect missing key information
                                var missingKeysInfo = ""
                                var validatedDeck: [[String: Any]] = []
                                
                                for (index, card) in decodedDeck.enumerated() {
                                    let (validatedCard, missingKeys) = validateAndCompleteCard(card)
                                    validatedDeck.append(validatedCard)
                                    
                                    if !missingKeys.isEmpty {
                                        missingKeysInfo += "Karta \(index + 1): Brakujące cechy: \(missingKeys.joined(separator: ", "))\n"
                                    }
                                }
                                
                                // Show alert if there are missing keys
                                if !missingKeysInfo.isEmpty {
                                    DispatchQueue.main.async {
                                        alertMessage = missingKeysInfo
                                        showAlert = true
                                    }
                                }
                                
                                // Update the deck
                                DispatchQueue.main.async {
                                    gra["Talia"] = validatedDeck
//                                    let taliaAll = Array(repeating: taliaBase, count: taliaRepeat).flatMap { $0 }
                                    let taliaAll = gra["Talia"] as! [[String:Any]]
                                    for playerNew in playersList
                                    {
                                        if let gracz = gra[playerNew] as? Dictionary<String, Any>{
                                            var playerKarty = taliaAll.filter { card in
                                                guard let postacie = card["postacie"] as? [String] else {
                                                    return false
                                                }
                                                return postacie.contains(gracz["nazwa"] as! String)
                                            }.map { card in
                                                var modifiedCard = card
                                                modifiedCard["player"] = playerNew
                                                return modifiedCard
                                            }
                                            setKarty(&gra, for: "Talia\(playerNew)", value: playerKarty)
                                        }
                                    }
                                }
                            }
                        } catch {
                            print("Error deserializing JSON: \(error)")
                        }
                    }
                }
                return true
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Missing Keys in Cards"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }

//            .onDrag {
//                guard isDragEnabled, !talia.isEmpty else { return NSItemProvider() }
//                let randomIndex = Int.random(in: 0..<talia.count)
//                return NSItemProvider(object: "Talia|\(randomIndex)" as NSString)
//            }
//            .onDrop(of: [UTType.text], isTargeted: nil) { providers in
//                guard isDropEnabled else { return false }
//                return handleDrop(providers: providers)
//            }
            
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
            
            var talia = getKarty(&gra, for: "Talia\(sourceKey)")
            
            talia.append(card)
            
            setKarty(&gra, for: "Talia\(sourceKey)", value: talia)
            
            
        }
    }
}

struct TaliaContainerView: View {
    @Binding var gra: Dictionary<String, Any>
    @Binding var lastPlayed: String
    @Binding var activePlayer: Int
    @Binding var gameRound: Int
    @Binding var show: Bool
    @Binding var selectedCard: String?
    let containerKey: String
    var isDragEnabled: Bool = true
    var isDropEnabled: Bool = true
    var size: CGFloat = 3
    var sizeFullAction: (String, Array<Dictionary<String, Any>>) -> Void = { _, _ in }
    @State private var kartyCount = 3

    var body: some View {
        VStack {
            header
            cardGrid
        }
        .scaleEffect(UIDevice.current.userInterfaceIdiom == .phone ? 0.70 : 1.0)
        .frame(width: min(size * 135, UIScreen.main.bounds.size.width))
        .padding(-10)
    }

    private var header: some View {
        let talia = getKarty(&gra, for: containerKey)
        return HStack {
            Text("\(talia.count)")
            Spacer()
            Text("Karty z talii \(containerKey)")
                .font(.headline)
                .padding()
            Spacer()
            Button("Ok") {
                show = false
            }
        }
        .frame(width: min(size * 135, UIScreen.main.bounds.size.width) - 40)
    }

    private var cardGrid: some View {
        let talia = getKarty(&gra, for: containerKey)
        let columns = Array(repeating: GridItem(.flexible()), count: Int(max(1, min(5, talia.count))))

        return LazyVGrid(columns: columns, spacing: 5) {
            ForEach(0..<talia.count, id: \.self) { index in
                let karta = talia[index]
                KartaView(karta: karta, selectedCard: $selectedCard)
                    .onDrag {
                        NSItemProvider(object: isDragEnabled ? "\(containerKey)|\(index)" as NSString : "" as NSString)
                    }
            }
        }
        .frame(minWidth: size * 100)
        .padding(.bottom, 50)
        .onAppear {
            kartyCount = talia.count
        }
        .onChange(of: talia.count) { newValue in
            kartyCount = newValue
        }
        .onDrop(of: [UTType.text], isTargeted: nil) { providers in
            guard isDropEnabled else { return false }
            return handleDrop(providers: providers)
        }
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
        var talia = getKarty(&gra, for: "Talia\(sourceKey)")
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
