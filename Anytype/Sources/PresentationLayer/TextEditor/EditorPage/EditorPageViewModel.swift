import Foundation
import SwiftUI
import Combine
import os
import Services
import AnytypeCore

final class EditorPageViewModel: EditorPageViewModelProtocol {
    weak private(set) var viewInput: EditorPageViewInput?
    
    let blocksStateManager: EditorPageBlocksStateManagerProtocol
    
    let document: BaseDocumentProtocol
    let modelsHolder: EditorMainItemModelsHolder
    let blockDelegate: BlockDelegate
    
    let router: EditorRouterProtocol
    
    let actionHandler: BlockActionHandlerProtocol
    let objectActionsService: ObjectActionsServiceProtocol
    
    private let searchService: SearchServiceProtocol
    private let cursorManager: EditorCursorManager
    private let blockBuilder: BlockViewModelBuilder
    private let headerModel: ObjectHeaderViewModel
    private let editorPageTemplatesHandler: EditorPageTemplatesHandlerProtocol
    private let accountManager: AccountManagerProtocol
    private let configuration: EditorPageViewModelConfiguration
    
    private let templatesSubscriptionService: TemplatesSubscriptionServiceProtocol
    private var availableTemplates = [ObjectDetails]()
    
    private lazy var subscriptions = [AnyCancellable]()
    
    private let blockActionsService: BlockActionsServiceSingleProtocol
    
    // MARK: - Initialization
    init(
        document: BaseDocumentProtocol,
        viewInput: EditorPageViewInput,
        blockDelegate: BlockDelegate,
        router: EditorRouterProtocol,
        modelsHolder: EditorMainItemModelsHolder,
        blockBuilder: BlockViewModelBuilder,
        actionHandler: BlockActionHandler,
        headerModel: ObjectHeaderViewModel,
        blockActionsService: BlockActionsServiceSingleProtocol,
        blocksStateManager: EditorPageBlocksStateManagerProtocol,
        cursorManager: EditorCursorManager,
        objectActionsService: ObjectActionsServiceProtocol,
        searchService: SearchServiceProtocol,
        editorPageTemplatesHandler: EditorPageTemplatesHandlerProtocol,
        accountManager: AccountManagerProtocol,
        configuration: EditorPageViewModelConfiguration,
        templatesSubscriptionService: TemplatesSubscriptionServiceProtocol
    ) {
        self.viewInput = viewInput
        self.document = document
        self.router = router
        self.modelsHolder = modelsHolder
        self.blockBuilder = blockBuilder
        self.actionHandler = actionHandler
        self.blockDelegate = blockDelegate
        self.headerModel = headerModel
        self.blockActionsService = blockActionsService
        self.blocksStateManager = blocksStateManager
        self.cursorManager = cursorManager
        self.objectActionsService = objectActionsService
        self.searchService = searchService
        self.editorPageTemplatesHandler = editorPageTemplatesHandler
        self.accountManager = accountManager
        self.configuration = configuration
        self.templatesSubscriptionService = templatesSubscriptionService
        setupLoadingState()
    }
    
    func setupSubscriptions() {
        subscriptions = []
        
        //        document.updatePublisher.sink { [weak self] in
        //            self?.handleUpdate(updateResult: $0)
        //        }.store(in: &subscriptions)
        
        document.syncStatus.sink { [weak self] status in
            self?.viewInput?.update(syncStatus: status)
        }.store(in: &subscriptions)
        
        document.flattenBlockIds.receiveOnMain().sink { [weak self] ids in
            print("Hello debug \(ids)")
            self?.handleUpdate(ids: ids)
        }.store(in: &subscriptions)
        
        headerModel.$header.sink { [weak self] value in
            guard let headerModel = value else { return }
            self?.updateHeaderIfNeeded(headerModel: headerModel)
        }.store(in: &subscriptions)
        
        document.resetBlocksSubject.sink { [weak self] blockIds in
            guard let items = self?.blockBuilder.buildEditorItems(infos: Array(blockIds)) else {
                return
            }
            self?.viewInput?.reloadItems(items: items)
        }.store(in: &subscriptions)
    }
    
    private func setupLoadingState() {
        let shimmeringBlockViewModel = blockBuilder.buildShimeringItem()
        
        viewInput?.update(
            changes: nil,
            allModels: [shimmeringBlockViewModel],
            completion: { }
        )
    }
    
    private func handleUpdate(ids: [BlockId]) {        
        let blocksViewModels = blockBuilder.buildEditorItems(infos: ids)
        
        
        let difference = modelsHolder.difference(between: blocksViewModels)
        if difference.insertions.isNotEmpty {
            modelsHolder.applyDifference(difference: difference)
        } else {
            modelsHolder.items = blocksViewModels
        }
        
        guard document.isOpened else { return }
        
        viewInput?.update(changes: difference, allModels: modelsHolder.items) { [weak self] in
            guard let self else { return }
            updateCursorIfNeeded()
            
            if !document.isLocked {
                cursorManager.handleGeneralUpdate(with: modelsHolder.items, type: document.details?.type)
            }
        }
        
        
        //        switch updateResult {
        //
        //        case .general:
        //            performGeneralUpdate()
        //
        //        case let .details(id):
        //            guard id == document.objectId else {
        //                performGeneralUpdate()
        //                return
        //            }
        //
        //            let allRelationsBlockViewModel = modelsHolder.items.allRelationViewModel
        //            let relationIds = allRelationsBlockViewModel.map(\.blockId)
        //            let diffrerence = difference(with: Set(relationIds))
        //
        //            guard !diffrerence.isEmpty else { return }
        //            modelsHolder.applyDifference(difference: diffrerence)
        //
        //            guard document.isOpened else { return }
        //            viewInput?.update(changes: diffrerence, allModels: modelsHolder.items)
        //        case let .blocks(updatedIds):
        //            guard !updatedIds.isEmpty else {
        //                return
        //            }
        //
        //            let diffrerence = difference(with: updatedIds)
        //
        //            modelsHolder.applyDifference(difference: diffrerence)
        //
        //            guard document.isOpened else { return }
        //            viewInput?.update(changes: diffrerence, allModels: modelsHolder.items)
        //
        //            updateCursorIfNeeded()
        //        case .syncStatus(let status):
        //            viewInput?.update(syncStatus: status)
        //        case .dataSourceUpdate:
        //            let models = document.children
        //
        //            let items = blockBuilder.buildEditorItems(infos: models)
        //            modelsHolder.items = items
        //        }
        
        if !configuration.isOpenedForPreview {
            blocksStateManager.checkDocumentLockField()
        }
    }


