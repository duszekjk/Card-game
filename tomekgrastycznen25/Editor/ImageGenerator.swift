//
//  ImageGenerator.swift
//  tomekgrastycznen25
//
//  Created by Jacek Kałużny on 19/02/2025.
//


import CoreML
import UIKit
import SwiftUICore

var allImagesGenerator: [String:UIImage] = [:]

struct ImageGeneratorView: View {
    @State var showingLabel : Bool = false
    var label: String
    
    var body: some View {
        if(allImagesGenerator[label] != nil)
        {
            
            Image(uiImage: allImagesGenerator[label]!)
                .resizable()
                .scaledToFit()
                .cornerRadius(showingLabel ? 5 : 40)
                .animation(.easeInOut(duration: 0.4), value: showingLabel)
        }
        else
        {
            Image(uiImage: UIImage(systemName: "photo.artframe")!)
                .cornerRadius(showingLabel ? 5 : 40)
                .onAppear()
                {
                    DispatchQueue.global().async {
                        let showingLabelNow = ImageGenerator()!.generateImage(from: label)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05)
                        {
                            showingLabel = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
                        {
                            showingLabel = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25)
                        {
                            showingLabel = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                        {
                            showingLabel = false
                        }
                        DispatchQueue.main.async
                        {
                            showingLabel = showingLabelNow
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8)
                            {
                                showingLabel = true
                            }
                        }
                    }
                }
        }
    }
}
class ImageGenerator {
    let unetModel: unet
    let vaeDecoderModel: vae_decoder
    let maxTokenSize = 20
    let embeddingSize = 128

    init?() {
        do {
            let config = MLModelConfiguration()
            self.unetModel = try unet(configuration: config)
            self.vaeDecoderModel = try vae_decoder(configuration: config)
        } catch {
            print("❌ Failed to load CoreML models: \(error)")
            return nil
        }
    }


//    func generateImage(from text: String) -> UIImage? {
//        if let existingImage = allImagesGenerator[text]
//        {
//            return existingImage
//        }
//        // ✅ Step 1: Convert text to tokenized format
//        print("Step 1")
//        guard let tokenizedText = tokenizeText(text) else {
//            print("❌ Failed to tokenize text")
//            return nil
//        }
//
//        // ✅ Step 2: Generate latent vectors (random noise input)
//        print("Step 2")
//        guard let latentVectors = generateLatentNoise() else {
//            print("❌ Failed to generate latent vectors")
//            return nil
//        }
//
//        // ✅ Step 3: Use U-Net to generate refined latent representation
//        print("Step 3")
//        guard let unetOutput = try? unetModel.prediction(
//            sample: latentVectors,
//            timestep: MLMultiArray(shape: [1], dataType: .float32),  // Arbitrary timestep
//            encoder_hidden_states: tokenizedText
//        ) else {
//            print("❌ U-Net inference failed")
//            return nil
//        }
//
//        print("Step Explicitly")
//        guard let latentImage = unetOutput.var_1127 as? MLMultiArray else {
//            print("❌ Failed to convert U-Net output to MLMultiArray")
//            return nil
//        }
//        
//        print("Step latentImage end")
//        let vaeOutput: vae_decoderOutput? = try? vaeDecoderModel.prediction(latent_vectors: latentImage)
//        print("Step vaeOutput end")
//
//        guard let decodedImageArray = vaeOutput?.var_256 else {
//            print("❌ VAE Decoder inference failed")
//            return nil
//        }
//        // ✅ Step 5: Convert MLMultiArray to UIImage
//        print("Step 5")
//        
//        let outImage = mlMultiArrayToUIImage(decodedImageArray)
//        allImagesGenerator[text] = outImage
//        
//        return outImage
//    }
    func generateImage(from text: String) -> Bool {
        if let existingImage = allImagesGenerator[text] {
            return false
        }
        allImagesGenerator[text] = UIImage(systemName: "timelapse")
        print("Step 1: Tokenizing text")
        guard let tokenizedText = tokenizeText(text) else {
            print("❌ Failed to tokenize text")
            return false
        }
        
        print("Step 2: Generating initial latent noise")
        guard var latentVectors = generateLatentNoise() else {
            print("❌ Failed to generate latent vectors")
            return false
        }
        let numSteps = 50
        let scheduler = DiffusionScheduler(steps: numSteps)

        for step in stride(from: numSteps, to: 0, by: -1) {
            let timestep = scheduler.getTimestep(step)

            print("Step 3.\(numSteps - step): Denoising (Timestep: \(timestep))")

            let timestepArray = try! MLMultiArray(shape: [1], dataType: .float32)
            timestepArray[0] = NSNumber(value: timestep)

            guard let unetOutput = try? unetModel.prediction(
                sample: latentVectors,
                timestep: timestepArray,
                encoder_hidden_states: tokenizedText
            ) else {
                print("❌ U-Net inference failed at step \(step)")
                return false
            }

            latentVectors = scheduler.updateLatents(latentVectors, with: unetOutput.var_1127, timestep: timestep)
            if(step%5 == 0)
            {
                print("Step 4: Decoding latents into an image")
                guard let vaeOutput = try? vaeDecoderModel.prediction(latent_vectors: latentVectors) else {
                    print("❌ VAE Decoder inference failed")
                    return false
                }
                let decodedImageArray = vaeOutput.var_256
                
                print("Step 5: Converting to UIImage")
                let outImage = mlMultiArrayToUIImage(decodedImageArray)
                DispatchQueue.main.async
                {
                    allImagesGenerator[text] = outImage
                }
                
            }
        }

        print("Step 4: Decoding latents into an image")
        guard let vaeOutput = try? vaeDecoderModel.prediction(latent_vectors: latentVectors) else {
            print("❌ VAE Decoder inference failed")
            return false
        }


        
        let decodedImageArray = vaeOutput.var_256
        
        print("Step 5: Converting to UIImage")
        let outImage = mlMultiArrayToUIImage(decodedImageArray)
        DispatchQueue.main.async
        {
            allImagesGenerator[text] = outImage
        }
        return true
    }

