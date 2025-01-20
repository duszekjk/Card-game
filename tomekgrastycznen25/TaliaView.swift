import SwiftUI
import UniformTypeIdentifiers

struct TaliaView: View {
    @Binding var talia: Array<Dictionary<String, Any>> // Binding to the global `talia` variable.
    var isDragEnabled: Bool = true
    var isDropEnabled: Bool = true

    var body: some View {
        VStack {
            Text("Talia")
                .font(.headline)

            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray)
                    .frame(width: 120, height: 180)
                    .shadow(radius: 5)

                Text("Talia")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .onDrag {
                guard isDragEnabled, !talia.isEmpty else { return NSItemProvider() }
                let randomIndex = Int.random(in: 0..<talia.count)
                return NSItemProvider(object: "Talia|\(randomIndex)" as NSString)
            }
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
                guard error == nil, let data = data as? Data, let identifier = String(data: data, encoding: .utf8) else {
                    return
                }

                DispatchQueue.main.async {
                    let parts = identifier.split(separator: "|")
                    guard parts.count == 2, parts.first == "Talia" else { return }

                    // Dropped card's source key and index (use for other sources too)
                    if let sourceKey = parts.first, let sourceIndex = Int(parts.last ?? "") {
                        moveCardToTalia(from: sourceKey, at: sourceIndex)
                    }
                }
            }
        }
        return true
    }

    private func moveCardToTalia(from sourceKey: String, at sourceIndex: Int) {
        // Handle adding card back to the talia.
        if sourceKey == "Talia" { return } // Prevent adding to the same talia.

        // Retrieve card from source
        if var sourceCards = gra[sourceKey] as? [String: Any],
           var karty = sourceCards["karty"] as? Array<Dictionary<String, Any>> {
            guard sourceIndex >= 0, sourceIndex < karty.count else { return }
            let card = karty.remove(at: sourceIndex)
            sourceCards["karty"] = karty
            gra[sourceKey] = sourceCards

            // Add card back to talia
            talia.append(card)
        }
    }
}
