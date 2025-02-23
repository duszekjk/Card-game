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
        path.move(to: CGPoint(x: 0.4967*width, y: 0.92198*height))
        path.addCurve(to: CGPoint(x: 0.40203*width, y: 0.85468*height), control1: CGPoint(x: 0.46553*width, y: 0.89937*height), control2: CGPoint(x: 0.43229*width, y: 0.87975*height))
        path.addCurve(to: CGPoint(x: 0.30353*width, y: 0.78042*height), control1: CGPoint(x: 0.36911*width, y: 0.82946*height), control2: CGPoint(x: 0.33477*width, y: 0.80761*height))
        path.addCurve(to: CGPoint(x: 0.20469*width, y: 0.69561*height), control1: CGPoint(x: 0.27057*width, y: 0.75295*height), control2: CGPoint(x: 0.23314*width, y: 0.72721*height))
        path.addCurve(to: CGPoint(x: 0.12898*width, y: 0.61269*height), control1: CGPoint(x: 0.1744*width, y: 0.67398*height), control2: CGPoint(x: 0.15286*width, y: 0.64108*height))
        path.addCurve(to: CGPoint(x: 0.08498*width, y: 0.52528*height), control1: CGPoint(x: 0.11749*width, y: 0.58331*height), control2: CGPoint(x: 0.09317*width, y: 0.55757*height))
        path.addCurve(to: CGPoint(x: 0.05846*width, y: 0.40825*height), control1: CGPoint(x: 0.07106*width, y: 0.48737*height), control2: CGPoint(x: 0.06283*width, y: 0.44815*height))
        path.addCurve(to: CGPoint(x: 0.07659*width, y: 0.2844*height), control1: CGPoint(x: 0.05132*width, y: 0.366*height), control2: CGPoint(x: 0.06572*width, y: 0.32421*height))
        path.addCurve(to: CGPoint(x: 0.13071*width, y: 0.19438*height), control1: CGPoint(x: 0.09313*width, y: 0.25453*height), control2: CGPoint(x: 0.10321*width, y: 0.21886*height))
        path.addCurve(to: CGPoint(x: 0.22217*width, y: 0.13218*height), control1: CGPoint(x: 0.15955*width, y: 0.17082*height), control2: CGPoint(x: 0.18613*width, y: 0.14404*height))
        path.addCurve(to: CGPoint(x: 0.35768*width, y: 0.13182*height), control1: CGPoint(x: 0.26479*width, y: 0.11114*height), control2: CGPoint(x: 0.31417*width, y: 0.11904*height))
        path.addCurve(to: CGPoint(x: 0.4836*width, y: 0.21925*height), control1: CGPoint(x: 0.41006*width, y: 0.14121*height), control2: CGPoint(x: 0.45051*width, y: 0.17974*height))
        path.addCurve(to: CGPoint(x: 0.53168*width, y: 0.21971*height), control1: CGPoint(x: 0.50135*width, y: 0.24639*height), control2: CGPoint(x: 0.51865*width, y: 0.25464*height))
        path.addCurve(to: CGPoint(x: 0.63101*width, y: 0.15544*height), control1: CGPoint(x: 0.56076*width, y: 0.19318*height), control2: CGPoint(x: 0.59475*width, y: 0.17237*height))
        path.addCurve(to: CGPoint(x: 0.77629*width, y: 0.14996*height), control1: CGPoint(x: 0.67571*width, y: 0.13289*height), control2: CGPoint(x: 0.72958*width, y: 0.13392*height))
        path.addCurve(to: CGPoint(x: 0.87165*width, y: 0.20857*height), control1: CGPoint(x: 0.80745*width, y: 0.17024*height), control2: CGPoint(x: 0.84909*width, y: 0.17716*height))
        path.addCurve(to: CGPoint(x: 0.9346*width, y: 0.30787*height), control1: CGPoint(x: 0.90113*width, y: 0.23415*height), control2: CGPoint(x: 0.92226*width, y: 0.27052*height))
        path.addCurve(to: CGPoint(x: 0.95111*width, y: 0.48092*height), control1: CGPoint(x: 0.95559*width, y: 0.36228*height), control2: CGPoint(x: 0.96117*width, y: 0.42355*height))
        path.addCurve(to: CGPoint(x: 0.89004*width, y: 0.60741*height), control1: CGPoint(x: 0.93914*width, y: 0.52676*height), control2: CGPoint(x: 0.92036*width, y: 0.57079*height))
        path.addCurve(to: CGPoint(x: 0.80305*width, y: 0.69047*height), control1: CGPoint(x: 0.86468*width, y: 0.63846*height), control2: CGPoint(x: 0.83262*width, y: 0.6637*height))
        path.addCurve(to: CGPoint(x: 0.70472*width, y: 0.77014*height), control1: CGPoint(x: 0.77009*width, y: 0.717*height), control2: CGPoint(x: 0.73913*width, y: 0.74565*height))
        path.addCurve(to: CGPoint(x: 0.61491*width, y: 0.84579*height), control1: CGPoint(x: 0.67699*width, y: 0.79817*height), control2: CGPoint(x: 0.64156*width, y: 0.81665*height))
        path.addCurve(to: CGPoint(x: 0.51199*width, y: 0.91646*height), control1: CGPoint(x: 0.57712*width, y: 0.86344*height), control2: CGPoint(x: 0.54525*width, y: 0.89198*height))
        path.addCurve(to: CGPoint(x: 0.4967*width, y: 0.92198*height), control1: CGPoint(x: 0.50789*width, y: 0.91999*height), control2: CGPoint(x: 0.50253*width, y: 0.92423*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.50799*width, y: 0.83949*height))
        path.addCurve(to: CGPoint(x: 0.60456*width, y: 0.77056*height), control1: CGPoint(x: 0.54332*width, y: 0.82199*height), control2: CGPoint(x: 0.57361*width, y: 0.79529*height))
        path.addCurve(to: CGPoint(x: 0.70091*width, y: 0.69704*height), control1: CGPoint(x: 0.63901*width, y: 0.74902*height), control2: CGPoint(x: 0.66735*width, y: 0.72007*height))
        path.addCurve(to: CGPoint(x: 0.84934*width, y: 0.5415*height), control1: CGPoint(x: 0.75533*width, y: 0.65022*height), control2: CGPoint(x: 0.80746*width, y: 0.60035*height))
        path.addCurve(to: CGPoint(x: 0.90005*width, y: 0.41086*height), control1: CGPoint(x: 0.87409*width, y: 0.50201*height), control2: CGPoint(x: 0.89805*width, y: 0.45784*height))
        path.addCurve(to: CGPoint(x: 0.83939*width, y: 0.26678*height), control1: CGPoint(x: 0.89144*width, y: 0.35827*height), control2: CGPoint(x: 0.86254*width, y: 0.31388*height))
        path.addCurve(to: CGPoint(x: 0.74526*width, y: 0.20517*height), control1: CGPoint(x: 0.81318*width, y: 0.23936*height), control2: CGPoint(x: 0.78311*width, y: 0.21376*height))
        path.addCurve(to: CGPoint(x: 0.63313*width, y: 0.22341*height), control1: CGPoint(x: 0.70665*width, y: 0.20185*height), control2: CGPoint(x: 0.66968*width, y: 0.21266*height))
        path.addCurve(to: CGPoint(x: 0.55099*width, y: 0.30864*height), control1: CGPoint(x: 0.60456*width, y: 0.24977*height), control2: CGPoint(x: 0.57411*width, y: 0.27675*height))
        path.addCurve(to: CGPoint(x: 0.4772*width, y: 0.32364*height), control1: CGPoint(x: 0.53635*width, y: 0.34495*height), control2: CGPoint(x: 0.49449*width, y: 0.38067*height))
        path.addCurve(to: CGPoint(x: 0.39019*width, y: 0.2328*height), control1: CGPoint(x: 0.44983*width, y: 0.29018*height), control2: CGPoint(x: 0.4189*width, y: 0.26446*height))
        path.addCurve(to: CGPoint(x: 0.2811*width, y: 0.20775*height), control1: CGPoint(x: 0.36142*width, y: 0.20412*height), control2: CGPoint(x: 0.31928*width, y: 0.2024*height))
        path.addCurve(to: CGPoint(x: 0.14603*width, y: 0.29587*height), control1: CGPoint(x: 0.2272*width, y: 0.2177*height), control2: CGPoint(x: 0.17765*width, y: 0.25103*height))
        path.addCurve(to: CGPoint(x: 0.12754*width, y: 0.40277*height), control1: CGPoint(x: 0.12827*width, y: 0.32781*height), control2: CGPoint(x: 0.12762*width, y: 0.36759*height))
        path.addCurve(to: CGPoint(x: 0.15913*width, y: 0.52199*height), control1: CGPoint(x: 0.12767*width, y: 0.44496*height), control2: CGPoint(x: 0.14125*width, y: 0.48459*height))
        path.addCurve(to: CGPoint(x: 0.22116*width, y: 0.6154*height), control1: CGPoint(x: 0.17774*width, y: 0.55503*height), control2: CGPoint(x: 0.19498*width, y: 0.58809*height))
        path.addCurve(to: CGPoint(x: 0.31845*width, y: 0.70484*height), control1: CGPoint(x: 0.25007*width, y: 0.64826*height), control2: CGPoint(x: 0.28441*width, y: 0.67707*height))
        path.addCurve(to: CGPoint(x: 0.41977*width, y: 0.78474*height), control1: CGPoint(x: 0.34282*width, y: 0.74322*height), control2: CGPoint(x: 0.38857*width, y: 0.75394*height))
        path.addCurve(to: CGPoint(x: 0.50799*width, y: 0.83949*height), control1: CGPoint(x: 0.44917*width, y: 0.80022*height), control2: CGPoint(x: 0.47218*width, y: 0.84779*height))
        path.closeSubpath()
        return path
    }
}
