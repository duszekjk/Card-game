//
//  MyIcon.swift
//  tomekgrastycznen25
//
//  Created by Jacek Kałużny on 05/02/2025.
//

import SwiftUI
struct ShieldOut: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.125*width, y: 0.125*height))
        path.addLine(to: CGPoint(x: 0.875*width, y: 0.875*height))
        path.move(to: CGPoint(x: 0.41595*width, y: 0.18268*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: 0.125*height), control1: CGPoint(x: 0.44587*width, y: 0.17034*height), control2: CGPoint(x: 0.47293*width, y: 0.15207*height))
        path.addCurve(to: CGPoint(x: 0.76662*width, y: 0.20809*height), control1: CGPoint(x: 0.5714*width, y: 0.1964*height), control2: CGPoint(x: 0.6428*width, y: 0.20662*height))
        path.addCurve(to: CGPoint(x: 0.81089*width, y: 0.21309*height), control1: CGPoint(x: 0.79026*width, y: 0.20837*height), control2: CGPoint(x: 0.80208*width, y: 0.20851*height))
        path.addCurve(to: CGPoint(x: 0.82886*width, y: 0.23127*height), control1: CGPoint(x: 0.8187*width, y: 0.21715*height), control2: CGPoint(x: 0.82489*width, y: 0.22342*height))
        path.addCurve(to: CGPoint(x: 0.83333*width, y: 0.275*height), control1: CGPoint(x: 0.83333*width, y: 0.24013*height), control2: CGPoint(x: 0.83333*width, y: 0.25175*height))
        path.addLine(to: CGPoint(x: 0.83333*width, y: 0.5*height))
        path.addCurve(to: CGPoint(x: 0.82002*width, y: 0.58648*height), control1: CGPoint(x: 0.83333*width, y: 0.53008*height), control2: CGPoint(x: 0.82851*width, y: 0.55896*height))
        path.move(to: CGPoint(x: 0.73425*width, y: 0.7344*height))
        path.addCurve(to: CGPoint(x: 0.52908*width, y: 0.90062*height), control1: CGPoint(x: 0.66397*width, y: 0.81612*height), control2: CGPoint(x: 0.5744*width, y: 0.87418*height))
        path.addCurve(to: CGPoint(x: 0.50874*width, y: 0.91009*height), control1: CGPoint(x: 0.51986*width, y: 0.906*height), control2: CGPoint(x: 0.51525*width, y: 0.90869*height))
        path.addCurve(to: CGPoint(x: 0.49126*width, y: 0.91009*height), control1: CGPoint(x: 0.50368*width, y: 0.91117*height), control2: CGPoint(x: 0.49632*width, y: 0.91117*height))
        path.addCurve(to: CGPoint(x: 0.47092*width, y: 0.90062*height), control1: CGPoint(x: 0.48475*width, y: 0.90869*height), control2: CGPoint(x: 0.48014*width, y: 0.906*height))
        path.addCurve(to: CGPoint(x: 0.16667*width, y: 0.5*height), control1: CGPoint(x: 0.38975*width, y: 0.85327*height), control2: CGPoint(x: 0.16667*width, y: 0.70452*height))
        path.addLine(to: CGPoint(x: 0.16667*width, y: 0.275*height))
        path.addCurve(to: CGPoint(x: 0.17114*width, y: 0.23127*height), control1: CGPoint(x: 0.16667*width, y: 0.25175*height), control2: CGPoint(x: 0.16667*width, y: 0.24013*height))
        path.addCurve(to: CGPoint(x: 0.18911*width, y: 0.21309*height), control1: CGPoint(x: 0.17511*width, y: 0.22342*height), control2: CGPoint(x: 0.1813*width, y: 0.21715*height))
        path.addCurve(to: CGPoint(x: 0.20833*width, y: 0.20876*height), control1: CGPoint(x: 0.19405*width, y: 0.21052*height), control2: CGPoint(x: 0.19994*width, y: 0.20935*height))
        return path
    }
}
