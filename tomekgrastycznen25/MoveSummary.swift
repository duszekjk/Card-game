//
//  moveSumary.swift
//  tomekgrastycznen25
//
//  Created by Jacek Kałużny on 09/02/2025.
//


import SwiftUI
import SpriteKit
struct MoveSummary: View {
    var graBefore : Dictionary<String, Any>// = Dictionary<String, Any>()
    var graAfter : Dictionary<String, Any>// = Dictionary<String, Any>()
    @Binding var show: Bool
    
    @State private var showFireworks = true
    @State private var scene: SKScene? = nil
    
    func spellCasted() -> SKScene {
        // Create a blank SKScene
        let scene = SKScene(size: UIScreen.main.bounds.size)  // or some other size
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.0)           // center = (0,0)
        scene.scaleMode = .resizeFill
        scene.backgroundColor = .clear

        if let emitter = SKEmitterNode(fileNamed: "ParticleSpell") {
            emitter.position = .zero // now it's the center, because anchor is (0.5,0.5)
            emitter.targetNode = scene
            scene.addChild(emitter)
        }

        return scene
    }
    func smokeCasted() -> SKScene {
        // Create a blank SKScene
        let scene = SKScene(size: UIScreen.main.bounds.size)  // or some other size
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.1)           // center = (0,0)
        scene.scaleMode = .resizeFill
        scene.backgroundColor = .clear

        if let emitter = SKEmitterNode(fileNamed: "Poof") {
            emitter.position = .zero // now it's the center, because anchor is (0.5,0.5)
            emitter.targetNode = scene

            scene.addChild(emitter)
        }

        return scene
    }
    
    var body: some View {
        VStack
        {
            if let player = graBefore["Player2"] as? Dictionary<String, Any>
            {
                HStack
                {
                    Image("\(player["nazwa"] as! String) Mini")
                    Text(player["nazwa"] as! String)
                        .font(.custom("Cinzel", size: 15))
                }
                PlayerSumary(player: player)
            }
            Divider()
            if let player = graBefore["Player1"] as? Dictionary<String, Any>
            {
                HStack
                {
                    Image("\(player["nazwa"] as! String) Mini")
                    Text(player["nazwa"] as! String)
                        .font(.custom("Cinzel", size: 15))
                }
                PlayerSumary(player: player)
            }
            Divider()
            Text(graAfter["ZaklęcieLastTableKey"] as! String)
                .font(.footnote)
                .padding(0)
                .padding(.bottom, -5)
            KartaContainerView(gra: .constant(graAfter), lastPlayed: .constant("None"), activePlayer: .constant(-21), gameRound: .constant(-21), landscape: .constant(true), selectedCard: .constant(nil), containerKey: "ZaklęcieLast", isDragEnabled: false, isDropEnabled: false)
            HStack
            {
                Image(systemName: (graAfter["ZaklęcieCast"] as? Bool) ?? false ? "wand.and.rays" : "xmark")
                    .foregroundStyle((graAfter["ZaklęcieCast"] as? Bool) ?? false ? .green : .red)
                ForEach(Range(0...5))
                {_ in
                    Image(systemName: "arrowshape.down")
                }
                Image(systemName: (graAfter["ZaklęcieCast"] as? Bool) ?? false ? "wand.and.rays" : "xmark")
                    .foregroundStyle((graAfter["ZaklęcieCast"] as? Bool) ?? false ? .green : .red)
            }
            .padding(.bottom)
            Divider()
            
            
            if let player = graAfter["Player2"] as? Dictionary<String, Any>
            {
                HStack
                {
                    Image("\(player["nazwa"] as! String) Mini")
                    Text(player["nazwa"] as! String)
                        .font(.custom("Cinzel", size: 15))
                }
                PlayerSumary(player: player)
            }
            Divider()
            if let player = graAfter["Player1"] as? Dictionary<String, Any>
            {
                HStack
                {
                    Image("\(player["nazwa"] as! String) Mini")
                    Text(player["nazwa"] as! String)
                        .font(.custom("Cinzel", size: 15))
                }
                PlayerSumary(player: player)
            }
            Divider()
            Button(action:
                    {
                show = false
            }, label:
                    {
                Text("OK")
                    .padding()
                    .foregroundStyle(Color.accentColor)
            })
        }
        .padding()
        .background(
            Group {
                if showFireworks {
                    if(scene != nil)
                    {
                        SpriteView(
                            scene: scene!,
                            preferredFramesPerSecond: 24
                        )
                        .padding(.bottom, 30)
//                        .frame(maxWidth: 300)
                        .background(Color.clear)
                    }
                }
            }
        )
        .background(.black.opacity(0.65))
        .cornerRadius(20)
        .foregroundStyle(.white)
        .shadow(color: .black, radius: 5)
        .padding()
        .frame(maxWidth:600)
        .onAppear {
            scene = (((graAfter["ZaklęcieCast"] as? Bool) == true) ? spellCasted() : smokeCasted())
            showFireworks = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                showFireworks = false
                scene = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    scene = (((graAfter["ZaklęcieCast"] as? Bool) == true) ? spellCasted() : smokeCasted())
                    showFireworks = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                        showFireworks = false
                        scene = nil
                    }
                }
            }
        }
        
    }
}

struct PlayerSumary: View {
    var player : Dictionary<String, Any>
    
    var body: some View {
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
        .padding(2)
    }
}
