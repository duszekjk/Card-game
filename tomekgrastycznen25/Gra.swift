//
//  Gra.swift
//  tomekgrastycznen25
//
//  Created by Jacek Kałużny on 18/01/2025.
//

import SwiftUI

var playersList = ["Player1", "Player2"]



extension ContentView
{
    func loadGame()
    {
        gra["Player1"] = loadPlayer(id:1)
        gra["Player2"] = loadPlayer(id:2)
        gra["TablePlayer1"] = loadTable()
        gra["TablePlayerLast"] = loadTable()
        gra["TablePlayer2"] = loadTable()
        gra["Lingering"] = loadTable()
        gra["Extra"] = loadTable()
        gra["Zaklęcie"] = loadSpell()
    }
    func loadTable() -> Dictionary<String, Any>
    {
        var table: Dictionary<String, Any> = Dictionary<String, Any>()
        table["karty"] = Array<Dictionary<String, Any>>()
        return table
        
    }
    func loadSpell()  -> Dictionary<String, Any>
    {
        var zaklęcie: Dictionary<String, Any> = Dictionary<String, Any>()
        zaklęcie["koszt"] = 0
        zaklęcie["atak"] = 0
        zaklęcie["karty"] = Array<Dictionary<String, Any>>()
        return zaklęcie
    }
    func loadPlayer(id: Int = 0) -> Dictionary<String, Any>
    {
        var gracz: Dictionary<String, Any> = Dictionary<String, Any>()
        let taliaAll = Array(repeating: taliaBase, count: 5).flatMap { $0 }
        if(id == 1)
        {
            gracz["id"] = "Player1"
            gracz["nazwa"] = "Mag Światła"
            talie[gracz["id"] as! String] = taliaAll.filter { card in
                guard let postacie = card["postacie"] as? [String] else {
                    return false
                }
                return postacie.contains(gracz["nazwa"] as! String)
            }.map { card in
                var modifiedCard = card
                modifiedCard["player"] = "Player1"
                return modifiedCard
            }
            gracz["ilośćKart"] = Int(3)
            gracz["manaMax"] = Int(10)
            gracz["mana"] = Int(3)
            gracz["życie"] = Int(9)
            gracz["akcjaRzucaneZaklęcie"] = "@Zaklęcie.karty.a.lingeringNow = 1"//selectKarta
            gracz["akcjaOdrzucaneZaklęcie"] = ""
            gracz["opisRzucaneZaklęcie"] = "Gdy rzucasz zaklęcie, jeden fragment dostaje Lingering"
            gracz["opisOdrzucaneZaklęcie"] = nil
            gracz["karty"] = loadCards(conut: gracz["ilośćKart"] as! Int, for: gracz["id"] as! String)
        }
        if(id == 2)
        {
            gracz["id"] = "Player2"
            gracz["nazwa"] = "Mag Krwii"
            talie[gracz["id"] as! String] = taliaAll.filter { card in
                guard let postacie = card["postacie"] as? [String] else {
                    return false
                }
                return postacie.contains(gracz["nazwa"] as! String)
            }.map { card in
                var modifiedCard = card
                modifiedCard["player"] = "Player1"
                return modifiedCard
            }
            gracz["ilośćKart"] = Int(2)
            gracz["manaMax"] = Int(6)
            gracz["mana"] = Int(3)
            gracz["życie"] = Int(12)
            gracz["akcjaRzucaneZaklęcie"] = "@PlayerMe.życie = @PlayerMe.życie - 1 & @Zaklęcie.koszt = @Zaklęcie.koszt - 3"
            gracz["akcjaOdrzucaneZaklęcie"] = ""
            gracz["opisRzucaneZaklęcie"] = "Gdy rzucasz zaklęcie, tracisz 1 ❤️ i staniasz to zaklęcie o 3."
            gracz["opisOdrzucaneZaklęcie"] = nil
            gracz["karty"] = loadCards(conut: gracz["ilośćKart"] as! Int, for: gracz["id"] as! String)
        }
        
        return gracz
    }
    func loadCards(conut numberOfCards:Int, for player: String) -> Array<Dictionary<String, Any>>
    {
        var talia = talie[player]!
        print(talia.count.description)
        print(player)
        talia.shuffle()
        var karty = Array<Dictionary<String, Any>> ()
        for _ in 0..<numberOfCards
        {
            if(talia.isEmpty)
            {
                continue
            }
            let karta = talia.popLast()
            karty.append(karta!)
        }
        talie[player] = talia
        print(talie[player]!.count.description)
        return karty
    }
}
