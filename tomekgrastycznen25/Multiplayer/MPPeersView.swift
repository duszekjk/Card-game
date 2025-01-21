//
// Created for XsAndOs
// by Stewart Lynch on 2022-09-14
// Using Swift 5.0
//
// Follow me on Twitter: @StewartLynch
// Subscribe on YouTube: https://youTube.com/StewartLynch
//

import SwiftUI

struct MPPeersView: View {
    
    @EnvironmentObject var connectionManager: MPConnectionManager
//    @EnvironmentObject var game: GameService
    @Binding var startGame: Bool
    @Binding var visible: Bool
    @Binding var thisDevice: Int
    var body: some View {
        VStack {
            HStack
            {
                Spacer()
                Text("Available Players")
                Spacer()
                Button("Done")
                {
                    visible = false
                }
                .padding()
            }
            List(connectionManager.availablePeers, id: \.self) { peer in
                HStack {
                    Text(peer.displayName)
                    Spacer()
                    Button("Select") {
//                        game.gameType = .peer
                        connectionManager.nearbyServiceBrowser.invitePeer(peer, to: connectionManager.session, withContext: nil, timeout: 30)
//                        game.player1.name = connectionManager.myPeerId.displayName
//                        game.player2.name = peer.displayName
                    }
                    .buttonStyle(.borderedProminent)
                    .onAppear()
                    {
                        thisDevice = -1
                        startGame = false
                    }
                }
                .alert("Received Invitation from \(connectionManager.receivedInviteFrom?.displayName ?? "Unknown")",
                       isPresented: $connectionManager.receivedInvite) {
                    Button("Accept") {
                        if let invitationHandler = connectionManager.invitationHandler {
                            invitationHandler(true, connectionManager.session)
                            thisDevice = 1
                            startGame = true
                            visible = false
//                            game.player1.name = connectionManager.receivedInviteFrom?.displayName ?? "Unknown"
//                            game.player2.name = connectionManager.myPeerId.displayName
//                            game.gameType = .peer
                        }
                    }
                    Button("Reject") {
                        if let invitationHandler = connectionManager.invitationHandler {
                            invitationHandler(false, nil)
                        }
                    }
                }
            }
        }
        .onAppear {
            connectionManager.isAvailableToPlay = true
            connectionManager.startBrowsing()
        }
        .onDisappear {
            connectionManager.stopBrowsing()
            connectionManager.stopAdvertising()
            connectionManager.isAvailableToPlay = false
        }
        .onChange(of: connectionManager.paired) { newValue in
            startGame = newValue
            if(thisDevice == -1)
            {
                thisDevice = 0
                visible = false
            }
            print("thisDevice = \(thisDevice)")
        }
    }
}

struct MPPeersView_Previews: PreviewProvider {
    static var previews: some View {
        MPPeersView(startGame: .constant(false), visible: .constant(true), thisDevice: .constant(-1))
            .environmentObject(MPConnectionManager(yourName: "Sample"))
//            .environmentObject(GameService())
    }
}