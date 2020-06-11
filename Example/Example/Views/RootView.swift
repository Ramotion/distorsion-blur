//
//  RootView.swift
//  Example
//
//  Created by Igor K. on 05.06.2020.
//  Copyright © 2020 Ramotion. All rights reserved.
//

import SwiftUI

struct RootView: View {
    
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

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
