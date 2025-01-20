struct TaliaSheetContent: View {
    @Binding var showTaliaID: Int
    @Binding var gra: GraType // Replace GraType with your actual type
    @Binding var talie: TalieType // Replace TalieType with your actual type
    @Binding var PlayerLast: PlayerType // Replace PlayerType with your actual type
    @Binding var activePlayer: PlayerType
    @Binding var gameRound: RoundType // Replace RoundType with your actual type

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
                }
                .buttonStyle(.borderedProminent)
                .padding()

                Button("Player2") {
                    showTaliaID = 2
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
        }
    }
}
