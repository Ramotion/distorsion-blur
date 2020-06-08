//
//  RootView.swift
//  Example
//
//  Created by Igor K. on 05.06.2020.
//  Copyright © 2020 Ramotion. All rights reserved.
//

import SwiftUI

struct RootView: View {
    
    @State private var image: Image?
    @State private var ratio: CGFloat = 0
    
    private var processor = DistorsionBlurEffect(first: #imageLiteral(resourceName: "3"), second: #imageLiteral(resourceName: "1"))
     
    
    var body: some View {
        let r = Binding(get: {
            return self.ratio
        }, set: { ratio in
            self.ratio = ratio
            self.updateImage(ratio: ratio)
        })
        
        return ZStack {
            image?
                .resizable()
                .scaledToFill()
            Slider(value: r)
                .padding(.bottom, 60)
                .frame(maxWidth: 240, maxHeight: .infinity, alignment: .bottom)
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear { self.updateImage(ratio: 0) }
    }
    
    private func updateImage(ratio: CGFloat) {
        guard let uiImage = processor?.generateEffect(for: ratio) else { return }
        self.image = Image(uiImage: uiImage)
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
