//
//  StółView.swift
//  tomekgrastycznen25
//
//  Created by Jacek Kałużny on 21/01/2025.
//


import SwiftUI

struct StółView: View {
    @Binding var gra: Dictionary<String, Any>
    @Binding var talie: Dictionary<String, Array<Dictionary<String, Any>>>
    @Binding var PlayerLast: String
    @Binding var activePlayer: Int
    @Binding var gameRound: Int
    @Binding var landscape : Bool
    @Binding var connectionView: Bool
    @Binding var thisDevice: Int
    var createSpell: (String, String, Array<Dictionary<String, Any>>) -> Void
    
    
    // Define variables for shared frame sizes
    private var kartaWidth: CGFloat {
        UIDevice.current.userInterfaceIdiom == .phone ? 252 : 306
    }
    private var kartaHeight: CGFloat {
        UIDevice.current.userInterfaceIdiom == .phone ? 94 : 140
    }
    var body: some View {
        HStack {
            VStack {
                KartaContainerView(
                    gra: $gra,
                    talia: bindingForKey(playersList[activePlayer], in: $talie),
                    lastPlayed: $PlayerLast,
                    activePlayer: $activePlayer,
                    gameRound: $gameRound,
                    landscape: $landscape,
                    containerKey: "TablePlayer2",
                    sizeFullAction: { tableKey, kards in
                        createSpell("Player2", tableKey, kards) // No labels here
                    }
                )
                .frame(width: kartaWidth, height: kartaHeight)
                
                KartaContainerView(
                    gra: $gra,
                    talia: bindingForKey(playersList[activePlayer], in: $talie),
                    lastPlayed: $PlayerLast,
                    activePlayer: $activePlayer,
                    gameRound: $gameRound,
                    landscape: $landscape,
                    containerKey: "TablePlayerLast",
                    sizeFullAction: { tableKey, kards in
                        createSpell(PlayerLast, tableKey, kards) // No labels here
                    }
                )
                .frame(width: kartaWidth, height: kartaHeight)
                
                KartaContainerView(
                    gra: $gra,
                    talia: bindingForKey(playersList[activePlayer], in: $talie),
                    lastPlayed: $PlayerLast,
                    activePlayer: $activePlayer,
                    gameRound: $gameRound,
                    landscape: $landscape,
                    containerKey: "TablePlayer1",
                    sizeFullAction: { tableKey, kards in
                        createSpell("Player1", tableKey, kards) // No labels here
                    }
                )
                .frame(width: kartaWidth, height: kartaHeight)
            }
            .padding(UIDevice.current.userInterfaceIdiom == .phone ? 1 : 8)
            
            VStack {
                Text("Lingering")
                    .font(.footnote)
                VStack {
                    
                    KartaContainerView(
                        gra: $gra,
                        talia: bindingForKey(playersList[activePlayer], in: $talie),
                        lastPlayed: $PlayerLast,
                        activePlayer: $activePlayer,
                        gameRound: $gameRound,
                        landscape: $landscape,
                        containerKey: "Lingering",
                        size: 3
                    )
                    .scaleEffect(UIDevice.current.userInterfaceIdiom == .phone ? 0.7 : 0.8)
                    .padding(UIDevice.current.userInterfaceIdiom == .phone ? 1 : 8)
                    .rotationEffect(Angle(degrees: 90))
                    
                }
                .frame(
                    width: UIDevice.current.userInterfaceIdiom == .phone ? 120 : 240,
                    height: UIDevice.current.userInterfaceIdiom == .phone ? 180 : 290
                )
                    Text("Ruch \(gameRound - 1)")
                        .padding()
                    if(gameRound < 3 && thisDevice == -1)
                    {
                        Button("Multiplayer BT") {
                            connectionView = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
            }
        }
    }
}
