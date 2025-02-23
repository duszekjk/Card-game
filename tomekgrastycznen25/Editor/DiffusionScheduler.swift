//
//  DiffusionScheduler.swift
//  tomekgrastycznen25
//
//  Created by Jacek Kałużny on 21/02/2025.
//

import SwiftUI

import CoreML
import UIKit
import SwiftUICore

class DiffusionScheduler {
    let numSteps: Int
    let startStep: Float = 1000.0  // Maximum noise level in diffusion
    let endStep: Float = 1.0       // Minimum noise level

    init(steps: Int) {
        self.numSteps = steps
    }

    func getTimestep(_ step: Int) -> Float {
        let t = Float(step) / Float(numSteps) // Normalize step
        return startStep - startStep * cos(t * .pi / 2)   // Cosine decay (closer to real diffusion)
    }


    func updateLatents(_ latents: MLMultiArray, with unetOutput: MLMultiArray, timestep: Float) -> MLMultiArray {
        let shape = latents.shape
        let updatedArray = try! MLMultiArray(shape: shape, dataType: .float32)

        // Compute the correct alpha for this timestep
        let alpha_t = exp(-timestep * 0.02)  // Simulating a noise decay factor

        for i in 0..<latents.count {
            let x_t = latents[i].floatValue
            let noise = unetOutput[i].floatValue
            let x_t_minus_1 = (x_t - (1 - alpha_t) * noise) / sqrt(alpha_t)  // Correct formula
            updatedArray[i] = NSNumber(value: x_t_minus_1)
        }
        
        return updatedArray
    }

}

// Helper function for blending two MLMultiArrays (latents + denoised update)
func blendMLMultiArrays(_ a: MLMultiArray, _ b: MLMultiArray, alpha: Float) -> MLMultiArray {
    let shape = a.shape
    let blendedArray = try! MLMultiArray(shape: shape, dataType: .float32)

    for i in 0..<a.count {
        blendedArray[i] = NSNumber(value: (1 - alpha) * a[i].floatValue + alpha * b[i].floatValue)
    }
    
    return blendedArray
}
