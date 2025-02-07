import SwiftUI

struct WrappingGridView: View {
    public let items: [AnyView]
    public var size: CGFloat
    
    @State private var containerWidth: CGFloat = 0  // Track available width
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            VStack(alignment: .leading, spacing: 0) {
                WrappingHStack(items: items, containerWidth: width, sizeDef: size)
                    .padding(0)
                    .animation(.easeInOut(duration: 0.3), value: width)  // Smooth animations
            }
            .onAppear { containerWidth = width }
            .onChange(of: width) { newValue in
                containerWidth = newValue  // Update width on resize
            }
            .padding(0)
        }
    }
}

struct WrappingHStack: View {
    let items: [AnyView]
    let containerWidth: CGFloat
    var sizeDef: CGFloat
    
    var body: some View {
        var currentWidth: CGFloat = 0
        var rows: [[AnyView]] = [[]] // Store items row by row
        
        var spaceSize:CGFloat = (sizeDef/5).rounded()
        
        for item in items {
            let itemSize = viewSize(for: item, sizeDef: sizeDef)  // Estimate item size
            if let newLineView: NewLineView = item.asView() {
                rows.append([])
                currentWidth = 6
            }
            else
            {
                if currentWidth + itemSize.width > containerWidth {
                    // Start a new row
                    rows.append([item])
                    currentWidth = itemSize.width * 1.0 + spaceSize + 6
                } else {
                    // Add to the current row
                    rows[rows.count - 1].append(item)
                    currentWidth += itemSize.width * 1.0 + spaceSize
                }
            }
        }
        
        return VStack(alignment: .leading, spacing: 1) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: spaceSize) {
                    ForEach(Array(row.enumerated()), id: \.offset) { _, item in
                        item
                    }
                }
            }
        }
        .transition(.opacity.combined(with: .scale))  // Fade & scale animation
    }
    
    private func viewSize(for view: AnyView, sizeDef: CGFloat) -> CGSize {
        #if os(iOS)
        let hosting = UIHostingController(rootView: view)
        let size = hosting.view.intrinsicContentSize
        #elseif os(macOS)
        let hosting = NSHostingView(rootView: view)
        let size = hosting.fittingSize
        #endif

        return (size == .zero || size.height > 70) ? CGSize(width: sizeDef, height: sizeDef) : size
    }

}
import SwiftUI

extension AnyView {
    func asView<T>() -> T? {
        return Mirror(reflecting: self).descendant("storage", "view") as? T
    }
}
