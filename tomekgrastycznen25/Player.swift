//
//  Player.swift
//  tomekgrastycznen25
//
//  Created by Jacek Kałużny on 18/01/2025.
//

import SwiftUI

struct PlayerView: View {
    let playerKey: String
    @Binding var gra: Dictionary<String, Any>
    @Binding var talia: Array<Dictionary<String, Any>>
    @Binding var lastPlayed: String
    @Binding var isActive: Bool
    @Binding var activePlayer : Int
    @Binding var gameRound : Int

    var body: some View {
        if let player = gra[playerKey] as? Dictionary<String, Any> {
            VStack(alignment: .leading, spacing: 10) {
                // Name
                Text(player["nazwa"] as? String ?? "Unknown Player")
                    .font(.title2)
                    .fontWeight(.bold)

                // ilośćKart, mana/manaMax, życie


                // karty
                if(isActive)
                {
                    KartaContainerView(gra: $gra, talia: $talia, lastPlayed: $lastPlayed, activePlayer: $activePlayer, gameRound: $gameRound, containerKey: playerKey, isDropEnabled: false, size: max(1, min(CGFloat(integerLiteral: (player["karty"]  as? Array<Dictionary<String, Any>>)?.count ?? 0), 5)))
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
                            Text("\(player["mana"] as? Int ?? 0)/\(player["manaMax"] as? Int ?? 0)")
                        }

                        Spacer()

                        // życie
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                            Text("\(player["życie"] as? Int ?? 0)")
                        }
                        Spacer()
                    }
                    .font(.headline)
                    Divider()
                    Spacer()
                    VStack(alignment: .leading){
                        HStack(alignment: .firstTextBaseline) {
                            Image(systemName: "wand.and.stars")
                            Text(player["akcjaRzucaneZaklęcie"] as? String ?? "No Action")
                                .font(.caption)
                                .foregroundColor(.blue)
                                .lineLimit(2)
                            
                        }
                        
                        // akcjaOdrzucaneZaklęcie
                        HStack(alignment: .firstTextBaseline) {
                            Image(systemName: "trash.fill")
                            Text(player["akcjaOdrzucaneZaklęcie"] as? String ?? "No Action")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .lineLimit(2)
                        }
                    }
                }
                .scaleEffect(UIDevice.current.userInterfaceIdiom == .phone ? 0.75 : 1.0)
            }
            .padding()
            .padding(.vertical, 40)
            .background(RoundedRectangle(cornerRadius: 10).fill(isActive ? Color(UIColor.secondarySystemGroupedBackground) : Color(UIColor.systemGroupedBackground)))
            .shadow(radius: isActive ? 6 : 1)
            .frame(maxWidth: UIScreen.main.bounds.size.width - 2.0)
        } else {
            Text("Player not found")
                .font(.headline)
                .foregroundColor(.red)
        }
    }
}
