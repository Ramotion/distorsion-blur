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
        ZStack(alignment: .top) {
            background(index: 0)
            PageView([
                self.page(title: "Sweden"),
                self.page(title: "New Zealand")
            ])
        }
    }
    
    private func background(index: Int) -> some View {
        ZStack {
            Image(uiImage: #imageLiteral(resourceName: "1"))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
        }
        
        /*
        Image(uiImage: #imageLiteral(resourceName: "4"))
        Image(uiImage: #imageLiteral(resourceName: "2"))
        Image(uiImage: #imageLiteral(resourceName: "1"))
            .resizable()
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .aspectRatio(contentMode: .fill)
            .border(Color.blue, width: 3.0)
            .clipped()
         */
    }
    
    private func page(title: String) -> some View {
        Text(title)
        //.font(Font.custom("Zapfino", size: 32))
        .font(Font.custom("Noteworthy-Bold", size: 32))
        //.font(Font.custom("Chalkduster", size: 32))
          
        .foregroundColor(.white)
    }
}
