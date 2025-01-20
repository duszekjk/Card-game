//
//  Zaklecie.swift
//  tomekgrastycznen25
//
//  Created by Jacek Kałużny on 20/01/2025.
//


import SwiftUI

struct ZaklęcieView: View {
    
    @Binding var gra: Dictionary<String, Any>
    @Binding var talia: Array<Dictionary<String, Any>>
    @Binding var lastPlayed: String
    @Binding var activePlayer : Int
    @Binding var gameRound : Int
    
    var playerKey:String
    
    var calculateSpellCost: () -> Int?
    var allSpells: () -> Void
    
    
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
                loadData()
            }
            HStack
            {
                ProgressView(value: (CGFloat(mana + życie + karty)/CGFloat(cost)))
                Text("\(mana + życie + karty)/\(cost)")
            }
            .padding()
            HStack(alignment: .firstTextBaseline)
            {
                Stepper("Mana \(mana)/\(manaMax)", value: $mana, in: 0...manaMax)
                    .frame(width:160)
                    .padding()
                VStack
                {
                    HStack
                    {
                        Stepper("Karty \(karty)/\(kartyMax)", value: $karty, in: 0...kartyMax)
                            .frame(width:160)
                            .padding()
                        Stepper("Życie \(życie)/\(życieMax)", value: $życie, in: 0...życieMax)
                            .frame(width:160)
                            .padding()
                    }
                    Text("Sacrifice")
                        .font(.footnote)
                }
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                
            }
            .padding()
            Divider()
            KartaContainerView(gra: $gra, talia: $talia, lastPlayed: $lastPlayed, activePlayer: $activePlayer, gameRound: $gameRound, containerKey: "Zaklęcie")
            
            HStack
            {
                Button("Rzuć", action: {
                    setData(for: "mana", manaMax - mana)
                    setData(for: "życie", życieMax - życie)
                    setData(for: "ilośćKart", kartyMax - karty)
                    allSpells()
                })
                .buttonStyle(.borderedProminent)
                .disabled((mana + życie + karty) != cost)
                
                Button("Odrzuć", action: {
                    allSpells()
                })
                .buttonStyle(.borderedProminent)
            }
            .padding()
            
        }
        .padding()
    }
    func loadData()
    {
        cost = calculateSpellCost() ?? 0
        manaMax = getData(for: "mana")
        życieMax = getData(for: "życie")
        kartyMax = getData(for: "ilośćKart")
        
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
    func getData(for name: String) -> Int
    {
        guard let gracz = gra[playerKey] as? [String: Any],
              let value = gracz[name] as? Int else { return 0 }
        return max(0, value)
    }
    func setData(for name: String, _ value: Int)
    {
        if var gracz = gra[playerKey] as? [String: Any] {
            gracz[name] = max(0, value)
        gra[playerKey] = gracz
        } else {
            print("Zaklęcie not found!!!")
        }
    }
}
