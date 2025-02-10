//
//  Spells.swift
//  tomekgrastycznen25
//
//  Created by Jacek Kałużny on 08/02/2025.
//
import SwiftUI

func calculateSpellCostBase(_ gra: inout Dictionary<String, Any>, activePlayer: Int) -> Int? {
    guard let zaklęcie = gra["Zaklęcie"] as? [String: Any],
          let cards = zaklęcie["karty"] as? [[String: Any]] else { return nil }

    let totalCost = cards.reduce(0) { result, card in
        if let koszt = card["koszt"] as? Int {
            return result + koszt
        }
        return result
    }
    var totaltotalCost = totalCost
    print("wycenianie")
    if let playerNow = gra["Player\(activePlayer + 1)"] as? [String: Any]
    {
        print("Player\(activePlayer + 1)")
        if let akcjeString = playerNow["akcjaRzucaneZaklęcie"] as? String
        {
            print(akcjeString)
            let akcje = akcjeString.split(separator: "&")
            for akcja in akcje
            {
                print(akcja)
                if(akcja.contains("@Zaklęcie.koszt = "))
                {
                    print("koszt")
                    var akcjaRight = akcja.split(separator: "=").last!.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "@Zaklęcie.koszt", with: totaltotalCost.description)
                    print(akcjaRight)
                    if let result = preprocessAndEvaluate(&gra, expression: akcjaRight) {
                        totaltotalCost = max(0, result)
                    } else {
                        print("Failed to evaluate: \(akcjaRight)")
                    }
                }
            }
        }
    }
    for zaklęcie in ((gra["Zaklęcie"] as! Dictionary<String, Any>)["karty"] as! Array<Dictionary<String, Any>>)
    {
        if let akcja = zaklęcie["wandering"] as? String
        {
            if(akcja.contains("@Zaklęcie.koszt = "))
            {
                var akcjaRight = akcja.split(separator: "=").last!.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "@Zaklęcie.koszt", with: totaltotalCost.description)
                if let result = preprocessAndEvaluate(&gra, expression: akcjaRight) {
                    totaltotalCost = max(0, result)
                } else {
                    print("Failed to evaluate: \(akcjaRight)")
                }
            }
        }
        
    }
    for zaklęcie in ((gra["Zaklęcie"] as! Dictionary<String, Any>)["karty"] as! Array<Dictionary<String, Any>>)
    {
        if let akcja = zaklęcie["akcjaRzucaneZaklęcie"] as? String
        {
            if(akcja.contains("@Zaklęcie.koszt = "))
            {
                var akcjaRight = akcja.split(separator: "=").last!.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "@Zaklęcie.koszt", with: totaltotalCost.description)
                if let result = preprocessAndEvaluate(&gra, expression: akcjaRight) {
                    totaltotalCost = max(0, result)
                } else {
                    print("Failed to evaluate: \(akcjaRight)")
                }
            }
        }
        
    }
    return totaltotalCost
}

func createSpellBase(_ gra: inout Dictionary<String, Any>, for playerKey:String, from tableKey:String,  with kards: Array<Dictionary<String, Any>>, activePlayer: Int) -> Bool
{
    print("creatingSpell")
    gra["activePlayer"] = activePlayer
    if var playerData = gra[tableKey] as? [String: Any] {
        print("for \(tableKey)")
        if var zaklęcieData = gra["Zaklęcie"] as? [String: Any] {
            var kartyZaklęte = [[String: Any]]()
            let stareKarty = kards//(playerData["karty"] as? [[String: Any]] ?? [[String: Any]]())
            print("with \(stareKarty.count) karty")
            for kartaZaklęta in stareKarty
            {
                print("\t-\(kartaZaklęta["opis"]) ")
                var kartaNowa = kartaZaklęta
                kartaNowa["lingeringNow"] = ""
                kartaNowa["wanderingNow"] = ""
                if(kartaNowa["wandering"] != nil)
                {
                    kartaNowa["wanderingNow"] = kartaNowa["wandering"]
                }
                kartyZaklęte.append(kartaNowa)
            }
            print("karty w kartyZaklęte \(kartyZaklęte.count)")
            if var wanderingData = gra["Wandering"] as? [String: Any] {
                if(wanderingData["karty"] != nil)
                {
                    var wanderingKarty = (wanderingData["karty"] as? [[String: Any]] ?? [[String: Any]]())
                    if(wanderingKarty.count > 0)
                    {
                        kartyZaklęte.append(contentsOf: wanderingKarty)
                    }
                    wanderingData["karty"] = [[String: Any]]()
                    gra["Wandering"] = wanderingData
                }
            }
            print("saving")
            zaklęcieData["karty"] = kartyZaklęte
            gra["Zaklęcie"] = zaklęcieData
            gra["ZaklęcieLast"] = zaklęcieData
            playerData["karty"] = []
            gra[String(tableKey)] = playerData
            print("saved")
            return true
        }
    } else {
        print("Player not found: \(playerKey)")
    }
    return false
}

