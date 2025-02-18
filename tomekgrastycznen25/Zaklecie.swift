//
//  Zaklecie.swift
//  tomekgrastycznen25
//
//  Created by Jacek Kałużny on 20/01/2025.
//


import SwiftUI

struct ZaklęcieView: View {
    
    @Binding var gra: Dictionary<String, Any>
    @Binding var lastPlayed: String
    @Binding var activePlayer : Int
    @Binding var gameRound : Int
    @Binding var landscape : Bool
    @Binding var selectedCard: String?
    
    var playerKey:String = ""
    
    var calculateSpellCost: () -> Int?
    var allSpells: () -> Void
    var cancelSpell: () -> Void
    
    
    @State var cost = 0
    
    @State var mana = 0
    @State var życie = 0
    @State var karty = 0
    
    @State var manaMax = 0
    @State var życieMax = 0
    @State var kartyMax = 0
    var body: some View {
        VStack
        {
            Text("Cena zaklęcia \(cost)")
                .onAppear()
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    loadData()
                }
            }
            HStack
            {
                ProgressView(value: (CGFloat(mana + życie + karty)/CGFloat(cost)))
                Text("\(mana + życie + karty)/\(cost)")
            }
            .padding()
            if(landscape)
            {
                HStack(alignment: .firstTextBaseline)
                {
                    Stepper("Mana \(mana)/\(manaMax)", value: $mana, in: 0...manaMax)
                        .frame(width:250)
                        .padding()
                    VStack
                    {
                        HStack
                        {
                            Stepper("Karty \(karty)/\(kartyMax)", value: $karty, in: 0...kartyMax)
                                .frame(width:250)
                                .padding()
                            Stepper("Życie \(życie)/\(życieMax)", value: $życie, in: 0...życieMax)
                                .frame(width:250)
                                .padding()
                        }
                        Text("Sacrifice")
                            .font(.footnote)
                    }
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                    
                }
                .padding()
            }
            else
            {
                VStack(alignment: .center)
                {
                    Stepper("Mana \(mana)/\(manaMax)", value: $mana, in: 0...manaMax)
                        .frame(width:250)
                        .padding()
                    VStack
                    {
                        VStack
                        {
                            Stepper("Karty \(karty)/\(kartyMax)", value: $karty, in: 0...kartyMax)
                                .frame(width:250)
                                .padding()
                            Stepper("Życie \(życie)/\(życieMax)", value: $życie, in: 0...życieMax)
                                .frame(width:250)
                                .padding()
                        }
                        Text("Sacrifice")
                            .font(.footnote)
                    }
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                    
                }
                .padding()
                
            }
            Divider()
            KartaContainerView(gra: $gra, lastPlayed: $lastPlayed, activePlayer: $activePlayer, gameRound: $gameRound, landscape: $landscape, selectedCard: $selectedCard, containerKey: "Zaklęcie", isReorderable: true, size: 11)
            
            HStack
            {
                Button("Rzuć", action: {
                    setData(&gra, for: playerKey, key: "mana", manaMax - mana)
                    setData(&gra, for: playerKey, key: "życie", życieMax - życie)
                    setData(&gra, for: playerKey, key: "ilośćKart", kartyMax - karty)
                    if var gracz = gra["Zaklęcie"] as? [String: Any] {
                        gracz["sacrifice"] = max(0, życie + karty)
                    gra["Zaklęcie"] = gracz
                    } else {
                        print("Zaklęcie not found!!!")
                    }
                    allSpells()
                })
                .buttonStyle(.borderedProminent)
                .disabled((mana + życie + karty) != cost || życieMax - życie < 3)
                
                Button("Odrzuć", action: {
                    cancelSpell()
                })
                .buttonStyle(.borderedProminent)
            }
            .padding()
            
        }
        .padding()
    }
    func loadData()
    {
//        playerKey = playersList[activePlayer]
//        
//        print("zaklęcie countig \(playerKey)")
        cost = calculateSpellCost() ?? 0
        manaMax = getData(&gra, for: playerKey, key: "mana")
        życieMax = getData(&gra, for: playerKey, key: "życie")
        kartyMax = getData(&gra, for: playerKey, key: "ilośćKart")
        
        mana = min(cost, manaMax)
        karty = 0
        życie = 0
        if(mana < cost)
        {
            karty = min(cost - mana, kartyMax)
            
            if(mana + karty < cost)
            {
                życie = min(cost - (mana + karty), życieMax)
            }
        }
    }
}
