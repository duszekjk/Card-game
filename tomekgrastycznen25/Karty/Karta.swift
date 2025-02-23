import SwiftUI
import UniformTypeIdentifiers

struct KartaView: View {
    let karta: Dictionary<String, Any>
    let showPostacie: Bool
    @Binding var selectedCard: String?
    @Binding var orderChanges : Int
    @State public var showBig = false
    
    @State private var capturedImage: UIImage?
    @State private var noiseImage: UIImage = generateFilmGrain(size: CGSize(width: 100, height: 135))!
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 3)
    var body: some View {
        VStack {
            if((karta["opis"] as? String ?? "") != "Placeholder")
            {
                HStack
                {
                    VStack
                    {
                        VStack
                        {
                            Text("\(karta["koszt"] as? Int ?? 0)")
                                .font(.footnote)
                                .padding(4)
                        }
                        .background(
                            Image("TextureCardBackSM")
                                .resizable()
                                .scaledToFill()
                                .blur(radius: 2)
                                .brightness(0.4)
                        )
                        .clipped()
                        .border(.yellow, width: 1.0)
                        .cornerRadius(6)
                        .padding(2)
                        Spacer()
                    }
                    Spacer()
                    if(showPostacie)
                    {
                        LazyVGrid(columns: columns, spacing: 0) {
                            ForEach(karta["postacie"] as? [String] ?? [], id: \.self) { postać in
                                if let _ = UIImage(named: postać + " Mini") {
                                    Image(postać + " Mini")
                                        .resizable()
                                        .scaledToFit()
                                }
                            }
                        }
                        .padding(-16)
                    }
                    else
                    {
                        ZStack
                        {
                            ImageGeneratorView(label: karta["opis"] as? String ?? "")
                                .frame(width: 40, height: 35)
                            AnimatedShapesView(shapes: (karta["opis"] as? String ?? "").getShapes(), noiseImage: $noiseImage, animate: false)
                                .scaleEffect(0.1)
                                .frame(width: 40, height: 35)
                                .clipped()
                                .padding(-5)
                        }
                    }
                    Spacer()
                }
                VStack
                {
                    TextWithSymbols(text: "\(karta["opis"] as? String ?? "")", font: .caption, foregroundColor: .black, orderChanges: $orderChanges)
                        .lineLimit(6)
                        .padding(3)
                    
                    Text("Zimeniono kolejność \(orderChanges) razy")
                        .font(.custom("Cinzel", size: 1))
                }
                .frame(width: 92, height: 70)
                    .background(
                            Image("TextureCardBackSM")
                                .resizable()
                                .scaledToFill()
                                .blur(radius: 3)
                                .brightness(0.4)
                    )
                    .clipped()
                    .cornerRadius(8)
            }
        }
        .padding(1)
        .frame(minWidth: 96, idealWidth: 97, maxWidth: 98, minHeight: 124, idealHeight: 125, maxHeight: 135)
        .background(
            Image("TextureCardBackSM")
                .resizable()
                .scaledToFill()
                .blur(radius: ((karta["opis"] as? String ?? "") != "Placeholder") ? 2 : 0)
                .brightness(((karta["opis"] as? String ?? "") != "Placeholder") ? -0.2 : 0)
        )
        .foregroundColor(.black)
        .overlay(content: {Image(uiImage: noiseImage)})
        .clipped()
        .cornerRadius(10)
        .shadow(radius: 5)
        .onTapGesture(count: 2) {
            showBig.toggle()
        }
        .sheet(isPresented: $showBig, onDismiss: {
            // Trigger share after dismissing the sheet
            if let image = capturedImage {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    saveAndShareImage(image: image, playerName: randomString(length: 15))
                }
                   
            }
        })
        {
            KartaBigView(karta: karta, showBig: $showBig, orderChanges: $orderChanges, onLongPress: { image in
                capturedImage = image
                showBig = false
            })
            .presentationDetents([.height(idealSheetHeight())])
        }
    }
    func idealSheetHeight() -> CGFloat {
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        let aspectRatio: CGFloat = 0.55 // Change this based on your iPad aspect ratio

        return min(screenHeight * 0.8, screenWidth / aspectRatio) // Limit max height
    }
}
struct KartaBigView: View {
    let karta: Dictionary<String, Any>
    @Binding var showBig: Bool
    @Binding var orderChanges : Int
    let onLongPress: (UIImage) -> Void
    @State var isSharing: Bool = false
    @State private var noiseImage: UIImage = generateFilmGrain(size: CGSize(width: 1024, height: 2048))!

