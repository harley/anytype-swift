import Services
import Combine
import UniformTypeIdentifiers
import AnytypeCore

final class BlockViewModelBuilder {
    private let document: BaseDocumentProtocol
    private let handler: BlockActionHandlerProtocol
    private let pasteboardService: PasteboardServiceProtocol
    private let router: EditorRouterProtocol
    private let delegate: BlockDelegate
    private let subjectsHolder: FocusSubjectsHolder
    private let markdownListener: MarkdownListener
    private let simpleTableDependenciesBuilder: SimpleTableDependenciesBuilder
    private let pageService: PageRepositoryProtocol
    private let detailsService: DetailsServiceProtocol
    private let audioSessionService: AudioSessionServiceProtocol
    private let infoContainer: InfoContainerProtocol
    private let tableService: BlockTableServiceProtocol
    private let objectTypeProvider: ObjectTypeProviderProtocol
    private let modelsHolder: EditorMainItemModelsHolder
    private let blockCollectionController: EditorBlockCollectionController
    private let accessoryStateManager: AccessoryViewStateManager
    private let cursorManager: EditorCursorManager
    private let keyboardActionHandler: KeyboardActionHandlerProtocol
    private let editorPageBlocksStateManager: EditorPageBlocksStateManager
    
    private let linkToObjectCoordinator: LinkToObjectCoordinatorProtocol
    private let markupChanger: BlockMarkupChangerProtocol
    private let slashMenuActionHandler: SlashMenuActionHandler
    
    init(
        document: BaseDocumentProtocol,
        handler: BlockActionHandlerProtocol,
        pasteboardService: PasteboardServiceProtocol,
        router: EditorRouterProtocol,
        delegate: BlockDelegate,
        markdownListener: MarkdownListener,
        simpleTableDependenciesBuilder: SimpleTableDependenciesBuilder,
        subjectsHolder: FocusSubjectsHolder,
        pageService: PageRepositoryProtocol,
        detailsService: DetailsServiceProtocol,
        audioSessionService: AudioSessionServiceProtocol,
        infoContainer: InfoContainerProtocol,
        tableService: BlockTableServiceProtocol,
        objectTypeProvider: ObjectTypeProviderProtocol,
        modelsHolder: EditorMainItemModelsHolder,
        blockCollectionController: EditorBlockCollectionController,
        accessoryStateManager: AccessoryViewStateManager,
        cursorManager: EditorCursorManager,
        keyboardActionHandler: KeyboardActionHandlerProtocol,
        linkToObjectCoordinator: LinkToObjectCoordinatorProtocol,
        markupChanger: BlockMarkupChangerProtocol,
        slashMenuActionHandler: SlashMenuActionHandler,
        editorPageBlocksStateManager: EditorPageBlocksStateManager
    ) {
        self.document = document
        self.handler = handler
        self.pasteboardService = pasteboardService
        self.router = router
        self.delegate = delegate
        self.markdownListener = markdownListener
        self.simpleTableDependenciesBuilder = simpleTableDependenciesBuilder
        self.subjectsHolder = subjectsHolder
        self.pageService = pageService
        self.detailsService = detailsService
        self.audioSessionService = audioSessionService
        self.infoContainer = infoContainer
        self.tableService = tableService
        self.objectTypeProvider = objectTypeProvider
        self.modelsHolder = modelsHolder
        self.blockCollectionController = blockCollectionController
        self.accessoryStateManager = accessoryStateManager
        self.cursorManager = cursorManager
        self.keyboardActionHandler = keyboardActionHandler
        self.linkToObjectCoordinator = linkToObjectCoordinator
        self.markupChanger = markupChanger
        self.slashMenuActionHandler = slashMenuActionHandler
        self.editorPageBlocksStateManager = editorPageBlocksStateManager
    }
    
    func buildEditorItems(infos: [BlockId]) -> [EditorItem] {
        let blockViewModels = build(infos)
        
        
        var editorItems = blockViewModels.map (EditorItem.block)
        
        let featureRelationsIndex = blockViewModels.firstIndex { $0.content == .featuredRelations }
        
        if let featureRelationsIndex = featureRelationsIndex {
            let spacer = SpacerBlockViewModel(usage: .firstRowOffset)
            editorItems.insert(.system(spacer), at: featureRelationsIndex + 1)
        }
        
        return editorItems
    }
    
    func buildShimeringItem() -> EditorItem {
        let shimmeringViewModel = ShimmeringBlockViewModel()
        
        return .system(shimmeringViewModel)
    }
    
    private func build(_ ids: [BlockId]) -> [BlockViewModelProtocol] {
        ids.compactMap {
            let block = build(id: $0)
            return block
        }
    }
    
