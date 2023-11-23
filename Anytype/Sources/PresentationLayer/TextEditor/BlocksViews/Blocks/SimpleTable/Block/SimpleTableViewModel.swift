import UIKit
import Combine
import Services

final class SimpleTableViewModel {
    let stateManager: SimpleTableStateManagerProtocol
    weak var dataSource: SpreadsheetViewDataSource? {
        didSet {
            forceUpdate(shouldApplyFocus: true)
        }
    }

    private let document: BaseDocumentProtocol
    private let cellBuilder: SimpleTableCellsBuilder
    private let cursorManager: EditorCursorManager
    private var tableBlockInfoProvider: BlockModelInfomationProvider

    @Published var widths = [CGFloat]()

    private var cancellables = [AnyCancellable]()

    init(
        document: BaseDocumentProtocol,
        tableBlockInfoProvider: BlockModelInfomationProvider,
        cellBuilder: SimpleTableCellsBuilder,
        stateManager: SimpleTableStateManagerProtocol,
        cursorManager: EditorCursorManager
    ) {
        self.document = document
        self.tableBlockInfoProvider = tableBlockInfoProvider
        self.cellBuilder = cellBuilder
        self.stateManager = stateManager
        self.cursorManager = cursorManager

        forceUpdate(shouldApplyFocus: false)
        stateManager.checkDocumentLockField()
        setupHandlers()
    }

    private func setupHandlers() {
        document.resetBlocksSubject.sink { [weak self] blockIds in
            guard let self else { return }
            
            guard let computedTable = ComputedTable(blockInformation: tableBlockInfoProvider.info, infoContainer: document.infoContainer) else {
                return
            }
            var allRelatedIds = [tableBlockInfoProvider.info.id] + document.infoContainer.recursiveChildren(of: tableBlockInfoProvider.info.id).map { $0.id }
            
            if Set(allRelatedIds).intersection(blockIds).count > 0 {
                forceUpdate(shouldApplyFocus: true)
            }
        }.store(in: &cancellables)
    }

//    private func handleUpdate(update: DocumentUpdate) {
//        switch update {
//        case .general, .details, .children:
//            forceUpdate(shouldApplyFocus: true)
//        case .syncStatus: break
//        case .blocks(let blockIds):
//            let container = document.infoContainer
//
//            let allChilds = container.recursiveChildren(of: tableBlockInfo.id).map(\.id)
//            guard blockIds.intersection(Set(allChilds)).isNotEmpty else {
//                return
//            }
//
//            let newItems = cellBuilder.buildItems(from: tableBlockInfo)
//
//           updateDifference(newItems: newItems)
////        case .dataSourceUpdate:
////            guard let newInfo = document.infoContainer.get(id: tableBlockInfo.id) else {
////                return
////            }
////            tableBlockInfo = newInfo
////
////            let cells = cellBuilder.buildItems(from: newInfo)
////
////            dataSource?.allModels = cells
//        case .unhandled(blockIds: let blockIds):
//            return
//        }
//
//        stateManager.checkDocumentLockField()
//    }

    private func updateDifference(newItems: [[EditorItem]]) {
        let newItems = cellBuilder.buildItems(from: tableBlockInfoProvider.info)

        var itemsToUpdate = [EditorItem]()
        zip(newItems, dataSource!.allModels).forEach { newSections, currentSections in
            zip(newSections, currentSections).forEach { newItem, currentItem in
                if newItem.hashValue != currentItem.hashValue {
                    itemsToUpdate.append(newItem)
                }
            }
        }

        dataSource?.update(changes: newItems.flatMap { $0 }, allModels: newItems)
    }

    private func forceUpdate(shouldApplyFocus: Bool) {
        let cells = cellBuilder.buildItems(from: tableBlockInfoProvider.info)
        let numberOfColumns = cells.first?.count ?? 0

        let widths = [CGFloat](repeating: 170, count: numberOfColumns)

        if self.widths != widths { self.widths = widths }

        dataSource?.update(
            changes: cells.flatMap { $0 },
            allModels: cells
        )

        if shouldApplyFocus {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.cursorManager.applyCurrentFocus()
            }
        }
    }
}