    let rows = Array(repeating: GridItem(.fixed(32), spacing: 0), count: 6)
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if((karta["opis"] as? String ?? "") != "Placeholder")
                {
                    HStack
                    {
                        VStack
                        {
                            VStack
                            {
                                Text("\(karta["koszt"] as? Int ?? 0)")
                                    .font(.title)
                                    .padding()
                            }
                            .background(
                                Image("TextureCardBackSM")
                                    .resizable()
                                    .scaledToFill()
                                    .blur(radius: 5)
                                    .brightness(0.4)
                            )
                            .clipped()
                            .border(.yellow, width: 2.0)
                            .cornerRadius(15)
                            Spacer()
                        }
                        .padding(0)
    
                        Spacer()
                        ZStack(alignment: .topTrailing)
                        {
                            ImageGeneratorView(label: karta["opis"] as? String ?? "")
//                                .frame(width: 260, height: 180)
                            AnimatedShapesView(shapes: (karta["opis"] as? String ?? "").getShapes(), noiseImage: $noiseImage, animate: true)
                                .padding(15)
                            VStack(alignment: .trailing, spacing: 0)
                            {
                                LazyHGrid(rows: rows, spacing: 0) {
                                    ForEach(karta["postacie"] as? [String] ?? [], id: \.self) { postać in
                                        if let _ = UIImage(named: postać + " Mini") {
                                            Image(postać + " Mini")
                                            //                                        .resizable()
                                            //                                        .scaledToFit()
                                        }
                                    }
                                }
                                .frame(height: 192)
                                .padding(0)
                                .padding(.top, 9)
                                .cornerRadius(5)
                                Spacer()
                            }
                        }
                    }
                    .padding(0)
                    .padding(.top, 17)
                    .overlay(FilmGrain())
                    Spacer()
                    VStack
                    {
                        TextWithSymbols(text: "\(karta["opis"] as? String ?? karta["akcjaRzucaneZaklęcie"] as? String ?? "----------")", font: .custom("Papyrus", size: 40), foregroundColor: .black, orderChanges: $orderChanges)
                            .lineLimit(6)
                            .padding(25)
                    }
//                    .frame(maxWidth: .infinity)
                        .background(
                                Image("TextureCardBackSM")
                                    .resizable()
                                    .scaledToFill()
                                    .blur(radius: 10)
                                    .brightness(0.4)
                        )
                        .clipped()
                        .cornerRadius(15)
                    Spacer()
                }
                else
                {
                    VStack
                    {
                        Spacer()
                    }
                }
            }
            .padding(15)
            .background(
                Image("TextureCardBackSM")
                    .resizable()
                    .scaledToFill()
                    .blur(radius: ((karta["opis"] as? String ?? "") != "Placeholder") ? 5 : 0)
                    .brightness(((karta["opis"] as? String ?? "") != "Placeholder") ? -0.2 : 0)
            )
            .foregroundColor(.black)
            .shadow(radius: 5)
            .onTapGesture(count: 2) {
                showBig.toggle()
            }
            .overlay(content: {Image(uiImage: noiseImage)})
            .onLongPressGesture {
                
                isSharing = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    captureView(size: geometry.size)
                }
            }
        }
        .frame(maxWidth: .infinity ,minHeight: UIScreen.main.bounds.size.height*0.85)
        .clipped()
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
    @Binding var lastPlayed: String
    @Binding var activePlayer : Int
    @Binding var gameRound : Int
    @Binding var landscape : Bool
    @Binding var selectedCard: String?
    let containerKey: String // Key in `gra` (e.g., "Zaklęcie", "Lingering")
    var isDragEnabled: Bool = true
    var isDropEnabled: Bool = true
    var isReorderable: Bool = false
    var isLingering: Bool = false
    var size:CGFloat = 3
    var sizeFullAction : (String, Array<Dictionary<String, Any>>) -> Void = { selectedContainerKey, kards in
        
    }
    @State public var kartyCount = 3
    @State public var orderChanges = 0
    @State private var isReordering = false
    @State private var draggedIndex: Int? = nil

    
    var body: some View {
        VStack {
            Text("Zimeniono kolejność \(orderChanges) razy")
                .font(.custom("Cinzel", size: 1))
            ScrollView(.horizontal, showsIndicators: false) {
                if let container = gra[containerKey] as? Dictionary<String, Any>
                {
                    let kartyLoad = container["karty"] as? Array<Dictionary<String, Any>> ?? emptyKarty
                    let karty = (kartyLoad.count < 1) ? emptyKarty : kartyLoad
                    let columns = Array(repeating: GridItem(.flexible()), count: Int(max(1, min(Int(size), karty.count * 2 + 1))))


                    VStack {
                        LazyVGrid(columns: columns, spacing: 5) {
                            if isReorderable {
                                DropBoxView(isReordering: $isReordering, index: 0, containerKey: containerKey, handleDrop: handleReorderDrop)
                            }

                            ForEach(karty.indices, id: \.self) { index in
                                VStack {
                                    
                                    if(isReorderable)
                                    {
                                        KartaView(karta: karty[index], showPostacie: false, selectedCard: $selectedCard, orderChanges: $orderChanges)
                                            .onDrag {
                                                draggedIndex = index
                                                isReordering = true
                                                return NSItemProvider(object: isDragEnabled ? "reorder|\(containerKey)|\(index)" as NSString : "" as NSString)
                                            }
                                    }
                                    else {
                                        KartaView(karta: karty[index], showPostacie: false, selectedCard: $selectedCard, orderChanges: $orderChanges)
                                            .onDrag {
                                                NSItemProvider(object: isDragEnabled ? "\(containerKey)|\(index)" as NSString : "" as NSString)
                                            }
                                    }
                                    
                                }

                                if isReorderable {
                                    DropBoxView(isReordering: $isReordering, index: index + 1, containerKey: containerKey, handleDrop: handleReorderDrop)
                                }
                            }

                        }
                    }
                    .frame(minWidth: size*100*(isReorderable ? 0.6 : 1.0))
                    .onAppear()
                    {
                        kartyCount = karty.count
                    }
                    .onChange(of: karty.count)
                    {
                        kartyCount = karty.count
                    }
                }

            }
            .frame(minWidth: min(size*100+20, (UIScreen.main.bounds.size.width - 20) * (isReorderable ? 1.35 : 1.0) * (UIDevice.current.userInterfaceIdiom == .phone ? 1.40 : 1.0)), alignment: .center)
            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 2))
            .onDrop(of: [UTType.text], isTargeted: nil) {  providers, location in
                orderChanges += 1
                isReordering = false
                guard isDropEnabled else { return false }
                print("drop")
                return handleDrop(providers: providers, location: location)
            }
        }
        .scaleEffect(UIDevice.current.userInterfaceIdiom == .phone ? 0.75 : 1.0)
        .scaleEffect(isReorderable ? 0.75 : 1.0)
    }
    private func handleReorderDrop(targetIndex: Int) {
        guard let draggedIndex = draggedIndex else {
            print("Error: Missing draggedIndex or draggedSourceKey")
            return
        }
        
        // Ensure the source container exists
        guard let container = gra[containerKey] as? Dictionary<String, Any> else {
            print("Error: Missing source or target container")
            return
        }
        
        // Load the source and target cards
        var sourceKarty = container["karty"] as? [Dictionary<String, Any>] ?? []

        // Move the item from the source to the target
        
        var adjustIndex = (draggedIndex < targetIndex) ? 1 : 0
        let movedItem = sourceKarty.remove(at: draggedIndex)
        if(targetIndex - adjustIndex < sourceKarty.count)
        {
            sourceKarty.insert(movedItem, at: targetIndex - adjustIndex)
        }
        else
        {
            sourceKarty.append(movedItem)
        }

        // Update the source and target containers
        var updatedTargetContainer = container
        updatedTargetContainer["karty"] = sourceKarty

        gra[containerKey] = updatedTargetContainer

        // Reset dragged state
        self.draggedIndex = nil

        print("Reorder completed:  at index \(targetIndex)")
    }



    
    private func handleDrop(providers: [NSItemProvider], location: CGPoint) -> Bool {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { (data, error) in
                print("dropA")
                guard error == nil, let data = data as? Data, let identifier = String(data: data, encoding: .utf8) else {
                    
                    print("error \(error.debugDescription)")
                    return
                }

                print("dropB")
                DispatchQueue.main.async {
                    let parts = identifier.split(separator: "|")
                    print("drop \(parts.description)")
                    if parts.count == 2 {
                        DispatchQueue.main.async
                        {
                            guard parts.count == 2,
                                  let sourceKey = parts.first,
                                  let sourceIndex = Int(parts.last ?? "") else { return }

                            if(!moveCard(&gra, from: String(sourceKey), at: sourceIndex, to: containerKey, isLingering: isLingering))
                            {
                                return
                            }
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
            }
        }
        return true
    }



//    private func moveCard(from sourceKey: String, at sourceIndex: Int, to destinationKey: String) -> Bool {
//        return moveCard(gra: &gra, from: sourceKey, at: sourceIndex, to: destinationKey, isLingering: isLingering)
//        var sourceCards = Array<Dictionary<String, Any>>()
//        var sourceIndexCorrected = sourceIndex
//        var talia = getKarty(&gra, for: "Talia\(sourceKey)")
//        if(gra[sourceKey] == nil)
//        {
//            sourceCards = talia
//            sourceIndexCorrected = Int.random(in: 0..<talia.count)
//        }
//        else
//        {
//            sourceCards = (gra[sourceKey] as! Dictionary<String, Any>)["karty"] as? Array<Dictionary<String, Any>> ?? []
//        }
//        guard sourceIndexCorrected >= 0, sourceIndexCorrected < sourceCards.count else { return false }
//        let cardTMP = sourceCards[sourceIndexCorrected]
//        print("lingering: \(cardTMP["lingering"]) \(isLingering)")
//        
//        if let lingeringString = cardTMP["lingering"] as? String
//        {
//            print(lingeringString)
//            if((!(lingeringString.count > 3) && isLingering) || ((lingeringString.count > 3) && !isLingering))
//            {
//                print("false A")
//                return false
//            }
//            print("true B")
//        }
//        else
//        {
//            if let lingeringString = cardTMP["lingering"] as? Int, !isLingering
//            {
//                print(cardTMP["lingering"])
//                print("false B")
//                return false
//            }
//        }
//        print("true A")
//        let card = sourceCards.remove(at: sourceIndexCorrected)
//        if var playerData = gra[sourceKey] as? [String: Any] {
//            playerData["karty"] = sourceCards
//            gra[sourceKey] = playerData
//        }
//
//        var destinationCards = (gra[destinationKey] as! Dictionary<String, Any>)["karty"] as? Array<Dictionary<String, Any>> ?? []
//        destinationCards.append(card)
//        if var playerData = gra[destinationKey] as? [String: Any] {
//            playerData["karty"] = destinationCards
//            gra[destinationKey] = playerData
//        }
//        return true
//    }
}
struct DropBoxView: View {
    @Binding var isReordering:Bool
    let index: Int
    let containerKey: String
    let handleDrop: (Int) -> Void

    var body: some View {
        Rectangle()
            .frame(width: 60, height: 135)
            .foregroundColor(Color.gray.opacity(0.5))
            .cornerRadius(5)
            .onDrop(of: [UTType.text], isTargeted: nil) { providers in
                
                isReordering = false
                providers.first?.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { (data, error) in
                    guard error == nil, let data = data as? Data, let identifier = String(data: data, encoding: .utf8) else {
                        return
                    }
                    DispatchQueue.main.async {
                        let parts = identifier.split(separator: "|")
                        if parts.count == 3, parts[0] == "reorder" {
                            handleDrop(index)
                        }
                    }
                }
                return true
            }
    }
}
func triggerDragAction(draggedData: String, action: ()->Void) {
    guard !draggedData.isEmpty else { return }
    print("Drag action triggered with data: \(draggedData)")
    action()
    // Perform any immediate actions for drag start here
}
