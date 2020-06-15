//
//  TransitionExampleView.swift
//  Example
//
//  Created by Igor K. on 15.06.2020.
//  Copyright © 2020 Ramotion. All rights reserved.
//

import Foundation
import SwiftUI
import DistorsionBlur

struct TransitionExampleView: View {
    
    @State private var ratio: CGFloat = 0
    
    var body: some View {
        ZStack {
            DistorionBlurContainer(firsImage: #imageLiteral(resourceName: "1"), secondImage: #imageLiteral(resourceName: "4"), ratio: ratio, bluredContent: {
                Text("Blurred")
            }, foregroundContent: {
                Text("Not Blurred").padding(.top, 100)
            })
            Slider(value: $ratio)
                .padding(.bottom, 60)
                .frame(maxWidth: 240, maxHeight: .infinity, alignment: .bottom)
        }
    }
}
