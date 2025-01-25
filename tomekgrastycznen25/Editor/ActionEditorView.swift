import SwiftUI

struct ActionEditorView: View {
    @Binding var gra: Dictionary<String, Any>
    @Binding var akcjaText: String
    @State private var currentAction: [String] = [] // Parts of the action being built
    @State private var selectedDirectory: Any? = nil
    @State private var quickActionNumber: Int = 1
    @State private var quickActionList = [
        "❤️‍🔥": "PlayerYou.życie = @PlayerYou.życie - ",
        "❤️": "PlayerMe.życie = @PlayerMe.życie + ",
        "🛡️": "PlayerMe.shield = @PlayerMe.shield + ",
        "🃏": "PlayerMe.ilośćKart = @PlayerMe.ilośćKart + ",
        "🔋": "PlayerMe.mana = @PlayerMe.mana + ",
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            szybkieAkcje
            Text("Builder")
                   .font(.headline)
            operatory
            // Dynamic Sub-Keys or Array Indices
            Divider()
            dictViews
            Divider()
            numberButtons
            Spacer()
            previewView
            Spacer()
            
            Text("Preview: \(akcjaText)")
                .padding()
                .border(Color.gray)
                .onChange(of: currentAction)
            {
                akcjaText = currentAction.joined()
            }
        }
        .padding()
        .navigationTitle("Edit Actions")
    }
    
    var previewView: some View {
        HStack {
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(currentAction, id: \.self) { part in
                        Button(makeNormal(part)) {
                            selectActionPart(part)
                        }
                        .padding()
                        .background(part == currentAction.last ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    }
                }
            }
            
        }
    }
    var dictViews: some View {
        VStack {
            if let selectedDict = selectedDirectory as? Dictionary<String, Any> {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(Array(selectedDict.keys), id: \.self) { subKey in
                                Button(".\(subKey)") {
                                    appendToAction(".\(subKey)")
                                }
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                            }
                        }
                    }
            } else if selectedDirectory is [Any] {
                arrayButtons
            }
            else
            {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(currentKeys(), id: \.self) { key in
                            Button(displayKey(key)) {
                                appendToAction(displayKey(key))
                            }
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                        }
                    }
                }
            }
        }
    }
    var szybkieAkcje: some View {
        HStack {
            Text("Szybkie akcje")
                .font(.headline)
            if(UIDevice.current.userInterfaceIdiom == .phone)
            {
                VStack
                {
                    Stepper("Ile (\(quickActionNumber))", value: $quickActionNumber)
                    HStack{
                        
                        ForEach(Array(quickActionList.keys), id: \.self) { subKey in
                            Button("\(subKey)") {
                                appendToAction("\(quickActionList[subKey]!)\(quickActionNumber)")
                            }
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                        }
                    }
                }
                
            }
            else
            {
                HStack
                {
                    Stepper("Ile (\(quickActionNumber))", value: $quickActionNumber)
                    Spacer()
                    ForEach(Array(quickActionList.keys), id: \.self) { subKey in
                        Button("\(subKey)") {
                            appendToAction("\(quickActionList[subKey]!)\(quickActionNumber)")
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    }
                }
            }
            
            Divider()
        }
        
        
    }
    
    var operatory: some View
    {
        HStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(["=", "+", "-", "*", "/", "&", "if", "(", ")", ":"], id: \.self) { operatorSymbol in
                        Button(operatorSymbol) {
                            appendOperator(operatorSymbol)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    }
                    
                    Button("← Remove Last") {
                        removeLast()
                    }
                    .padding()
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(8)
                    
                    Button("Clear All") {
                        clearAction()
                    }
                    .padding()
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    var arrayButtons: some View
    {
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Button("First") {
                    appendToAction(".0")
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                
                Button("Select Element") {
                    appendToAction(".selectedKarta")
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                
                Button("Random") {
                    appendToAction(".random")
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            }
        }
    }
    var numberButtons: some View
    {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                
                ForEach(0...10, id: \.self) { operatorSymbol in
                        Button("\(operatorSymbol)") {
                            appendOperator("\(operatorSymbol)")
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    }
            }
        }
    }
    // MARK: - Helpers
    
    private func currentKeys() -> [String] {
        if currentAction.isEmpty || isLastOperator() {
            return gra.keys.sorted()
        } else if let dict = selectedDirectory as? Dictionary<String, Any> {
            return dict.keys.sorted()
        }
        return []
    }
    
    private func makeNormal(_ key: String) -> String {
        var text = key
        text.replace("@Player1", with: "@PlayerMe")
        text.replace("@Player2", with: "@PlayerYou")
        return text
    }
    private func appendToAction(_ key: String) {
        if currentAction.isEmpty || isLastOperator() {
            let resolvedKey = resolveSpecialKeys(key)
            currentAction.append("@\(resolvedKey)")
            selectedDirectory = gra[resolvedKey]
        } else {
            currentAction.append(key)
            if key.starts(with: ".") {
                updateSelectedDirectory(for: key)
            }
        }
    }
    
    private func appendOperator(_ operatorSymbol: String) {
        currentAction.append(" \(operatorSymbol) ")
        selectedDirectory = nil // Reset to allow a new start
    }
    
    private func updateSelectedDirectory(for key: String) {
        if let dict = selectedDirectory as? Dictionary<String, Any>, key.starts(with: ".") {
            let subKey = String(key.dropFirst(1))
            selectedDirectory = dict[subKey]
        }
    }
    
    private func selectActionPart(_ part: String) {
        if let index = currentAction.firstIndex(of: part) {
            selectedDirectory = gra
            for i in 0...index {
                updateSelectedDirectory(for: currentAction[i])
            }
        }
    }
    
    private func removeLast() {
        guard !currentAction.isEmpty else { return }
        currentAction.removeLast()
        if currentAction.isEmpty {
            selectedDirectory = nil
        } else {
            selectActionPart(currentAction.last!)
        }
    }
    
    private func clearAction() {
        currentAction = []
        selectedDirectory = nil
        akcjaText = ""
    }
    
    private func resolveSpecialKeys(_ key: String) -> String {
        switch key {
        case "PlayerMe":
            return "Player1"
        case "PlayerYou":
            return "Player2"
        default:
            return key
        }
    }
    
    private func displayKey(_ key: String) -> String {
        switch key {
        case "Player1":
            return "PlayerMe"
        case "Player2":
            return "PlayerYou"
        default:
            return key
        }
    }
    
    private func isLastOperator() -> Bool {
        guard let last = currentAction.last else { return false }
        return ["=", "+", "-", "*", "/", "&", "if", "(", ")", ":"].contains(last.trimmingCharacters(in: .whitespaces))
    }
}
