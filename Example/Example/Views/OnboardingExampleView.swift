//
//  OnboardingExampleView.swift
//  Example
//
//  Created by Igor K. on 15.06.2020.
//  Copyright © 2020 Ramotion. All rights reserved.
//

import Foundation
import SwiftUI
import DistorsionBlur

struct OnboardingExampleView: View {
    
    var body: some View {
        OnboardingView([
            OnboardingPage(content: self.page(title: "Sweden"), image: #imageLiteral(resourceName: "3")),
            OnboardingPage(content: self.page(title: "New Zealand"), image: #imageLiteral(resourceName: "1")),
            OnboardingPage(content: self.page(title: "Bali"), image: #imageLiteral(resourceName: "4")),
            OnboardingPage(content: self.page(title: "Maldives"), image: #imageLiteral(resourceName: "2")),
            OnboardingPage(content: self.page(title: "Hawaii"), image: #imageLiteral(resourceName: "5"))
        ])
    }
    
    private func page(title: String) -> some View {
        Text(title)
        .font(Font.custom("Noteworthy-Bold", size: 32))
        //.font(Font.custom("Zapfino", size: 32))
        //.font(Font.custom("Chalkduster", size: 32))
        .foregroundColor(.white)
    }
}
