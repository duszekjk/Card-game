//
//  Player.swift
//  tomekgrastycznen25
//
//  Created by Jacek Kałużny on 18/01/2025.
//

import SwiftUI
import ImageIO
import UniformTypeIdentifiers
//import MobileCoreServices

struct PlayerView: View {
    @EnvironmentObject var connectionManager: MPConnectionManager
    @Environment(\.colorScheme) var colorScheme
    
    @State private var capturedImage: UIImage?
    
    
    let playerKey: String
    @Binding var gra: Dictionary<String, Any>
    @Binding var lastPlayed: String
    @Binding var isActive: Bool
    @Binding var activePlayer : Int
    @Binding var gameRound : Int
    @Binding var landscape : Bool
    @Binding var playerLoose : String
    @Binding var playerWin : String// = ""//playersList.first { $0 != playerLoose } ?? "Unknown"
    @Binding var nameWin : String// = ""//getTextData(&gra, for: playerWin, key: "nazwa")
    @Binding var nameLoose : String// = ""//getTextData(&gra, for: playerLoose, key: "nazwa")
    @Binding var endGame : Bool
    @Binding var selectedCard: String?
    
    @State public var showTalia: Bool = false
    @State public var showTaliaID: Int = 0
    
    @State var showBig: Bool = false
    
    
    @State private var timer: Timer?
    
    
    @State public var backgroundImage: UIImage = generateFilmGrain(size: CGSize(width: 24, height: 15))!
    @State public var backgroundImage2: UIImage = generateFilmGrain(size: CGSize(width: 240, height: 150))!
    
