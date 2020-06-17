//
//  OnboardingView.swift
//  Example
//
//  Created by Igor K. on 17.06.2020.
//  Copyright © 2020 Ramotion. All rights reserved.
//

import Foundation
import SwiftUI
import DistorsionBlur

struct OnboardingView<Page: View>: View {
    @State var currentPage = 0
    @State private(set) var pageProgress: CGFloat = 0
    
    private let viewControllers: [UIHostingController<Page>]

    init(_ views: [Page]) {
        self.viewControllers = views.map {
            let vc = UIHostingController(rootView: $0)
            vc.view.clipsToBounds = true
            vc.view.backgroundColor = .clear
            return vc
        }
    }

    var body: some View {
        ZStack {
            background
            pages
        }
    }
    
    private var background: some View {
        DistorionBlurContainer(firsImage: #imageLiteral(resourceName: "1"), secondImage: #imageLiteral(resourceName: "4"), ratio: pageProgress, bluredContent: {
            Text("Blurred")
        }, foregroundContent: {
            Text("Not Blurred").padding(.top, 100)
        })
    }
    
    private var pages: some View {
        ZStack(alignment: .bottom) {
            PageViewController(controllers: viewControllers,
                               currentPage: $currentPage,
                               pageProgress: $pageProgress)
            PageControl(pagesCount: viewControllers.count, currentPage: $currentPage)
                .padding(.bottom)
        }
    }
}
