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
        PageView([
            Image(uiImage: #imageLiteral(resourceName: "1")),
            Image(uiImage: #imageLiteral(resourceName: "4"))
        ])
    }
}
