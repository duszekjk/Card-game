//
//  Player.swift
//  tomekgrastycznen25
//
//  Created by Jacek Kałużny on 18/01/2025.
//

import SwiftUI

struct PlayerView: View {
    @EnvironmentObject var connectionManager: MPConnectionManager
    let playerKey: String
    @Binding var gra: Dictionary<String, Any>
    @Binding var talia: Array<Dictionary<String, Any>>
    @Binding var lastPlayed: String
    @Binding var isActive: Bool
    @Binding var activePlayer : Int
    @Binding var gameRound : Int
    @Binding var landscape : Bool
    @Binding var playerLoose : String
    @Binding var endGame : Bool
    
    @State var showBig: Bool = false
    var body: some View {
        if let player = gra[playerKey] as? Dictionary<String, Any> {
            VStack(alignment: .leading, spacing: 10) {
                // Name
                Text(player["nazwa"] as? String ?? "Unknown Player")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.leading, 40)

                // ilośćKart, mana/manaMax, życie


                // karty
                if(isActive)
                {
                    KartaContainerView(gra: $gra, talia: $talia, lastPlayed: $lastPlayed, activePlayer: $activePlayer, gameRound: $gameRound, landscape: $landscape, containerKey: playerKey, isDropEnabled: false, size: max(3, min(CGFloat(integerLiteral: (player["karty"]  as? Array<Dictionary<String, Any>>)?.count ?? 3), 10)))
                }

                // akcjaRzucaneZaklęcie
                HStack
                {
                    HStack {
                        // ilośćKart
                        HStack {
                            Image(systemName: "doc.on.doc")
                            Text("\(player["ilośćKart"] as? Int ?? 0)")
                        }

                        Spacer()

                        // mana/manaMax
                        HStack {
                            Image(systemName: "bolt.fill")
                            Text("\(player["mana"] as? Int ?? 0) /\(player["manaMax"] as? Int ?? 0)")
                        }
                        .onChange(of: player["mana"] as? Int ?? 0)
                        { newValue in
                            var manaMax = player["manaMax"] as? Int ?? 0
                            if(newValue > manaMax)
                            {
                                var updatedPlayer = player
                                updatedPlayer["mana"] = manaMax
                                gra[playerKey] = updatedPlayer
                            }
                        }

                        Spacer()

                        // tarcza
                        HStack {
                            Image(systemName: "shield.pattern.checkered")
                                .foregroundColor(.red)
                            Text("\(player["tarcza"] as? Int ?? 0)")
                        }
                        
                        Spacer()

                        // życie
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                            Text("\(player["życie"] as? Int ?? 0)")
                        }
                        .onChange(of: player["życie"] as? Int ?? 0) { newValue in
                            if let life = newValue as? Int, life == 0 {
                                playerLoose = playerKey // Set the player who lost
                                connectionManager.send(gameState: gra)
                                endGame = true          // Trigger the end of the game
                            }
                        }

                        Spacer()
                    }
                    .font(.headline)
                    Divider()
                    Spacer()
                    VStack(alignment: .leading){
                        HStack(alignment: .firstTextBaseline) {
                            Image(systemName: "wand.and.stars")
                            Text(player["opisRzucaneZaklęcie"] as? String ?? "Brak akcji")
                                .font(.caption)
                                .foregroundColor(.blue)
                                .lineLimit(2)
                            
                        }
                        
                        // akcjaOdrzucaneZaklęcie
                        HStack(alignment: .firstTextBaseline) {
                            Image(systemName: "trash.fill")
                            Text(player["opisOdrzucaneZaklęcie"] as? String ?? "Brak akcji")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .lineLimit(2)
                        }
                    }
                }
                .scaleEffect(UIDevice.current.userInterfaceIdiom == .phone ? 0.75 : 1.0)
            }
            .padding()
//            .padding(.vertical, 40)
            .background(RoundedRectangle(cornerRadius: 10).fill(isActive ? Color(UIColor.secondarySystemGroupedBackground) : Color(UIColor.systemGroupedBackground)))
            .shadow(radius: isActive ? 6 : 1)
            .frame(minWidth: UIScreen.main.bounds.size.width/2, idealWidth: UIScreen.main.bounds.size.width - 5.0, maxWidth: UIScreen.main.bounds.size.width - 2.0)
            .onTapGesture(count: 1) {
                DispatchQueue.main.async
                {
                    showBig = true
                }
            }
            .sheet(isPresented: $showBig)
            {
                PlayerBigView(playerKey: playerKey, gra: $gra, talia: $talia, lastPlayed: $lastPlayed, isActive: $isActive, activePlayer: $activePlayer, gameRound: $gameRound
                              , landscape: $landscape, playerLoose: $playerLoose, endGame: $endGame)
            }
        } else {
            Text("Player not found")
                .font(.headline)
                .foregroundColor(.red)
        }
    }
}
struct PlayerBigView: View {
    let playerKey: String
    @Binding var gra: Dictionary<String, Any>
    @Binding var talia: Array<Dictionary<String, Any>>
    @Binding var lastPlayed: String
    @Binding var isActive: Bool
    @Binding var activePlayer : Int
    @Binding var gameRound : Int
    @Binding var landscape : Bool
    @Binding var playerLoose : String
    @Binding var endGame : Bool
    
