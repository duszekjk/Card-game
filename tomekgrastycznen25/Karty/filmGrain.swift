import SwiftUI

func generateFilmGrain(size: CGSize) -> UIImage? {
    let context = CIContext()

    // Generate base random noise
    guard let filter = CIFilter(name: "CIRandomGenerator"),
          let outputImage = filter.outputImage else { return nil }

    let rect = CGRect(origin: .zero, size: size)
    let croppedImage = outputImage.cropped(to: rect) // Crop noise

    // Convert noise to grayscale (remove color)
    let grayscaleFilter = CIFilter(name: "CIColorControls")
    grayscaleFilter?.setValue(croppedImage, forKey: kCIInputImageKey)
    grayscaleFilter?.setValue(0.0, forKey: kCIInputSaturationKey) // No color
    grayscaleFilter?.setValue(1.8, forKey: kCIInputContrastKey) // Boost contrast

    guard let grayNoise = grayscaleFilter?.outputImage else { return nil }

    // Create alpha mask (adjust opacity)
    let alphaFilter = CIFilter(name: "CIMultiplyCompositing")
    alphaFilter?.setValue(grayNoise, forKey: kCIInputImageKey)
    alphaFilter?.setValue(CIImage(color: CIColor(red: 1, green: 1, blue: 1, alpha: 0.1)), forKey: kCIInputBackgroundImageKey)

    guard let alphaAdjustedNoise = alphaFilter?.outputImage else { return nil }

    // Apply a slight blur to soften the grain
    let blurFilter = CIFilter(name: "CIGaussianBlur")
    blurFilter?.setValue(alphaAdjustedNoise, forKey: kCIInputImageKey)
    blurFilter?.setValue(0.1, forKey: kCIInputRadiusKey) // Small blur for smooth grain

    guard let finalImage = blurFilter?.outputImage else { return nil }

    // Convert to UIImage
    if let cgImage = context.createCGImage(finalImage, from: finalImage.extent) {
        #if os(macOS)
        return UIImage(cgImage: cgImage, size: size)
        #else
        return UIImage(cgImage: cgImage)
        #endif
        
    }
    return nil
}
//import UIKit
//import CoreImage
//
//func generateFilmGrainDarker(size: CGSize) -> UIImage? {
//    let context = CIContext()
//
//    // Generate random noise
//    guard let filter = CIFilter(name: "CIRandomGenerator"),
//          let outputImage = filter.outputImage else { return nil }
//
//    let rect = CGRect(origin: .zero, size: size)
//    let croppedImage = outputImage.cropped(to: rect) // Crop noise
//
//    // Extract red channel for intensity
//    let redChannelFilter = CIFilter(name: "CIColorMatrix")
//    redChannelFilter?.setValue(croppedImage, forKey: kCIInputImageKey)
//    redChannelFilter?.setValue(CIVector(x: 1, y: 0, z: 0, w: 0), forKey: "inputRVector") // Keep red
//    redChannelFilter?.setValue(CIVector(x: 1, y: 0, z: 0, w: 0), forKey: "inputGVector") // Remove green
//    redChannelFilter?.setValue(CIVector(x: 1, y: 0, z: 0, w: 0), forKey: "inputBVector") // Remove blue
//    redChannelFilter?.setValue(CIVector(x: 0, y: 0, z: 1, w: 0), forKey: "inputAVector") // Keep alpha
//
//    guard let redNoise = redChannelFilter?.outputImage else { return nil }
//
////    // Blend red noise and alpha using a multiply composite
////    let blendFilter = CIFilter(name: "CIMultiplyCompositing")
////    blendFilter?.setValue(redNoise, forKey: kCIInputImageKey)
////    blendFilter?.setValue(blueAlpha, forKey: kCIInputBackgroundImageKey)
////
////    guard let blendedNoise = blendFilter?.outputImage else { return nil }
//
//    // Apply contrast and soften grain slightly
//    let contrastFilter = CIFilter(name: "CIColorControls")
//    contrastFilter?.setValue(redNoise, forKey: kCIInputImageKey)
//    contrastFilter?.setValue(-1.5, forKey: kCIInputBrightnessKey) // No color
////    contrastFilter?.setValue(1.5, forKey: kCIInputContrastKey) // Increase contrast slightly
//    
//    
//    guard let finalContrastImage = contrastFilter?.outputImage else { return nil }
//    let alphaFilter = CIFilter(name: "CIMultiplyCompositing")
//    alphaFilter?.setValue(finalContrastImage, forKey: kCIInputImageKey)
//    alphaFilter?.setValue(CIImage(color: CIColor(red: 1, green: 1, blue: 1, alpha: 0.05)), forKey: kCIInputBackgroundImageKey)
//    guard let alphaAdjustedNoise = alphaFilter?.outputImage else { return nil }
//
//    let blurFilter = CIFilter(name: "CIGaussianBlur")
//    blurFilter?.setValue(alphaAdjustedNoise, forKey: kCIInputImageKey)
//    blurFilter?.setValue(0.1, forKey: kCIInputRadiusKey) // Minimal blur for softening
//
//    guard let finalImage = blurFilter?.outputImage else { return nil }
//
//    // Convert to UIImage
//    if let cgImage = context.createCGImage(finalImage, from: finalImage.extent) {
//        return UIImage(cgImage: cgImage)
//    }
//    return nil
//}
