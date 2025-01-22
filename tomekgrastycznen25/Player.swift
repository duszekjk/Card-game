//
//  Player.swift
//  tomekgrastycznen25
//
//  Created by Jacek Kałużny on 18/01/2025.
//

import SwiftUI
import ImageIO
import MobileCoreServices

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
                    KartaContainerView(gra: $gra, talia: $talia, lastPlayed: $lastPlayed, activePlayer: $activePlayer, gameRound: $gameRound, landscape: $landscape, containerKey: playerKey, isDropEnabled: false, size: max(3, min(CGFloat(integerLiteral: (player["karty"]  as? Array<Dictionary<String, Any>>)?.count ?? 3), 10)))
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
            .background(RoundedRectangle(cornerRadius: 10).fill(isActive ? Color(UIColor.secondarySystemGroupedBackground) : Color(UIColor.systemGroupedBackground)))
            .shadow(radius: isActive ? 6 : 1)
            .frame(minWidth: UIScreen.main.bounds.size.width/2, idealWidth: UIScreen.main.bounds.size.width - 5.0, maxWidth: UIScreen.main.bounds.size.width - 2.0)
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

    private func saveImageWithMetadata(image: UIImage, fileName: String) -> URL? {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        guard let imageData = image.pngData(),
              let source = CGImageSourceCreateWithData(imageData as CFData, nil),
              let type = CGImageSourceGetType(source) else {
            print("Failed to create image source")
            return nil
        }

        let metadata = NSMutableDictionary()
        metadata[kCGImagePropertyTIFFDictionary as String] = [
            kCGImagePropertyTIFFArtist as String: "SwiftUI App",
            kCGImagePropertyTIFFSoftware as String: "Custom Renderer"
        ]

        guard let destination = CGImageDestinationCreateWithURL(tempURL as CFURL, type, 1, nil) else {
            print("Failed to create image destination")
            return nil
        }

        CGImageDestinationAddImageFromSource(destination, source, 0, metadata as CFDictionary)
        if CGImageDestinationFinalize(destination) {
            print("Image with metadata saved at \(tempURL)")
            return tempURL
        } else {
            print("Failed to save image with metadata")
            return nil
        }
    }

    private func saveAndShareImage(image: UIImage, playerName: String) {
        // Ensure the filename is descriptive and ends with .png
        let sanitizedPlayerName = playerName.replacingOccurrences(of: " ", with: "_")
        let fileName = "\(sanitizedPlayerName).png"


        do {
            let tempURL = saveImageWithMetadata(image: image, fileName: fileName)
            // Present the share sheet
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)

            // For iPad, set the sourceView and sourceRect to avoid crashes
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                if let popoverController = activityVC.popoverPresentationController {
                    popoverController.sourceView = rootVC.view
                    popoverController.sourceRect = CGRect(
                        x: rootVC.view.bounds.midX,
                        y: rootVC.view.bounds.midY,
                        width: 0,
                        height: 0
                    )
                    popoverController.permittedArrowDirections = []
                }
                rootVC.present(activityVC, animated: true, completion: nil)
            }
        } catch {
            print("Failed to write image to file: \(error)")
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
                            KartaContainerView(gra: $gra, talia: $talia, lastPlayed: $lastPlayed, activePlayer: $activePlayer, gameRound: $gameRound, landscape: $landscape, containerKey: playerKey, isDropEnabled: false, size: max(1, min(CGFloat(integerLiteral: (player["karty"]  as? Array<Dictionary<String, Any>>)?.count ?? 3), 10)))
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
                .background(RoundedRectangle(cornerRadius: 10).fill(isActive ? Color(UIColor.secondarySystemGroupedBackground) : Color(UIColor.systemGroupedBackground)))
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

}
