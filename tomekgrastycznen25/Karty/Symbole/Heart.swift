//
//  MyIcon.swift
//  tomekgrastycznen25
//
//  Created by Jacek Kałużny on 05/02/2025.
//
import SwiftUI

struct Heart: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.75097*width, y: 0.06704*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: 0.00001*height), control1: CGPoint(x: 0.67436*width, y: 0.02236*height), control2: CGPoint(x: 0.59071*width, y: 0.00001*height))
        path.addCurve(to: CGPoint(x: 0.24903*width, y: 0.06704*height), control1: CGPoint(x: 0.40928*width, y: 0.00001*height), control2: CGPoint(x: 0.32563*width, y: 0.02236*height))
        path.addCurve(to: CGPoint(x: 0.06705*width, y: 0.24902*height), control1: CGPoint(x: 0.17242*width, y: 0.11177*height), control2: CGPoint(x: 0.11176*width, y: 0.17242*height))
        path.addCurve(to: CGPoint(x: 0, y: 0.49999*height), control1: CGPoint(x: 0.02234*width, y: 0.32562*height), control2: CGPoint(x: 0, y: 0.40929*height))
        path.addCurve(to: CGPoint(x: 0.06705*width, y: 0.75097*height), control1: CGPoint(x: 0, y: 0.59072*height), control2: CGPoint(x: 0.02235*width, y: 0.67437*height))
        path.addCurve(to: CGPoint(x: 0.24903*width, y: 0.93293*height), control1: CGPoint(x: 0.11176*width, y: 0.82759*height), control2: CGPoint(x: 0.17241*width, y: 0.88825*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: 0.99999*height), control1: CGPoint(x: 0.32562*width, y: 0.97764*height), control2: CGPoint(x: 0.40928*width, y: 0.99999*height))
        path.addCurve(to: CGPoint(x: 0.75097*width, y: 0.93293*height), control1: CGPoint(x: 0.59071*width, y: 0.99999*height), control2: CGPoint(x: 0.67436*width, y: 0.97764*height))
        path.addCurve(to: CGPoint(x: 0.93294*width, y: 0.75097*height), control1: CGPoint(x: 0.82757*width, y: 0.88825*height), control2: CGPoint(x: 0.88823*width, y: 0.82759*height))
        path.addCurve(to: CGPoint(x: width, y: 0.49999*height), control1: CGPoint(x: 0.97765*width, y: 0.67437*height), control2: CGPoint(x: width, y: 0.59072*height))
        path.addCurve(to: CGPoint(x: 0.93294*width, y: 0.24902*height), control1: CGPoint(x: width, y: 0.4093*height), control2: CGPoint(x: 0.97764*width, y: 0.32563*height))
        path.addCurve(to: CGPoint(x: 0.75097*width, y: 0.06704*height), control1: CGPoint(x: 0.88823*width, y: 0.17243*height), control2: CGPoint(x: 0.82757*width, y: 0.11177*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.74707*width, y: 0.41797*height))
        path.addCurve(to: CGPoint(x: 0.73112*width, y: 0.45638*height), control1: CGPoint(x: 0.74338*width, y: 0.43405*height), control2: CGPoint(x: 0.73805*width, y: 0.44683*height))
        path.addLine(to: CGPoint(x: 0.50325*width, y: 0.76432*height))
        path.addLine(to: CGPoint(x: 0.27604*width, y: 0.45637*height))
        path.addCurve(to: CGPoint(x: 0.26009*width, y: 0.41796*height), control1: CGPoint(x: 0.26908*width, y: 0.44683*height), control2: CGPoint(x: 0.26377*width, y: 0.43404*height))
        path.addCurve(to: CGPoint(x: 0.26399*width, y: 0.36263*height), control1: CGPoint(x: 0.2564*width, y: 0.40192*height), control2: CGPoint(x: 0.2577*width, y: 0.38345*height))
        path.addCurve(to: CGPoint(x: 0.30338*width, y: 0.31118*height), control1: CGPoint(x: 0.27028*width, y: 0.34179*height), control2: CGPoint(x: 0.28342*width, y: 0.32466*height))
        path.addCurve(to: CGPoint(x: 0.35807*width, y: 0.29459*height), control1: CGPoint(x: 0.32117*width, y: 0.29991*height), control2: CGPoint(x: 0.33941*width, y: 0.29439*height))
        path.addCurve(to: CGPoint(x: 0.40592*width, y: 0.30599*height), control1: CGPoint(x: 0.37672*width, y: 0.2948*height), control2: CGPoint(x: 0.39268*width, y: 0.29861*height))
        path.addCurve(to: CGPoint(x: 0.4414*width, y: 0.33528*height), control1: CGPoint(x: 0.41916*width, y: 0.31336*height), control2: CGPoint(x: 0.43099*width, y: 0.32313*height))
        path.addCurve(to: CGPoint(x: 0.50325*width, y: 0.36132*height), control1: CGPoint(x: 0.45703*width, y: 0.35265*height), control2: CGPoint(x: 0.47764*width, y: 0.36132*height))
        path.addCurve(to: CGPoint(x: 0.56575*width, y: 0.33528*height), control1: CGPoint(x: 0.52929*width, y: 0.36132*height), control2: CGPoint(x: 0.55013*width, y: 0.35265*height))
        path.addCurve(to: CGPoint(x: 0.60123*width, y: 0.30599*height), control1: CGPoint(x: 0.57617*width, y: 0.32312*height), control2: CGPoint(x: 0.58798*width, y: 0.31336*height))
        path.addCurve(to: CGPoint(x: 0.64909*width, y: 0.29459*height), control1: CGPoint(x: 0.61447*width, y: 0.29862*height), control2: CGPoint(x: 0.63042*width, y: 0.2948*height))
        path.addCurve(to: CGPoint(x: 0.70313*width, y: 0.31118*height), control1: CGPoint(x: 0.66775*width, y: 0.29439*height), control2: CGPoint(x: 0.68576*width, y: 0.29991*height))
        path.addCurve(to: CGPoint(x: 0.74317*width, y: 0.36263*height), control1: CGPoint(x: 0.72352*width, y: 0.32466*height), control2: CGPoint(x: 0.73687*width, y: 0.34179*height))
        path.addCurve(to: CGPoint(x: 0.74707*width, y: 0.41797*height), control1: CGPoint(x: 0.74946*width, y: 0.38346*height), control2: CGPoint(x: 0.75076*width, y: 0.40193*height))
        path.closeSubpath()
        return path
    }
}
