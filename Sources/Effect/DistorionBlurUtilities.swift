//
//  DistorionBlurUtilities.swift
//  DistorionBlur
//
//  Created by Igor K. on 10.06.2020.
//  Copyright © 2020 Ramotion. All rights reserved.
//

import Foundation
import SwiftUI

public struct DistorionBlurUtilities {
    
    private static var cache: [CGRect: [TwirlGeometry]] = [:]
    
    public static func calculateRandomTwirlPositions(in rect: CGRect) -> [TwirlGeometry] {
        return calculateRandomTwirlPositions(in: rect, recalculate: .constant(false))
    }
    
    public static func calculateRandomTwirlPositions(in rect: CGRect, recalculate: Binding<Bool>) -> [TwirlGeometry] {
        
        if !recalculate.wrappedValue, let result = cache[rect], !result.isEmpty {
            return result
        }
        
        let count = Int.random(in: 1...7)
        let w = rect.width
        let h = rect.height
        let maxR = min(w, h) / 2
        let minR = maxR * 0.35
        let maxAttemptsCount: Int = 10
        
        var placed: [(CGPoint, CGFloat)] = [] //center & radius
        for _ in 0 ..< count {
            var attempts = maxAttemptsCount
            while attempts > 0 {
                let radius = CGFloat.random(in: minR..<maxR)
                let x = radius + CGFloat.random(in: 0...(w - 2 * radius))
                let y = radius + CGFloat.random(in: 0...(h - 2 * radius))
                let intersects = placed.contains { (c: CGPoint, r: CGFloat) -> Bool in
                    let a: CGFloat = (c.x - x) * (c.x - x)
                    let b: CGFloat = (c.y - y) * (c.y - y)
                    let c: CGFloat = (r + radius) * (r + radius)
                    return a + b < c
                }
                
                if intersects {
                    attempts -= 1
                } else {
                    placed.append((CGPoint(x: x, y: y), radius))
                    break
                }
            }
        }
        
        let twirls = placed.map { TwirlGeometry(center: $0, radius: $1) }
        cache[rect] = twirls
        DispatchQueue.main.async { recalculate.wrappedValue = false }
        return twirls
    }
}


extension CGRect: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(minX)
        hasher.combine(minY)
        hasher.combine(maxX)
        hasher.combine(maxY)
    }
}
