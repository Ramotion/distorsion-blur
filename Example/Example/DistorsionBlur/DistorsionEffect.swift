//
//  DistorsionEffect.swift
//  DistorsionBlur
//
//  Created by Igor K. on 08.06.2020.
//  Copyright © 2020 Ramotion. All rights reserved.
//

import Foundation
import SwiftUI

public enum DistorsionPattern {
    case single(centerDisposition: CGPoint)
    case grid(rows: Int, columns: Int, centerDisposition: CGPoint)
    case polygon(sides: Int, angle: Angle, centerDisposition: CGPoint)
    case custom(transformation: (_ input: CIImage, _ ratio: CGFloat, _ frame: CGRect) -> CIImage)
}

struct DistorsionEffect {
 
    private let firstImage: CIImage
    private let secondImage: CIImage
    private let distorsionPattern: DistorsionPattern
    private let context = CIContext()
    
    init?(first: UIImage,
          second: UIImage,
          distorsionPattern: DistorsionPattern = .grid(rows: 1, columns: 3, centerDisposition: .zero)) {
        
        guard let f = CIImage(image: first),
            let s = CIImage(image: second) else { return nil }
        
        self.distorsionPattern = distorsionPattern
        self.firstImage = f
        self.secondImage = s
    }
    
    func generateEffect(for effectRatio: CGFloat) -> UIImage? {
        
        let ratio = effectRatio.limited(0, 1)
        let radiusRatio = 1 - abs(0.5 - ratio) * 2
        let alpha = CIVector(x: 0.0, y: 0.0, z: 0.0, w: ratio)
        
        let alphaFilter = CIFilter.colorMatrix(inputAVector: alpha)
        let backgroundFilter = CIFilter.sourceOverCompositing(backgroundImage: firstImage)
        let inputImage = secondImage |> alphaFilter |> backgroundFilter
        
        var outputImage: CIImage = inputImage
        switch distorsionPattern {
        case .single(let disposition):
            let center = CIVector(x: firstImage.extent.width / 2, y: firstImage.extent.height / 2)
            let radius = radiusRatio * firstImage.extent.width / 2 /* max distorsion radius */
            let filter = CIFilter.twirlDistortion(inputCenter: center + disposition, inputRadius: radius)
            outputImage = inputImage |> filter
        case let .grid(rows, columns, disposition):
            let wr = firstImage.extent.width / (2 * CGFloat(columns))
            let hr = firstImage.extent.height / (2 * CGFloat(rows))
            let r = min(wr, hr)
            
            let dx = (firstImage.extent.width - 2 * r * CGFloat(columns)) / 2
            let dy = (firstImage.extent.height - 2 * r * CGFloat(rows)) / 2
            let radius = radiusRatio * r
            
            for y in 0 ..< rows {
                for x in 0 ..< columns {
                    let cx = r * CGFloat(1 + 2 * x)
                    let cy = r * CGFloat(1 + 2 * y)
                    let c = CIVector(x: cx + dx, y: cy + dy)
                    let filter = CIFilter.twirlDistortion(inputCenter: c + disposition, inputRadius: radius)
                    outputImage = outputImage |> filter
                }
            }
        case let .polygon(sides, angle, disposition):
            fatalError()
        case .custom(let transformation):
            let frame = firstImage.extent
            outputImage = transformation(inputImage, ratio, frame)
        }
        
        
        if let result = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: result)
        }
        
        return nil
    }
}
