//
//  CGPoint+Extensions.swift
//  DistorsionBlur
//
//  Created by Igor K. on 09.06.2020.
//  Copyright © 2020 Ramotion. All rights reserved.
//

import Foundation
import SwiftUI


func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

func += (lhs: inout CGPoint, rhs: CGPoint) {
    lhs = lhs + rhs
}

func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

func -= (lhs: inout CGPoint, rhs: CGPoint) {
    lhs = lhs - rhs
}

func * (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
}

func *= (lhs: inout CGPoint, rhs: CGPoint) {
    lhs = lhs * rhs
}

func / (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x / rhs.x, y: lhs.y / rhs.y)
}

func /= (lhs: inout CGPoint, rhs: CGPoint) {
    lhs = lhs / rhs
}

func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
    return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
}


///CIVector & CGPoint calculations
func + (lhs: CGPoint, rhs: CIVector) -> CIVector {
    return CIVector(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

func + (lhs: CIVector, rhs: CGPoint) -> CIVector {
    return CIVector(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

func - (lhs: CGPoint, rhs: CIVector) -> CIVector {
    return CIVector(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

func - (lhs: CIVector, rhs: CGPoint) -> CIVector {
    return CIVector(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}


extension CGPoint {
    public init(uniform v: CGFloat) {
        self.init(x: v, y: v)
    }
}
