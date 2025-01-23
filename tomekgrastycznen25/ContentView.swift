//
//  ContentView.swift
//  tomekgrastycznen25
//
//  Created by Jacek Kałużny on 18/01/2025.
//

import SwiftUI
import SwiftData
import Foundation

func triggerLocalNetworkPermission() {
    let service = NetService(domain: "local.", type: "_tomekgra._tcp.", name: "TestService", port: 12345)
    service.publish()
    print("Published Bonjour service to trigger local network permission.")
}


struct ContentView: View {
    @StateObject var connectionManager: MPConnectionManager
    
    @AppStorage("yourName") var yourName = randomString(length: 8)
    
    @State public var gra: Dictionary<String, Any> = Dictionary<String, Any>()
    @State public var activePlayer : Int = 0
    @State public var thisDevice : Int = -1
    @State public var PlayerLast : String = ""
    @State public var gameRound : Int = 1
    @State public var talie : Dictionary<String, Array<Dictionary<String, Any>>> = Dictionary<String, Array<Dictionary<String, Any>>>()
    
    
    @State public var showZaklęcie = false
    @State public var showZaklęcieMini = false
    
    @State public var connectionView = false
    @State public var showOdrzucanie = false
    @State public var odrzucanieEndMove = false
    
    @State public var playerLoose : String = ""
    @State public var endGame : Bool = false
    @State public var startGame : Bool = false
    
    @State public var landscape = false
    
    @State public var actionUserIntpuKartaShow: Bool = false
    @State public var actionUserIntpuKartaOptions: Array<Dictionary<String, Any>> = Array<Dictionary<String, Any>>()
    @State public var actionUserIntpuKartaOnSelected: ((Int) -> Void)? = nil
    
