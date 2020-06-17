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
    private let controllerWillChange: (_ previous: Int, _ current: Int) -> Void
    private let controllerDidChange: (_ previous: Int, _ current: Int) -> Void
    private let pageOffsetChanged: (_ pageProgress: CGFloat, _ fullProgress: CGFloat, _ isForward: Bool) -> Void
    
    init(controllers: [UIViewController],
         currentPage: Binding<Int>,
         pageProgress: Binding<CGFloat> = .constant(0),
         fullProgress: Binding<CGFloat> = .constant(0),
         orientation: UIPageViewController.NavigationOrientation = .horizontal,
         controllerWillChange: @escaping (_ previous: Int, _ current: Int) -> Void = { _,_ in },
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
        let vc = PageVC(transitionStyle: .scroll, navigationOrientation: orientation)
        vc.dataSource = context.coordinator
        vc.delegate = context.coordinator
        vc.view.backgroundColor = .clear
        
        let pagesCount = controllers.count
        vc.offsetDidChanged = { [weak vc] s, old, new in
            guard let vc = vc, pagesCount > 1 else { return }
            guard s.isDragging || s.isDecelerating else { return }
            
            let n = self.orientation == .horizontal ? new.x : new.y
            let o = self.orientation == .horizontal ? old.x : old.y
            
            let isForward = n > o
            let w = vc.view.bounds.width
            let p = (n - w) / w
            let progress = (CGFloat(self.currentPage) + p) / CGFloat(pagesCount - 1)
            
            self.pageProgress = p
            self.fullProgress = progress
            self.pageOffsetChanged(p, progress, isForward)
        }
        return vc
    }

    func updateUIViewController(_ pageViewController: PageVC, context: Context) {
//        let vc = [controllers[currentPage]]
//        pageViewController.setViewControllers(vc, direction: .forward, animated: true)
//        let scrollView = pageViewController.view.subviews.compactMap { $0 as? UIScrollView }.first
//        let x = pageProgress * pageViewController.view.frame.width
//        pageViewController.shouldHandleScrollEvents = false
//        scrollView?.contentOffset = CGPoint(x: x, y: 0)
//        pageViewController.shouldHandleScrollEvents = true
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


final class PageVC: UIPageViewController {
    
    var offsetDidChanged: (_ scrollView: UIScrollView, _ old: CGPoint, _ new: CGPoint) -> Void = { _, _, _ in }
    private var observer: NSKeyValueObservation?
    fileprivate var shouldHandleScrollEvents: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let scrollView = view.subviews.compactMap({ $0 as? UIScrollView }).first else { return }
        observer = scrollView.observe(\.contentOffset, options: [.old, .new]) { [unowned self] (sv, observer) in
            guard self.shouldHandleScrollEvents else { return }
            guard let old = observer.oldValue, let new = observer.newValue else { return }
            self.offsetDidChanged(sv, old, new)
        }
    }
}
