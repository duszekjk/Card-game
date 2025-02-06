//
//  Akcje.swift
//  tomekgrastycznen25
//
//  Created by Jacek Kałużny on 18/01/2025.
//

import Foundation

func getData(_ gra: inout Dictionary<String, Any>, for player: String, key:String) -> Int
{
    guard let gracz = gra[player] as? [String: Any],
          let value = gracz[key] as? Int else { return 0 }
    return max(0, value)
}
func getTextData(_ gra: inout Dictionary<String, Any>, for player: String, key:String) -> String
{
    print("getTextData(for \(player), key: \(key)")
    guard let gracz = gra[player] as? [String: Any] else { return "error 1" }
    print(gracz)
    guard let value = gracz[key] as? String else { return "error 2" }
    print(value)
    return value
}
func getKarty(_ gra: inout Dictionary<String, Any>, for player: String) -> [[String: Any]]
{
    
    if let gracz = gra[player] as? [String: Any] {
        if let value = gracz["karty"] as? [[String: Any]]
        {
            return value
        }
        else {
            print("no cards for \(player)")
            return []
        }
    } else {
            print("no data for \(player)")
            print("\(gra)")
            return []
    }
    return []
}
func setKarty(_ gra: inout Dictionary<String, Any>, for player: String, value: [[String: Any]])
{
    if var gracz = gra[player] as? [String: Any] {
        gracz["karty"] = value
        gra[player] = gracz
    } else {
        print("Error saving cards for \(player) in game:")
    }
}
func setData(_ gra: inout Dictionary<String, Any>, for player: String, key:String, _ value: Int)
{
    if var gracz = gra[player] as? [String: Any] {
        gracz[key] = max(0, value)
        gra[player] = gracz
    } else {
        print("Error setting data \(key): \(value)")
    }
}
extension ContentView
{
    
    func createSpell(for playerKey:String, from tableKey:String,  with kards: Array<Dictionary<String, Any>>)
    {
        print("createingSpell")
        if var playerData = gra[tableKey] as? [String: Any] {
            print("for \(tableKey)")
            if var zaklęcieData = gra["Zaklęcie"] as? [String: Any] {
                var kartyZaklęte = [[String: Any]]()
                let stareKarty = (playerData["karty"] as? [[String: Any]] ?? [[String: Any]]())
                print("with \(stareKarty.count) karty")
                for kartaZaklęta in stareKarty
                {
                    var kartaNowa = kartaZaklęta
//                    if(kartaNowa["lingering"] != nil)
//                    {
                    kartaNowa["lingeringNow"] = ""
//                    }
                    kartaNowa["wanderingNow"] = ""
                    if(kartaNowa["wandering"] != nil)
                    {
                        kartaNowa["wanderingNow"] = kartaNowa["wandering"]
                    }
                    kartyZaklęte.append(kartaNowa)
                }
                
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
                zaklęcieData["karty"] = kartyZaklęte
                gra["Zaklęcie"] = zaklęcieData
                playerData["karty"] = []
                gra[String(tableKey)] = playerData
                activePlayer = playersList.firstIndex(of: playerKey) ?? activePlayer
                print(" Zaklęcie ready")
                if(activePlayer == thisDevice || thisDevice == -1)
                {
                    print(" Zaklęcie showing")
                    showZaklęcie = true
                }
                else
                {
                    connectionManager.send(gameState: gra)
                }
            }
        } else {
            print("Player not found: \(playerKey)")
        }
        
    }
    
    
    
    func calculateSpellCost() -> Int? {
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
                        if let result = preprocessAndEvaluate(expression: akcjaRight) {
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
                    if let result = preprocessAndEvaluate(expression: akcjaRight) {
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
                    if let result = preprocessAndEvaluate(expression: akcjaRight) {
                        totaltotalCost = max(0, result)
                    } else {
                        print("Failed to evaluate: \(akcjaRight)")
                    }
                }
            }
            
        }

