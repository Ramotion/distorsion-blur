//
//  PageView.swift
//  Example
//
//  Created by Igor K. on 15.06.2020.
//  Copyright © 2020 Ramotion. All rights reserved.
//

import SwiftUI

struct PageView<Page: View>: View {
    var viewControllers: [UIHostingController<Page>]
    @State var currentPage = 0

    init(_ views: [Page]) {
        self.viewControllers = views.map {
            let vc = UIHostingController(rootView: $0)
            vc.view.clipsToBounds = true
            vc.view.backgroundColor = .clear
            return vc
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            PageViewController(controllers: viewControllers, currentPage: $currentPage, controllerWillChange: {
                print("WILL CHANGE. From: \($0), to: \($1)")
            }, controllerDidChange: {
                print("DID CHANGE. From: \($0), to: \($1)")
            })
            PageControl(pagesCount: viewControllers.count, currentPage: $currentPage)
                .padding(.bottom)
        }
    }
}
