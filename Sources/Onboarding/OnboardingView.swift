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
    
    private var ratio: CGFloat { return abs(pageProgress) }
    
    private let viewControllers: [UIHostingController<Page>]
    private let images: [UIImage]
    private let useSingleDistorsionPattern: Bool
    private let loop: Bool
    
    public init(pages: [OnboardingPage<Page>],
                loop: Bool = false,
                singlePattern: Bool = false) {
        
        self.viewControllers = pages.map {
            let vc = UIHostingController(rootView: $0.content())
            vc.view.clipsToBounds = true
            vc.view.backgroundColor = .clear
            return vc
        }
        self.images = pages.map { $0.backgroundImage }
        self.loop = loop
        self.useSingleDistorsionPattern = singlePattern
    }

    public var body: some View {
        ZStack {
            ZStack {
                background?
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                    .blur(radius: (1 - abs(0.5 - ratio) * 2) * 10)
            }
            .overlay(pages)
            indicator
        }
    }
    
    private var background: Image? {
        let processor = DistorsionEffect(first: images[currentPage],
                                         second: images[nextPage],
                                         distorsionPattern: .manual(calculate: { r in
            return DistorionBlurUtilities.calculateRandomTwirlPositions(in: r, recalculate: self.$recalculateDistorsionPattern)
        }))
        guard let uiImage = processor?.generateEffect(for: ratio) else { return nil }
        return Image(uiImage: uiImage)
    }
    
    private var pages: some View {
        PageViewController(controllers: viewControllers,
                           currentPage: $currentPage,
                           loop: loop,
                           pageProgress: $pageProgress,
                           controllerWillChange: { _, next in self.nextPage = next },
                           controllerDidChange: { _,_ in
                            guard !self.useSingleDistorsionPattern else { return }
                            self.recalculateDistorsionPattern = true
        })
    }
    
    private var indicator: some View {
        VStack() {
            Spacer()
            PageControl(pagesCount: viewControllers.count, currentPage: $currentPage)
                .padding(.bottom)
        }
    }
}