    private func difference(
        with blockIds: Set<BlockId>
    ) -> CollectionDifference<EditorItem> {
        var currentModels = modelsHolder.items
        
        for (offset, model) in modelsHolder.items.enumerated() {
            guard case let .block(blockViewModel) = model else { continue }
            for blockId in blockIds {
                
                if blockViewModel.blockId == blockId {
                    guard let newViewModel = blockBuilder.build(id: blockId) else {
                        continue
                    }
                    
                    currentModels[offset] = .block(newViewModel)
                }
            }
        }
        
        return modelsHolder.difference(between: currentModels)
    }
    
    private func updateCursorIfNeeded() {
        DispatchQueue.main.async { [unowned self] in 
            cursorManager.applyCurrentFocus()
        }
        
    }
    
    // iOS 14 bug fix applying header section while editing
    private func updateHeaderIfNeeded(headerModel: ObjectHeader) {
        guard modelsHolder.header != headerModel else {
            return
        }

        viewInput?.update(header: headerModel)
        modelsHolder.header = headerModel
    }
    
    private func handleTemplatesIfNeeded() {
        Task { @MainActor in
            guard !document.isLocked, configuration.shouldShowTemplateSelection,
                  let details = document.details, details.isSelectTemplate else {
                await templatesSubscriptionService.stopSubscription()
                viewInput?.update(details: document.details, templatesCount: 0)
                return
            }
            
            await templatesSubscriptionService.startSubscription(
                objectType: details.type,
                spaceId: document.spaceId
            ) { [weak self] details in
                guard let self else { return }
                availableTemplates = details
                viewInput?.update(details: document.details, templatesCount: availableTemplates.count)
            }
        }
    }
}

// MARK: - View output

extension EditorPageViewModel {
    func viewDidLoad() {
        
        blocksStateManager.checkOpenedState()
        
        Task { @MainActor in
            do {
                if configuration.isOpenedForPreview {
                    try await document.openForPreview()
                } else {
                    try await document.open()
                    blocksStateManager.checkOpenedState()
                }
            } catch {
                router.closeEditor()
            }
            
            if let objectDetails = document.details {
                AnytypeAnalytics.instance().logShowObject(type: objectDetails.analyticsType, layout: objectDetails.layoutValue)
            }
        }
    }
    
    func viewWillAppear() { }
    
    func viewDidAppear() {
        // document. simulate general update
        
        cursorManager.didAppeared(with: modelsHolder.items, type: document.details?.type)
    }
    
    func viewWillDisappear() {}
    
    func viewDidDissapear() {}
    
    func shakeMotionDidAppear() {
        router.showAlert(
            alertModel: .undoAlertModel(
                undoAction: { [weak self] in
                    guard let self = self else { return }
                    Task {
                        try await self.objectActionsService.undo(objectId: self.document.objectId)
                    }
                }
            )
        )
    }
}

// MARK: - Selection Handling

extension EditorPageViewModel {
    func didSelectBlock(at indexPath: IndexPath) {
        element(at: indexPath)?
            .didSelectRowInTableView(editorEditingState: blocksStateManager.editingState)
    }
    
    func didFinishEditing(blockId: BlockId) {
        if blockId == BundledRelationKey.description.rawValue {
            AnytypeAnalytics.instance().logSetObjectDescription()
        }
    }
    
    func element(at: IndexPath) -> BlockViewModelProtocol? {
        modelsHolder.blockViewModel(at: at.row)
    }
    
    func handleSettingsAction(action: ObjectSettingsAction) {
        switch action {
        case .cover(let objectCoverPickerAction):
            headerModel.handleCoverAction(action: objectCoverPickerAction)
        case .icon(let objectIconPickerAction):
            headerModel.handleIconAction(action: objectIconPickerAction)
        }
    }
}

extension EditorPageViewModel {
    
    func showSettings() {
        router.showSettings { [weak self] action in
            self?.handleSettingsAction(action: action)
        }
    }
    
    @MainActor
    func showTemplates() {
        router.showTemplatesPicker(availableTemplates: availableTemplates)
    }
}

// Cursor
extension EditorPageViewModel {
    func cursorFocus(blockId: BlockId) {
        cursorManager.restoreLastFocus(at: blockId)
    }
}

// MARK: - Debug

extension EditorPageViewModel: CustomDebugStringConvertible {
    var debugDescription: String {
        "\(Unmanaged.passUnretained(self).toOpaque()) -> \(String(reflecting: Self.self)) -> \(String(describing: document.objectId))"
    }
}