    var body: some View {
        if let player = gra[playerKey] as? Dictionary<String, Any> {
            VStack(alignment: .center, spacing: 10) {
                // Name
                if let playerName = player["nazwa"] as? String,
                   UIImage(named: playerName) != nil {
                    ZStack {
                        // Background Image with Inner Shadow
                        Image(playerName)
                            .resizable()
                            .scaledToFill()
                            .blur(radius: 30)
                        Image(playerName)
                            .resizable()
                            .scaledToFill()
                            .blur(radius: 30)
                        Image(playerName)
                            .resizable()
                            .scaledToFill()
                            .blur(radius: 50)
                        Image(playerName)
                            .resizable()
                            .scaledToFill()
                            .blur(radius: 50)
                        Image(playerName)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                            ) // Rounded top corners
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(Color.primary.opacity(0.1), lineWidth: 0) // Subtle edge polish
                            )
                            .overlay(
                                // Simulate inner shadow using gradient
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.black.opacity(0.2), // Dark inner shadow
                                                Color.clear
                                            ]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                            )
                            .clipped()

                    }
                    .frame(maxWidth: .infinity, maxHeight: 300) // Adjust height as needed
                    
                    Text(player["nazwa"] as? String ?? "Unknown Player")
                        .foregroundColor(.white)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                else
                {
                    Text(player["nazwa"] as? String ?? "Unknown Player")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                }

//                    .padding(.leading, 40)
                // karty
                if(isActive)
                {
                    KartaContainerView(gra: $gra, talia: $talia, lastPlayed: $lastPlayed, activePlayer: $activePlayer, gameRound: $gameRound, landscape: $landscape, containerKey: playerKey, isDropEnabled: false, size: max(1, min(CGFloat(integerLiteral: (player["karty"]  as? Array<Dictionary<String, Any>>)?.count ?? 3), 10)))
                }

                // akcjaRzucaneZaklęcie
                VStack
                {
                    HStack {
                        // ilośćKart
                        Spacer()
                        HStack {
                            Image(systemName: "doc.on.doc")
                            Text("\(player["ilośćKart"] as? Int ?? 0)")
                        }

                        Spacer()

                        // mana/manaMax
                        HStack {
                            Image(systemName: "bolt.fill")
                            Text("\(player["mana"] as? Int ?? 0)/\(player["manaMax"] as? Int ?? 0)")
                        }

                        Spacer()
                        
                        HStack {
                            Image(systemName: "shield.pattern.checkered")
                                .foregroundColor(.red)
                            Text("\(player["tarcza"] as? Int ?? 0)")
                        }
                        
                        // życie
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                            Text("\(player["życie"] as? Int ?? 0)")
                        }

                        Spacer()
                    }
                    .font(.headline)
                    .padding()
                    Divider()
                    Spacer()
                    Text(player["opis"] as? String ?? "")
                    Spacer()
                    VStack(alignment: .leading){
                        HStack(alignment: .firstTextBaseline) {
                            Image(systemName: "wand.and.stars")
                            Text(player["opisRzucaneZaklęcie"] as? String ?? "No Action")
                                .font(.caption)
                                .foregroundColor(.blue)
                                .lineLimit(2)
                            
                        }
                        
                        // akcjaOdrzucaneZaklęcie
                        HStack(alignment: .firstTextBaseline) {
                            Image(systemName: "trash.fill")
                            Text(player["opisOdrzucaneZaklęcie"] as? String ?? "No Action")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .lineLimit(2)
                        }
                    }
                }
                .scaleEffect(UIDevice.current.userInterfaceIdiom == .phone ? 0.75 : 1.0)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(isActive ? Color(UIColor.secondarySystemGroupedBackground) : Color(UIColor.systemGroupedBackground)))
            .frame(minHeight: UIScreen.main.bounds.size.height*0.85)
            .shadow(radius: isActive ? 6 : 1)
        } else {
            Text("Player not found")
                .font(.headline)
                .foregroundColor(.red)
        }
    }
}
