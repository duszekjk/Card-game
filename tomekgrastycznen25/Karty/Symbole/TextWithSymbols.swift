import SwiftUI

struct TextWithSymbols: View {
    var text: String
    var font: Font
    var foregroundColor: Color = .primary

    @State var components : [AnyView] = []

    var body: some View {

        let size = fontSize(for: font)
        WrappingGridView(items: components, size: size)
            .padding(0)
            .onAppear()
            {
                components = text.splitToComponents(size: size, font: font)
            }
    }
}


struct TextComponent: Identifiable {
    let id = UUID() // Ensures unique IDs
    var text: String
    var shape: AnyView? // Use AnyView to store generic Shapes
    
    init(text: String) {
        self.text = text
        self.shape = nil
    }

    init(shape: some Shape) {
        self.text = ""
        self.shape = AnyView(shape)
    }
}
extension String {
    func getShapes() -> [AnyView] {
        var components: [AnyView] = []
        for char in self {
            let strChar = String(char)
            if let shape = emojiSymbols[strChar] {
                components.append(AnyView(shape))
            }
        }
        return components
    }
}
extension String {
    func splitToComponents(size: CGFloat, font: Font) -> [AnyView] {
        var components: [AnyView] = []
        var currentText = ""

        for char in self {
            let strChar = String(char)
            if let shape = emojiSymbols[strChar] {
                if !currentText.isEmpty {
                    components.append(AnyView(Text(currentText).font(font))) // Add plain text before emoji
                    currentText = ""
                }
                components.append(AnyView(shape.frame(width: size, height: size)))
            } else {
                if(strChar == " ")
                {
                    if !currentText.isEmpty {
                        components.append(AnyView(Text(currentText).font(font)))
                        currentText = ""
                    }
                }
                else
                {
                    if(strChar == "\n")
                    {
                        components.append(AnyView(Text(currentText).font(font)))
                        currentText = ""
                        components.append(AnyView(NewLineView()))
                    }
                    else
                    {
                        currentText.append(strChar)
                    }
                }
            }
        }

        if !currentText.isEmpty {
            components.append(AnyView(Text(currentText).font(font)))
        }
//        for family in UIFont.familyNames {
//            print(family)
//        }

        return components
    }
}

func fontSize(for font: Font) -> CGFloat {
    #if os(iOS)
    let textStyle: UIFont.TextStyle? = {
        switch font {
        case .largeTitle: return .largeTitle
        case .title: return .title1
        case .title2: return .title2
        case .title3: return .title3
        case .headline: return .headline
        case .subheadline: return .subheadline
        case .body: return .body
        case .callout: return .callout
        case .footnote: return .footnote
        case .caption: return .caption1
        case .caption2: return .caption2
        default: return nil
        }
    }()
    
    if let textStyle = textStyle {
        return UIFont.preferredFont(forTextStyle: textStyle).pointSize
    }
    
    #elseif os(macOS)
    let nsFontSize: CGFloat? = {
        switch font {
        case .largeTitle: return NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .regular) + 10).pointSize
        case .title: return NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .large)).pointSize
//        case .title2: return NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .large))
//        case .title3: return NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .large))
//        case .headline: return NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .headline))
//        case .subheadline: return NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .subheadline))
//        case .body: return NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .body))
//        case .callout: return NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .callout))
//        case .footnote: return NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .footnote))
        case .caption: return 20.0
//        case .caption2: return NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .caption2))
        default: return nil
        }
    }()
    
    if let nsFont = nsFontSize {
        return nsFont
    }
    #endif
    
    return 40 // Default fallback size
}

struct NewLineView: View {
    
    var body: some View {
        Text("\n")
    }
    
    
}
