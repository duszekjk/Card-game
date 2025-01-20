import SwiftUI

struct TaliaSheetContent: View {
    @Binding var showTaliaID: Int
    @Binding var gra: Dictionary<String, Any>
    @Binding var talie: Dictionary<String, Array<Dictionary<String, Any>>>
    @Binding var PlayerLast: String
    @Binding var activePlayer : Int
    @Binding var gameRound : Int

    let playersList: [String]

    var body: some View {
        if showTaliaID > 0 && showTaliaID < playersList.count + 1 {
            ScrollView {
                TaliaContainerView(
                    gra: $gra,
                    talia: bindingForKey(playersList[showTaliaID - 1], in: $talie),
                    lastPlayed: $PlayerLast,
                    activePlayer: $activePlayer,
                    gameRound: $gameRound,
                    containerKey: "TaliaPlayer\(showTaliaID)",
                    size: 5
                )
            }
        } else {
            VStack {
                Button("Player1") {
                    showTaliaID = 1
                    print("(showTaliaID - 1) \((showTaliaID - 1)) / \(playersList.count)  \(showTaliaID > 0 && showTaliaID < playersList.count + 1)")
                }
                .buttonStyle(.borderedProminent)
                .padding()

                Button("Player2") {
                    showTaliaID = 2
                    print("(showTaliaID - 1) \((showTaliaID - 1)) / \(playersList.count)  \(showTaliaID > 0 && showTaliaID < playersList.count + 1)")
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
        }
    }
}
