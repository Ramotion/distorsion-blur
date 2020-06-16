//
//  PageControl.swift
//  Example
//
//  Created by Igor K. on 15.06.2020.
//  Copyright © 2020 Ramotion. All rights reserved.
//

import Foundation
import SwiftUI

struct PageControl: UIViewRepresentable {
    
    @Binding private var currentPage: Int
    private let pagesCount: Int

    init(pagesCount: Int, currentPage: Binding<Int>) {
        _currentPage = currentPage
        self.pagesCount = pagesCount
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(control: self)
    }

    func makeUIView(context: Context) -> UIPageControl {
        let control = UIPageControl()
        control.numberOfPages = pagesCount
        control.addTarget(
            context.coordinator,
            action: #selector(Coordinator.updateCurrentPage(sender:)),
            for: .valueChanged)

        return control
    }

    func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.currentPage = currentPage
    }

    final class Coordinator: NSObject {
        var control: PageControl

        init(control: PageControl) {
            self.control = control
        }

        @objc func updateCurrentPage(sender: UIPageControl) {
            control.currentPage = sender.currentPage
        }
    }
}
