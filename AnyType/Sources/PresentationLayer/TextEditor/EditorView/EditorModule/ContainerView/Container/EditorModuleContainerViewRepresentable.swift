import Foundation
import SwiftUI
import Combine
import os

struct EditorModuleContainerViewRepresentable: UIViewControllerRepresentable {
    private(set) var documentId: String
    private(set) var shouldShowDocument: Binding<Bool> = .init(get: { false }, set: { value in })
    
    func makeCoordinator() -> Coordinator {
        .init(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<EditorModuleContainerViewRepresentable>) -> EditorModuleContainerViewController {
        let view = EditorModuleContainerViewBuilder.view(id: documentId)
        
        // TODO: Fix later.
        // We should enable back button handling.
        /// Subscribe `coordinator` on events from `view.headerView`.
        /// TODO: Add back button here.
//        _ = context.coordinator.configured(headerViewModelPublisher: view.headerViewModelPublisher)
        
        context.coordinator.configured(userActionStream: view.userActionPublisher)
        
        return view
    }
    
    func updateUIViewController(_ uiViewController: EditorModuleContainerViewController, context: UIViewControllerRepresentableContext<EditorModuleContainerViewRepresentable>) {
        // our model did change?
        // should we do something?
        // well, we should calculate diffs.
        // But not now.
        // later.
        
        // Do we need to reload table view data here?
        //        DispatchQueue.main.async {
        //            uiViewController.tableView?.tableView.reloadData()
        //        }
    }
    
    class Coordinator {
        typealias Parent = EditorModuleContainerViewRepresentable
        typealias IncomingAction = EditorModuleContainerViewController.UserAction
        
        // MARK: Variables
        private var parent: Parent
        private var subscription: AnyCancellable?
        
        // MARK: Initialization
        init(_ parent: Parent) {
            self.parent = parent
        }
        
        /// Subscription
        func configured(userActionStream: AnyPublisher<IncomingAction, Never>) {
            self.subscription = userActionStream.sink(receiveValue: { [weak self] (value) in
                switch value {
                case .shouldDismiss: self?.dismiss()
                }
            })
        }
        
        /// Do dismiss
        func dismiss() {
            self.parent.shouldShowDocument.wrappedValue = false
        }
    }
}

