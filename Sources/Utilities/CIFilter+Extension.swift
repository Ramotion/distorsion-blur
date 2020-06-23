//
//  CIFilter+Extension.swift
//  DistorsionBlur
//
//  Created by Igor K. on 08.06.2020.
//  Copyright © 2020 Ramotion. All rights reserved.
//

import Foundation
import CoreImage

infix operator |> : ApplyPrecedence

precedencegroup ApplyPrecedence {
    associativity: left
    lowerThan: BitwiseShiftPrecedence
    higherThan: MultiplicationPrecedence
}

extension CIImage {
    static func |> (lhs: CIImage, rhs: CIFilter) -> CIImage {
        rhs.setValue(lhs, forKey: kCIInputImageKey)
        return rhs.outputImage ?? lhs
    }
    
    static func |> (lhs: CIImage, rhs: CIFilter?) -> CIImage {
        guard let filter = rhs else { return lhs }
        filter.setValue(lhs, forKey: kCIInputImageKey)
        return filter.outputImage ?? lhs
    }
    
    static func |> (lhs: CIImage, rhs: (CIImage) -> CIImage) -> CIImage {
        return rhs(lhs)
    }
}

extension CIFilter {
    
    func apply(to image: CIImage) -> CIImage {
        setValue(image, forKey: kCIInputImageKey)
        return outputImage ?? image
    }
}

extension CIFilter {
    
    /// [CITwirlDistortion](http://developer.apple.com/library/ios/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CITwirlDistortion)
    ///
    /// - parameter inputCenter: The center of the effect as x and y coordinates. defaultValue = [150 150].
    /// - parameter inputRadius: The radius determines how many pixels are used to create the distortion. The larger the radius, the wider the extent of the distortion. defaultValue = 300.
    /// - parameter inputAngle: The angle (in radians) of the twirl. Values can be positive or negative. defaultValue = CGFloat.pi
    ///
    /// - returns: Generated CIFilter (you can get result with ["outputImage"])
    static func twirlDistortion(inputCenter: CIVector = CIVector(x: 150.0, y: 150.0), inputRadius: CGFloat = 300, inputAngle: CGFloat = CGFloat.pi / 2.5) -> CIFilter? {
        
        guard let filter = CIFilter(name: "CITwirlDistortion") else { return nil }
        filter.setDefaults()
        filter.setValue(inputCenter, forKey: kCIInputCenterKey)
        filter.setValue(inputRadius, forKey: kCIInputRadiusKey)
        filter.setValue(inputAngle, forKey: kCIInputAngleKey)
        return filter
    }

    /// [CISourceOverCompositing](http://developer.apple.com/library/ios/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CISourceOverCompositing)
    ///
    /// - parameter backgroundImage: The image to use as a background image.
    ///
    /// - returns: Generated CIFilter (you can get result with ["outputImage"])
    static func sourceOverCompositing(backgroundImage: CIImage) -> CIFilter? {
        
        guard let filter = CIFilter(name: "CISourceOverCompositing") else { return nil }
        filter.setDefaults()
        filter.setValue(backgroundImage, forKey: kCIInputBackgroundImageKey)
        return filter
    }
    
    /// [CIColorMatrix](http://developer.apple.com/library/ios/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CIColorMatrix)
    ///
    /// - parameter inputRVector: The amount of red to multiply the source color values by. defaultValue = [1 0 0 0].
    /// - parameter inputGVector: The amount of green to multiply the source color values by. defaultValue = [0 1 0 0].
    /// - parameter inputBVector: The amount of blue to multiply the source color values by. defaultValue = [0 0 1 0].
    /// - parameter inputAVector: The amount of alpha to multiply the source color values by. defaultValue = [0 0 0 1].
    /// - parameter inputBiasVector: A vector that’s added to each color component. defaultValue = [0 0 0 0].
    ///
    /// - returns: Generated CIFilter (you can get result with ["outputImage"])
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