func cancelSpellBase(_ gra: inout Dictionary<String, Any>, activePlayer: Int)
{
    gra["ZaklęcieCast"] = false
    var playerNow = gra["Player\(activePlayer + 1)"] as! [String: Any]
    print(playerNow)
    if(playerNow["akcjaOdrzuconeZaklęcie"] != nil)
    {
        print("cancelSpell player action \(playerNow["akcjaOdrzuconeZaklęcie"])")
        if((playerNow["akcjaOdrzuconeZaklęcie"] as? String ?? "") != "")
        {
            spell(&gra, player: "Player\(activePlayer + 1)", run: playerNow["akcjaOdrzuconeZaklęcie"] as! String, against: "Player\((activePlayer + 1) % 2 + 1)")
        }
    }
    for zaklęcie in ((gra["Zaklęcie"] as! Dictionary<String, Any>)["karty"] as! Array<Dictionary<String, Any>>)
    {
        print("cancelSpell kard action")
        spell(&gra, player: "Player\(activePlayer + 1)", run: zaklęcie["akcjaOdrzuconeZaklęcie"] as! String, against: "Player\((activePlayer + 1) % 2 + 1)")
    }
    graLock.sync {
        for zaklęcie in ((gra["Zaklęcie"] as! Dictionary<String, Any>)["karty"] as! Array<Dictionary<String, Any>>)
        {
            var player = zaklęcie["player"] as! String
            var talia = getKarty(&gra, for: "Talia\(player)")//talie[player] as! Array<Dictionary<String, Any>>
            talia.append(zaklęcie)
            setKarty(&gra, for: "Talia\(player)", value: talia)
            //            }
        }
        if var playerData = gra["Zaklęcie"] as? [String: Any] {
            playerData["karty"] = Array<Dictionary<String, Any>>()
            gra["Zaklęcie"] = playerData
        } else {
            print("Zaklęcie not found!!!")
        }
    }
}
func allSpellsBase(_ gra: inout Dictionary<String, Any>, activePlayer: inout Int, createSpell:(inout Dictionary<String, Any>, String, String, Array<Dictionary<String, Any>>, inout Int) -> Void) -> Bool
{
    gra["ZaklęcieCast"] = true
    if let spellCost = calculateSpellCostBase(&gra, activePlayer: activePlayer) {
        print("Spell cost: \(spellCost)")
        if var playerData = gra["Zaklęcie"] as? [String: Any] {
            playerData["koszt"] = spellCost
            gra["Zaklęcie"] = playerData
        } else {
            print("Zaklęcie not found!!!")
        }
        var playerNow = gra["Player\(activePlayer + 1)"] as! [String: Any]
        
        for zaklęcie in ((gra["Zaklęcie"] as! Dictionary<String, Any>)["karty"] as! Array<Dictionary<String, Any>>)
        {
            var zaklęcieNow = zaklęcie
            if(zaklęcie["wanderingNow"] != nil)
            {
                if let wander = zaklęcie["wanderingNow"] as? Int
                {
                }else {
                    if let wander = zaklęcie["wanderingNow"] as? String
                    {
                        zaklęcieNow["wanderingNow"] = nil
                        if(wander.count > 5)
                        {
                            spell(&gra, player: "Player\(activePlayer + 1)", run: wander, against: "Player\((activePlayer + 1) % 2 + 1)")
                        }
                    }
                }
            }
        }
        if(playerNow["akcjaRzucaneZaklęcie"] != nil)
        {
            if((playerNow["akcjaRzucaneZaklęcie"] as? String ?? "") != "")
            {
                spell(&gra, player: "Player\(activePlayer + 1)", run: playerNow["akcjaRzucaneZaklęcie"] as! String, against: "Player\((activePlayer + 1) % 2 + 1)")
            }
        }
        for zaklęcie in ((gra["Zaklęcie"] as! Dictionary<String, Any>)["karty"] as! Array<Dictionary<String, Any>>)
        {
            spell(&gra, player: "Player\(activePlayer + 1)", run: zaklęcie["akcjaRzucaneZaklęcie"] as! String, against: "Player\((activePlayer + 1) % 2 + 1)")
        }
        if let mainZaklęcie = gra["Zaklęcie"] as? Dictionary<String, Any>, let pacyfizmCount = mainZaklęcie["pacyfizmNow"] as? Int
        {
            for zaklęcie in ((gra["Zaklęcie"] as! Dictionary<String, Any>)["karty"] as! Array<Dictionary<String, Any>>)
            {
                if let pacyfizm = zaklęcie["pacyfizm"] as? String
                {
                    for _ in 0..<pacyfizmCount
                    {
                        spell(&gra, player: "Player\(activePlayer + 1)", run: pacyfizm, against: "Player\((activePlayer + 1) % 2 + 1)")
                    }
                }
            }
            graLock.sync {
                setData(&gra, for: "Zaklęcie", key: "pacyfizmNow", 0)
            }
        }
        
        for zaklęcie in ((gra["Zaklęcie"] as! Dictionary<String, Any>)["karty"] as! Array<Dictionary<String, Any>>)
        {
            var zaklęcieNow = zaklęcie
            let player = zaklęcie["player"] as! String
            
            if(zaklęcie["wanderingNow"] != nil)
            {
                
                if let wander = zaklęcie["wanderingNow"] as? Int
                {
                    var wandering = gra["Wandering"] as! Dictionary<String, Any>
                    var wanderingKarty = wandering["karty"] as! Array<Dictionary<String, Any>>
                    zaklęcieNow["wanderingNow"] = nil
                    wanderingKarty.append(zaklęcieNow)
                    wandering["karty"] = wanderingKarty
                    gra["Wandering"] = wandering
                    continue
                }
            }
            if(zaklęcie["lingeringNow"] != nil)
            {
                
                if let _ = zaklęcie["lingeringNow"] as? Int
                {
                    var lingering = gra["Lingering"] as! Dictionary<String, Any>
                    var lingeringKarty = lingering["karty"] as! Array<Dictionary<String, Any>>
                    zaklęcieNow["lingeringNow"] = nil
                    lingeringKarty.append(zaklęcieNow)
                    lingering["karty"] = lingeringKarty
                    gra["Lingering"] = lingering
                    continue
                }
                else
                {
                    if let ling = zaklęcie["lingeringNow"] as? String
                    {
                        zaklęcieNow["lingeringNow"] = nil
                        if(ling.count > 5)
                        {
                            spell(&gra, player: "Player\(activePlayer + 1)", run: ling, against: "Player\((activePlayer + 1) % 2 + 1)")
                        }
                    }
                }
            }
            print("Karta back to Talia\(player) \(zaklęcieNow["opis"]!)")
            var talia = getKarty(&gra, for: "Talia\(player)")
            print("\(talia.count)")
            talia.append(zaklęcieNow)
            print("\(talia.count)")
            setKarty(&gra, for: "Talia\(player)", value: talia)
        }
        if var playerData = gra["Zaklęcie"] as? [String: Any] {
            playerData["karty"] = Array<Dictionary<String, Any>>()
            gra["Zaklęcie"] = playerData
        } else {
            print("Zaklęcie not found!!!")
        }
        if var lingeringData = gra["Lingering"] as? [String: Any] {
            if(lingeringData["karty"] != nil)
            {
                var ligeringKarty = (lingeringData["karty"] as? [[String: Any]] ?? [[String: Any]]())
                var ligeringKartySize = ligeringKarty.count
                print("ligeringKartySize \(ligeringKartySize)")
                if(ligeringKarty.count > 0)
                {
                    var stareKarty = getKarty(&gra, for: "TablePlayerLast")//(gra["karty"] as? [[String: Any]] ?? [[String: Any]]())
                    print("stareKarty \(stareKarty)")
                    for _ in 0..<ligeringKartySize
                    {
                        let kartal = ligeringKarty.removeFirst()
                        stareKarty.append(kartal)
                        print("append \(stareKarty)")
                        if(stareKarty.count >= 3)
                        {
                            graLock.sync
                            {
                                setKarty(&gra, for: "TablePlayerLast", value: stareKarty)
                                setKarty(&gra, for: "Lingering", value: ligeringKarty)
                            }
//                            DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                            createSpell(&gra, "Player\(activePlayer + 1)", "TablePlayerLast", stareKarty, &activePlayer)
                            print("setKarty for Player\(activePlayer + 1) ")
                            graLock.sync
                            {
                                setKarty(&gra, for: "TablePlayerLast", value: [[String: Any]]())
                            }
//                            }
                            return false
                        }
                    }
                    setKarty(&gra, for: "TablePlayerLast", value: stareKarty)
                    setKarty(&gra, for: "Lingering", value: ligeringKarty)
                    print("gra[\"Lingering\"] = \(ligeringKarty)")
                    
                }
            }
        }
    } else {
        print("Failed to calculate spell cost")
        return false
    }
    return true
}
