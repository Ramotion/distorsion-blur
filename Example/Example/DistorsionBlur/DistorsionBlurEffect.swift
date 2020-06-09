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

public enum DistorsionPattern {
    case single(centerDisposition: CGPoint)
    case grid(rows: Int, columns: Int, centerDisposition: CGPoint)
    case polygon(sides: Int, angle: Angle, centerDisposition: CGPoint)
}

public struct DistorsionBlurEffect {
 
    private let firstImage: CIImage
    private let secondImage: CIImage
    
    private let context = CIContext()
    
    init?(first: UIImage,
          second: UIImage,
          distorsionPattern: DistorsionPattern = .single(centerDisposition: .zero)) {
        
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
        let center = CIVector(x: firstImage.extent.width / 2, y: firstImage.extent.height / 2)
        
        let alphaFilter = CIFilter.colorMatrix(inputAVector: alpha)
        let backgroundFilter = CIFilter.sourceOverCompositing(backgroundImage: firstImage)!
        let distorsionFilter = CIFilter.twirlDistortion(inputCenter: center, inputRadius: radius)
        
        let outputImage = secondImage >> alphaFilter >> backgroundFilter >> distorsionFilter
                
        if let result = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: result)
        }
        
        return nil
    }
}

infix operator >> : ApplyPrecedence

precedencegroup ApplyPrecedence {
    associativity: left
    lowerThan: BitwiseShiftPrecedence
    higherThan: MultiplicationPrecedence
}


extension CIImage {
    static func >> (lhs: CIImage, rhs: CIFilter) -> CIImage {
        rhs.setValue(lhs, forKey: kCIInputImageKey)
        return rhs.outputImage ?? lhs
    }
    
    static func >> (lhs: CIImage, rhs: CIFilter?) -> CIImage {
        guard let filter = rhs else { return lhs }
        filter.setValue(lhs, forKey: kCIInputImageKey)
        return filter.outputImage ?? lhs
    }
}


extension CIFilter {
    static func twirlDistortion(inputCenter: CIVector = CIVector(x: 150.0, y: 150.0), inputRadius: CGFloat = 300, inputAngle: CGFloat = 2 * CGFloat.pi) -> CIFilter? {
        
        guard let filter = CIFilter(name: "CITwirlDistortion") else { return nil }
        filter.setDefaults()
        filter.setValue(inputCenter, forKey: kCIInputCenterKey)
        filter.setValue(inputRadius, forKey: kCIInputRadiusKey)
        filter.setValue(inputAngle, forKey: kCIInputAngleKey)
        return filter
    }

    
    static func sourceOverCompositing(backgroundImage: CIImage) -> CIFilter? {
        
        guard let filter = CIFilter(name: "CISourceOverCompositing") else { return nil }
        filter.setDefaults()
        filter.setValue(backgroundImage, forKey: kCIInputBackgroundImageKey)
        return filter
    }
    
    static func colorMatrix(inputRVector: CIVector = CIVector(x: 1.0, y: 0.0, z: 0.0, w: 0.0), inputGVector: CIVector = CIVector(x: 0.0, y: 1.0, z: 0.0, w: 0.0), inputBVector: CIVector = CIVector(x: 0.0, y: 0.0, z: 1.0, w: 0.0), inputAVector: CIVector = CIVector(x: 0.0, y: 0.0, z: 0.0, w: 1.0), inputBiasVector: CIVector = CIVector(x: 0.0, y: 0.0, z: 0.0, w: 0.0)) -> CIFilter? {
        
        guard let filter = CIFilter(name: "CIColorMatrix") else { return nil }
        filter.setDefaults()
        filter.setValue(inputRVector, forKey: "inputRVector")
        filter.setValue(inputGVector, forKey: "inputGVector")
        filter.setValue(inputBVector, forKey: "inputBVector")
        filter.setValue(inputAVector, forKey: "inputAVector")
        filter.setValue(inputBiasVector, forKey: "inputBiasVector")
        return filter
    }
}
