import Foundation
import Combine
import BlocksModels
import UIKit
import FloatingPanel
import SwiftUI

protocol ObjectSettingswModelOutput: AnyObject {
    func undoRedoAction()
    func layoutPickerAction()
    func coverPickerAction()
    func iconPickerAction()
    func relationsAction()
}

final class ObjectSettingsViewModel: ObservableObject, Dismissible {
    var onDismiss: () -> Void = {} {
        didSet {
            objectActionsViewModel.dismissSheet = onDismiss
        }
    }
    
    var settings: [ObjectSetting] {
        guard let details = document.details else { return [] }
        return settingsBuilder.build(
            details: details,
            restrictions: objectActionsViewModel.objectRestrictions,
            isLocked: document.isLocked
        )
    }
    
    let objectActionsViewModel: ObjectActionsViewModel

    private weak var router: EditorRouterProtocol?
    private let document: BaseDocumentProtocol
    private let objectDetailsService: DetailsServiceProtocol
    private let settingsBuilder = ObjectSettingBuilder()
    
    private var subscription: AnyCancellable?
    private weak var output: ObjectSettingswModelOutput?
    
    init(
        document: BaseDocumentProtocol,
        objectDetailsService: DetailsServiceProtocol,
        router: EditorRouterProtocol,
        output: ObjectSettingswModelOutput
    ) {
        self.document = document
        self.objectDetailsService = objectDetailsService
        self.router = router
        self.output = output
        
        self.objectActionsViewModel = ObjectActionsViewModel(
            objectId: document.objectId,
            undoRedoAction: { [weak output] in
                output?.undoRedoAction()
            },
            openPageAction: { [weak router] screenData in
                router?.showPage(data: screenData)
            }
        )

        objectActionsViewModel.onLinkItselfAction = { [weak router] onSelect in
            router?.showLinkTo(onSelect: onSelect)
        }
        
        setupSubscription()
        onDocumentUpdate()
    }

    func onTapLayoutPicker() {
        output?.layoutPickerAction()
    }
    
    func onTapIconPicker() {
        output?.iconPickerAction()
    }
    
    func onTapCoverPicker() {
        output?.coverPickerAction()
    }
    
    func showRelations() {
        output?.relationsAction()
    }
    
    // MARK: - Private
    private func setupSubscription() {
        subscription = document.updatePublisher.sink { [weak self] _ in
            self?.onDocumentUpdate()
        }
    }
    
    private func onDocumentUpdate() {
        objectWillChange.send()
        if let details = document.details {
            objectActionsViewModel.details = details
        }
        objectActionsViewModel.isLocked = document.isLocked
        objectActionsViewModel.objectRestrictions = document.objectRestrictions
    }
}
