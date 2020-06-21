//
//  OnboardingView.swift
//  Example
//
//  Created by Igor K. on 17.06.2020.
//  Copyright © 2020 Ramotion. All rights reserved.
//

import Foundation
import SwiftUI


public struct OnboardingPage<Content: View> {
    public let content: () -> Content
    public let backgroundImage: UIImage
    
    public init(content: @autoclosure @escaping () -> Content, image: UIImage) {
        self.content = content
        self.backgroundImage = image
    }
}

public struct OnboardingView<Page: View>: View {
    
    @State public private(set) var currentPage = 0
    @State public private(set) var pageProgress: CGFloat = 0
    @State private var nextPage = 0
    @State private var recalculateDistorsionPattern: Bool = false
    
    private let viewControllers: [UIHostingController<Page>]
    private let images: [UIImage]
    private let useSingleDistorsionPattern: Bool
    
    public init(_ pages: [OnboardingPage<Page>], singlePattern: Bool = true) {
        self.viewControllers = pages.map {
            let vc = UIHostingController(rootView: $0.content())
            vc.view.clipsToBounds = true
            vc.view.backgroundColor = .clear
            return vc
        }
        self.images = pages.map { $0.backgroundImage }
        self.useSingleDistorsionPattern = singlePattern
    }

    public var body: some View {
        ZStack {
            background
            pages
        }
    }
    
    private var background: some View {
        DistorionBlurContainer(firsImage: images[currentPage],
                               secondImage: images[nextPage],
                               ratio: abs(pageProgress), bluredContent: {
            Text("Blurred").padding(.top, -100)
        }, foregroundContent: {
            Text("Not Blurred").padding(.top, 100)
        }, distorsionPattern: .manual(calculate: { rect  in
            DistorionBlurUtilities.calculateRandomTwirlPositions(in: rect, recalculate: self.$recalculateDistorsionPattern)
        }))
    }
    
    private var pages: some View {
        ZStack(alignment: .bottom) {
            PageViewController(controllers: viewControllers,
                               currentPage: $currentPage,
                               pageProgress: $pageProgress,
                               controllerWillChange: { _, next in self.nextPage = next },
                               controllerDidChange: { _,_ in
                                    guard !self.useSingleDistorsionPattern else { return }
                                    self.recalculateDistorsionPattern = true
                               })
            PageControl(pagesCount: viewControllers.count, currentPage: $currentPage)
                .padding(.bottom)
        }
    }
}
