import SwiftUI

struct AnimatedShapesView: View {
    let shapes: [AnyView]
    let viewSize: CGSize = CGSize(width: min(400, UIScreen.main.bounds.size.width-160), height: min(350, (UIScreen.main.bounds.size.width-160) * 0.875))
    let stepsBetweenFrames = 10
    @Binding var noiseImage: UIImage
    var animate: Bool
    @State private var shapeParameters: [[ShapeParams]] = []
    @State private var animationStep = 0
    @State private var isAnimating = false
    @State private var size: CGFloat = 350

    let fantasyGradients: [LinearGradient] = [
        LinearGradient(colors: [Color.red, Color.orange], startPoint: .top, endPoint: .bottom),
        LinearGradient(colors: [Color.blue, Color.black], startPoint: .leading, endPoint: .trailing),
        LinearGradient(colors: [Color.black, Color.yellow], startPoint: .top, endPoint: .bottomTrailing),
        LinearGradient(colors: [Color.gray, Color.white], startPoint: .bottomLeading, endPoint: .topTrailing),
        LinearGradient(colors: [Color.purple, Color.black], startPoint: .topLeading, endPoint: .bottomTrailing)
    ]

    struct ShapeParams {
        var x: CGFloat
        var y: CGFloat
        var rotation: Double
        var gradient: LinearGradient
    }

    var body: some View {
        ZStack {
            ForEach(0..<shapes.count, id: \.self) { index in
                if shapeParameters.indices.contains(index) {
                    let params = shapeParameters[index][animationStep]
                    shapes[index]
                        .shadow(color: .white, radius: 4)
                        .frame(width: size, height: size)
                        .overlay(FilmGrain())
                        .foregroundStyle(params.gradient)
                        .rotation3DEffect(.degrees(params.rotation), axis: (x: 1, y: 1, z: 0))
                        .position(x: params.x, y: params.y)
                        .animation(.easeInOut(duration: 0.1), value: animationStep)
                        .shadow(color: .white, radius: 5)
                }
            }
        }
        .frame(width: viewSize.width, height: viewSize.height)
        .onAppear {
            if(animate)
            {
                generateSmoothAnimationFrames()
                startContinuousAnimation()
            }
            else
            {
                shapeParameters = generateRandomParameters()
                animationStep += 1
            }
        }
    }

    func generateSmoothAnimationFrames() {
        let rawKeyframes = generateRandomParameters()
        shapeParameters = rawKeyframes.map { interpolateSmoothPath($0) }
    }

    func generateRandomParameters() -> [[ShapeParams]] {
        size = (viewSize.width * 0.54) / sqrt(CGFloat(shapes.count))
        return shapes.map { _ in
            (0..<7).map { step in
                let rotationRange = (step == 6 || step < 2) ? (-10.0...10.0) : (-110.0...110.0) // Limit rotation in final step
                let finalPositions = (step == 6 || step < 2) ? distributePositions() : [CGPoint(x: CGFloat.random(in: size / 2 ... viewSize.width - size / 2), y: CGFloat.random(in: size / 2 ... viewSize.height - size / 2))]

                return ShapeParams(
                    x: finalPositions.randomElement()?.x ?? viewSize.width / 2,
                    y: finalPositions.randomElement()?.y ?? viewSize.height / 2,
                    rotation: Double.random(in: rotationRange),
                    gradient: fantasyGradients.randomElement()! // Select a fantasy gradient
                )
            }
        }
    }

    func distributePositions() -> [CGPoint] {
        var positions: [CGPoint] = []
        let minSpacing = size * 0.65

        for _ in 0..<shapes.count {
            var newPosition: CGPoint
            var attempts = 0

            repeat {
                newPosition = CGPoint(
                    x: CGFloat.random(in: size / 2 ... viewSize.width - size / 2),
                    y: CGFloat.random(in: size / 2 ... viewSize.height - size / 2)
                )
                attempts += 1
            } while positions.contains(where: { distance($0, newPosition) < minSpacing }) && attempts < 100

            positions.append(newPosition)
        }
        return positions
    }

    func distance(_ p1: CGPoint, _ p2: CGPoint) -> CGFloat {
        return sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2))
    }

    /// Interpolates between each animation step using Bezier curves for smooth movement.
    func interpolateSmoothPath(_ keyframes: [ShapeParams]) -> [ShapeParams] {
        var smoothPath: [ShapeParams] = []

        for i in 0..<keyframes.count - 1 {
            let start = keyframes[i]
            let end = keyframes[i + 1]

            for step in 0...stepsBetweenFrames {
                let t = CGFloat(step) / CGFloat(stepsBetweenFrames)
                let bezierPoint = cubicBezier(start: start, end: end, t: t)

                smoothPath.append(bezierPoint)
            }
        }
        return smoothPath
    }

    /// Calculates a Bezier curve interpolation between two points.
    func cubicBezier(start: ShapeParams, end: ShapeParams, t: CGFloat) -> ShapeParams {
        let controlPointX = (start.x + end.x) / 2 + CGFloat.random(in: -20...20)
        let controlPointY = (start.y + end.y) / 2 + CGFloat.random(in: -20...20)

        let x = (1 - t) * (1 - t) * start.x + 2 * (1 - t) * t * controlPointX + t * t * end.x
        let y = (1 - t) * (1 - t) * start.y + 2 * (1 - t) * t * controlPointY + t * t * end.y

        let rotation = start.rotation * (1 - t) + end.rotation * t

        return ShapeParams(x: x, y: y, rotation: rotation, gradient: start.gradient)
    }

    func startContinuousAnimation() {
        isAnimating = true
        DispatchQueue.global().async {
            while isAnimating {
                DispatchQueue.main.async {
                    if animationStep < shapeParameters.first!.count - 1 {
                        animationStep += 1
                    } else {
                        isAnimating = false
                    }
                }
                noiseImage = generateFilmGrain(size: CGSize(width: noiseImage.size.width, height: noiseImage.size.height))!
                usleep(21000) // Fast, smooth transitions
            }
        }
    }
}

struct FilmGrain: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<80, id: \.self) { _ in
                    Circle()
                        .fill(Color.white.opacity(Double.random(in: 0.08...0.19)))
                        .frame(width: CGFloat.random(in: 1...4), height: CGFloat.random(in: 1...4))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                }
            }
        }
    }
}