    init(yourName: String) {
        self.yourName = yourName
        _connectionManager = StateObject(wrappedValue: MPConnectionManager(yourName: yourName))
    }
    var body: some View {
        if(connectionView)
        {
            MPPeersView(startGame: $startGame, visible: $connectionView, thisDevice: $thisDevice, yourName: yourName)
                .environmentObject(connectionManager)
            
        }
        else
        {
            if(!connectionManager.paired && thisDevice != -1)
            {
                MPPeersView(startGame: $startGame, visible: $connectionView, thisDevice: $thisDevice, yourName: yourName)
                    .environmentObject(connectionManager)
                
            }
            else
            {
                HStack {
                    VStack {
                        PlayerView(playerKey: "Player2", gra: $gra, talia: bindingForKey("Player2", in: $talie),
                                   lastPlayed: $PlayerLast, isActive: Binding<Bool>(
                                    get: { activePlayer == 1 && (thisDevice == 1 || thisDevice == -1) },
                                    set: { newValue in
                                        activePlayer = newValue ? 1 : 0 // Update activePlayer accordingly
                                    }
                                   ), activePlayer: $activePlayer, gameRound: $gameRound, landscape: $landscape, playerLoose: $playerLoose, endGame: $endGame)
                        .environmentObject(connectionManager)
                        StółView(
                            gra: $gra,
                            talie: $talie,
                            PlayerLast: $PlayerLast,
                            activePlayer: $activePlayer,
                            gameRound: $gameRound,
                            landscape: $landscape,
                            connectionView: $connectionView,
                            thisDevice: $thisDevice,
                            createSpell: createSpell
                        )
                        PlayerView(playerKey: "Player1", gra: $gra, talia: bindingForKey("Player1", in: $talie),
                                   lastPlayed: $PlayerLast,
                                   isActive: Binding<Bool>(
                                    get: { activePlayer == 0  && (thisDevice == 0 || thisDevice == -1) },
                                    set: { newValue in
                                        activePlayer = newValue ? 0 : 1 // Update activePlayer accordingly
                                    }
                                   ),
                                   activePlayer: $activePlayer, gameRound: $gameRound, landscape: $landscape,playerLoose: $playerLoose, endGame: $endGame)
                        .environmentObject(connectionManager)
                        
                    }
                    .sheet(isPresented: $showZaklęcie, onDismiss: {
                        showZaklęcieMini = true
                    })
                    {
                        ZaklęcieView(gra: $gra, talie: $talie, lastPlayed: $PlayerLast, activePlayer: $activePlayer, gameRound: $gameRound, landscape: $landscape, playerKey: playersList[activePlayer], calculateSpellCost: calculateSpellCost, allSpells: allSpells, cancelSpell: cancelSpell)
                    }
                    .sheet(isPresented: $showOdrzucanie) {
                        checkumberOfCards(endMove: odrzucanieEndMove)
                    } content: {
                        OdrzucanieKartView(gra: $gra, talie: $talie, activePlayer: $activePlayer, gameRound: $gameRound, show: $showOdrzucanie)
                    }
                    
                    
                }
                .onAppear()
                {
                    triggerLocalNetworkPermission()
                    loadGame()
                    let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                    let interfaceOrientation = scene?.interfaceOrientation
                    
                    if interfaceOrientation == .landscapeLeft || interfaceOrientation == .landscapeRight {
                        landscape = true
                    } else {
                        landscape = false
                    }
                    print("isLandscape \(landscape)")
                    gameRound += 1
                }
                .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                    let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                    let interfaceOrientation = scene?.interfaceOrientation
                    
                    if interfaceOrientation == .landscapeLeft || interfaceOrientation == .landscapeRight {
                        landscape = true
                    } else {
                        landscape = false
                    }
                    print("isLandscape \(landscape)")
                }
                .onChange(of: startGame)
                {
                    if(thisDevice == 1)
                    {
                        endGame = false
                        playerLoose = ""
                        gameRound = 1
                        loadGame()
                        gameRound += 1
                    }
                    else
                    {
                        thisDevice = 0
                    }
                    print("thisDevice = \(thisDevice)")
                }
                .onChange(of: gameRound)
                {
                    
                    activePlayer = gameRound % playersList.count
                    print("Next MOVE \(thisDevice), \(activePlayer), \(gameRound)")
                    if (activePlayer != thisDevice && thisDevice != -1) {
                        gra["talie"] = talie
                        connectionManager.send(gameState: gra)
                        print("Sent gra to peers")
                    }
                    else
                    {
                        if(!endGame)
                        {
                            checkumberOfCards(endMove: false)
                            waitForOdrzucanieToBeFalse {
                                setData(for: playersList[activePlayer], key: "mana", getData(for: playersList[activePlayer], key: "mana") + 1)
                                setData(for: playersList[activePlayer], key: "tarcza", max(0, getData(for: playersList[activePlayer], key: "tarcza") - 1))
                                var maxKart = getData(for: playersList[activePlayer], key: "ilośćKart")  + 1
                                var karty = getKarty(for: playersList[activePlayer])
                                karty.append(contentsOf: loadCards(conut: max(1, maxKart - karty.count), for: playersList[activePlayer]))
                                setKarty(for: playersList[activePlayer], value: karty)
                                
                                DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
                                    var maxKart = getData(for: playersList[activePlayer], key: "ilośćKart")  + 1
                                    var karty = getKarty(for: playersList[activePlayer])
                                    if(maxKart > karty.count)
                                    {
                                        karty.append(contentsOf: loadCards(conut: max(0, maxKart - karty.count), for: playersList[activePlayer]))
                                        setKarty(for: playersList[activePlayer], value: karty)
                                    }
                                    
                                }
                            }
                        }
                    }
                }
                .onChange(of: connectionManager.move) { newGra in
                    print("Updating local gra from received data")
                    DispatchQueue.main.async {
                        self.gra = connectionManager.gra
                        self.talie = gra["talie"] as! Dictionary<String, Array<Dictionary<String, Any>>>
                        activePlayer = thisDevice
                        if(getKarty(for: "Zaklęcie").count == 0)
                        {
                            var newgameRound = gameRound + 1
                            if(newgameRound % playersList.count != thisDevice)
                            {
                                newgameRound += 1
                            }
                            gameRound = newgameRound
                        }
                        else
                        {
                            showZaklęcie = true
                        }
                    }
                }
                .sheet(isPresented: $actionUserIntpuKartaShow)
                {
                    ForEach(actionUserIntpuKartaOptions.indices, id: \.self) { index in
                        Button("\((actionUserIntpuKartaOptions[index]).debugDescription)")
                        {
                            if(actionUserIntpuKartaOnSelected != nil)
                            {
                                actionUserIntpuKartaOnSelected!(index)
                            }
                        }
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
        var maxKart = getData(for: playersList[activePlayer], key: "ilośćKart")//  + (!endMove ? 1 : 0)
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

    func waitForOdrzucanieToBeFalse(completion: @escaping () -> Void) {
        DispatchQueue.global().async {
            var counter = 4
            while counter > 0
            {
                counter -= 1
                while self.showOdrzucanie {
                    // Wait for a short period before checking again
                    counter = 7
                    Thread.sleep(forTimeInterval: 0.1)
                }
                Thread.sleep(forTimeInterval: 0.1)
            }
            DispatchQueue.main.async {
                completion()
            }
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
    ContentView(yourName: "Jacek")
}
