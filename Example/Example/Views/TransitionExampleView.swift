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
            Color.black.edgesIgnoringSafeArea(.all)
            
            DistorionBlurContainer(firsImage: #imageLiteral(resourceName: "3"), secondImage: #imageLiteral(resourceName: "5"), ratio: ratio, bluredContent: {
                Text("Blurred")
                .foregroundColor(Color.white)
                .font(Font.custom("Noteworthy-Bold", size: 32))
            }, foregroundContent: {
                Text("Not Blurred")
                .foregroundColor(Color.white)
                .font(Font.custom("Chalkduster", size: 32))
                .padding(.top, 100)
            })
            
            Slider(value: $ratio)
                .padding(.bottom, 60)
                .frame(maxWidth: 240, maxHeight: .infinity, alignment: .bottom)
        }
    }
}
