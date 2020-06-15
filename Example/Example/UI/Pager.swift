//
//  Pager.swift
//  Example
//
//  Created by Igor K. on 15.06.2020.
//  Copyright © 2020 Ramotion. All rights reserved.
//

import Foundation
import SwiftUI

struct Pager<Content: View>: UIViewRepresentable {
    
    enum Position {
        case next
        case current
        case previous
    }
    
    private let pageBuilder: (_ index: Int, _ position: Position) -> Content?
    private let controllerWillChange: (_ previous: Int, _ current: Int) -> Void
    private let controllerDidChange: (_ previous: Int, _ current: Int) -> Void
    
    private let vc: UIPageViewController
    private let currentIndex: Binding<Int>
    
    init(currentIndex: Binding<Int>,
         @ViewBuilder pageBuilder: @escaping (Int, Position) -> Content?,
         direction: UIPageViewController.NavigationOrientation = .horizontal,
         controllerWillChange: @escaping (_ previous: Int, _ current: Int) -> Void = { _,_ in },
         controllerDidChange: @escaping (_ previous: Int, _ current: Int) -> Void = { _,_ in }) {
        
        self.currentIndex = currentIndex
        self.pageBuilder = pageBuilder
        self.controllerWillChange = controllerWillChange
        self.controllerDidChange = controllerDidChange
        self.vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: direction, options: nil)
    }
    
    func makeUIView(context: UIViewRepresentableContext<Pager>) -> UIView {
        vc.view.backgroundColor = .white
        return vc.view
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<Pager>) {
        //let scrollView = vc.view.subviews.compactMap { $0 as? UIScrollView }.first
    }
    
    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(container: self)
        vc.delegate = coordinator
        vc.dataSource = coordinator
        return coordinator
    }
    
    final class Coordinator: NSObject, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
        
        private let container: Pager
        private var currentVC: UIViewController?
        
        private var currentIndex: Int {
            get { return container.currentIndex.wrappedValue }
            set { container.currentIndex.wrappedValue = newValue }
        }
        
        init(container: Pager) {
            self.container = container
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
            container.controllerWillChange(currentIndex, vc.pageIndex)
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            guard completed, let controller = pageViewController.viewControllers?.first else { return }
            
            let previousIndex = currentIndex
            currentIndex = controller.pageIndex
            container.controllerDidChange(previousIndex, currentIndex)
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
            container.controllerWillChange(previousIndex, index)
            currentIndex = index
            currentVC = controller(for: currentIndex, position: .current)
            let controllers = [currentVC].compactMap { $0 }
            container.vc.setViewControllers(controllers, direction: direction, animated: animated, completion: nil)
            container.controllerDidChange(previousIndex, currentIndex)
        }
        
        private func controller(for index: Int, position: Position) -> UIViewController? {
            guard let content = container.pageBuilder(index, position) else { return nil }
            let vc = UIHostingController(rootView: content)
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
