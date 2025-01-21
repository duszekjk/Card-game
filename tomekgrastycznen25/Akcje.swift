//
//  Akcje.swift
//  tomekgrastycznen25
//
//  Created by Jacek Kałużny on 18/01/2025.
//

import Foundation

extension ContentView
{
    
    func getData(for player: String, key:String) -> Int
    {
        guard let gracz = gra[player] as? [String: Any],
              let value = gracz[key] as? Int else { return 0 }
        return max(0, value)
    }
    func getTextData(for player: String, key:String) -> String
    {
        print("getTextData(for \(player), key: \(key)")
        guard let gracz = gra[player] as? [String: Any] else { return "error 1" }
        print(gracz)
        guard let value = gracz[key] as? String else { return "error 2" }
        print(value)
        return value
    }
    func getKarty(for player: String) -> [[String: Any]]
    {
        guard let gracz = gra[player] as? [String: Any],
              let value = gracz["karty"] as? [[String: Any]] else { return [] }
        return value
    }
    func setKarty(for player: String, value: [[String: Any]])
    {
        if var gracz = gra[player] as? [String: Any] {
            gracz["karty"] = value
            gra[player] = gracz
        } else {
            print("Error saving cards")
        }
    }
    func setData(for player: String, key:String, _ value: Int)
    {
        if var gracz = gra[player] as? [String: Any] {
            gracz[key] = max(0, value)
            gra[player] = gracz
        } else {
            print("Error setting data \(key): \(value)")
        }
    }
    func createSpell(for playerKey:String, from tableKey:String,  with kards: Array<Dictionary<String, Any>>)
    {
        if var playerData = gra[tableKey] as? [String: Any] {
            if var zaklęcieData = gra["Zaklęcie"] as? [String: Any] {
                zaklęcieData["karty"] = playerData["karty"]
                gra["Zaklęcie"] = zaklęcieData
                playerData["karty"] = []
                gra[String(tableKey)] = playerData
                activePlayer = playersList.firstIndex(of: playerKey) ?? activePlayer
                if(activePlayer == thisDevice)
                {
                    showZaklęcie = true
                }
                else
                {
                    gra["talie"] = talie
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

        return totalCost
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
                for zaklęcie in ((gra["Zaklęcie"] as! Dictionary<String, Any>)["karty"] as! Array<Dictionary<String, Any>>)
                {
                    spell(player: "Player\(activePlayer + 1)", run: zaklęcie["akcjaRzucaneZaklęcie"] as! String, against: "Player\((activePlayer + 1) % 2 + 1)")
                }
                
                for zaklęcie in ((gra["Zaklęcie"] as! Dictionary<String, Any>)["karty"] as! Array<Dictionary<String, Any>>)
                {
                        let player = zaklęcie["player"] as! String
                        var talia = talie[player] as! Array<Dictionary<String, Any>>
                        talia.append(zaklęcie)
                        talie[player] = talia
                }
                if var playerData = gra["Zaklęcie"] as? [String: Any] {
                    playerData["karty"] = Array<Dictionary<String, Any>>()
                    gra["Zaklęcie"] = playerData
                } else {
                    print("Zaklęcie not found!!!")
                }
                showZaklęcie = false
                checkumberOfCards(endMove: true)
            } else {
                print("Failed to calculate spell cost")
            }
    }
    func spell(player playerMe: String, run action: String, against playerYou: String)
    {
        print("---------------starting spell---------------")
        printFormatted(dictionary: gra)
        
        // Parse and execute the action
        print("---------------parsing spell---------------")
        let parsedAction = parseAction(action: action, playerMe: playerMe, playerYou: playerYou)
        printFormatted(dictionary: (gra["Zaklęcie"] as! Dictionary<String, Any>))
        print("---------------running spell \(parsedAction)---------------")
        executeAction(parsedAction)
        
        print("---------------finished spell---------------")
        printFormatted(dictionary: gra)
        print("---------------ending spell---------------")
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
        if action.contains("if") {
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
            assignValue(to: leftSide, value: max(0, result))
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
                print("Key \(key) not found in \(current ?? "nil")")
                return nil
            }
        }

        return current
    }


    private func assignValue(to key: String, value: Any)
    {
        let parts = key.split(separator: ".")
        guard parts.count == 2, let playerKeyStart = parts.first, let variableKey = parts.last else {
            print("Invalid key: \(key)")
            return
        }
        let playerKey = String(playerKeyStart.dropFirst()).replacingOccurrences(of: "@", with: "")
        if var playerData = gra[playerKey] as? [String: Any] {
            playerData[String(variableKey)] = value
            gra[String(playerKey)] = playerData
        } else {
            print("Player not found: \(playerKey)")
        }
    }
}
