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
    case single(twirlAngle: Angle, centerDisposition: CGPoint)
    case grid(rows: Int, columns: Int, twirlAngle: Angle, centerDisposition: CGPoint)
    case polygon(sides: Int, radius: CGFloat, rotation: Angle, scale: CGFloat, twirlAngle: Angle, centerDisposition: CGPoint)
    case manual(calculate: (_ frame: CGRect) -> [TwirlGeometry])
    case custom(transformation: (_ input: CIImage, _ ratio: CGFloat, _ frame: CGRect) -> CIImage)
}

public struct TwirlGeometry {
    let center: CGPoint
    let radius: CGFloat
    let angle: Angle
    
    init(center: CGPoint,
         radius: CGFloat,
         angle: Angle = Angle(radians: Double.pi / 2.5)) {
        
        self.center = center
        self.radius = radius
        self.angle = angle
    }
}

struct DistorsionEffect {
 
    private let firstImage: CIImage
    private let secondImage: CIImage
    private let distorsionPattern: DistorsionPattern
    private let context = CIContext()
    
    private var randomTwirlPositions: [(CGPoint, CGFloat)] = []
    
    init?(first: UIImage,
          second: UIImage,
          distorsionPattern: DistorsionPattern = .single(twirlAngle: Angle(radians: Double.pi / 2.5), centerDisposition: .zero)) {
        
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
        case let .single(twirlAngle, disposition):
            let center = CIVector(x: firstImage.extent.width / 2, y: firstImage.extent.height / 2)
            let radius = radiusRatio * firstImage.extent.width / 2 /* max distorsion radius */
            let filter = CIFilter.twirlDistortion(inputCenter: center + disposition, inputRadius: radius, inputAngle: twirlAngle.fradians)
            outputImage = inputImage |> filter
        case let .grid(rows, columns, twirlAngle, disposition):
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
                    let filter = CIFilter.twirlDistortion(inputCenter: c + disposition, inputRadius: radius, inputAngle: twirlAngle.fradians)
                    outputImage = outputImage |> filter
                }
            }
        case let .polygon(sides, radius, rotation, scale, twirlAngle, disposition):
            let w = firstImage.extent.width - 2 * radius
            let h = firstImage.extent.height - 2 * radius
            let s = min(w, h) / 2.0 * scale
            let c = CGPoint(x: w / 2.0, y: h / 2.0) + CGPoint(uniform: radius)
            let r = radiusRatio * radius
            
            for i in 0 ..< sides {
                let additionalAngle = CGFloat(rotation.radians)
                let a = CGFloat(i) * 2 * CGFloat.pi / CGFloat(sides) + additionalAngle
                let o = CIVector(x: c.x + CGFloat(cos(a) * s), y: c.y + CGFloat(sin(a) * s))
                
                let filter = CIFilter.twirlDistortion(inputCenter: o + disposition, inputRadius: r, inputAngle: twirlAngle.fradians)
                outputImage = outputImage |> filter
            }
        case .manual(let calculate):
            let twirls = calculate(firstImage.extent)
            for t in twirls {
                let o = CIVector(x: t.center.x, y: t.center.y)
                let radius = radiusRatio * t.radius
                let filter = CIFilter.twirlDistortion(inputCenter: o, inputRadius: radius, inputAngle: t.angle.fradians)
                outputImage = outputImage |> filter
            }
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


fileprivate extension Angle {
    var fradians: CGFloat {
        return CGFloat(self.radians)
    }
}
