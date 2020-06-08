//
//  DistorsionBlurEffect.swift
//  Example
//
//  Created by Igor K. on 08.06.2020.
//  Copyright © 2020 Ramotion. All rights reserved.
//

import Foundation
import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct DistorsionBlurEffect {
 
    private let firstImage: CIImage
    private let secondImage: CIImage
    
    private let context = CIContext()
    
    init?(first: UIImage, second: UIImage) {
        guard let f = CIImage(image: first),
            let s = CIImage(image: second) else { return nil }
        
        self.firstImage = f
        self.secondImage = s
    }
    
    func generateEffect(for effectRatio: CGFloat) -> UIImage? {
        
        let ratio = effectRatio.limited(0, 1)
        let radiusRatio = 1 - abs(0.5 - ratio) * 2
        let radius = radiusRatio * firstImage.extent.width / 2 /* max distorsion radius */
        let alpha = CIVector(x: 0.0, y: 0.0, z: 0.0, w: ratio)
        
        let overlayAlpha = CIFilter.colorMatrix(inputImage: secondImage, inputAVector: alpha)!
        let overlayBlend = CIFilter.sourceOverCompositing(inputImage: overlayAlpha.outputImage!, inputBackgroundImage: firstImage)!
        
        let center = CIVector(x: firstImage.extent.width / 2, y: firstImage.extent.height / 2)
        let distorsion = CIFilter.twirlDistortion(inputImage: overlayBlend.outputImage!, inputCenter: center, inputRadius: NSNumber(value: Double(radius)))
                
        if let outputImage = distorsion?.outputImage,
            let result = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: result)
        }
        
        return nil
    }
}
