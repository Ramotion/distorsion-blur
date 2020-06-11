//
//  DistorionBlurContainer.swift
//  DistorsionBlur
//
//  Created by Igor K. on 08.06.2020.
//  Copyright © 2020 Ramotion. All rights reserved.
//

import Foundation
import SwiftUI

struct DistorionBlurContainer<BluredContent, ForegroundContent>: View where BluredContent: View, ForegroundContent: View {
    
    @State private var image: Image?
    private let bluredContent: () -> BluredContent
    private let foregroundContent: () -> ForegroundContent
    private let ratio: CGFloat
    private let processor: DistorsionEffect?
    
    init(firsImage: UIImage,
         secondImage: UIImage,
         ratio: CGFloat,
         bluredContent: @escaping () -> BluredContent,
         foregroundContent: @escaping () -> ForegroundContent,
         distorsionPattern: DistorsionPattern = .manual(calculate: DistorionBlurUtilities.calculateRandomTwirlPositions)) {
        
        self.ratio = ratio
        self.bluredContent = bluredContent
        self.foregroundContent = foregroundContent
        self.processor = DistorsionEffect(first: firsImage, second: secondImage, distorsionPattern: distorsionPattern)
    }
    
    var body: some View{
        return ZStack {
            background?
                .resizable()
                .scaledToFill()
                .overlay(bluredContent())
                .blur(radius: (1 - abs(0.5 - ratio) * 2) * 10)
            foregroundContent()
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private var background: Image? {
        guard let uiImage = processor?.generateEffect(for: ratio) else { return nil }
        return Image(uiImage: uiImage)
    }
}
