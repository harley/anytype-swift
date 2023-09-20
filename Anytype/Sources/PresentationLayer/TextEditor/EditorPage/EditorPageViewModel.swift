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
    
    lazy var subscriptions = [AnyCancellable]()

    private let activeWorkpaceStorage: ActiveWorkpaceStorageProtocol

    // MARK: - Initialization
    init(
        document: BaseDocumentProtocol,
        viewInput: EditorPageViewInput,
        router: EditorRouterProtocol,
        modelsHolder: EditorMainItemModelsHolder,
        blockBuilder: BlockViewModelBuilder,
        actionHandler: BlockActionHandler,
        headerModel: ObjectHeaderViewModel,
        blocksStateManager: EditorPageBlocksStateManagerProtocol,
        cursorManager: EditorCursorManager,
        objectActionsService: ObjectActionsServiceProtocol,
        searchService: SearchServiceProtocol,
        editorPageTemplatesHandler: EditorPageTemplatesHandlerProtocol,
        accountManager: AccountManagerProtocol,
        configuration: EditorPageViewModelConfiguration,
        templatesSubscriptionService: TemplatesSubscriptionServiceProtocol,
        activeWorkpaceStorage: ActiveWorkpaceStorageProtocol
    ) {
        self.viewInput = viewInput
        self.document = document
        self.router = router
        self.modelsHolder = modelsHolder
        self.blockBuilder = blockBuilder
        self.actionHandler = actionHandler
        self.headerModel = headerModel
        self.blocksStateManager = blocksStateManager
        self.cursorManager = cursorManager
        self.objectActionsService = objectActionsService
        self.searchService = searchService
        self.editorPageTemplatesHandler = editorPageTemplatesHandler
        self.accountManager = accountManager
        self.configuration = configuration
        self.templatesSubscriptionService = templatesSubscriptionService
        self.activeWorkpaceStorage = activeWorkpaceStorage

        setupLoadingState()
    }
    
    func setupSubscriptions() {
        subscriptions = []
        
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
            guard let self else { return }
            let filtered = Set(blockIds).intersection(modelsHolder.blocksMapping.keys)
            
            let items = blockBuilder.buildEditorItems(infos: Array(filtered))
            viewInput?.reconfigure(items: items)
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
//            cursorManager.applyCurrentFocus()
            
            if !document.isLocked {
                cursorManager.handleGeneralUpdate(with: modelsHolder.items, type: document.details?.type)
            }
        }

//        cursorManager.applyCurrentFocus(shouldInvalidateFocus: false)
        
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
            guard !document.isLocked, let details = document.details, details.isSelectTemplate else {
                await templatesSubscriptionService.stopSubscription()
                viewInput?.update(details: document.details, templatesCount: 0)
                return
            }
            
            await templatesSubscriptionService.startSubscription(
                objectType: details.type,
                spaceId: document.spaceId
            ) { [weak self] details in
                guard let self else { return }
                viewInput?.update(details: document.details, templatesCount: details.count)
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
                router.showOpenDocumentError(error: error)
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
        Task {
            try await activeWorkpaceStorage.setActiveSpace(spaceId: document.spaceId)
        }
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
        router.showTemplatesPicker()
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