    func build(id: BlockId) -> BlockViewModelProtocol? {
        if let model = modelsHolder.blocksMapping[id] {
            return model
        }
        
        guard let info = infoContainer.get(id: id) else {
            return nil
        }
        
        let blockInformationProvider = BlockModelInfomationProvider(infoContainer: infoContainer, info: info)
  
        switch info.content {
        case let .text(content):
            switch content.contentType {
            case .code:
                return CodeBlockViewModel(
                    infoProvider: blockInformationProvider,
                    document: document,
                    becomeFirstResponder: { _ in },
                    handler: handler,
                    editorCollectionController: blockCollectionController,
                    showCodeSelection: { [weak self] info, codeLanguage in
                        self?.router.showCodeLanguage(blockId: info.id, selectedLanguage: codeLanguage)
                    }
                )
            default:
                let textBlockActionHandler = TextBlockActionHandler(
                    info: info,
                    focusSubject: subjectsHolder.focusSubject(for: info.id),
                    showPage: { [weak self] objectId in
                        self?.router.showPage(objectId: objectId)
                    },
                    openURL: { [weak router] url in
                        router?.openUrl(url)
                    },
                    onShowStyleMenu: { [weak self] in
                        self?.editorPageBlocksStateManager.didSelectStyleSelection(infos: [$0])
                    },
                    onEnterSelectionMode: { [weak self] in
                        self?.editorPageBlocksStateManager.didSelectEditingState(info: $0)
                    },
                    showTextIconPicker: { [weak router, weak document] in
                        guard let router, let document else { return }
                        router.showTextIconPicker(
                            contextId: document.objectId,
                            objectId: info.id
                        )
                    },
                    showWaitingView: { [weak router] text in
                        router?.showWaitingView(text: text)
                    },
                    hideWaitingView: {  [weak router] in
                        router?.hideWaitingView()
                    },
                    showURLBookmarkPopup: { [weak router] parameters in
                        router?.showLinkContextualMenu(inputParameters: parameters)
                    },
                    actionHandler: handler,
                    pasteboardService: pasteboardService,
                    markdownListener: markdownListener,
                    collectionController: blockCollectionController,
                    cursorManager: cursorManager,
                    accessoryViewStateManager: accessoryStateManager,
                    keyboardHandler: keyboardActionHandler,
                    linkToObjectCoordinator: linkToObjectCoordinator,
                    markupChanger: markupChanger,
                    slashMenuActionHandler: slashMenuActionHandler
                )
                
                let viewModel = TextBlockViewModel(
                    document: document,
                    blockInformationProvider: blockInformationProvider,
                    stylePublisher: document.detailsPublisher
                        .receiveOnMain()
                        .compactMap { $0.layoutValue == .todo ? .todo : .none }
                        .removeDuplicates()
                        .eraseToAnyPublisher(),
                    actionHandler: textBlockActionHandler,
                    cursorManager: cursorManager
                )
                
                textBlockActionHandler.viewModel = viewModel
                
                return viewModel
            }
        case let .file(content):
            switch content.contentType {
            case .file, .none:
                return BlockFileViewModel(
                    informationProvider: blockInformationProvider,
                    handler: handler,
                    showFilePicker: { [weak self] blockId in
                        self?.showFilePicker(blockId: blockId)
                    },
                    onFileOpen: { [weak router] fileContext in
                        router?.openImage(fileContext)
                    }
                )
            case .image:
                return BlockImageViewModel(
                    blockInformationProvider: blockInformationProvider,
                    handler: handler,
                    showIconPicker: { [weak self] blockId in
                        self?.showMediaPicker(type: .images, blockId: blockId)
                    },
                    onImageOpen: router.openImage
                )
            case .video:
                return VideoBlockViewModel(
                    informantionProvider: blockInformationProvider,
                    audioSessionService: audioSessionService,
                    showVideoPicker: { [weak self] blockId in
                        self?.showMediaPicker(type: .videos, blockId: blockId)
                    }
                )
            case .audio:
                return AudioBlockViewModel(
                    informationProvider: blockInformationProvider,
                    audioSessionService: audioSessionService,
                    showAudioPicker: { [weak self] blockId in
                        self?.showFilePicker(blockId: blockId, types: [.audio])
                    }
                )
            }
        case .divider:
            return DividerBlockViewModel(blockInformationProvider: blockInformationProvider)
        case let .bookmark(data):
            
            let details = document.detailsStorage.get(id: data.targetObjectID)
            
            if details?.isDeleted ?? false {
                return NonExistentBlockViewModel(info: info)
            }
            
            return BlockBookmarkViewModel(
                editorCollectionController: blockCollectionController, objectDetailsProvider: ObjectDetailsInfomationProvider(
                    detailsStorage: document.detailsStorage,
                    targetObjectId: data.targetObjectID,
                    details: details
                ),
                infoProvider: blockInformationProvider,
                showBookmarkBar: { [weak self] info in
                    self?.showBookmarkBar(info: info)
                },
                openUrl: { [weak self] url in
                    AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.blockBookmarkOpenUrl)
                    self?.router.openUrl(url.url)
                }
            )
        case let .link(content):
            guard let details = document.detailsStorage.get(id: content.targetBlockID) else {
                anytypeAssertionFailure(
                    "Couldn't find details for block link", info: ["targetBlockID": content.targetBlockID]
                )
                return nil
            }
            
            return BlockLinkViewModel(
                informationProvider: blockInformationProvider,
                objectDetailsProvider: ObjectDetailsInfomationProvider(
                    detailsStorage: document.detailsStorage,
                    targetObjectId: content.targetBlockID,
                    details: details
                ),
                blocksController: blockCollectionController,
                detailsService: detailsService,
                openLink: { [weak self] data in
                    self?.router.showPage(data: data)
                }
            )
        case .featuredRelations:
            return FeaturedRelationsBlockViewModel(
                infoProvider: blockInformationProvider,
                document: document,
                collectionController: blockCollectionController
            ) { [weak self] relation in
                guard let self = self else { return }
                let bookmarkFilter = self.document.details?.layoutValue != .bookmark
                let allowTypeChange = !self.document.objectRestrictions.objectRestriction.contains(.typechange)
                
                if relation.key == BundledRelationKey.type.rawValue && !self.document.isLocked && bookmarkFilter && allowTypeChange {
                    self.router.showTypes(
                        selectedObjectId: self.document.details?.type,
                        onSelect: { [weak self] type in
                            self?.typeSelected(type)
                        }
                    )
                } else {
                    self.router.showRelationValueEditingView(key: relation.key)
                }
            }
        case let .relation(content):
            let relation = document.parsedRelations.all.first {
                $0.key == content.key
            }

            guard let relation = relation else {
                return nil
            }
            
            return RelationBlockViewModel(
                blockInformationProvider: blockInformationProvider,
                relationProvider: RelationProvider(
                    relation: relation,
                    relationPublisher: document.parsedRelationsPublisher
                ),
                collectionController: blockCollectionController
            ) { [weak self] in
                self?.router.showRelationValueEditingView(key: relation.key)
            }
        case .tableOfContents:
            return TableOfContentsViewModel(
                info: info,
                document: document,
                onTap: { [weak self] blockId in
                    self?.delegate.scrollToBlock(blockId: blockId)
                },
                editorCollectionController: blockCollectionController
            )
        case .smartblock, .layout, .tableRow, .tableColumn, .widget: return nil
        case .table:
            return SimpleTableBlockViewModel(
                info: info,
                simpleTableDependenciesBuilder: simpleTableDependenciesBuilder,
                infoContainer: infoContainer,
                tableService: tableService,
                document: document,
                focusSubject: subjectsHolder.focusSubject(for: info.id)
            )
        case let .dataView(data):
            let objectDetailsProvider = ObjectDetailsInfomationProvider(
                detailsStorage: document.detailsStorage,
                targetObjectId: data.targetObjectID,
                details: document.detailsStorage.get(id: data.targetObjectID)
            )
            
            return DataViewBlockViewModel(
                blockInformationProvider: BlockModelInfomationProvider(
                    infoContainer: infoContainer,
                    info: info
                ),
                objectDetailsProvider: objectDetailsProvider,
                reloadable: blockCollectionController,
                showFailureToast: { [weak self] message in
                    self?.router.showFailureToast(message: message)
                },
                openSet: { [weak self] data in
                    self?.router.showPage(data: data)
                }
            )
        case .unsupported:
            guard let parentId = info.configurationData.parentId,
                  let parent = document.infoContainer.get(id: parentId),
                  parent.content.type != .layout(.header)
            else {
                return nil
            }
            
            return UnsupportedBlockViewModel(info: info)
        }
    }
    
    private func typeSelected(_ type: ObjectType) {
        Task { [weak self] in
            guard let self else { return }
            try await handler.setObjectType(type: type)
            AnytypeAnalytics.instance().logObjectTypeChange(type.analyticsType)
            
            guard let isSelectTemplate = document.details?.isSelectTemplate, isSelectTemplate else { return }
            try await handler.applyTemplate(objectId: document.objectId, templateId: type.defaultTemplateId)
        }
    }
    // MARK: - Actions
    
    private var subscriptions = [AnyCancellable]()
    
    private func showMediaPicker(type: MediaPickerContentType, blockId: BlockId) {
        router.showImagePicker(contentType: type) { [weak self] itemProvider in
            guard let itemProvider = itemProvider else { return }
            
            self?.handler.uploadMediaFile(
                uploadingSource: .itemProvider(itemProvider),
                type: type,
                blockId: blockId
            )
        }
    }
    
    private func showFilePicker(blockId: BlockId, types: [UTType] = [.item]) {
        let model = Picker.ViewModel(types: types)
        model.$resultInformation.safelyUnwrapOptionals().sink { [weak self] result in
            self?.handler.uploadFileAt(localPath: result.filePath, blockId: blockId)
        }.store(in: &subscriptions)
        
        router.showFilePicker(model: model)
    }
    
    private func showBookmarkBar(info: BlockInformation) {
        router.showBookmarkBar() { [weak self] url in
            Task { [weak self] in
                try await self?.handler.fetch(url: url, blockId: info.id)
            }
        }
    }
}
