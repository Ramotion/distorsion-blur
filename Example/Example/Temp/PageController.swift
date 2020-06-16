//
//  PageController.swift
//  Example
//
//  Created by Igor K. on 15.06.2020.
//  Copyright © 2020 Ramotion. All rights reserved.
//

import Foundation
import SwiftUI

struct PageController: UIViewControllerRepresentable {
    
    enum Position {
        case next
        case current
        case previous
    }
    
    private let pageBuilder: (_ index: Int, _ position: Position) -> UIViewController?
    private let controllerWillChange: (_ previous: Int, _ current: Int) -> Void
    private let controllerDidChange: (_ previous: Int, _ current: Int) -> Void
    
    private let vc: UIPageViewController
    private let currentIndex: Binding<Int>
    
    init(currentIndex: Binding<Int>,
         orientation: UIPageViewController.NavigationOrientation = .horizontal,
         controllerWillChange: @escaping (_ previous: Int, _ current: Int) -> Void = { _,_ in },
         controllerDidChange: @escaping (_ previous: Int, _ current: Int) -> Void = { _,_ in },
         pageBuilder: @escaping (Int, Position) -> UIViewController?) {
        
        self.vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: orientation)
        self.currentIndex = currentIndex
        self.pageBuilder = pageBuilder
        self.controllerWillChange = controllerWillChange
        self.controllerDidChange = controllerDidChange
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(controller: self)
    }

    func makeUIViewController(context: Context) -> UIPageViewController {
        vc.dataSource = context.coordinator
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
        //let scrollView = vc.view.subviews.compactMap { $0 as? UIScrollView }.first
        context.coordinator.setIndex(currentIndex.wrappedValue)
    }
    
    final class Coordinator: NSObject, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
        
        private let parent: PageController
        private var currentVC: UIViewController?
        
        private var currentIndex: Int {
            get { return parent.currentIndex.wrappedValue }
            set { DispatchQueue.main.async { self.parent.currentIndex.wrappedValue = newValue } }
        }
        
        init(controller: PageController) {
            self.parent = controller
        }
        
        
        //MARK: - Page view controller data source methods
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            
            return controller(for: viewController.pageIndex - 1, position: .previous)
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            
            return controller(for: viewController.pageIndex + 1, position: .next)
        }
        
        
        //MARK: - Page view controller delegate methods    
        func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
            guard let vc = pendingViewControllers.first else { return }
            parent.controllerWillChange(currentIndex, vc.pageIndex)
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            guard completed, let controller = pageViewController.viewControllers?.first else { return }
            
            let previousIndex = currentIndex
            currentIndex = controller.pageIndex
            parent.controllerDidChange(previousIndex, currentIndex)
        }
        
        //MARK: - Actions
        func reload() {
            setIndex(0)
        }

        func setIndex(_ index: Int, animated: Bool = false) {
            let direction: UIPageViewController.NavigationDirection = index >= currentIndex ? .forward : .reverse
            self.setIndex(index, direction: direction, animated: animated)
        }

        func setIndex(_ index: Int, direction: UIPageViewController.NavigationDirection, animated: Bool = false) {
            let previousIndex = currentIndex
            parent.controllerWillChange(previousIndex, index)
            currentIndex = index
            currentVC = controller(for: currentIndex, position: .current)
            let controllers = [currentVC].compactMap { $0 }
            parent.vc.setViewControllers(controllers, direction: direction, animated: animated, completion: nil)
            parent.controllerDidChange(previousIndex, currentIndex)
        }
        
        private func controller(for index: Int, position: Position) -> UIViewController? {
            guard let vc = parent.pageBuilder(index, position) else { return nil }
            vc.pageIndex = index
            return vc
        }
    }
}


//MARK: - Utilities
private extension UIViewController {
    static var pageIndexKey: Int = 0
    
    var pageIndex: Int {
        get { return getAssociatedObject(&UIViewController.pageIndexKey) ?? 0 }
        set { setAssociatedObject(&UIViewController.pageIndexKey, newValue) }
    }
}
