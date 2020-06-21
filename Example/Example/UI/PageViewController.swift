//
//  PageViewController.swift
//  Example
//
//  Created by Igor K. on 15.06.2020.
//  Copyright © 2020 Ramotion. All rights reserved.
//

import SwiftUI
import UIKit

struct PageViewController: UIViewControllerRepresentable {
        
    @Binding var currentPage: Int
    @Binding var pageProgress: CGFloat
    @Binding var fullProgress: CGFloat
    
    private let controllers: [UIViewController]
    private let orientation: UIPageViewController.NavigationOrientation
    private let controllerWillChange: (_ current: Int, _ next: Int) -> Void
    private let controllerDidChange: (_ previous: Int, _ current: Int) -> Void
    private let pageOffsetChanged: (_ pageProgress: CGFloat, _ fullProgress: CGFloat, _ isForward: Bool) -> Void
    
    init(controllers: [UIViewController],
         currentPage: Binding<Int>,
         pageProgress: Binding<CGFloat> = .constant(0),
         fullProgress: Binding<CGFloat> = .constant(0),
         orientation: UIPageViewController.NavigationOrientation = .horizontal,
         controllerWillChange: @escaping (_ current: Int, _ next: Int) -> Void = { _,_ in },
         controllerDidChange: @escaping (_ previous: Int, _ current: Int) -> Void = { _,_ in },
         pageOffsetChanged: @escaping (_ pageProgress: CGFloat, _ fullProgress: CGFloat, _ isForward: Bool) -> Void = { _,_,_ in }) {
        
        self.controllers = controllers
        self._currentPage = currentPage
        self._pageProgress = pageProgress
        self._fullProgress = fullProgress
        self.orientation = orientation
        self.controllerWillChange = controllerWillChange
        self.controllerDidChange = controllerDidChange
        self.pageOffsetChanged = pageOffsetChanged
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> PageVC {
        let vc = PageVC(controllers: controllers, orientation: orientation)
        vc.scrollingHandler = { i in
            self.pageProgress = i.pageProgress
        }
        
        vc.dataSource = context.coordinator
        vc.delegate = context.coordinator
        vc.view.backgroundColor = .clear
        
        return vc
    }

    func updateUIViewController(_ pageViewController: PageVC, context: Context) {
        let scrollView = pageViewController.view.subviews.compactMap ({ $0 as? UIScrollView }).first
        guard let sv = scrollView, !sv.isDragging, !sv.isDecelerating else { return }
        
        let vc = [controllers[currentPage]]
        pageViewController.setViewControllers(vc, direction: .forward, animated: true)
    }

    final class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: PageViewController

        init(_ pageViewController: PageViewController) {
            self.parent = pageViewController
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerBefore viewController: UIViewController) -> UIViewController? {
            
            guard let index = parent.controllers.firstIndex(of: viewController) else { return nil }
            if index == 0 {
                return parent.controllers.last
            }
            return parent.controllers[index - 1]
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerAfter viewController: UIViewController) -> UIViewController? {
            
            guard let index = parent.controllers.firstIndex(of: viewController) else { return nil }
            if index + 1 == parent.controllers.count {
                return parent.controllers.first
            }
            return parent.controllers[index + 1]
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
            
            guard let nextVC = pendingViewControllers.first,
                  let nextIndex = parent.controllers.firstIndex(of: nextVC) else { return }
            
            parent.controllerWillChange(parent.currentPage, nextIndex)
        }

        func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            
            if completed,
                let visibleViewController = pageViewController.viewControllers?.first,
                let index = parent.controllers.firstIndex(of: visibleViewController) {
                
                let previousIndex = parent.currentPage
                parent.currentPage = index
                parent.controllerDidChange(previousIndex, index)
            }
        }
    }
}

struct ScrollingInfo {
    let pageProgress: CGFloat
    let fullProgress: CGFloat
    let isForward: Bool
}

final class PageVC: UIPageViewController {
    
    var scrollingHandler: (ScrollingInfo) -> Void = { _ in }
    
    private var observer: NSKeyValueObservation?
    private let controllers: [UIViewController]
    
    init(controllers: [UIViewController],
         orientation: UIPageViewController.NavigationOrientation) {
        
        self.controllers = controllers
        super.init(transitionStyle: .scroll, navigationOrientation: orientation, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let scrollView = view.subviews.compactMap({ $0 as? UIScrollView }).first else { return }
        
        observer = scrollView.observe(\.contentOffset, options: [.old, .new]) { [unowned self] (s, o) in
            guard let old = o.oldValue, let new = o.newValue else { return }
            
            guard self.controllers.count > 1 else { return }
            guard s.isDragging || s.isDecelerating else { return }
            
            guard let visibleVC = self.viewControllers?.first else { return }
            guard let currentPage = self.controllers.firstIndex(of: visibleVC) else { return }
            
            let n = self.navigationOrientation == .horizontal ? new.x : new.y
            let o = self.navigationOrientation == .horizontal ? old.x : old.y
            
            let isForward = n > o
            let w = self.view.bounds.width
            let p = (n - w) / w
            let progress = (CGFloat(currentPage) + p) / CGFloat(self.controllers.count - 1)
            
            let info = ScrollingInfo(pageProgress: p, fullProgress: progress, isForward: isForward)
            self.scrollingHandler(info)
        }
    }
}