    let requiredKeys = requiredKeysForPostacie
    
    
    
    
    
    
    var body: some View {
        if let player = gra[playerKey] as? Dictionary<String, Any> {
                VStack(alignment: .leading, spacing: 7) {
                    // Name
                    HStack
                    {
                        Text(player["nazwa"] as? String ?? "Unknown Player")
                            .font(.custom("Cinzel", size: 20))
                            .fontWeight(.bold)
                            .padding(.leading, 90)
                        Text(playerKey)
                            .font(.custom("Cinzel", size: 15))
                            .padding(.leading, 10)
                    }
                    .frame(width: 300, height: 15)
                    .onDrag {
                        // Ensure the player JSON includes all required keys
                        var completePlayer = addMissingKeys(to: player)
                        completePlayer["karty"] = []
                        if let data = try? JSONSerialization.data(withJSONObject: completePlayer, options: []),
                           let jsonString = String(data: data, encoding: .utf8) {
                            return NSItemProvider(object: jsonString as NSString)
                        }
                        return NSItemProvider(object: "" as NSString)
                    }

                    .onDrop(of: [UTType.plainText], isTargeted: nil) { providers in
                        guard let provider = providers.first else { return false }
                        
                        provider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { (item, error) in
                            if let data = item as? Data,
                               let jsonString = String(data: data, encoding: .utf8),
                               let jsonData = jsonString.data(using: .utf8) {
                                do {
                                    if let decodedPlayer = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                                        // Validate the JSON structure
                                        if validatePlayerJSON(decodedPlayer) {
                                            // Update your SwiftUI object if valid
                                            DispatchQueue.main.async {
                                                gra[playerKey] = decodedPlayer
                                            }
                                        } else {
                                            print("Invalid JSON structure for player.")
                                        }
                                    }
                                } catch {
                                    print("Error deserializing JSON: \(error)")
                                }
                            }
                        }
                        return true
                    }
                    
                    if(isActive)
                    {
                        HStack
                        {
                            if(UIDevice.current.userInterfaceIdiom != .phone)
                            {
                                TaliaView(gra: $gra, gameRound: $gameRound, playerID: player["id"] as! String, nazwa: "Talia\n\(player["nazwa"] ?? playerKey)")
                                    .onTapGesture(count: 1) {
                                        DispatchQueue.main.async
                                        {
                                            showTaliaID = activePlayer + 1
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
                                                lastPlayed: $lastPlayed,
                                                activePlayer: $activePlayer,
                                                gameRound: $gameRound, show: $showTalia, selectedCard: $selectedCard,
                                                containerKey: "TaliaPlayer\(showTaliaID)",
                                                size: 5
                                            )
                                        }
                                    }
                            }
                            KartaContainerView(gra: $gra, lastPlayed: $lastPlayed, activePlayer: $activePlayer, gameRound: $gameRound, landscape: $landscape, selectedCard: $selectedCard, containerKey: playerKey, isDropEnabled: false, size: max(3, min(CGFloat(integerLiteral: (player["karty"]  as? Array<Dictionary<String, Any>>)?.count ?? 3), 10)))
                        }
                    }
                    
                    HStack
                    {
                        HStack {
                            HStack {
                                Image(systemName: "doc.on.doc")
                                Text("\(player["ilośćKart"] as? Int ?? 0)")
                            }
                            
                            Spacer()
                            
                            HStack {
                                Image(systemName: "bolt.fill")
                                Text("\(player["mana"] as? Int ?? 0) /\(player["manaMax"] as? Int ?? 0)")
                            }
//                            .onChange(of: player["mana"] as? Int ?? 0)
//                            { newValue in
//                                var manaMax = player["manaMax"] as? Int ?? 0
//                                if(newValue > manaMax)
//                                {
//                                    var updatedPlayer = player
//                                    updatedPlayer["mana"] = manaMax
//                                    gra[playerKey] = updatedPlayer
//                                }
//                            }
                            
                            Spacer()
                            
                            HStack {
                                Image(systemName: "shield.pattern.checkered")
                                    .foregroundColor(.red)
                                Text("\(player["tarcza"] as? Int ?? 0)")
                            }
                            
                            Spacer()
                            
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                                Text("\(player["życie"] as? Int ?? 0)")
                            }
//                            .onChange(of: player["życie"] as? Int ?? 0) { newValue in
//                                if let life = newValue as? Int, life == 0 {
//                                    playerLoose = playerKey
//                                    connectionManager.send(gameState: gra)
//                                    endGame = true
//                                }
//                            }
                            
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
                .background(
                    ZStack
                    {
                        if let playerName = player["nazwa"] as? String,
                           UIImage(named: playerName) != nil {
                            Image(playerName)
                                .resizable(resizingMode: .tile)
                                .aspectRatio(12.0, contentMode: .fill)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .blur(radius: 40)
                                .saturation(1.4)
                                .brightness(colorScheme == .dark ? -0.3 : 0.2)
                                .cornerRadius(10)
                            Image(playerName)
                                .resizable()
                                .aspectRatio(12.0, contentMode: .fill)
                                .saturation(1.4)
                                .opacity(0.8)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .blur(radius: 60)
                                .cornerRadius(10)
                        }
                        Image(uiImage: backgroundImage)
                            .resizable()
                            .aspectRatio(12.0, contentMode: .fill)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .cornerRadius(10)
                        Image(uiImage: backgroundImage2)
                            .resizable(resizingMode: .tile)
                            .aspectRatio(12.0, contentMode: .fill)
                            .opacity(0.5)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .cornerRadius(10)
                        
                    }
                        .cornerRadius(10)
                )
                .background(RoundedRectangle(cornerRadius: 10).fill(isActive ? Color("PlayerColor") : Color("PlayerColor")))
                .shadow(radius: isActive ? 6 : 1)
                .frame(minWidth: UIScreen.main.bounds.size.width/2, idealWidth: UIScreen.main.bounds.size.width - 15.0, maxWidth: UIScreen.main.bounds.size.width - 5.0)
                .clipped()
                .cornerRadius(10)
                .onTapGesture(count: 1) {
                    DispatchQueue.main.async
                    {
                        showBig = true
                    }
                }
                .onAppear {
                    startPolling()
                }
                .onDisappear {
                    stopPolling()
                }
                .sheet(isPresented: $showBig, onDismiss: {
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
                    PlayerBigView(playerKey: playerKey, gra: $gra, lastPlayed: $lastPlayed, isActive: $isActive, activePlayer: $activePlayer, gameRound: $gameRound
                                  , landscape: $landscape, playerLoose: $playerLoose, endGame: $endGame, selectedCard: $selectedCard, onLongPress: { image in
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
    private func startPolling() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            checkAndFixValues()
        }
    }
    
    private func stopPolling() {
        timer?.invalidate()
        timer = nil
    }
    private func checkAndFixValues() {
        var life = 0
        graLock.sync {
            // Ensure player data exists
            guard var player = gra[playerKey] as? [String: Any] else { return }
            
            // ✅ Mana Correction
            let mana = player["mana"] as? Int ?? 0
            let manaMax = player["manaMax"] as? Int ?? 0
            if mana > manaMax {
                player["mana"] = manaMax
            }
            
            // ✅ Life Check
            life = player["życie"] as? Int ?? 0
            
            if life < 0 {
                life = 0
                player["życie"] = life
            }
            
            // ✅ Update dictionary
            gra[playerKey] = player
        }
        if life == 0 {
            
            DispatchQueue.main.async {
                playerLoose = playerKey
                playerWin = playersList.first { $0 != playerLoose } ?? "Unknown"
                nameWin = getTextData(&gra, for: playerWin, key: "nazwa")
                nameLoose = getTextData(&gra, for: playerLoose, key: "nazwa")
                connectionManager.send(gameState: gra)
                endGame = true
            }
        }
    }
    func addMissingKeys(to json: [String: Any]) -> [String: Any] {
        
        var updatedJSON = json

        // Add missing keys with null value
        for key in requiredKeys {
            if updatedJSON[key] == nil {
                updatedJSON[key] = NSNull() // Adds a null value
            }
        }
        return updatedJSON
    }
    func validatePlayerJSON(_ json: [String: Any]) -> Bool {
        
        // Check if all required keys exist
        for key in requiredKeys {
            if json[key] == nil {
                print("Missing key: \(key)")
                return false
            }
        }
        
        // Additional validation: `id` must start with "Player"
        if let id = json["id"] as? String, !id.starts(with: "Player") {
            print("Invalid id: \(id). It must start with 'Player'.")
            return false
        }
        
        return true
    }

}
struct PlayerBigView: View {
    let playerKey: String
    @Binding var gra: Dictionary<String, Any>
    @Binding var lastPlayed: String
    @Binding var isActive: Bool
    @Binding var activePlayer : Int
    @Binding var gameRound : Int
    @Binding var landscape : Bool
    @Binding var playerLoose : String
    @Binding var endGame : Bool
    @Binding var selectedCard: String?
    
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
                                KartaContainerView(gra: $gra, lastPlayed: $lastPlayed, activePlayer: $activePlayer, gameRound: $gameRound, landscape: $landscape, selectedCard: $selectedCard, containerKey: playerKey, isDropEnabled: false, size: max(1, min(CGFloat(integerLiteral: (player["karty"]  as? Array<Dictionary<String, Any>>)?.count ?? 3), 10)))
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
                                                lastPlayed: $lastPlayed,
                                                activePlayer: $activePlayer,
                                                gameRound: $gameRound, show: $showTalia, selectedCard: $selectedCard,
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
