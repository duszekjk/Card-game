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
        if(id == 1)
        {
            gracz["id"] = "Player1"
            gracz["nazwa"] = "Mag Światła"
            gracz["ilośćKart"] = Int(3)
            gracz["manaMax"] = Int(10)
            gracz["mana"] = Int(3)
            gracz["życie"] = Int(9)
            gracz["akcjaRzucaneZaklęcie"] = "@Zaklęcie.karta 1 > @Table"
            gracz["akcjaOdrzucaneZaklęcie"] = ""
            gracz["karty"] = loadCards(conut: gracz["ilośćKart"] as! Int)
        }
        if(id == 2)
        {
            gracz["id"] = "Player2"
            gracz["nazwa"] = "Mag Krwii"
            gracz["ilośćKart"] = Int(2)
            gracz["manaMax"] = Int(6)
            gracz["mana"] = Int(3)
            gracz["życie"] = Int(12)
            gracz["akcjaRzucaneZaklęcie"] = "@PlayerMe.życie = @PlayerMe.życie - 1 & @Zaklęcie.koszt = -1"
            gracz["karty"] = loadCards(conut: gracz["ilośćKart"] as! Int)
        }
        
        return gracz
    }
    func loadCards(conut numberOfCards:Int) -> Array<Dictionary<String, Any>>
    {
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
        return karty
    }
}
