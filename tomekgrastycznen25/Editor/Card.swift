//
//  Card.swift
//  tomekgrastycznen25
//
//  Created by Jacek Kałużny on 23/01/2025.
//
let samplePostacie = ["Mag Światła", "Mag Krwii", "Mag Ognia", "Mag Wody"]

let sampleCard = Card(
    opis: "1 ❤️‍🔥, \nPacyfizm: Przeciwnik 🃏",
    koszt: 0,
    postacie: ["Mag Światła", "Mag Krwii"],
    akcjaRzucaneZaklęcie: "@PlayerYou.życie = @PlayerYou.życie - 1",
    akcjaOdrzuconeZaklęcie: "",
    wandering: "",
    lingering: .string(""),
    pacyfizm: "@PlayerYou.ilośćKart = @PlayerYou.ilośćKart + 1"
)


import SwiftUI

import Foundation

struct Card: Identifiable, Codable {
    let id = UUID()
    var opis: String
    var koszt: Int
    var postacie: [String]
    var akcjaRzucaneZaklęcie: String
    var akcjaOdrzuconeZaklęcie: String
    var wandering: String
    var lingering: LingeringType
    var pacyfizm: String

    enum LingeringType: Codable {
        case int(Int)
        case string(String)
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let intValue = try? container.decode(Int.self) {
                self = .int(intValue)
            } else if let stringValue = try? container.decode(String.self) {
                self = .string(stringValue)
            } else {
                throw DecodingError.typeMismatch(
                    LingeringType.self,
                    DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid lingering value")
                )
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .int(let value):
                try container.encode(value)
            case .string(let value):
                try container.encode(value)
            }
        }
    }
}


extension Card {
    static func load(from json: String) -> Card? {
        print(json)
        guard let data = json.data(using: .utf8) else {
            print("error1")
            return nil }
        print("2")
        do
        {
            var ret = try JSONDecoder().decode(Card.self, from: data)
            return ret
        }
        catch
        {
            print("Decoding error: \(error)")
            return nil
        }
    }
    
    func save() -> String? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}


struct CardEditorView: View {
    @Binding var gra: Dictionary<String, Any>
    @Binding var jsonText: String?
    @State private var postacie = ["Mag Światła", "Mag Krwii"]
    @State private var card: Card
    
    @State private var showWandering: Bool = false
    @State private var showAkcjaRzucaneZaklęcie: Bool = false
    @State private var showAkcjaOdrzuconeZaklęcie: Bool = false
    @State private var lingeringString: Bool = false
    @State private var showLingering: Bool = false
    @State private var showPacyfizm: Bool = false
    init(gra:Binding<Dictionary<String, Any>>, jsonText: Binding<String?>) {
        _gra = gra
        _jsonText = jsonText
        _card = State(initialValue: Card.load(from: jsonText.wrappedValue ?? "") ?? Card(
            opis: "",
            koszt: 0,
            postacie: [],
            akcjaRzucaneZaklęcie: "",
            akcjaOdrzuconeZaklęcie: "",
            wandering: "",
            lingering: .string(""),
            pacyfizm: ""
        ))
    }
    
    var body: some View {
        Form {
            Section(header: Text("Opis")) {
                TextEditor(text: $card.opis)
                    .frame(height: 100)
                    .border(Color.gray)
            }
            
            Section(header: Text("Koszt")) {
                Stepper(value: $card.koszt, in: 0...100) {
                    Text("Koszt: \(card.koszt)")
                }
            }
            
            Section(header: Text("Akcje")) {
                
                HStack
                {
                    Button("akcjaOdrzuconeZaklęcie")
                    {
                        showAkcjaOdrzuconeZaklęcie = true
                    }
                    .sheet(isPresented: $showAkcjaOdrzuconeZaklęcie)
                    {
                        ActionEditorView(gra: $gra, akcjaText: $card.akcjaOdrzuconeZaklęcie)
                    }
                    Text(card.akcjaOdrzuconeZaklęcie)
                }
                HStack
                {
                    Button("pacyfizm")
                    {
                        showPacyfizm = true
                    }
                    .sheet(isPresented: $showPacyfizm)
                    {
                        ActionEditorView(gra: $gra, akcjaText: $card.pacyfizm)
                    }
                    Text(card.pacyfizm)
                }
                HStack
                {
                    Button("wandering")
                    {
                        showWandering = true
                    }
                    .sheet(isPresented: $showWandering)
                    {
                        ActionEditorView(gra: $gra, akcjaText: $card.wandering)
                    }
                    Text(card.wandering)
                }
                HStack
                {
                    Button("akcjaRzucaneZaklęcie")
                    {
                        showAkcjaRzucaneZaklęcie = true
                    }
                    .sheet(isPresented: $showAkcjaRzucaneZaklęcie)
                    {
                        ActionEditorView(gra: $gra, akcjaText: $card.akcjaRzucaneZaklęcie)
                    }
                    Text(card.akcjaRzucaneZaklęcie)
                }
                HStack
                {
                    VStack
                    {
                        Text("lingering")
                            .font(.headline)
                        Picker("Lingering Type", selection: Binding(
                            get: {
                                switch card.lingering {
                                case .int:
                                    return "Zachowaj"
                                case .string:
                                    return "String"
                                }
                            },
                            set: { newValue in
                                switch newValue {
                                case "Zachowaj":
                                    card.lingering = .int(0)
                                case "String":
                                    card.lingering = .string("")
                                default:
                                    break
                                }
                            }
                        )) {
                            Text("Zachowaj").tag("Zachowaj")
                            Text("Akcja").tag("String")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        switch card.lingering {
                        case .int(let value):
                            Stepper(value: Binding(
                                get: { value },
                                set: { card.lingering = .int($0) }
                            ), in: 0...100) {
                                Text("Ilość kart: \(value)")
                            }
                        case .string(let value):
                            HStack{
                                Button("lingering")
                                {
                                    showLingering = true
                                }
                                .sheet(isPresented: $showLingering)
                                {
                                    ActionEditorView(gra: $gra, akcjaText: Binding(
                                        get: { value },
                                        set: { card.lingering = .string($0) }
                                    ))
                                }
                                Text(value)
                            }.padding()
                        }
                    }
                }
            }
            Section(header: Text("Postacie")) {
                ForEach(postacie, id: \.self) { postać in
                    Toggle(postać, isOn: Binding(
                        get: { card.postacie.contains(postać) },
                        set: { isSelected in
                            if isSelected {
                                card.postacie.append(postać)
                            } else {
                                card.postacie.removeAll { $0 == postać }
                            }
                        }
                    ))
                }
            }
            
            Button("Save") {
                if let updatedJSON = card.save() {
                    jsonText = updatedJSON
                }
            }
        }
        .onAppear()
        {
            if(jsonText != nil)
            {
                card = Card.load(from: jsonText!)!
            }
        }
        .onChange(of: jsonText)
        {
            if(jsonText != nil)
            {
                card = Card.load(from: jsonText!)!
            }
        }
        .navigationTitle("Edit Card")
    }
}
