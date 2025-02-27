//
//  Gra.swift
//  tomekgrastycznen25
//
//  Created by Jacek Kałużny on 18/01/2025.
//

import SwiftUI

var playersList = ["Player1", "Player2"]

let graLock = DispatchQueue(label: "gra.lock")


extension ContentView
{
    func loadGame()
    {
        print("LOAD_START")
        loadDefaultDecks()
        
        //#--- PLAYER1 LOAD
        
        var talia1 = gra["TaliaLoadPlayer1"] as? Array<Dictionary<String, Any>> ?? Array<Dictionary<String, Any>>()
        var taliaNazwa = selectedTaliaFile1A ?? "1F defaultDeck"
        if(selectedTaliaFile1A != nil )
        {
            var taliaNazwa = selectedTaliaFile1A!//gra["TaliaNazwa"] as! String
            gra["TaliaNazwaPlayer1"] = taliaNazwa
            talia1 = loadDeck(fromFile: taliaNazwa) ?? []
            gra["TaliaLoadPlayer1"] = talia1
            
            if(selectedTaliaFile1B != nil)
            {
                taliaNazwa = selectedTaliaFile1B!
                talia1 = loadDeck(fromFile: taliaNazwa) ?? []
                gra["TaliaLoadPlayer1"] = gra["TaliaLoadPlayer1"] as! [[String : Any]] + talia1
                
                if(selectedTaliaFile1C != nil)
                {
                    taliaNazwa = selectedTaliaFile1C!
                    talia1 = loadDeck(fromFile: taliaNazwa) ?? []
                    gra["TaliaLoadPlayer1"] = gra["TaliaLoadPlayer1"] as! [[String : Any]] + talia1
                }
            }
        }
        else
        {
            gra["TaliaLoadPlayer1"] = loadDefaultDeck() ?? taliaBase
        }
        print("TALIA LOADED")
        if(talia1.count < 2)
        {
            print("wielkości: \(talia1.count) \(taliaBase.count)")
            print("TALIA LOADED IS EMPTY RELOADING \(talia1)")
            gra["TaliaLoadPlayer1"] =  taliaBase
        }
        
        var graczLoad = (selectedPlayer1File != nil ? loadPlayer(jsonPath: getPostacieDirectory().appendingPathComponent(selectedPlayer1File!).appendingPathExtension("json"), id: 0) : loadPlayerDef(id:1))!
        print("graczLoad: \(graczLoad)")
        if(graczLoad.isEmpty)
        {
            graczLoad = loadPlayerDef(id:0)
            print("graczLoad: \(graczLoad)")
        }
        gra["Player1"] = graczLoad
        loadTalia(taliaName: "Player1", characterName: getTextData(&gra, for: "Player1", key: "nazwa"))
        
        
        var talia2 = gra["TaliaLoadPlayer2"] as? Array<Dictionary<String, Any>> ?? Array<Dictionary<String, Any>>()
        //#--- PLAYER2 LOAD
        if(selectedTaliaFile2A != nil )
        {
            taliaNazwa = selectedTaliaFile1A!
            talia2 = loadDeck(fromFile: taliaNazwa) ?? []
            gra["TaliaLoadPlayer2"] = talia2
            
            if(selectedTaliaFile2B != nil)
            {
                taliaNazwa = selectedTaliaFile1A!
                talia2 = loadDeck(fromFile: taliaNazwa) ?? []
                gra["TaliaLoadPlayer2"] = gra["TaliaLoadPlayer2"] as! [[String : Any]] + talia2
                
                if(selectedTaliaFile2C != nil)
                {
                    taliaNazwa = selectedTaliaFile1A!
                    talia2 = loadDeck(fromFile: taliaNazwa) ?? []
                    gra["TaliaLoadPlayer2"] = gra["TaliaLoadPlayer2"] as! [[String : Any]] + talia2
                }
            }
        }
        else
        {
            gra["TaliaLoadPlayer2"] = loadDefaultDeck() ?? taliaBase
        }
        taliaNazwa = selectedTaliaFile1A ?? "1F defaultDeck"
        print("TALIA LOADED")
        if(talia2.count < 2)
        {
            print("wielkości: \(talia2.count) \(taliaBase.count)")
            print("TALIA LOADED IS EMPTY RELOADING \(talia2)")
            gra["TaliaLoadPlayer1"] =  taliaBase
        }
        
        graczLoad = (selectedPlayer1File != nil ? loadPlayer(jsonPath: getPostacieDirectory().appendingPathComponent(selectedPlayer2File!).appendingPathExtension("json"), id: 1) : loadPlayerDef(id:2))!
        print("graczLoad: \(graczLoad)")
        if(graczLoad.isEmpty)
        {
            graczLoad = loadPlayerDef(id:1)
            print("graczLoad: \(graczLoad)")
        }
        gra["Player2"] = graczLoad
        loadTalia(taliaName: "Player2", characterName: getTextData(&gra, for: "Player2", key: "nazwa"))
        
        gra["TablePlayer1"] = loadTable()
        gra["TablePlayerLast"] = loadTable()
        gra["TablePlayer2"] = loadTable()
        gra["Lingering"] = loadTable()
        gra["Wandering"] = loadTable()
        gra["Zaklęcie"] = loadSpell()
        setKarty(&gra, for: "Player1", value: loadCards(conut: getData(&gra, for: "Player1", key: "ilośćKart"), for: "Player1"))
        setKarty(&gra, for: "Player2", value: loadCards(conut: getData(&gra, for: "Player2", key: "ilośćKart"), for: "Player2"))
        gra["KoniecŻyciaCounterPlayer1"] = 0
        gra["KoniecŻyciaCounterPlayer2"] = 0
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
        zaklęcie["sacrifice"] = 0
        zaklęcie["karty"] = Array<Dictionary<String, Any>>()
        return zaklęcie
    }
    func loadTalia(taliaName: String, characterName: String)
    {
        let taliaAll = Array(repeating: gra["TaliaLoad\(taliaName)"] as! [[String:Any]], count: taliaRepeat).flatMap { $0 }
        var karty = Dictionary<String, Any>()
        karty["karty"] = taliaAll
        gra["Talia\(taliaName)"] = karty
        print("gra[Player] -> making talia")
        var taliaGracz = taliaAll.filter { card in
            guard let postacie = card["postacie"] as? [String] else {
                return false
            }
            return postacie.contains(characterName)
        }.map { card in
            var modifiedCard = card
            modifiedCard["player"] = taliaName
            return modifiedCard
        }
        print("talia \(taliaName) with \(taliaGracz.count) cards")
        setKarty(&gra, for: "Talia\(taliaName)", value: taliaGracz)
    }
    func loadPlayerDef(id: Int = 0) -> Dictionary<String, Any>
    {
        var gracz: Dictionary<String, Any> = Dictionary<String, Any>()
        if(id == 1)
        {
            gracz["id"] = "Player1"
            gracz["nazwa"] = "Mag Światła"
            
            print("gra[Player] ->  talia ok")
            gracz["ilośćKart"] = Int(3)
            gracz["manaMax"] = Int(10)
            gracz["mana"] = Int(3)
            gracz["życie"] = Int(9)
            gracz["tarcza"] = Int(0)
            gracz["akcjaRzucaneZaklęcie"] = "@Zaklęcie.karty.a.lingeringNow = 1"//selectKarta
            gracz["akcjaOdrzucaneZaklęcie"] = ""
            gracz["opisRzucaneZaklęcie"] = "Jeden fragment dostaje Lingering"
            gracz["opisOdrzucaneZaklęcie"] = nil
            gracz["opis"] = "Mistyczny czarodziej władający mocą czystej energii światła. Jego zaklęcia nie tylko ranią przeciwników, ale także pozostawiają świetliste echa, które utrzymują się na polu walki, wzmacniając jego sojuszników. Przemierza krainy, by szerzyć blask nadziei i obnażać ukryte cienie."
            print("gra[Player] ->  cards")
            print("gra[Player] ->  cards  ok 1")
        }
        if(id == 2)
        {
            gracz["id"] = "Player2"
            gracz["nazwa"] = "Mag Krwii"
            
            
            gracz["ilośćKart"] = Int(2)
            gracz["manaMax"] = Int(6)
            gracz["mana"] = Int(3)
            gracz["życie"] = Int(12)
            gracz["tarcza"] = Int(0)
            gracz["akcjaRzucaneZaklęcie"] = "@PlayerMe.życie = @PlayerMe.życie - 1 & @Zaklęcie.koszt = @Zaklęcie.koszt - 3"
            gracz["akcjaOdrzucaneZaklęcie"] = ""
            gracz["opisRzucaneZaklęcie"] = "Tracisz 1 ❤️ i staniasz to zaklęcie o 3."
            gracz["opisOdrzucaneZaklęcie"] = nil
            gracz["opis"] = "Mroczny mag, który czerpie siłę z własnej żywotności, aby tworzyć potężne zaklęcia. Każde użycie magii to dla niego akt poświęcenia, lecz w zamian zyskuje przerażającą przewagę nad wrogami. Jego krew płynie nie tylko w żyłach, ale także w ogniu jego czarów, które niszczą i wyczerpują każdego, kto odważy się go wyzwać."
//            gracz["karty"] = loadCards(conut: gracz["ilośćKart"] as! Int, for: gracz["id"] as! String)
            print("gra[Player] ->  cards  ok 2")
        }
        
        return gracz
    }
    func loadCards(conut numberOfCards:Int, for player: String) -> Array<Dictionary<String, Any>>
    {
        var talia = getKarty(&gra, for: "Talia\(player)")
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
        setKarty(&gra, for: "Talia\(player)", value: talia)
        return karty
    }
}
