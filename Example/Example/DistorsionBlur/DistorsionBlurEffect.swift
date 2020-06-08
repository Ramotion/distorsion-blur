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
        let distorsion = CIFilter.twirlDistortion(inputImage: overlayBlend.outputImage!, inputCenter: center, inputRadius: NSNumber(value: Double(radius)))!
        
        let blur = radiusRatio * 12
        let blurN = NSNumber(value: Double(blur))
        //let blurred = CIFilter.zoomBlur(inputImage: distorsion.outputImage!, inputCenter: center, inputAmount: blurN)
        //let blurred = CIFilter.boxBlur(inputImage: distorsion.outputImage!, inputRadius: blurN)
        let blurred = CIFilter.gaussianBlur(inputImage: distorsion.outputImage!, inputRadius: blurN)
        
        if let outputImage = blurred?.outputImage,
            let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            
            let a = abs(outputImage.extent.origin.x)
            let w = outputImage.extent.width - 2 * a
            let h = outputImage.extent.height - 2 * a
            let croppingRect = CGRect(x: a, y: a, width: w, height: h)
            let scaled = cgimg.cropping(to: croppingRect)!
            
            return UIImage(cgImage: scaled)
        }
        
        return nil
    }
    
    func compositeSourceOver(img: CIImage, overlay:CIImage) -> CIImage {

        let parameters = [
            kCIInputBackgroundImageKey: img,
            kCIInputImageKey: overlay
        ]
        guard let filter = CIFilter(name: "CISourceOverCompositing", parameters: parameters) else {
            fatalError()
        }
        guard let outputImage = filter.outputImage else { fatalError() }
        let cropRect = img.extent
        return outputImage.cropped(to: cropRect)
    }
}

/*
extension UIImage {
    func resizeCI(size:CGSize) -> UIImage? {
        let scale = (Double)(size.width) / (Double)(self.size.width)
            let image = UIKit.CIImage(CGImage:self.CGImage!)
            
            let filter = CIFilter(name: "CILanczosScaleTransform")!
            filter.setValue(image, forKey: kCIInputImageKey)
            filter.setValue(NSNumber(double:scale), forKey: kCIInputScaleKey)
            filter.setValue(1.0, forKey:kCIInputAspectRatioKey)
            let outputImage = filter.valueForKey(kCIOutputImageKey) as! UIKit.CIImage
            
            let context = CIContext(options: [kCIContextUseSoftwareRenderer: false])
            let resizedImage = UIImage(CGImage: context.createCGImage(outputImage, fromRect: outputImage.extent))
            return resizedImage
    }
}
*/

/*
private func loadImage1() {
    guard let inputImage = UIImage(named: "1") else { return }
    let beginImage = CIImage(image: inputImage)
    
    let context = CIContext()
    let currentFilter = CIFilter.sepiaTone()
    currentFilter.inputImage = beginImage
    currentFilter.intensity = 1
    
    guard let outputImage = currentFilter.outputImage else { return }

    if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
        let uiImage = UIImage(cgImage: cgimg)
        let image = Image(uiImage: uiImage)
    }
}

private func loadImage2() {
    guard let inputImage = UIImage(named: "2") else { return }
    let beginImage = CIImage(image: inputImage)
    
    let context = CIContext()
    let currentFilter = CIFilter.crystallize()
    //currentFilter.inputImage = beginImage not working
    currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
    currentFilter.radius = 200
    
    guard let outputImage = currentFilter.outputImage else { return }

    if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
        let uiImage = UIImage(cgImage: cgimg)
        image = Image(uiImage: uiImage)
    }
}
*/
