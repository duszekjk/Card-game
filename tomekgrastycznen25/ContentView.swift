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
    @State public var gameRound : Int = 1
    @State public var talie : Dictionary<String, Array<Dictionary<String, Any>>> = Dictionary<String, Array<Dictionary<String, Any>>>()
    
    
    @State public var showZaklęcie = false
    @State public var showZaklęcieMini = false
    
    @State public var showOdrzucanie = false
    @State public var odrzucanieEndMove = false
    @State public var showTalia: Bool = false
    @State public var showTaliaID: Int = 0
    
    @State public var playerLoose : String = ""
    @State public var endGame : Bool = false
    
    @State public var landscape = false

    var body: some View {
        HStack {
            if(landscape)
            {
                VStack
                {
                    TaliaView(gra: $gra, talia: bindingForKey("Player2", in: $talie), nazwa: "Talia Player 2")
                        .onTapGesture(count: 2) {
                            DispatchQueue.main.async
                            {
                                showTaliaID = 2
                                print("(showTaliaID - 1) \((showTaliaID - 1)) / \(playersList.count)  \(showTaliaID > 0 && showTaliaID < playersList.count + 1)")
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                showTalia.toggle()
                            }
                        }
                    Text("Debug menu")
                        .font(.headline)
                    Text("Dodatkowe pomocnicze\nopcje i opisy\nna czas tworzenia")
                    Text("Ruch \(gameRound)")
                        .padding()
                    Button("Koniec ruchu", action:  { activePlayer += 1
                        activePlayer = activePlayer % playersList.count}
                           
                           
                    )
                    
                    Button("Run Spell") {
                        allSpells()
                    }
                    .padding()
                    TaliaView(gra: $gra, talia: bindingForKey("Player1", in: $talie), nazwa: "Talia Player 1")
                        .onTapGesture(count: 2) {
                            DispatchQueue.main.async
                            {
                                showTaliaID = 1
                                print("(showTaliaID - 1) \((showTaliaID - 1)) / \(playersList.count)  \(showTaliaID > 0 && showTaliaID < playersList.count + 1)")
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                showTalia.toggle()
                            }
                        }
                }
                .sheet(isPresented: $showTalia) {
                    TaliaSheetContent(
                        showTaliaID: $showTaliaID,
                        gra: $gra,
                        talie: $talie,
                        PlayerLast: $PlayerLast,
                        activePlayer: $activePlayer,
                        gameRound: $gameRound,
                        playersList: playersList
                    )
                }
                Divider()
            }
            VStack {
                PlayerView(playerKey: "Player2", gra: $gra, talia: bindingForKey("Player2", in: $talie),
                           lastPlayed: $PlayerLast, isActive: Binding<Bool>(
                                get: { activePlayer == 1 },
                                set: { newValue in
                                    activePlayer = newValue ? 1 : 0 // Update activePlayer accordingly
                                }
                           ), activePlayer: $activePlayer, gameRound: $gameRound, landscape: $landscape, playerLoose: $playerLoose, endGame: $endGame)
                HStack
                {
                    VStack
                    {
                        KartaContainerView(gra: $gra, talia: bindingForKey(playersList[activePlayer], in: $talie), lastPlayed: $PlayerLast, activePlayer: $activePlayer, gameRound: $gameRound, containerKey: "TablePlayer2", sizeFullAction: { tableKey, kards in
                            createSpell(for: "Player2", from: tableKey, with: kards)
                        })
                        .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 252 : 336, height: UIDevice.current.userInterfaceIdiom == .phone ? 105 : 150)
                        KartaContainerView(gra: $gra, talia: bindingForKey(playersList[activePlayer], in: $talie), lastPlayed: $PlayerLast, activePlayer: $activePlayer, gameRound: $gameRound, containerKey: "TablePlayerLast", sizeFullAction: { tableKey, kards in
                            createSpell(for: PlayerLast, from: tableKey, with: kards)
                        })
                        .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 252 : 336, height: UIDevice.current.userInterfaceIdiom == .phone ? 105 : 150)
                        KartaContainerView(gra: $gra, talia: bindingForKey(playersList[activePlayer], in: $talie), lastPlayed: $PlayerLast, activePlayer: $activePlayer, gameRound: $gameRound, containerKey: "TablePlayer1", sizeFullAction: { tableKey, kards in
                            createSpell(for: "Player1", from: tableKey, with: kards)
                        })
                        .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 252 : 336, height: UIDevice.current.userInterfaceIdiom == .phone ? 105 : 150)
                    }
                    .padding(UIDevice.current.userInterfaceIdiom == .phone ? 1 : 8)
                    
                    VStack
                    {
                        Text("Lingering")
                            .font(.footnote)
                        KartaContainerView(gra: $gra, talia: bindingForKey(playersList[activePlayer], in: $talie), lastPlayed: $PlayerLast, activePlayer: $activePlayer, gameRound: $gameRound, containerKey: "Lingering", size: 2)
                            .scaleEffect(UIDevice.current.userInterfaceIdiom == .phone ? 0.7 : 1.0)
                            .padding(UIDevice.current.userInterfaceIdiom == .phone ? 1 : 8)
                            .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? 110 : 240, height: UIDevice.current.userInterfaceIdiom == .phone ? 250 : 450)
                        //                        .background(.blue)
                    }
                }
                    PlayerView(playerKey: "Player1", gra: $gra, talia: bindingForKey("Player1", in: $talie),
                               lastPlayed: $PlayerLast,
                               isActive: Binding<Bool>(
                                get: { activePlayer == 0 },
                                set: { newValue in
                                    activePlayer = newValue ? 0 : 1 // Update activePlayer accordingly
                                }
                               ),
                               activePlayer: $activePlayer, gameRound: $gameRound, landscape: $landscape,playerLoose: $playerLoose, endGame: $endGame)
            }
            .sheet(isPresented: $showZaklęcie, onDismiss: {
                showZaklęcieMini = true
            })
            {
                ZaklęcieView(gra: $gra, talie: $talie, lastPlayed: $PlayerLast, activePlayer: $activePlayer, gameRound: $gameRound, playerKey: playersList[activePlayer], calculateSpellCost: calculateSpellCost, allSpells: allSpells)
            }
            .sheet(isPresented: $showOdrzucanie) {
                checkumberOfCards(endMove: odrzucanieEndMove)
            } content: {
                OdrzucanieKartView(gra: $gra, talie: $talie, activePlayer: $activePlayer, gameRound: $gameRound, show: $showOdrzucanie)
            }

            
        }
        .onAppear()
        {
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
            if(!endGame)
            {
                print("Next MOVE")
                activePlayer = gameRound % playersList.count
                checkumberOfCards(endMove: false)
                setData(for: playersList[activePlayer], key: "mana", getData(for: playersList[activePlayer], key: "mana") + 1)
                var maxKart = getData(for: playersList[activePlayer], key: "ilośćKart")  + 1
                var karty = getKarty(for: playersList[activePlayer])
                karty.append(contentsOf: loadCards(conut: max(0, maxKart - karty.count), for: playersList[activePlayer]))
                setKarty(for: playersList[activePlayer], value: karty)
            }
        }
        .sheet(isPresented: $endGame) {
            VStack {
                Text("Game Over!")
                    .font(.largeTitle)
                    .padding()

                let playerWin = playersList.first { $0 != playerLoose } ?? "Unknown"
                let nameWin = getTextData(for: playerWin, key: "nazwa")
                let nameLoose = getTextData(for: playerLoose, key: "nazwa")
                Text("\(nameWin) (\(playerWin)) wins!")
                    .font(.title2)
                    .padding()

                Text("\(nameLoose) (\(playerLoose)) loses.")
                    .font(.title3)
                    .padding()

                Button("Restart Game") {
                    endGame = false
                    playerLoose = ""
                    gameRound = 1
                    loadGame()
                    if(UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight)
                    {
                        landscape = true
                    }
                    else
                    {
                        landscape = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
        }

    }
    func checkumberOfCards(endMove: Bool = true)
    {
        if(endGame)
        {
            return
        }
        print("checkumberOfCards end\(endMove)")
        odrzucanieEndMove = endMove
        var karty = getKarty(for: playersList[activePlayer])
        var maxKart = getData(for: playersList[activePlayer], key: "ilośćKart")  + (!endMove ? 1 : 0)
        if(karty.count > maxKart)
        {
            showOdrzucanie = true
        }
        else
        {
            if(endMove)
            {
                odrzucanieEndMove = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    gameRound += 1
                }
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



}
func bindingForKey<T>(_ key: String, in dictionary: Binding<[String: [T]]>) -> Binding<[T]> {
    Binding(
        get: { dictionary.wrappedValue[key] ?? [] },
        set: { newValue in
            dictionary.wrappedValue[key] = newValue
        }
    )
}

#Preview {
    ContentView()
}
