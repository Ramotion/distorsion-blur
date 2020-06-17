//
//  RootView.swift
//  Example
//
//  Created by Igor K. on 05.06.2020.
//  Copyright © 2020 Ramotion. All rights reserved.
//

import SwiftUI
import DistorsionBlur

struct RootView: View {
    
    var body: some View {
        OnboardingView([
            self.page(title: "Sweden"),
            self.page(title: "New Zealand"),
            self.page(title: "Bali"),
            self.page(title: "Maldives"),
            self.page(title: "Hawaii")
        ])
    }
    
    private func page(title: String) -> some View {
        Text(title)
        .font(Font.custom("Noteworthy-Bold", size: 32))
        .foregroundColor(.white)
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
