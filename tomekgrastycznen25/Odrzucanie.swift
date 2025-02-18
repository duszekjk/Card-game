//
//  Odrzucanie.swift
//  tomekgrastycznen25
//
//  Created by Jacek Kałużny on 20/01/2025.
//

import SwiftUI
struct OdrzucanieKartView: View {
    @Binding var gra: Dictionary<String, Any>
    @Binding var activePlayer : Int
    @Binding var gameRound : Int
    @Binding var show : Bool
    @Binding var selectedCard: String?
    
    @State var cards: CGFloat = 2.0
    @State var maxCards: CGFloat = 1.0
    
    var random = false
    var body: some View {
        VStack {
            Text(gra["ZaklęcieLastTableKey"] as? String ?? "")
                .font(.footnote)
                .padding(.bottom, -5)
            KartaContainerView(gra: .constant(gra), lastPlayed: .constant("None"), activePlayer: .constant(-21), gameRound: .constant(-21), landscape: .constant(true), selectedCard: .constant(nil), containerKey: "ZaklęcieLast", isDragEnabled: false, isDropEnabled: false)
            
            Divider()
            Spacer()
            Divider()
            Text("Odrzucanie kart")
                .font(.title2)
            Text(playersList[activePlayer])
                .font(.footnote)
            
            Text("Jeśli masz za dużo kart. Musisz wybrać, które chesz odrzucić")
            
            HStack
            {
                ProgressView(value: min(maxCards, cards)/max(cards, 1))
                    .padding()
                Text("\(min(maxCards, cards), specifier: "%d") / \(max(cards, 1), specifier: "%d")")
                
            }
            .padding()
            
            
            if let container = gra[playersList[activePlayer]] as? Dictionary<String, Any>
                {
                    let kartyLoad = container["karty"] as? Array<Dictionary<String, Any>> ?? emptyKarty
                    let karty = (kartyLoad.isEmpty) ? emptyKarty : kartyLoad
                    let columns = Array(repeating: GridItem(.flexible()), count: Int(max(1, min(5, karty.count))))

                    VStack {
                        LazyVGrid(columns: columns, spacing: 5) {
                            ForEach(0..<karty.count, id: \.self) { index in
                                let karta = karty[index]
                                Button(action: {
                                    let player = karta["player"] as! String
                                    var talia = getKarty(&gra, for: "Talia\(player)")
                                    talia.append(karta)
                                    var kartyEdit = karty
                                    kartyEdit.remove(at: index)
                                    var containerEdit = container
                                    containerEdit["karty"] = kartyEdit
                                    gra[playersList[activePlayer]] = containerEdit
                                    setKarty(&gra, for: "Talia\(player)", value: talia)
                                }, label: { KartaView(karta: karta, showPostacie: false, selectedCard: $selectedCard, orderChanges: $gameRound) })
                                
                                    
                            }
                        }
                    }
                    .padding()
                    .onAppear()
                    {
                        cards = CGFloat(kartyLoad.count)
                        maxCards = CGFloat(container["ilośćKart"] as? Int ?? 0)// + (activePlayer == (gameRound % playersList.count) ? 1 : 0)
                        print("onAppear OdrzucanieKartView maxCards \(maxCards)")
                        if(cards <= maxCards)
                        {
                            show = false
                        }
                        if(maxCards == 0)
                        {
                            for index in 0..<karty.count
                            {
                                let karta = karty[index]
                                let player = karta["player"] as! String
                                var talia = getKarty(&gra, for: "Talia\(player)")
                                talia.append(karta)
                                setKarty(&gra, for: "Talia\(player)", value: talia)
                            }
                            var kartyEdit = karty
                            kartyEdit.removeAll()
                            var containerEdit = container
                            containerEdit["karty"] = kartyEdit
                            gra[playersList[activePlayer]] = containerEdit
                        }
                        else
                        {
                            print("onAppear OdrzucanieKartView \((gameRound < 3)) \(gameRound)")
                            if(random || gameRound < 3)
                            {
                                let index = Int.random(in: 0..<karty.count)
                                let karta = karty[index]
                                let player = karta["player"] as? String ?? playersList[activePlayer]
                                var talia = getKarty(&gra, for: "Talia\(player)")
                                talia.append(karta)
                                var kartyEdit = karty
                                kartyEdit.remove(at: index)
                                var containerEdit = container
                                containerEdit["karty"] = kartyEdit
                                gra[playersList[activePlayer]] = containerEdit
                                setKarty(&gra, for: "Talia\(player)", value: talia)
                                show = false
                            }
                        }
                    }
                    .onChange(of: kartyLoad.count)
                    {
                        cards = CGFloat(kartyLoad.count)
                        maxCards = CGFloat(container["ilośćKart"] as? Int ?? 0) + (activePlayer == (gameRound % playersList.count) ? 1 : 0)
                        if(cards <= maxCards)
                        {
                            show = false
                        }
//                        if(random)
//                        {
//                            let index = Int.random(in: 0..<karty.count)
//                            let karta = karty[index]
//                            let player = karta["player"] as? String ?? playersList[activePlayer]
//                            var talia = getKarty(&gra, for: "Talia\(player)")
//                            talia.append(karta)
//                            var kartyEdit = karty
//                            kartyEdit.remove(at: index)
//                            var containerEdit = container
//                            containerEdit["karty"] = kartyEdit
//                            gra[playersList[activePlayer]] = containerEdit
//                            setKarty(&gra, for: "Talia\(player)", value: talia)
//                        }
                    }
                
                }
                else
                {
                    let karty = emptyKarty
                    let columns = Array(repeating: GridItem(.flexible()), count: Int(max(1, min(5, karty.count))))
                    VStack {
                        LazyVGrid(columns: columns, spacing: 5) {
                            ForEach(0..<karty.count, id: \.self) { index in
                                let karta = karty[index]
                                KartaView(karta: karta, showPostacie: false, selectedCard: $selectedCard, orderChanges: $gameRound)
                            }
                        }
                    }
                }

            }
    }
}
