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
//    print("getTextData(for \(player), key: \(key)")
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
    func createSpellLong(_ gra: inout Dictionary<String, Any>, for playerKey:String, from tableKey:String,  with kards: Array<Dictionary<String, Any>>, activePlayer: inout Int)
    {
        
        var plr = activePlayer
        DispatchQueue.main.async {
            self.activePlayer = plr
        }
        createSpell(for: playerKey, from: tableKey,  with: kards)
    }
    func createSpell(for playerKey:String, from tableKey:String,  with kards: Array<Dictionary<String, Any>>)
    {
        activePlayer = playersList.firstIndex(of: playerKey) ?? activePlayer
        
        var spellState = false
        DispatchQueue.main.async {
            graLock.sync {
                    spellState = createSpellBase(&gra, for: playerKey, from: tableKey,  with: kards, activePlayer: activePlayer)
            }
            var playerSpell = tableKey.replacingOccurrences(of: "Table", with: "").replacingOccurrences(of: "PlayerLast", with: "Player\(activePlayer + 1)")
            self.activePlayer = Int(playerSpell.replacingOccurrences(of: "Player", with:""))! - 1
            print(" Zaklęcie ready \(((gra["Zaklęcie"] as! [String:Any])["karty"] as! [Any]).count)")
            if(spellState)
            {
                if(activePlayer == thisDevice || thisDevice == -1)
                {
                    print(" Zaklęcie showing \(activePlayer)")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        graLock.sync {
                            showZaklęcie = true
                        }
                    }
                }
                else
                {
                    connectionManager.send(gameState: gra)
                }
            }
            
        }
    }
    
    func calculateSpellCost() -> Int? {
        return calculateSpellCostBase(&gra, activePlayer: activePlayer)
    }
    
    func cancelSpell()
    {
        cancelSpellBase(&gra, activePlayer: activePlayer)
        showZaklęcie = false
        checkumberOfCards(endMove: true)
    }
    func allSpells()
    {
        var status = allSpellsBase(&gra, activePlayer: &activePlayer, createSpell: createSpellLong)
        showZaklęcie = false
        checkumberOfCards(endMove: status)
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
}

func spell(_ gra: inout Dictionary<String, Any>, player playerMe: String, run action: String, against playerYou: String)
{
    graLock.sync {
        print("---------------starting spell---------------")
        let parsedAction = parseAction(&gra, action: action, playerMe: playerMe, playerYou: playerYou)
        print("---------------running spell \(parsedAction)---------------")
        executeAction(&gra, parsedAction)
    }
}

func parseAction(_ gra: inout Dictionary<String, Any>, action: String, playerMe: String, playerYou: String) -> String
{
    var parsedAction = action.replacingOccurrences(of: "PlayerMe", with: playerMe).replacingOccurrences(of: "PlayerYou", with: playerYou)

    return parsedAction
}

func executeAction(_ gra: inout Dictionary<String, Any>, _ action: String)
{
    let actions = action.split(separator: "&")
    for singleAction in actions {
        let trimmedAction = singleAction.trimmingCharacters(in: .whitespaces)
        executeSingleAction(&gra, trimmedAction)
    }
}

func executeSingleAction(_ gra: inout Dictionary<String, Any>, _ actionFull: String)
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
        let resultLeft = preprocessAndEvaluate(&gra, expression: leftSideCondition) ?? 0
        let resultRight = preprocessAndEvaluate(&gra, expression: rightSideCondition) ?? 0
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
    if let result = preprocessAndEvaluate(&gra, expression: rightSide) {
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
            print("Adding pacyfizmNow \(kto) Player\((gra["activePlayer"] as! Int) + 1) \(value) < \(życieNow)")
            if(value < życieNow && kto != "Player\((gra["activePlayer"] as! Int) + 1)")
            {
                var pacyfizmNow = getData(&gra, for: kto, key: "pacyfizmNow")
                pacyfizmNow += change
                setData(&gra, for: "Zaklęcie", key: "pacyfizmNow", pacyfizmNow)
                print("Adding pacyfizmNow \(pacyfizmNow)")
            }
        }
        
        assignValue(&gra, to: leftSide, value: max(0, value))
    } else {
        print("Failed to evaluate: \(rightSide)")
    }
}

func evaluateExpression(_ gra: inout Dictionary<String, Any>, _ expression: String) -> Int? {
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

func preprocessAndEvaluate(_ gra: inout Dictionary<String, Any>, expression: String) -> Int? {
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
    return evaluateExpression(&gra, processedExpression)
}



func resolvePlaceholder(keys: [String], in dictionary: Any) -> Any? {
    var current: Any? = dictionary

    for key in keys {
        if let dict = current as? [String: Any], let next = dict[key] {
            current = next
        } else {
            if let dict = current as? [Any]  {
                var atIndex = 0
                if(key == "selectKarta")
                {
                    
                        //--------------- TO DO --------------------//
                    
//                    if let arrayKarty = dict as? Array<Dictionary<String, Any>>
//                    {
//                        Task {
//                            atIndex = await showCardSelectionSheet(&gra, options: arrayKarty)
//                            let next = dict[atIndex]
//                            // Proceed with the selected value
//                            print("User selected: \(next)")
//                        }
//                    }
//                    print("Brak kart")
                    
                    
                        //--------------- TO DO --------------------//
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


func assignValue(_ gra: inout Dictionary<String, Any>, to key: String, value: Any)
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
                            //--------------- TO DO --------------------//
//                            Task {
//                                atIndex = await showCardSelectionSheet(options: arrayKarty)
//                                let next = dict[atIndex]
//                                // Proceed with the selected value
//                                print("User selected: \(next)")
//                            }
                            //--------------- TO DO --------------------//
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
    }
    else {
        print("Invalid key: \(key)")
        return
    }
}
