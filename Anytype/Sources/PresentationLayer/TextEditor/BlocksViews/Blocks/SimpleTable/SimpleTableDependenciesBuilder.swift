import Services
import UIKit
import AnytypeCore

struct SimpleTableDependenciesContainer {
    let blockDelegate: BlockDelegate?
    let relativePositionProvider: RelativePositionProvider?
    let stateManager: SimpleTableStateManager
    let viewModel: SimpleTableViewModel
}

@MainActor
final class SimpleTableDependenciesBuilder {
    let cursorManager: EditorCursorManager
    
    private let document: BaseDocumentProtocol
    private let router: EditorRouterProtocol
    private let handler: BlockActionHandlerProtocol
    private let pasteboardService: PasteboardServiceProtocol
    private let markdownListener: MarkdownListener
    private let focusSubjectHolder: FocusSubjectsHolder
    private let tableService = BlockTableService()
    private let responderScrollViewHelper: ResponderScrollViewHelper
    private let pageService: PageRepositoryProtocol
    private let linkToObjectCoordinator: LinkToObjectCoordinatorProtocol
    private let searchService: SearchServiceProtocol

    weak var mainEditorSelectionManager: SimpleTableSelectionHandler?
    weak var viewInput: (EditorPageViewInput & RelativePositionProvider)?

    init(
        document: BaseDocumentProtocol,
        router: EditorRouterProtocol,
        handler: BlockActionHandlerProtocol,
        pasteboardService: PasteboardServiceProtocol,
        markdownListener: MarkdownListener,
        focusSubjectHolder: FocusSubjectsHolder,
        viewInput: (EditorPageViewInput & RelativePositionProvider)?,
        mainEditorSelectionManager: SimpleTableSelectionHandler?,
        responderScrollViewHelper: ResponderScrollViewHelper,
        pageService: PageRepositoryProtocol,
        linkToObjectCoordinator: LinkToObjectCoordinatorProtocol,
        searchService: SearchServiceProtocol
    ) {
        self.document = document
        self.router = router
        self.handler = handler
        self.pasteboardService = pasteboardService
        self.markdownListener = markdownListener
        self.focusSubjectHolder = focusSubjectHolder
        self.viewInput = viewInput
        self.mainEditorSelectionManager = mainEditorSelectionManager
        self.responderScrollViewHelper = responderScrollViewHelper
        self.pageService = pageService
        self.linkToObjectCoordinator = linkToObjectCoordinator
        self.searchService = searchService
        
        self.cursorManager = EditorCursorManager(focusSubjectHolder: focusSubjectHolder)
    }

    func buildDependenciesContainer(blockInformation: BlockInformation) -> SimpleTableDependenciesContainer {
        let selectionOptionHandler = SimpleTableSelectionOptionHandler(
            router: router,
            tableService: tableService,
            document: document,
            tableBlockInformation: blockInformation,
            actionHandler: handler
        )

        let stateManager = SimpleTableStateManager(
            document: document,
            tableBlockInformation: blockInformation,
            selectionOptionHandler: selectionOptionHandler,
            router: router,
            cursorManager: cursorManager,
            mainEditorSelectionManager: mainEditorSelectionManager
        )

        let simpleTablesAccessoryState = AccessoryViewBuilder.accessoryState(
            actionHandler: handler,
            router: router,
            document: document,
            searchService: searchService
        )

        let simpleTablesBlockDelegate = BlockDelegateImpl(
            viewInput: viewInput,
            accessoryState: simpleTablesAccessoryState.0,
            cursorManager: cursorManager
        )

        let cellsBuilder = SimpleTableCellsBuilder(
            document: document,
            router: router,
            handler: handler,
            pasteboardService: pasteboardService,
            delegate: simpleTablesBlockDelegate,
            markdownListener: markdownListener,
            cursorManager: cursorManager,
            focusSubjectHolder: focusSubjectHolder,
            responderScrollViewHelper: responderScrollViewHelper
        )

        let viewModel = SimpleTableViewModel(
            document: document,
            tableBlockInfo: blockInformation,
            cellBuilder: cellsBuilder,
            stateManager: stateManager,
            cursorManager: cursorManager
        )

        return .init(
            blockDelegate: simpleTablesBlockDelegate,
            relativePositionProvider: viewInput,
            stateManager: stateManager,
            viewModel: viewModel
        )
    }
}
