//
//  Player.swift
//  tomekgrastycznen25
//
//  Created by Jacek Kałużny on 18/01/2025.
//

import SwiftUI
import ImageIO
//import MobileCoreServices

struct PlayerView: View {
    @EnvironmentObject var connectionManager: MPConnectionManager
    
    @State private var capturedImage: UIImage?
    
    
    let playerKey: String
    @Binding var gra: Dictionary<String, Any>
    @Binding var talia: Array<Dictionary<String, Any>>
    @Binding var lastPlayed: String
    @Binding var isActive: Bool
    @Binding var activePlayer : Int
    @Binding var gameRound : Int
    @Binding var landscape : Bool
    @Binding var playerLoose : String
    @Binding var endGame : Bool
    
    
    @State public var showTalia: Bool = false
    @State public var showTaliaID: Int = 0
    
    @State var showBig: Bool = false
    var body: some View {
        if let player = gra[playerKey] as? Dictionary<String, Any> {
                VStack(alignment: .leading, spacing: 10) {
                    // Name
                    Text(player["nazwa"] as? String ?? "Unknown Player")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.leading, 40)
                    
                    // ilośćKart, mana/manaMax, życie
                    
                    
                    // karty
                    if(isActive)
                    {
                        HStack
                        {
                            if(UIDevice.current.userInterfaceIdiom != .phone)
                            {
                                TaliaView(gra: $gra, talia: $talia, nazwa: "Talia\n\(player["nazwa"] ?? playerKey)")
                                    .onTapGesture(count: 1) {
                                        DispatchQueue.main.async
                                        {
                                            showTaliaID = 2
                                            print("(showTaliaID - 1) \((showTaliaID - 1)) / \(playersList.count)  \(showTaliaID > 0 && showTaliaID < playersList.count + 1)")
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            showTalia.toggle()
                                        }
                                    }
                                    .sheet(isPresented: $showTalia) {
                                        ScrollView {
                                            TaliaContainerView(
                                                gra: $gra,
                                                talia: $talia,
                                                lastPlayed: $lastPlayed,
                                                activePlayer: $activePlayer,
                                                gameRound: $gameRound,
                                                containerKey: "TaliaPlayer\(showTaliaID)",
                                                size: 5
                                            )
                                        }
                                    }
                            }
                            KartaContainerView(gra: $gra, talia: $talia, lastPlayed: $lastPlayed, activePlayer: $activePlayer, gameRound: $gameRound, landscape: $landscape, containerKey: playerKey, isDropEnabled: false, size: max(3, min(CGFloat(integerLiteral: (player["karty"]  as? Array<Dictionary<String, Any>>)?.count ?? 3), 10)))
                        }
                    }
                    
                    // akcjaRzucaneZaklęcie
                    HStack
                    {
                        HStack {
                            // ilośćKart
                            HStack {
                                Image(systemName: "doc.on.doc")
                                Text("\(player["ilośćKart"] as? Int ?? 0)")
                            }
                            
                            Spacer()
                            
                            // mana/manaMax
                            HStack {
                                Image(systemName: "bolt.fill")
                                Text("\(player["mana"] as? Int ?? 0) /\(player["manaMax"] as? Int ?? 0)")
                            }
                            .onChange(of: player["mana"] as? Int ?? 0)
                            { newValue in
                                var manaMax = player["manaMax"] as? Int ?? 0
                                if(newValue > manaMax)
                                {
                                    var updatedPlayer = player
                                    updatedPlayer["mana"] = manaMax
                                    gra[playerKey] = updatedPlayer
                                }
                            }
                            
                            Spacer()
                            
                            // tarcza
                            HStack {
                                Image(systemName: "shield.pattern.checkered")
                                    .foregroundColor(.red)
                                Text("\(player["tarcza"] as? Int ?? 0)")
                            }
                            
                            Spacer()
                            
                            // życie
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                                Text("\(player["życie"] as? Int ?? 0)")
                            }
                            .onChange(of: player["życie"] as? Int ?? 0) { newValue in
                                if let life = newValue as? Int, life == 0 {
                                    playerLoose = playerKey // Set the player who lost
                                    connectionManager.send(gameState: gra)
                                    endGame = true          // Trigger the end of the game
                                }
                            }
                            
                            Spacer()
                        }
                        .font(.headline)
                        .frame(minWidth: 300)
                        Divider()
                        Spacer()
                        VStack(alignment: .leading){
                            HStack(alignment: .firstTextBaseline) {
                                Image(systemName: "wand.and.stars")
                                Text(player["opisRzucaneZaklęcie"] as? String ?? "Brak akcji")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .lineLimit(2)
                                
                            }
                            
                            // akcjaOdrzucaneZaklęcie
                            HStack(alignment: .firstTextBaseline) {
                                Image(systemName: "trash.fill")
                                Text(player["opisOdrzucaneZaklęcie"] as? String ?? "Brak akcji")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .lineLimit(2)
                            }
                        }
                    }
                    .scaleEffect(UIDevice.current.userInterfaceIdiom == .phone ? 0.75 : 1.0)
                }
                .padding()
                //            .padding(.vertical, 40)
                .background(RoundedRectangle(cornerRadius: 10).fill(isActive ? Color(PlatformColor.secondarySystemGroupedBackground) : Color(PlatformColor.systemGroupedBackground)))
                .shadow(radius: isActive ? 6 : 1)
                .frame(minWidth: UIScreen.main.bounds.size.width/2, idealWidth: UIScreen.main.bounds.size.width - 65.0, maxWidth: UIScreen.main.bounds.size.width - 55.0)
                .onTapGesture(count: 1) {
                    DispatchQueue.main.async
                    {
                        showBig = true
                    }
                }
                .sheet(isPresented: $showBig, onDismiss: {
                    // Trigger share after dismissing the sheet
                    if let image = capturedImage {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            if let player = gra[playerKey] as? Dictionary<String, Any>,
                               let playerName = player["nazwa"] as? String {
                                saveAndShareImage(image: image, playerName: playerName)
                            }
                            
                        }
                    }
                })
                {
                    PlayerBigView(playerKey: playerKey, gra: $gra, talia: $talia, lastPlayed: $lastPlayed, isActive: $isActive, activePlayer: $activePlayer, gameRound: $gameRound
                                  , landscape: $landscape, playerLoose: $playerLoose, endGame: $endGame, onLongPress: { image in
                        capturedImage = image
                        showBig = false
                    })
                }
            
        } else {
            Text("Player not found")
                .font(.headline)
                .foregroundColor(.red)
        }
    }


}
struct PlayerBigView: View {
    let playerKey: String
    @Binding var gra: Dictionary<String, Any>
    @Binding var talia: Array<Dictionary<String, Any>>
    @Binding var lastPlayed: String
    @Binding var isActive: Bool
    @Binding var activePlayer : Int
    @Binding var gameRound : Int
    @Binding var landscape : Bool
    @Binding var playerLoose : String
    @Binding var endGame : Bool
    