    private func tokenizeText(_ text: String) -> MLMultiArray? {
        print("tokenizeText Step 1")
        var tokenized = Array(text.utf8).map { NSNumber(value: $0) }

        // Ensure fixed length
        print("tokenizeText Step 2")
        if tokenized.count > maxTokenSize {
            tokenized = Array(tokenized.prefix(maxTokenSize))
        } else {
            tokenized += Array(repeating: NSNumber(value: 0), count: maxTokenSize - tokenized.count)
        }

        // ✅ Only allocate required memory
        print("tokenizeText Step 3")
        guard let tokenArray = try? MLMultiArray(shape: [1, maxTokenSize, embeddingSize] as [NSNumber], dataType: .float32) else {
            return nil
        }

        // ✅ Use a more efficient loop
        print("tokenizeText Step 4")
        for i in 0..<maxTokenSize {
            let tokenValue = tokenized[i].floatValue / 255.0  // Normalize UTF-8 values
            let startIndex = i * embeddingSize
            for j in 0..<embeddingSize {
                tokenArray[startIndex + j] = NSNumber(value: tokenValue)  // Set all embedding positions
            }
        }

        return tokenArray
    }


    private func generateLatentNoise() -> MLMultiArray? {
        let shape = [1, 4, 128, 96]  // ✅ Ensure this matches model expectations
        guard let latentNoise = try? MLMultiArray(shape: shape as [NSNumber], dataType: .float32) else {
            print("❌ Failed to create latent noise array")
            return nil
        }

        // ✅ Use a more memory-efficient way to generate noise
        for i in 0..<latentNoise.count {
            latentNoise[i] = NSNumber(value: Float.random(in: -1.0...1.0))  // Keep within normal range
        }

        return latentNoise
    }

    private func mlMultiArrayToUIImage(_ array: MLMultiArray) -> UIImage? {
        let height = 192, width = 256  // Match actual output shape
        let channelCount = 3  // Assuming RGB
        
        guard array.shape == [1, NSNumber(value: height), NSNumber(value: width), NSNumber(value: channelCount)] else {
            print("❌ MLMultiArray shape mismatch! Expected [1, 256, 192, 3], got \(array.shape)")
            return nil
        }

        let totalPixels = height * width * channelCount
        var imageData = [UInt8](repeating: 0, count: totalPixels)

        // Convert MLMultiArray index to correct image index
        for h in 0..<height {
            for w in 0..<width {
                for c in 0..<channelCount {
                    let index = (h * width + w) * channelCount + c  // Flattened image index
                    let mlIndex = [0, h, w, c] as [NSNumber]  // Multi-array index
                    let value = array[mlIndex].floatValue

                    // Normalize from [-1, 1] to [0, 255]
                    let normalizedValue = (value + 1.0) / 2.0 * 255.0
                    imageData[index] = UInt8(max(0, min(255, normalizedValue)))  // Ensure within range
                }
            }
        }

        guard let provider = CGDataProvider(data: NSData(bytes: imageData, length: totalPixels) as CFData) else {
            print("❌ Failed to create CGDataProvider")
            return nil
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)  // ✅ Fix: Ensure RGB-only format

        guard let cgImage = CGImage(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 24,  // ✅ Fix: Correct pixel format for RGB (8 * 3 channels)
            bytesPerRow: width * channelCount,
            space: colorSpace,
            bitmapInfo: bitmapInfo,
            provider: provider,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        ) else {
            print("❌ Failed to create CGImage")
            return nil
        }

        return UIImage(cgImage: cgImage)
    }

}
