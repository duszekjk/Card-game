//
//  RandomMove.swift
//  tomekgrastycznen25
//
//  Created by Jacek Kałużny on 07/02/2025.
//

import Foundation


func makeRandomMove(_ gra: inout Dictionary<String, Any>, for player: String, activePlayer: inout Int, gameRound gR: Int, botPlayers : [String] = [], createSpell: (String, String, Array<Dictionary<String, Any>>) -> Void) -> (Int, String, Int, Int)
{
    var tablePlaceholders = ["TablePlayer1", "TablePlayerLast", "TablePlayer2"]
    var moveOk = false
//    var activePlayer = aP
    var gameRound = gR
    
    var lastPlayed = ""
//    for _ in 0...5
//    {
        var kards = getKarty(&gra, for: player)
        var kartaID = Int.random(in: 0..<kards.count)
        var karta = kards[kartaID]
        var containerKey = ""
        var isLingering = false
        var koszt = (karta["koszt"] as? Int ?? 0)
        var playerMana = getData(&gra, for: player, key: "mana") + Int(getData(&gra, for: player, key: "ilośćKart")/3)
        tablePlaceholders.append("Table\(player)")
        if(koszt < playerMana)
        {
            tablePlaceholders.append("Table\(player)")
            tablePlaceholders.append("Table\(player)")
        }
        if(koszt < playerMana/2)
        {
            tablePlaceholders.append("Table\(player)")
            tablePlaceholders.append("Table\(player)")
        }
        if(koszt < playerMana/3)
        {
            tablePlaceholders.append("Table\(player)")
        }
        
        if let _ = karta["lingering"] as? Int
        {
            containerKey = "Lingering"
            isLingering = true
        }
        else
        {
            containerKey = tablePlaceholders.randomElement()!
        }
    
        graLock.sync {
            moveOk = moveCard(&gra, from:player, at: kartaID, to: containerKey, isLingering: isLingering)
        }
        if(moveOk)
        {
            lastPlayed = String(player)
            if let container = gra[containerKey] as? Dictionary<String, Any>
            {
                let kartyLoad = container["karty"] as? Array<Dictionary<String, Any>> ?? []
                if(CGFloat(kartyLoad.count) == 3 && !isLingering)
                {
                    var playerSpell = containerKey.replacingOccurrences(of: "Table", with: "").replacingOccurrences(of: "PlayerLast", with: lastPlayed)
                    print("Running spell \(containerKey) bc \(CGFloat(kartyLoad.count)) == 3")
                    for kartaZaklęta in kartyLoad
                    {
                        print("\t-\(kartaZaklęta["opis"]) ")
                    }
                    if(botPlayers.contains(playerSpell))
                    {
                        sizeFullActionBot(&gra, for: playerSpell, from: containerKey, with: kartyLoad, activePlayer: &activePlayer)
                        gameRound += 1
                    }
                    else {
                        createSpell(playerSpell, containerKey, kartyLoad)
                    }
                }
                else {
                    gameRound += 1
                    activePlayer = gameRound % playersList.count
                }
            }
            
            return (kartaID, containerKey, activePlayer, gameRound)
        }
        else
        {
            print("error moving card \(kartaID) to \(containerKey)")
        }
//    }
    return (-1, "", activePlayer, gameRound)
}

func sizeFullActionBot(_ gra: inout Dictionary<String, Any>, for playerKey:String, from tableKey:String,  with kards: Array<Dictionary<String, Any>>, activePlayer: inout Int)
{
    activePlayer = playersList.firstIndex(of: playerKey) ?? activePlayer
    createSpellBase(&gra, for:playerKey, from:tableKey,  with: kards, activePlayer: activePlayer)
    print(" Zaklęcie ready")
    var rzućSzansa = 0
    var koszt = calculateSpellCostBase(&gra, activePlayer: activePlayer) ?? 4
    var mana = getData(&gra, for: playerKey, key: "mana")
    var ilośćKart = getData(&gra, for: playerKey, key: "ilośćKart")
    if(koszt < mana)
    {
        rzućSzansa += 4
    }
    if(koszt < mana + ilośćKart)
    {
        rzućSzansa += 3
    }
    if(koszt + 3 > mana + ilośćKart + getData(&gra, for: playerKey, key: "życie"))
    {
        rzućSzansa -= 5
    }
    rzućSzansa += Int.random(in: -8...10)
    var rzuć = (rzućSzansa > 0)
    if(rzuć)
    {
        allSpellsBase(&gra, activePlayer: &activePlayer, createSpell: sizeFullActionBot)
    }
    else
    {
        cancelSpellBase(&gra, activePlayer: activePlayer)
    }
}
func moveCard(_ gra: inout Dictionary<String, Any>, from sourceKey: String, at sourceIndex: Int, to destinationKey: String, isLingering: Bool) -> Bool {
    var sourceCards = Array<Dictionary<String, Any>>()
    var sourceIndexCorrected = sourceIndex
    var talia = getKarty(&gra, for: "Talia\(sourceKey)")
    if(gra[sourceKey] == nil)
    {
        sourceCards = talia
        sourceIndexCorrected = Int.random(in: 0..<talia.count)
    }
    else
    {
        sourceCards = (gra[sourceKey] as! Dictionary<String, Any>)["karty"] as? Array<Dictionary<String, Any>> ?? []
    }
    guard sourceIndexCorrected >= 0, sourceIndexCorrected < sourceCards.count else { return false }
    let cardTMP = sourceCards[sourceIndexCorrected]
    print("lingering: \(cardTMP["lingering"]) \(isLingering)")
    
    if let lingeringString = cardTMP["lingering"] as? String
    {
        print(lingeringString)
        if((!(lingeringString.count > 3) && isLingering) || ((lingeringString.count > 3) && !isLingering))
        {
            print("false A")
            return false
        }
        print("true B")
    }
    else
    {
        if let lingeringString = cardTMP["lingering"] as? Int, !isLingering
        {
            print(cardTMP["lingering"])
            print("false B")
            return false
        }
    }
    print("true A")
    let card = sourceCards.remove(at: sourceIndexCorrected)
    if var playerData = gra[sourceKey] as? [String: Any] {
        playerData["karty"] = sourceCards
        gra[sourceKey] = playerData
    }

    var destinationCards = (gra[destinationKey] as! Dictionary<String, Any>)["karty"] as? Array<Dictionary<String, Any>> ?? []
    destinationCards.append(card)
    if var playerData = gra[destinationKey] as? [String: Any] {
        playerData["karty"] = destinationCards
        gra[destinationKey] = playerData
    }
    return true
}