    @State public var showTalia: Bool = false
    @State public var showTaliaID: Int = 0
    
    let onLongPress: (UIImage) -> Void
    @State var isSharing: Bool = false
    
    
    var blurSize =  UIScreen.main.bounds.size.height*0.02+20
    
    var body: some View {
        
        GeometryReader { geometry in
            if let player = gra[playerKey] as? Dictionary<String, Any> {
                VStack(alignment: .center, spacing: 10) {
                    // Name
                    VStack
                    {
                        if let playerName = player["nazwa"] as? String,
                           UIImage(named: playerName) != nil {
                            ZStack {
                                // Background Image with Inner Shadow
                                Image(playerName)
                                    .resizable()
                                    .scaledToFill()
                                    .blur(radius: blurSize)
                                Image(playerName)
                                    .resizable()
                                    .scaledToFill()
                                    .blur(radius: blurSize)
                                Image(playerName)
                                    .resizable()
                                    .scaledToFill()
                                    .blur(radius: blurSize)
                                Image(playerName)
                                    .resizable()
                                    .scaledToFill()
                                    .blur(radius: blurSize)
                                    .brightness(-0.1)
                                VStack()
                                {
                                    Image(playerName)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .clipped()
                                }
                                .frame(maxWidth: .infinity, maxHeight: 340)
                                .clipped()
                                
                            }
                            .frame(maxWidth: .infinity, maxHeight: 340) // Adjust height as needed
                            .padding(.top, -30)
                            .padding(.horizontal, -40)
                            
                            Text(player["nazwa"] as? String ?? "Unknown Player")
                                .foregroundColor(.white)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .fontWeight(.bold)
                        }
                        else
                        {
                            Text(player["nazwa"] as? String ?? "Unknown Player")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .fontWeight(.bold)
                                .padding()
                        }
                    }
                    .onLongPressGesture {
                        
                        isSharing = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            captureView(size: geometry.size)
                        }
                    }
                    //                .frame(maxHeight: 300)
                    // karty
                    // akcjaRzucaneZaklęcie
                    VStack
                    {
                        Divider()
                        HStack {
                            // ilośćKart
                            Spacer()
                            HStack {
                                Image(systemName: "doc.on.doc")
                                Text("\(player["ilośćKart"] as? Int ?? 0)")
                            }
                            
                            Spacer()
                            
                            // mana/manaMax
                            HStack {
                                Image(systemName: "bolt.fill")
                                Text("\(player["mana"] as? Int ?? 0)/\(player["manaMax"] as? Int ?? 0)")
                            }
                            
                            Spacer()
                            
                            HStack {
                                Image(systemName: "shield.pattern.checkered")
                                    .foregroundColor(.red)
                                Text("\(player["tarcza"] as? Int ?? 0)")
                            }
                            
                            // życie
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                                Text("\(player["życie"] as? Int ?? 0)")
                            }
                            
                            Spacer()
                        }
                        .font(.headline)
                        .padding()
                        Divider()
                        if(isActive && !isSharing)
                        {
                            HStack
                            {
                                KartaContainerView(gra: $gra, talia: $talia, lastPlayed: $lastPlayed, activePlayer: $activePlayer, gameRound: $gameRound, landscape: $landscape, containerKey: playerKey, isDropEnabled: false, size: max(1, min(CGFloat(integerLiteral: (player["karty"]  as? Array<Dictionary<String, Any>>)?.count ?? 3), 10)))
                                    .padding(.horizontal, 25)
                                    .onLongPressGesture {
                                            DispatchQueue.main.async
                                            {
                                                showTaliaID = 2
                                                print("(showTaliaID - 1) \((showTaliaID - 1)) / \(playersList.count)  \(showTaliaID > 0 && showTaliaID < playersList.count + 1)")
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                showTalia.toggle()
                                            }
                                    }
                                    .sheet(isPresented: $showTalia) {
                                        ScrollView {
                                            TaliaContainerView(
                                                gra: $gra,
                                                talia: $talia,
                                                lastPlayed: $lastPlayed,
                                                activePlayer: $activePlayer,
                                                gameRound: $gameRound,
                                                containerKey: "TaliaPlayer\(showTaliaID)",
                                                size: 5
                                            )
                                        }
                                    }
                            }
                        }
                        
                        Spacer()
                        Text(player["opis"] as? String ?? "")
                            .scaleEffect(UIDevice.current.userInterfaceIdiom == .phone ? 0.75 : 1.0)
                        Spacer()
                        VStack(alignment: .leading){
                            HStack(alignment: .firstTextBaseline) {
                                Image(systemName: "wand.and.stars")
                                Text(player["opisRzucaneZaklęcie"] as? String ?? "No Action")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .lineLimit(2)
                                
                            }
                            
                            // akcjaOdrzucaneZaklęcie
                            HStack(alignment: .firstTextBaseline) {
                                Image(systemName: "trash.fill")
                                Text(player["opisOdrzucaneZaklęcie"] as? String ?? "No Action")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .lineLimit(2)
                            }
                        }
                    }
                    //
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(isActive ? Color(PlatformColor.secondarySystemGroupedBackground) : Color(PlatformColor.systemGroupedBackground)))
                .frame(maxWidth: geometry.size.width, minHeight: UIScreen.main.bounds.size.height*0.85)
                .shadow(radius: isActive ? 6 : 1)
            } else {
                Text("Player not found")
                    .font(.headline)
                    .foregroundColor(.red)
            }
        }
        .frame(maxWidth: .infinity ,minHeight: UIScreen.main.bounds.size.height*0.85)
        .padding(.top, -30)
    }
