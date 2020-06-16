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
    
    enum Position {
        case next
        case current
        case previous
    }
    
    @Binding var currentPage: Int

    private let controllers: [UIViewController]
    private let orientation: UIPageViewController.NavigationOrientation
    private let controllerWillChange: (_ previous: Int, _ current: Int) -> Void
    private let controllerDidChange: (_ previous: Int, _ current: Int) -> Void
    
    init(controllers: [UIViewController],
         currentPage: Binding<Int>,
         orientation: UIPageViewController.NavigationOrientation = .horizontal,
         controllerWillChange: @escaping (_ previous: Int, _ current: Int) -> Void = { _,_ in },
         controllerDidChange: @escaping (_ previous: Int, _ current: Int) -> Void = { _,_ in }) {
        
        self.controllers = controllers
        self._currentPage = currentPage
        self.orientation = orientation
        self.controllerWillChange = controllerWillChange
        self.controllerDidChange = controllerDidChange
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: orientation)
        vc.dataSource = context.coordinator
        vc.delegate = context.coordinator
        vc.view.backgroundColor = .clear
        return vc
    }

    func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
        pageViewController.setViewControllers(
            [controllers[currentPage]], direction: .forward, animated: true)
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
