import SwiftUI

// Model for a card
struct Karta: Identifiable, Hashable {
    let id = UUID()
    let koszt: Int
    let akcjaRzucaneZaklęcie: String
    let akcjaOdrzuconeZaklęcie: String
}

// Card View
struct KartaView: View {
    let karta: Karta

    var body: some View {
        VStack {
            Text("Koszt: \(karta.koszt)")
                .font(.headline)
            Text("Rzuć: \(karta.akcjaRzucaneZaklęcie)")
                .font(.caption)
                .lineLimit(2)
            Text("Odrzuć: \(karta.akcjaOdrzuconeZaklęcie)")
                .font(.caption)
                .lineLimit(2)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue))
        .foregroundColor(.white)
        .shadow(radius: 5)
        .frame(width: 120, height: 80)
    }
}

// A container for cards with drag-and-drop support
struct KartaContainerView: View {
    @Binding var karty: [Karta]
    let title: String
    var isDragEnabled: Bool = true
    var isDropEnabled: Bool = true

    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(karty) { karta in
                        KartaView(karta: karta)
                            .onDrag {
                                isDragEnabled ? NSItemProvider(object: karta.id.uuidString as NSString) : nil
                            }
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 2))
            .onDrop(of: [UTType.text], isTargeted: nil) { providers in
                guard isDropEnabled else { return false }
                return handleDrop(providers: providers)
            }
        }
        .padding()
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { (data, error) in
                if let data = data as? Data,
                   let uuidString = String(data: data, encoding: .utf8),
                   let uuid = UUID(uuidString: uuidString),
                   let droppedKarta = allKarty.first(where: { $0.id == uuid }) {
                    DispatchQueue.main.async {
                        karty.append(droppedKarta)
                    }
                }
            }
        }
        return true
    }
}

// Sample data
var allKarty = taliaBase.map {
    Karta(koszt: $0["koszt"] as! Int,
          akcjaRzucaneZaklęcie: $0["akcjaRzucaneZaklęcie"] as! String,
          akcjaOdrzuconeZaklęcie: $0["akcjaOdrzuconeZaklęcie"] as! String)
}