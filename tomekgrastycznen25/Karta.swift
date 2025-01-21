import SwiftUI
import UniformTypeIdentifiers

struct KartaView: View {
    let karta: Dictionary<String, Any>
    @State public var showBig = false

    var body: some View {
        VStack {
            if((karta["opis"] as? String ?? "") != "Placeholder")
            {
                HStack
                {
                    Text("\(karta["koszt"] as? Int ?? 0)")
                        .font(.footnote)
                    Spacer()
                }
                .padding()
                Text("\(karta["opis"] as? String ?? "")")
                    .font(.caption)
                    .lineLimit(6)
            }
        }
        .padding(1)
        .frame(minWidth: 96, idealWidth: 97, maxWidth: 98, minHeight: 124, idealHeight: 125, maxHeight: 135)
        .background(RoundedRectangle(cornerRadius: 10).fill(((karta["opis"] as? String ?? "") != "Placeholder") ? Color.blue : Color.gray))
        .foregroundColor(.white)
        .shadow(radius: 5)
        .onTapGesture(count: 2) {
            showBig.toggle()
        }
        .sheet(isPresented: $showBig)
        {
            KartaBigView(karta: karta, showBig: $showBig)
        }
    }
}
struct KartaBigView: View {
    let karta: Dictionary<String, Any>
    @Binding var showBig: Bool

    var body: some View {
        VStack {
            if((karta["opis"] as? String ?? "") != "Placeholder")
            {
                HStack
                {
                    Text("\(karta["koszt"] as? Int ?? 0)")
                        .font(.footnote)
                    Spacer()
                }
                .padding()
                Spacer()
                Text("\(karta["opis"] as? String ?? "")")
                    .font(.caption)
                    .lineLimit(6)
                    .padding()
                Spacer()
            }
        }
        .padding(15)
        .background(RoundedRectangle(cornerRadius: 10).fill(((karta["opis"] as? String ?? "") != "Placeholder") ? Color.blue : Color.gray))
        .foregroundColor(.white)
        .shadow(radius: 5)
        .onTapGesture(count: 2) {
            showBig.toggle()
        }
    }
}
var emptyKarta:Dictionary<String, Any> = [
    "koszt": 0,
    "akcjaRzucaneZaklęcie": "",
    "akcjaOdrzuconeZaklęcie": "",
    "pacyfizm": "",
    "opis": "Placeholder"
]
var emptyKarty = [emptyKarta, emptyKarta, emptyKarta]

struct KartaContainerView: View {
    @Binding var gra: Dictionary<String, Any>
    @Binding var talia: Array<Dictionary<String, Any>>
    @Binding var lastPlayed: String
    @Binding var activePlayer : Int
    @Binding var gameRound : Int
    @Binding var landscape : Bool
    let containerKey: String // Key in `gra` (e.g., "Zaklęcie", "Lingering")
    var isDragEnabled: Bool = true
    var isDropEnabled: Bool = true
    var size:CGFloat = 3
    var sizeFullAction : (String, Array<Dictionary<String, Any>>) -> Void = { selectedContainerKey, kards in
        
    }
    @State public var kartyCount = 3
    var body: some View {
        VStack {

            ScrollView(.horizontal, showsIndicators: false) {
                if let container = gra[containerKey] as? Dictionary<String, Any>
                {
                    let kartyLoad = container["karty"] as? Array<Dictionary<String, Any>> ?? emptyKarty
                    let karty = (kartyLoad.isEmpty) ? emptyKarty : kartyLoad
                    let columns = Array(repeating: GridItem(.flexible()), count: Int(max(1, min(Int(size), karty.count))))


                    VStack {
                        LazyVGrid(columns: columns, spacing: 5) {
                            ForEach(karty.indices, id: \.self) { index in
                                let karta = karty[index]
                                KartaView(karta: karta)
                                    .onDrag {
                                        NSItemProvider(object: isDragEnabled ? "\(containerKey)|\(index)" as NSString : "" as NSString)
                                    }
                            }
                        }
                    }
                    .frame(minWidth: size*100)
                    .onAppear()
                    {
                        kartyCount = karty.count
                    }
                    .onChange(of: karty.count)
                    {
                        kartyCount = karty.count
                    }
                }
                else
                {
                    let karty = emptyKarty
                    let columns = Array(repeating: GridItem(.flexible()), count: Int(max(1, min(5, karty.count))))
//                    if(landscape)
//                    {
                        HStack
                        {
                            ForEach(karty.indices, id: \.self) { index in
                                let karta = karty[index]
                                KartaView(karta: karta)
                                    .onDrag {
                                        NSItemProvider(object: isDragEnabled ? "\(containerKey)|\(index)" as NSString : "" as NSString)
                                    }
                            }
                        }
                        .frame(minWidth: size*100)
//                    }
//                    else
//                    {
//                        LazyVGrid(columns: columns, spacing: 5) {
//                            ForEach(karty.indices, id: \.self) { index in
//                                let karta = karty[index]
//                                KartaView(karta: karta)
//                                    .onDrag {
//                                        NSItemProvider(object: isDragEnabled ? "\(containerKey)|\(index)" as NSString : "" as NSString)
//                                    }
//                            }
//                        }
//                        .frame(minWidth: size*100)
//                        
//                    }
                }

            }
            .frame(minWidth: min(size*100, UIScreen.main.bounds.size.width - 20), alignment: .center)
//            .frame(minWidth: size*111, idealWidth: size*112, maxWidth: size*113, minHeight: 134 , idealHeight: min(135 * (roundl(CGFloat(kartyCount)/CGFloat(size))), 460), maxHeight: 460, alignment: .center)
            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 2))
            .onDrop(of: [UTType.text], isTargeted: nil) { providers in
                guard isDropEnabled else { return false }
                return handleDrop(providers: providers)
            }
        }
        .scaleEffect(UIDevice.current.userInterfaceIdiom == .phone ? 0.75 : 1.0)
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { (data, error) in
                guard error == nil, let data = data as? Data, let identifier = String(data: data, encoding: .utf8) else {
                    return
                }

                DispatchQueue.main.async {
                    let parts = identifier.split(separator: "|")
                    guard parts.count == 2,
                          let sourceKey = parts.first,
                          let sourceIndex = Int(parts.last ?? "") else { return }

                    moveCard(from: String(sourceKey), at: sourceIndex, to: containerKey)
                    lastPlayed = String(sourceKey)
                    if let container = gra[containerKey] as? Dictionary<String, Any>
                    {
                        let kartyLoad = container["karty"] as? Array<Dictionary<String, Any>> ?? []
                        if(CGFloat(kartyLoad.count) == size)
                        {
                            print("Running spell bc \(CGFloat(kartyLoad.count)) == \(size)")
                            sizeFullAction(containerKey, kartyLoad)
                        }
                        else {
                            gameRound += 1
                            activePlayer = gameRound % playersList.count
                        }
                    }
                }
            }
        }
        return true
    }

    private func moveCard(from sourceKey: String, at sourceIndex: Int, to destinationKey: String) {
        var sourceCards = Array<Dictionary<String, Any>>()
        var sourceIndexCorrected = sourceIndex
        if(gra[sourceKey] == nil)
        {
            sourceCards = talia
            sourceIndexCorrected = Int.random(in: 0..<talia.count)
        }
        else
        {
            sourceCards = (gra[sourceKey] as! Dictionary<String, Any>)["karty"] as? Array<Dictionary<String, Any>> ?? []
        }
        guard sourceIndexCorrected >= 0, sourceIndexCorrected < sourceCards.count else { return }

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
    }
}