#if os(iOS)
    private func captureView(size: CGSize) {
        // Render the view with the specific dimensions
        let hostingController = UIHostingController(rootView: self)
        let window = UIApplication.shared.windows.first
        guard let targetView = hostingController.view,
              let parentView = window?.rootViewController?.view else { return }

        // Match the size to the geometry-provided dimensions
        targetView.frame = CGRect(origin: CGPoint(x: 0.0, y: 30), size: size)
        parentView.addSubview(targetView)

        // Render the view into an image
        let renderer = UIGraphicsImageRenderer(size: targetView.bounds.size)
        let image = renderer.image { _ in
            targetView.drawHierarchy(in: targetView.bounds, afterScreenUpdates: true)
        }

        // Clean up the temporary view
        targetView.removeFromSuperview()

        // Pass the captured image
        onLongPress(image)
    }
#else
    private func captureView(size: CGSize) {
        // Create a hosting controller for the SwiftUI view
        let hostingController = NSHostingController(rootView: self)
        
        // Create an off-screen window to render the view
        let offscreenWindow = NSWindow(
            contentRect: CGRect(origin: .zero, size: size),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        offscreenWindow.contentView = hostingController.view
        offscreenWindow.makeKeyAndOrderFront(nil)
        
        // Match the size to the geometry-provided dimensions
        hostingController.view.frame = CGRect(origin: .zero, size: size)
        
        // Render the view into an image
        guard let bitmapRep = hostingController.view.bitmapImageRepForCachingDisplay(in: hostingController.view.bounds) else { return }
        hostingController.view.cacheDisplay(in: hostingController.view.bounds, to: bitmapRep)
        let image = NSImage(size: size)
        image.addRepresentation(bitmapRep)
        
        // Clean up the temporary window
        offscreenWindow.orderOut(nil)
        
        // Pass the captured image
        onLongPress(image)
    }
#endif
}