        return totaltotalCost
    }
    
    func cancelSpell()
    {
        
        var playerNow = gra["Player\(activePlayer + 1)"] as! [String: Any]
        if(playerNow["akcjaOdrzuconeZaklęcie"] != nil)
        {
            if((playerNow["akcjaOdrzuconeZaklęcie"] as? String ?? "") != "")
            {
                spell(player: "Player\(activePlayer + 1)", run: playerNow["akcjaOdrzuconeZaklęcie"] as! String, against: "Player\((activePlayer + 1) % 2 + 1)")
            }
        }
        for zaklęcie in ((gra["Zaklęcie"] as! Dictionary<String, Any>)["karty"] as! Array<Dictionary<String, Any>>)
        {
            spell(player: "Player\(activePlayer + 1)", run: zaklęcie["akcjaOdrzuconeZaklęcie"] as! String, against: "Player\((activePlayer + 1) % 2 + 1)")
        }
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
        showZaklęcie = false
        checkumberOfCards(endMove: true)
        
    }
    func allSpells()
    {
            if let spellCost = calculateSpellCost() {
                print("Spell cost: \(spellCost)")
                if var playerData = gra["Zaklęcie"] as? [String: Any] {
                    playerData["koszt"] = spellCost
                    gra["Zaklęcie"] = playerData
                } else {
                    print("Zaklęcie not found!!!")
                }
                printFormatted(dictionary: (gra["Zaklęcie"] as! Dictionary<String, Any>))
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
                                    spell(player: "Player\(activePlayer + 1)", run: wander, against: "Player\((activePlayer + 1) % 2 + 1)")
                                }
                            }
                        }
                    }
                }
                if(playerNow["akcjaRzucaneZaklęcie"] != nil)
                {
                    if((playerNow["akcjaRzucaneZaklęcie"] as? String ?? "") != "")
                    {
                        spell(player: "Player\(activePlayer + 1)", run: playerNow["akcjaRzucaneZaklęcie"] as! String, against: "Player\((activePlayer + 1) % 2 + 1)")
                    }
                }
