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

struct OnboardingPage<Content: View> {
    let content: () -> Content
    let backgroundImage: UIImage
    
    init(content: @autoclosure @escaping () -> Content, image: UIImage) {
        self.content = content
        self.backgroundImage = image
    }
}

struct OnboardingView<Page: View>: View {
    @State var currentPage = 0
    @State var nextPage = 0 
    @State private(set) var pageProgress: CGFloat = 0
    
    private let viewControllers: [UIHostingController<Page>]
    private let images: [UIImage]
    
    init(_ pages: [OnboardingPage<Page>]) {
        self.viewControllers = pages.map {
            let vc = UIHostingController(rootView: $0.content())
            vc.view.clipsToBounds = true
            vc.view.backgroundColor = .clear
            return vc
        }
        self.images = pages.map { $0.backgroundImage }
    }

    var body: some View {
        ZStack {
            background
            pages
        }
    }
    
    private var background: some View {
        
        DistorionBlurContainer(firsImage: images[currentPage],
                               secondImage: images[nextPage],
                               ratio: abs(pageProgress), bluredContent: {
            Text("Blurred")
        }, foregroundContent: {
            Text("Not Blurred").padding(.top, 100)
        })
    }
    
    private var pages: some View {
        ZStack(alignment: .bottom) {
            PageViewController(controllers: viewControllers,
                               currentPage: $currentPage,
                               pageProgress: $pageProgress,
                               controllerWillChange: { _, next in
                                
                print("next: \(next)")
                self.nextPage = next
            })
            PageControl(pagesCount: viewControllers.count, currentPage: $currentPage)
                .padding(.bottom)
        }
    }
}
