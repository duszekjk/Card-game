//
//  ContentView.swift
//  tomekgrastycznen25
//
//  Created by Jacek Kałużny on 18/01/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State public var gra: Dictionary<String, Any> = Dictionary<String, Any>()
    @State public var activePlayer : Int = 0
    @State public var PlayerLast : String = ""
    @State public var gameRound : Int = 0
    @State public var talia : Array<Dictionary<String, Any>> = Array<Dictionary<String, Any>>()
    
    
    @State public var showZaklęcie = false
    @State public var showZaklęcieMini = false
    
    @State public var showOdrzucanie = false
    
    @State public var landscape = false

    var body: some View {
        HStack {
            if(landscape)
            {
                VStack
                {
                    Text("Debug menu")
                        .font(.headline)
                    Text("Dodatkowe pomocnicze\nopcje i opisy\nna czas tworzenia")
                    Text("Ruch \(gameRound)")
                        .padding()
                    Button("Koniec ruchu", action:  { activePlayer += 1
                        activePlayer = activePlayer % playersList.count}
                           
                           
                    )
                    Button("Add Cards to Zaklęcie") {
                        gra["Zaklęcie"] = Dictionary<String, Any>()
                        addRandomCardsToSpell()
                        printFormatted(dictionary: (gra["Zaklęcie"] as! Dictionary<String, Any>))
                        gameRound += 1
                    }
                    .padding()
                    
                    Button("Run Spell") {
                        allSpells()
                    }
                    .padding()
                    TaliaView(gra: $gra, talia: $talia)
                }
                Divider()
            }
            VStack {
                PlayerView(playerKey: "Player2", gra: $gra, talia: $talia, lastPlayed: $PlayerLast, isActive: Binding<Bool>(
                    get: { activePlayer == 1 },
                    set: { newValue in
                        activePlayer = newValue ? 1 : 0 // Update activePlayer accordingly
                    }
                ), activePlayer: $activePlayer, gameRound: $gameRound)
                HStack
                {
                    VStack
                    {
                        KartaContainerView(gra: $gra, talia: $talia, lastPlayed: $PlayerLast, activePlayer: $activePlayer, gameRound: $gameRound, containerKey: "TablePlayer2", sizeFullAction: { tableKey, kards in
                            createSpell(for: "Player2", from: tableKey, with: kards)
                        })
                        .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 252 : 336, height: UIDevice.current.userInterfaceIdiom == .phone ? 105 : 150)
                        KartaContainerView(gra: $gra, talia: $talia, lastPlayed: $PlayerLast, activePlayer: $activePlayer, gameRound: $gameRound, containerKey: "TablePlayerLast", sizeFullAction: { tableKey, kards in
                            createSpell(for: PlayerLast, from: tableKey, with: kards)
                        })
                        .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 252 : 336, height: UIDevice.current.userInterfaceIdiom == .phone ? 105 : 150)
                        KartaContainerView(gra: $gra, talia: $talia, lastPlayed: $PlayerLast, activePlayer: $activePlayer, gameRound: $gameRound, containerKey: "TablePlayer1", sizeFullAction: { tableKey, kards in
                            createSpell(for: "Player1", from: tableKey, with: kards)
                        })
                        .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 252 : 336, height: UIDevice.current.userInterfaceIdiom == .phone ? 105 : 150)
                    }
                    .padding(UIDevice.current.userInterfaceIdiom == .phone ? 1 : 8)
                    KartaContainerView(gra: $gra, talia: $talia, lastPlayed: $PlayerLast, activePlayer: $activePlayer, gameRound: $gameRound, containerKey: "Lingering", size: 2)
                        .scaleEffect(UIDevice.current.userInterfaceIdiom == .phone ? 0.7 : 1.0)
                        .padding(UIDevice.current.userInterfaceIdiom == .phone ? 1 : 8)
                        .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 110 : 240, height: UIDevice.current.userInterfaceIdiom == .phone ? 250 : 450)
//                        .background(.blue)
                }
                PlayerView(playerKey: "Player1", gra: $gra, talia: $talia, lastPlayed: $PlayerLast, isActive: Binding<Bool>(
                    get: { activePlayer == 0 },
                    set: { newValue in
                        activePlayer = newValue ? 0 : 1 // Update activePlayer accordingly
                    }
                ), activePlayer: $activePlayer, gameRound: $gameRound)
            }
            .sheet(isPresented: $showZaklęcie, onDismiss: {
                showZaklęcieMini = true
            })
            {
                ZaklęcieView(gra: $gra, talia: $talia, lastPlayed: $PlayerLast, activePlayer: $activePlayer, gameRound: $gameRound, playerKey: playersList[activePlayer], calculateSpellCost: calculateSpellCost, allSpells: allSpells)
            }
            .sheet(isPresented: $showOdrzucanie) {
                checkumberOfCards()
            } content: {
                OdrzucanieKartView(gra: $gra, talia: $talia, activePlayer: $activePlayer, gameRound: $gameRound, show: $showOdrzucanie)
            }

            
        }
        .onAppear()
        {
            talia = Array(repeating: taliaBase, count: 6).flatMap { $0 }
            loadGame()
            if(UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight)
            {
                landscape = true
            }
            else
            {
                landscape = false
            }
            gameRound += 1
        }
        .onChange(of: UIDevice.current.orientation)
        {
            if(UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight)
            {
                landscape = true
            }
            else
            {
                landscape = false
            }
        }
        .onChange(of: gameRound)
        {
            activePlayer = gameRound % playersList.count
            setData(for: playersList[activePlayer], key: "mana", getData(for: playersList[activePlayer], key: "mana") + 1)
            var karty = getKarty(for: playersList[activePlayer])
            karty.append(contentsOf: loadCards(conut: 1))
            setKarty(for: playersList[activePlayer], value: karty)
        }
    }
    func checkumberOfCards()
    {
            var karty = getKarty(for: playersList[activePlayer])
            var maxKart = getData(for: playersList[activePlayer], key: "ilośćKart")  + (activePlayer == (gameRound % playersList.count) ? 1 : 0)
            if(karty.count > maxKart)
            {
                showOdrzucanie = true
            }
            else
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    gameRound += 1
                }
            }
    }
    func printFormatted(dictionary: Dictionary<String, Any>) {
        if let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print(jsonString)
        } else {
            print("Failed to format gra as JSON.")
        }
    }

    func addRandomCardsToSpell() {
        guard var zaklęcie = gra["Zaklęcie"] as? [String: Any] else { return }
        var cards = zaklęcie["karty"] as? [[String: Any]] ?? []

        for _ in 0..<3 {
            if talia.isEmpty { break }
            if let karta = talia.popLast() {
                cards.append(karta)
            }
        }

        zaklęcie["karty"] = cards
        gra["Zaklęcie"] = zaklęcie
    }


}

#Preview {
    ContentView()
}
