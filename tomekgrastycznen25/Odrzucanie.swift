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
            Text("Odrzucanie kart")
                .font(.headline)
            Text(playersList[activePlayer])
                .font(.footnote)
            Text("Jeśli masz za dużo kart. Musisz wybrać, które chesz odrzucić")
            
            ProgressView(value: min(maxCards, cards)/max(cards, 1))
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
                                }, label: { KartaView(karta: karta, showPostacie: false, selectedCard: $selectedCard) })
                                
                                    
                            }
                        }
                    }
                    .onAppear()
                    {
                        cards = CGFloat(kartyLoad.count)
                        maxCards = CGFloat(container["ilośćKart"] as? Int ?? 0)// + (activePlayer == (gameRound % playersList.count) ? 1 : 0)
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
                            if(random)
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
                                KartaView(karta: karta, showPostacie: false, selectedCard: $selectedCard)
                            }
                        }
                    }
                }

            }
    }
}