//                for zaklęcie in ((gra["Zaklęcie"] as! Dictionary<String, Any>)["karty"] as! Array<Dictionary<String, Any>>)
//                {
//                    spell(player: "Player\(activePlayer + 1)", run: zaklęcie["wandering"] as! String, against: "Player\((activePlayer + 1) % 2 + 1)")
//                }
                for zaklęcie in ((gra["Zaklęcie"] as! Dictionary<String, Any>)["karty"] as! Array<Dictionary<String, Any>>)
                {
                    spell(player: "Player\(activePlayer + 1)", run: zaklęcie["akcjaRzucaneZaklęcie"] as! String, against: "Player\((activePlayer + 1) % 2 + 1)")
                }
                if let mainZaklęcie = gra["Zaklęcie"] as? Dictionary<String, Any>, let pacyfizmCount = mainZaklęcie["pacyfizmNow"] as? Int
                {
                    for zaklęcie in ((gra["Zaklęcie"] as! Dictionary<String, Any>)["karty"] as! Array<Dictionary<String, Any>>)
                    {
                        if let pacyfizm = zaklęcie["pacyfizm"] as? String
                        {
                            for _ in 0..<pacyfizmCount
                            {
                                spell(player: "Player\(activePlayer + 1)", run: pacyfizm, against: "Player\((activePlayer + 1) % 2 + 1)")
                            }
                        }
                    }
                    setData(&gra, for: "Zaklęcie", key: "pacyfizmNow", 0)
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
                                    spell(player: "Player\(activePlayer + 1)", run: ling, against: "Player\((activePlayer + 1) % 2 + 1)")
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
                showZaklęcie = false
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
                                    setKarty(&gra, for: "TablePlayerLast", value: stareKarty)
                                    DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
                                        createSpell(for: "Player\(activePlayer + 1)", from: "TablePlayerLast", with: stareKarty)
                                        print("setKarty \(stareKarty)")
                                        setKarty(&gra, for: "TablePlayerLast", value: [[String: Any]]())
                                        setKarty(&gra, for: "Lingering", value: ligeringKarty)
                                    }
                                    return
                                }
                            }
                            setKarty(&gra, for: "TablePlayerLast", value: stareKarty)
                            setKarty(&gra, for: "Lingering", value: ligeringKarty)
                            print("gra[\"Lingering\"] = \(ligeringKarty)")
                            
                        }
                    }
                }
                checkumberOfCards(endMove: true)
            } else {
                print("Failed to calculate spell cost")
            }
    }
    func spell(player playerMe: String, run action: String, against playerYou: String)
    {
        print("---------------starting spell---------------")
//        printFormatted(dictionary: gra)
//        
//        // Parse and execute the action
//        print("---------------parsing spell---------------")
        let parsedAction = parseAction(action: action, playerMe: playerMe, playerYou: playerYou)
//        printFormatted(dictionary: (gra["Zaklęcie"] as! Dictionary<String, Any>))
        print("---------------running spell \(parsedAction)---------------")
        executeAction(parsedAction)
        
//        print("---------------finished spell---------------")
//        printFormatted(dictionary: gra)
//        print("---------------ending spell---------------")
    }

    private func parseAction(action: String, playerMe: String, playerYou: String) -> String
    {
        var parsedAction = action.replacingOccurrences(of: "PlayerMe", with: playerMe).replacingOccurrences(of: "PlayerYou", with: playerYou)

        return parsedAction
    }

    private func executeAction(_ action: String)
    {
        let actions = action.split(separator: "&")
        for singleAction in actions {
            let trimmedAction = singleAction.trimmingCharacters(in: .whitespaces)
            executeSingleAction(trimmedAction)
        }
    }

    private func executeSingleAction(_ actionFull: String)
    {
        // Split the action into left-hand side and right-hand side
        var action = actionFull
        if action.contains("if ") {
            // Split the action into condition and execution parts
            let ifParts = action.split(separator: "if", maxSplits: 1).last!.split(separator: ":", maxSplits: 1)
            let conditionPart = ifParts.first!.trimmingCharacters(in: .whitespaces)
            let executionParts = ifParts.last!.split(separator: "else", maxSplits: 1)
            let truePart = executionParts.first!.trimmingCharacters(in: .whitespaces)
            let falsePart = executionParts.count > 1 ? executionParts[1].trimmingCharacters(in: .whitespaces) : ""

            // Parse the condition
            let separators = ["==", ">=", "<=", ">", "<"]
            var separator = ""
            for sep in separators {
                if conditionPart.contains(sep) {
                    separator = sep
                    break
                }
            }

            guard !separator.isEmpty else {
                print("Error: No valid condition separator found in: \(conditionPart)")
                return
            }

            let condition = conditionPart.split(separator: separator, maxSplits: 1)
            let leftSideCondition = condition[0].trimmingCharacters(in: .whitespaces)
            let rightSideCondition = condition[1].trimmingCharacters(in: .whitespaces)

            // Evaluate condition
            let resultLeft = preprocessAndEvaluate(expression: leftSideCondition) ?? 0
            let resultRight = preprocessAndEvaluate(expression: rightSideCondition) ?? 0
            var conditionMet = false

            switch separator {
            case "==": conditionMet = resultLeft == resultRight
            case ">": conditionMet = resultLeft > resultRight
            case ">=": conditionMet = resultLeft >= resultRight
            case "<": conditionMet = resultLeft < resultRight
            case "<=": conditionMet = resultLeft <= resultRight
            default: break
            }

            // Choose the action based on the condition
            if conditionMet {
                action = truePart
            } else {
                action = falsePart
            }

            // If no valid action remains, return
            if action.isEmpty {
                return
            }
        }
        let components = action.split(separator: "=", maxSplits: 1)
        print("components = \(components.debugDescription)")
        guard components.count == 2 else {
            print("Invalid action: \(action)")
            return
        }

        let leftSide = components[0].trimmingCharacters(in: .whitespaces)
        let rightSide = components[1].trimmingCharacters(in: .whitespaces)
        print("left \(leftSide)")
        print("right \(rightSide)")
        // Evaluate the right side and assign it to the left side
        if let result = preprocessAndEvaluate(expression: rightSide) {
            var value = max(0, result)
            if(leftSide.contains(".życie"))
            {
                var kto = String(leftSide.split(separator: ".").first!.dropFirst())
                var życieNow = getData(&gra, for: kto, key: "życie")
                var tarczaNow = getData(&gra, for: kto, key: "tarcza")
                
                var change = życieNow - value
                print("Changing życie from \(życieNow) to \(value)")
                if(value < życieNow && tarczaNow > 0)
                {
                    print("Changing życie by  \(change)")
                    if(tarczaNow >= change)
                    {
                        tarczaNow -= change
                        value = życieNow
                        setData(&gra, for: kto, key: "tarcza", tarczaNow)
                    }
                    else
                    {
                        change -= tarczaNow
                        setData(&gra, for: kto, key: "tarcza", 0)
                        value = życieNow - change
                    }
                }
                print("Adding pacyfizmNow \(kto) Player\(activePlayer + 1) \(value) < \(życieNow)")
                if(value < życieNow && kto != "Player\(activePlayer + 1)")
                {
                    var pacyfizmNow = getData(&gra, for: kto, key: "pacyfizmNow")
                    pacyfizmNow += change
                    setData(&gra, for: "Zaklęcie", key: "pacyfizmNow", pacyfizmNow)
                    print("Adding pacyfizmNow \(pacyfizmNow)")
                }
            }
            
            assignValue(to: leftSide, value: max(0, value))
        } else {
            print("Failed to evaluate: \(rightSide)")
        }
    }

    private func evaluateExpression(_ expression: String) -> Int? {
        // Split the expression into tokens (operators and operands)
        let tokens = expression.split(separator: " ").map { String($0) }
        var values = [Int]()
        var operators = [String]()
        print("tokens ready")
        // Precedence map for operators
        let precedence: [String: Int] = [
            "+": 1,
            "-": 1,
            "*": 2,
            "/": 2
        ]
        
        func applyOperator() {
            guard values.count >= 2, let op = operators.popLast() else { return }
            let b = values.popLast()!
            let a = values.popLast()!
            let result: Int
            
            switch op {
            case "+": result = a + b
            case "-": result = a - b
            case "*": result = a * b
            case "/": result = a / b // Integer division
            default: return
            }
            
            values.append(result)
        }
        
        for token in tokens {
            if let num = Int(token) {
                values.append(num)
            } else if token == "(" {
                operators.append(token)
            } else if token == ")" {
                print("aS \(values)  \(operators)")
                if(values.count >= 2)
                {
                    while let lastOp = operators.last, lastOp != "(" && !operators.isEmpty {
                        applyOperator()
                    }
                }
                else
                {
                    print("missing values \(values.description)")
                }
                print("aE \(values)  \(operators)")
                operators.popLast() // Remove the "("
            } else if precedence.keys.contains(token) {
                print("bS \(values)  \(operators)")
                while let lastOp = operators.last,
                      lastOp != "(",
                      precedence[lastOp]! >= precedence[token]! {
                    applyOperator()
                }
                print("bE \(values)  \(operators)")
                operators.append(token)
            }
        }
        
        // Apply remaining operators
        print("cS \(values)  \(operators)")
        while !operators.isEmpty && values.count >= 2 {
            applyOperator()
        }
        print("cE \(values)  \(operators)")
        
        return values.last
    }

    private func preprocessAndEvaluate(expression: String) -> Int? {
        // Split the expression into tokens
        let tokens = expression.split(separator: " ").map { String($0) }
        var processedTokens = [String]()
        
        for token in tokens {
            if token.hasPrefix("@") {
                // Resolve the placeholder
                let keys = token.dropFirst().split(separator: ".").map { String($0) }
                if let value = resolvePlaceholder(keys: keys, in: gra) as? Int {
                    processedTokens.append(String(value))
                } else {
                    print("Failed to resolve token: \(token)")
                    return nil
                }
            } else {
                // Keep the token as is (operators or numbers)
                processedTokens.append(token)
            }
        }
        
        // Join the processed tokens back into a string
        let processedExpression = processedTokens.joined(separator: " ")
        print("processedExpression: \(processedExpression)")
        return evaluateExpression(processedExpression)
    }



    private func resolvePlaceholder(keys: [String], in dictionary: Any) -> Any? {
        var current: Any? = dictionary

        for key in keys {
            if let dict = current as? [String: Any], let next = dict[key] {
                current = next
            } else {
                if let dict = current as? [Any]  {
                    var atIndex = 0
                    if(key == "selectKarta")
                    {
                        if let arrayKarty = dict as? Array<Dictionary<String, Any>>
                        {
                            Task {
                                atIndex = await showCardSelectionSheet(options: arrayKarty)
                                let next = dict[atIndex]
                                // Proceed with the selected value
                                print("User selected: \(next)")
                            }
                        }
                        print("Brak kart")
                        return nil
                    }
                    else
                    {
                        atIndex = Int(key) ?? Int.random(in: 0..<dict.count)
                    }
                    let next = dict[atIndex]
                    current = next
                } else {
                    print("Key \(key) not found in \(current ?? "nil")")
                    if let dict = current as? [String: Any]
                    {
                        print("Creating new key \(key)")
                        return dict[key]
                    }
                    return current
                }
            }
        }

        return current
    }
    func showCardSelectionSheet(options: Array<Dictionary<String, Any>>) async -> Int {
        await withCheckedContinuation { continuation in
            
            self.actionUserIntpuKartaOptions = options
            self.actionUserIntpuKartaOnSelected = { selectedOption in
                continuation.resume(returning: selectedOption)
            }
            self.actionUserIntpuKartaShow = true
        }
    }


    private func assignValue(to key: String, value: Any)
    {
        let parts = key.split(separator: ".")
        if let playerKeyStart = parts.first
        {
            var keys = parts
            let playerKey = String(playerKeyStart.dropFirst()).replacingOccurrences(of: "@", with: "")
            var current: Any? = gra[playerKey]
            var startId = true
            var backTrace = [Any]()
            var backTraceKey = [Any]()
            var selected:Any? = nil
            print("Keys down:")
            for key in keys {
                if(startId)
                {
                    startId = false
                    continue
                }
                print("\(String(key)) = \(current.debugDescription)")

                if let dict = current as? [String: Any], let next = dict[String(key)] {
                    backTrace.append(current)
                    backTraceKey.append(String(key))
                    current = next                } else {
                    if let dict = current as? [Any]  {
                        var atIndex = 0
                        if(key == "selectKarta")
                        {
                            print("User select")
                            if let arrayKarty = dict as? Array<Dictionary<String, Any>>
                            {
                                Task {
                                    atIndex = await showCardSelectionSheet(options: arrayKarty)
                                    let next = dict[atIndex]
                                    // Proceed with the selected value
                                    print("User selected: \(next)")
                                }
                            }
                            print("Brak kart")
                            return
                        }
                        else
                        {
                            atIndex = Int(key) ?? Int.random(in: 0..<dict.count)
                        }
                        selected = atIndex
                        let next = dict[atIndex]
                        backTrace.append(current)
                        backTraceKey.append(Int(atIndex))
                        current = next
                    } else {
                        print("Key \(key) not found in \(current ?? "nil")")
                        return
                    }
                }
            }
            current = value
            var imax = backTraceKey.count
            
            print("Keys up:")
            for i in 1...backTraceKey.count
            {
                if let key = backTraceKey[imax - i] as? Int, let back = backTrace[imax - i] as? [Any] {
                    var newBack = back
                    print("\(String(key)) = \(current.debugDescription)")

                    newBack[key] = current
                    current = newBack
                }
                else
                {
                    if let key = backTraceKey[imax - i] as? String, let back = backTrace[imax - i] as? [String: Any] {
                        var newBack = back
                        print("\(newBack.debugDescription) \(String(key)) = \(current.debugDescription)")

                        newBack[key] = current
                        current = newBack
                    }
                    else
                    {
                        print("Can't set \(current ?? "nil") to \(key)")
                        
                    }
                }
            }
            gra[playerKey] = current
            
            
            
//            if var playerData = gra[playerKey] as? [String: Any] {
//                
//                for key in keys
//                {
//                playerData[String(variableKey)] = value
//                gra[String(playerKey)] = playerData
//            } else {
//                print("Player not found: \(playerKey)")
//            }
        }
        else {
            print("Invalid key: \(key)")
            return
        }
    }
}
