//
//  RootView.swift
//  Example
//
//  Created by Igor K. on 05.06.2020.
//  Copyright © 2020 Ramotion. All rights reserved.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct RootView: View {
    
    @State private var image: Image?
    
    var body: some View {
        VStack {
            image?
                .resizable()
                .scaledToFill()
        }
        .gesture(DragGesture()
            .onChanged { g in
                let ratio = g.location.x / UIScreen.main.bounds.width
                self.loadImage3(radiusRatio: ratio)
            }
        )
        .edgesIgnoringSafeArea(.all)
        .onAppear { self.loadImage3(radiusRatio: 0) }
    }

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
            image = Image(uiImage: uiImage)
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
    
    private let context = CIContext()
    private var distorsionFilter: CIFilter? = {
        guard let inputImage = UIImage(named: "2") else { return nil }
        let beginImage = CIImage(image: inputImage)
        
        //let context = CIContext()
        guard let filter = CIFilter(name: "CITwirlDistortion") else { return nil }
        filter.setValue(beginImage, forKey: kCIInputImageKey)
        filter.setValue(CIVector(x: inputImage.size.width / 2, y: inputImage.size.height / 2), forKey: kCIInputCenterKey)
        return filter
    }()
    
    private func loadImage3(radiusRatio: CGFloat) {
            
        let radius = radiusRatio * 320 /* max distorsion radius */
        distorsionFilter?.setValue(radius, forKey: kCIInputRadiusKey)
        guard let outputImage = distorsionFilter?.outputImage else { return }

        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
