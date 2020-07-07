//
//  DocumentModule+ContainerViewBuilder.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 01.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

fileprivate typealias Namespace = DocumentModule

extension Namespace {
    /// This is a builder for Namespace.ContainerViewController. (DocumentModule.ContainerViewController)
    /// It provides several builders which could build both `SwiftUI` (`SwiftUIBuilder`) and `UIKit` (`UIKitBuilder`) components.
    ///
    enum ContainerViewBuilder {
        struct Request {
            typealias Id = String            
            var id: Id
            
            fileprivate var documentRequest: DocumentModule.ContentViewBuilder.Request {
                .init(documentRequest: .init(id: self.id))
            }
        }
    }
}

extension Namespace.ContainerViewBuilder {
    /// `SwiftUI` builder.
    /// It builds component for `SwiftUI`.
    enum SwiftUIBuilder {
        private typealias CurrentViewRepresentable = Namespace.ContainerViewRepresentable
        private static func create(by request: Request) -> AnyView {
            .init(CurrentViewRepresentable.create(documentId: request.id))
        }
        
        private static func create(by request: Request, shouldShowDocument: Binding<Bool>) -> AnyView {
            .init(CurrentViewRepresentable.create(documentId: request.id, shouldShowDocument: shouldShowDocument))
        }

        static func documentView(by request: Request) -> some View {
            self.create(by: request)
        }
        
        static func documentView(by request: Request, shouldShowDocument: Binding<Bool>) -> some View {
            self.create(by: request, shouldShowDocument: shouldShowDocument)
        }
    }
}

extension Namespace.ContainerViewBuilder {
    /// `UIKit` builder.
    /// It builds component for `UIKit`.
    enum UIKitBuilder {
        /// We have the following system.
        /// Builder has two kind of components: Self and Child.
        /// You have an access to both components through `SelfComponent` and `ChildComponent`.
        /// We don't have a type erasure here ( we don't want to ).
        ///
        /// Next, typealiases to `Child` components ( `ChildViewModel`, `ChildViewController`, `ChildViewBuilder` ) have prefix `Child`.
        ///
        /// But, typealiases to `Self` components ( `ViewModel`, `ViewController`, `SelfComponent` ) may not have prefix `Self`.
        ///
        /// Interesting part is `SelfComponent`.
        /// `SelfComponent` is a triple `(ViewController, ViewModel, ChildComponent)`.
        ///
        /// It allows us to access to child of child of views to configure them on any level if we want to.
        ///
        ///
        typealias ViewModel = DocumentModule.ContainerViewController.ViewModel
        typealias ViewController = DocumentModule.ContainerViewController
        
        typealias ChildViewModel = DocumentModule.ContentViewController.ViewModel
        typealias ChildViewController = DocumentModule.ContentViewController
        typealias ChildViewBuilder = DocumentModule.ContentViewBuilder
        
        typealias ChildComponent = ChildViewBuilder.UIKitBuilder.SelfComponent
        typealias SelfComponent = (ViewController, ViewModel, ChildComponent)
        
        /// Returns `ChildComponent` for request in concrete builder. It uses `ChildViewBuilder.UIKitBuilder.selfComponent(by:)` method.
        /// For us `childComponent` is a `selfComponent` of `ChildViewBuilder` or `ChildViewBuilder.UIKitBuilder.selfComponent(by:)`
        /// - Parameter request: A request for which we will build child component.
        /// - Returns: A child component for a request.
        ///
        static func childComponent(by request: Request) -> ChildComponent {
            ChildViewBuilder.UIKitBuilder.selfComponent(by: request.documentRequest)
        }
        
        /// Return `SelfComponent` for request in concrete builder.
        /// For us `selfComponent` is a target for this builder. It access childComponent to configure it by entities on this level.
        ///
        /// For example, if you want connect user actions which are coming from internal view, you need access to it on level of builder.
        /// It will be `childComponent` or `childChildComponent` ( a.k.a. `ChildViewBuilder.UIKitBuilder.ChildComponent` )
        ///
        /// - Parameter request: A request for which we will build self component.
        /// - Returns: A self component for a request.
        ///
        static func selfComponent(by request: Request) -> SelfComponent {
            let childComponent = self.childComponent(by: request)
            
            let childViewController = childComponent.0
            
            /// Configure Navigation Controller
            let navigationController: UINavigationController = .init(navigationBarClass: Namespace.ContainerViewBuilder.NavigationBar.self, toolbarClass: nil)
            NavigationBar.applyAppearance()
            navigationController.setViewControllers([childViewController], animated: false)
            
            /// Configure Navigation Item for Content View Model.
            /// We need it to support Selection navigation bar buttons.
            let childViewModel = childComponent.1
            _ = childViewModel.configured(navigationItem: childViewController.navigationItem)
            
            let childChildComponent = childComponent.2
            let childChildViewModel = childChildComponent.1
            
            /// Don't forget configure router by events from blocks.
            let router: DocumentViewRouting.CompoundRouter = .init()
            _ = router.configured(userActionsStream: childChildViewModel.soloUserActionPublisher)
            
            /// Configure ViewModel of current View Controller.
            let viewModel: ViewModel = .init()
            _ = viewModel.configured(router: router)
            
            /// Configure current ViewController.
            let viewController: ViewController = .init(viewModel: viewModel)
            _ = viewController.configured(childViewController: navigationController)
            
            /// Configure navigation item of root
            childViewController.navigationItem.leftBarButtonItem = .init(title: "Dismiss", style: .plain, target: viewController, action: #selector(viewController.dismissAction))
            
            /// DEBUG: Conformance to navigation delegate.
            ///
            navigationController.delegate = viewController
            
            return (viewController, viewModel, childComponent)
        }
        
        static func view(by request: Request) -> ViewController {
            self.selfComponent(by: request).0
        }
    }
}

// MARK: Custom Appearance
/// TODO: Move it somewhere
private extension Namespace.ContainerViewBuilder {
    class NavigationBar: UINavigationBar {
        static func applyAppearance() {
            let appearance = Self.appearance()
            appearance.prefersLargeTitles = false
            appearance.tintColor = .orange
            appearance.backgroundColor = .white
        }
    }
}
