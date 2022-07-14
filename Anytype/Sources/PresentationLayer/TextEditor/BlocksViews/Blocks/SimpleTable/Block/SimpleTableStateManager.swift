import Combine
import Foundation
import BlocksModels
import UIKit

protocol SimpleTableSelectionHandler: AnyObject {
    func didStartSimpleTableSelectionMode(
        simpleTableBlockId: BlockId,
        selectedBlockIds: [BlockId],
        menuModel: SimpleTableMenuModel
    )
    func didStopSimpleTableSelectionMode()
}

protocol SimpleTableMenuDelegate: AnyObject {
    func didSelectTab(tab: SimpleTableMenuView.Tab)
}

protocol SimpleTableStateManagerProtocol: EditorPageBlocksStateManagerProtocol {
    var selectedMenuTabPublisher: AnyPublisher<SimpleTableMenuView.Tab, Never> { get }
    var selectedMenuTab: SimpleTableMenuView.Tab { get }
}

final class SimpleTableStateManager: SimpleTableStateManagerProtocol, SimpleTableMenuDelegate {
    var editorEditingStatePublisher: AnyPublisher<EditorEditingState, Never> { $editingState.eraseToAnyPublisher() }
    var selectedMenuTabPublisher: AnyPublisher<SimpleTableMenuView.Tab, Never> { $selectedMenuTab.eraseToAnyPublisher() }
    var editorSelectedBlocks: AnyPublisher<[BlockId], Never> { $selectedBlocks.eraseToAnyPublisher() }
    var selectedBlocksIndexPaths = [IndexPath]()

    @Published var editingState: EditorEditingState = .editing
    @Published var selectedMenuTab: SimpleTableMenuView.Tab = .cell
    @Published private var selectedBlocks = [BlockId]()

    private let tableBlockInformation: BlockInformation

    private let document: BaseDocumentProtocol
    private let tableService: BlockTableServiceProtocol
    private let router: EditorRouterProtocol
    private let actionHandler: BlockActionHandlerProtocol
    private weak var mainEditorSelectionManager: SimpleTableSelectionHandler?

    weak var dataSource: SpreadsheetViewDataSource? // DO WE NEED IT STILL?? ? ? ? ? ?? ?

    init(
        document: BaseDocumentProtocol,
        tableBlockInformation: BlockInformation,
        tableService: BlockTableServiceProtocol,
        router: EditorRouterProtocol,
        actionHandler: BlockActionHandlerProtocol,
        mainEditorSelectionManager: SimpleTableSelectionHandler?
    ) {
        self.document = document
        self.tableBlockInformation = tableBlockInformation
        self.tableService = tableService
        self.router = router
        self.actionHandler = actionHandler
        self.mainEditorSelectionManager = mainEditorSelectionManager
    }

    func checkDocumentLockField() {

    }

    func canSelectBlock(at indexPath: IndexPath) -> Bool {
        return true
    }

    func didLongTap(at indexPath: IndexPath) {

    }

    func didUpdateSelectedIndexPaths(_ indexPaths: [IndexPath]) {
        guard case .selecting = editingState else { return }
        selectedBlocksIndexPaths = indexPaths

        updateMenuItems(for: selectedBlocksIndexPaths)
    }

    func canPlaceDividerAtIndexPath(_ indexPath: IndexPath) -> Bool {
        return false
    }

    func canMoveItemsToObject(at indexPath: IndexPath) -> Bool {
        return false
    }

    func moveItem(with blockDragConfiguration: BlockDragConfiguration) {

    }

    func didSelectMovingIndexPaths(_ indexPaths: [IndexPath]) {
    }

    func didSelectEditingMode() {
        editingState = .editing

        selectedBlocksIndexPaths.removeAll()
    }


    // MARK: - SimpleTableMenuDelegate

    func didSelectTab(tab: SimpleTableMenuView.Tab) {
        self.selectedMenuTab = tab

        updateMenuItems(for: selectedBlocksIndexPaths)
    }

    private func updateMenuItems(for selectedBlocks: [IndexPath]) {
        guard let computedTable = ComputedTable(blockInformation: tableBlockInformation, infoContainer: document.infoContainer) else {
            return
        }
        let horizontalListItems: [HorizontalListItem]

        switch selectedMenuTab {
        case .cell:
            horizontalListItems = SimpleTableCellMenuItem.allCases.map { item in
                HorizontalListItem.init(
                    id: "\(item.hashValue)",
                    title: item.title,
                    image: .image(item.image),
                    action: { [weak self] in self?.handleCellAction(action: item) }
                )
            }
        case .row:
            horizontalListItems = SimpleTableRowMenuItem.allCases.map { item in
                HorizontalListItem.init(
                    id: "\(item.hashValue)",
                    title: item.title,
                    image: .image(item.image),
                    action: { [weak self] in self?.handleRowAction(action: item) }
                )
            }
        case .column:
            horizontalListItems = SimpleTableColumnMenuItem.allCases.map { item in
                HorizontalListItem.init(
                    id: "\(item.hashValue)",
                    title: item.title,
                    image: .image(item.image),
                    action: { [weak self] in self?.handleColumnAction(action: item) }
                )
            }
        }

        let blockIds = computedTable.cells.blockIds(for: selectedBlocks)

        mainEditorSelectionManager?.didStartSimpleTableSelectionMode(
            simpleTableBlockId: tableBlockInformation.id,
            selectedBlockIds: blockIds,
            menuModel: .init(
                tabs: tabs(),
                items: horizontalListItems,
                onDone: { [weak self] in self?.didSelectEditingMode() }
            )
        )
    }

    private func tabs() -> [SimpleTableMenuModel.TabModel] {
        SimpleTableMenuView.Tab.allCases.map { item in
            SimpleTableMenuModel.TabModel(
                id: item.rawValue,
                title: item.title,
                isSelected: selectedMenuTab == item,
                action: { [weak self] in self?.didSelectTab(tab: item) }
            )
        }
    }

    private func handleColumnAction(action: SimpleTableColumnMenuItem) {
        guard let table = ComputedTable(
                blockInformation: tableBlockInformation,
                infoContainer: document.infoContainer
              ) else { return }

        let selectedColumns = selectedBlocksIndexPaths
            .map { table.cells[$0.section][$0.row].columnId }
        let uniqueColumns = Set(selectedColumns)

        let selectedBlockIds = selectedBlocksIndexPaths
            .compactMap { table.cells[$0.section][$0.row].blockId }

        fillSelectedRows()

        switch action {
        case .insertLeft:
            uniqueColumns.forEach {
                tableService.insertColumn(contextId: document.objectId, targetId: $0, position: .left)
            }
        case .insertRight:
            uniqueColumns.forEach {
                tableService.insertColumn(contextId: document.objectId, targetId: $0, position: .right)
            }
        case .moveLeft:
            let allColumnIds = table.allColumnIds
            let dropColumnIds = uniqueColumns.compactMap { item -> BlockId? in
                guard let index = allColumnIds.firstIndex(of: item) else { return nil }
                let indexBefore = allColumnIds.index(before: index)

                return allColumnIds[safe: indexBefore]
            }

            zip(uniqueColumns, dropColumnIds).forEach { targetId, dropColumnId in
                tableService.columnMove(contextId: document.objectId, targetId: targetId, dropTargetID: dropColumnId, position: .left)

            }
        case .moveRight:
            let allColumnIds = table.allColumnIds
            let dropColumnIds = uniqueColumns.compactMap { item -> BlockId? in
                guard let index = allColumnIds.firstIndex(of: item) else { return nil }
                let indexBefore = allColumnIds.index(after: index)

                return allColumnIds[safe: indexBefore]
            }

            zip(uniqueColumns, dropColumnIds).forEach { targetId, dropColumnId in
                tableService.columnMove(contextId: document.objectId, targetId: targetId, dropTargetID: dropColumnId, position: .right)

            }
        case .duplicate:
            uniqueColumns.forEach {
                tableService.columnDuplicate(contextId: document.objectId, targetId: $0)
            }

        case .delete:
            uniqueColumns.forEach {
                tableService.deleteColumn(contextId: document.objectId, targetId: $0)
            }
        case .clearContents:
            tableService.clearContents(contextId: document.objectId, blockIds: selectedBlockIds)
        case .sort:
            uniqueColumns.forEach {
                tableService.columnSort(contextId: document.objectId, columnId: $0, blocksSortType: .desc)
            }
        case .color:
            onColorSelection(for: selectedBlockIds)
            return
        case .style:
            break
        }

        editingState = .editing
        mainEditorSelectionManager?.didStopSimpleTableSelectionMode()
        selectedMenuTab = .cell
    }

    private func onColorSelection(for selectedBlockIds: [BlockId]) {
        measureTime(for: "onColorSelection") {
            let blockInformations = selectedBlockIds.compactMap(document.infoContainer.get(id:))

            let backgroundColors = blockInformations.map(\.backgroundColor)
            let textColors = blockInformations.compactMap { blockInformation -> MiddlewareColor in
                if case let .text(blockText) = blockInformation.content {
                    return blockText.color ?? .default
                }

                return MiddlewareColor.default
            }

            let uniqueBackgroundColors = Set(backgroundColors)
            let uniqueTextColors = Set(textColors)

            let backgroundColor = uniqueBackgroundColors.count > 1 ? nil : (uniqueBackgroundColors.first ?? .default)
            let textColor = uniqueTextColors.count > 1 ? nil : (uniqueTextColors.first ?? .default)

            router.showColorPicker(
                onColorSelection: { [weak actionHandler] colorItem in
                    measureTime(for: "colorItem") {
                        switch colorItem {
                        case .text(let blockColor):
                            actionHandler?.setTextColor(blockColor, blockIds: selectedBlockIds)
                        case .background(let blockBackgroundColor):
                            actionHandler?.setBackgroundColor(blockBackgroundColor, blockIds: selectedBlockIds)
                        }
                    }
                },
                selectedColor: textColor.map(UIColor.Text.uiColor(from:)) ?? nil,
                selectedBackgroundColor: backgroundColor.map(UIColor.Background.uiColor(from:)) ?? nil
            )
        }
    }

    private func handleRowAction(action: SimpleTableRowMenuItem) {
        guard let table = ComputedTable(
            blockInformation: tableBlockInformation,
            infoContainer: document.infoContainer
        ) else { return }

        let selectedRowIds = selectedBlocksIndexPaths
            .map { table.cells[$0.section][$0.row].rowId }
        let uniqueRows = Set(selectedRowIds)

        let selectedBlockIds = selectedBlocksIndexPaths
            .compactMap { table.cells[$0.section][$0.row].blockId }

        fillSelectedRows()

        switch action {
        case .insertAbove:
            uniqueRows.forEach {
                tableService.insertRow(contextId: document.objectId, targetId: $0, position: .top)
            }
        case .insertBelow:
            uniqueRows.forEach {
                tableService.insertRow(contextId: document.objectId, targetId: $0, position: .bottom)
            }
        case .moveUp:
            let allRowIds = table.allRowIds
            let dropRowIds = uniqueRows.compactMap { item -> BlockId? in
                guard let index = allRowIds.firstIndex(of: item) else { return nil }
                let indexBefore = allRowIds.index(before: index)

                return allRowIds[safe: indexBefore]
            }

            zip(uniqueRows, dropRowIds).forEach { targetId, dropColumnId in
                tableService.rowMove(
                    contextId: document.objectId,
                    targetId: targetId,
                    dropTargetID: dropColumnId,
                    position: .top
                )
            }
        case .moveDown:
            let allRowIds = table.allRowIds
            let dropRowIds = uniqueRows.compactMap { item -> BlockId? in
                guard let index = allRowIds.firstIndex(of: item) else { return nil }
                let indexAfter = allRowIds.index(after: index)

                return allRowIds[safe: indexAfter]
            }

            zip(uniqueRows, dropRowIds).forEach { targetId, dropColumnId in
                tableService.rowMove(
                    contextId: document.objectId,
                    targetId: targetId,
                    dropTargetID: dropColumnId,
                    position: .bottom
                )
            }
        case .duplicate:
            uniqueRows.forEach {
                tableService.rowDuplicate(contextId: document.objectId, targetId: $0)
            }
        case .delete:
            uniqueRows.forEach {
                tableService.deleteRow(contextId: document.objectId, targetId: $0)
            }
        case .clearContents:
            tableService.clearContents(contextId: document.objectId, blockIds: selectedBlockIds)
        case .color:
            onColorSelection(for: selectedBlockIds)
            return
        case .style:
            return
        }

        editingState = .editing
        mainEditorSelectionManager?.didStopSimpleTableSelectionMode()
        selectedMenuTab = .cell
    }

    private func handleCellAction(action: SimpleTableCellMenuItem) {
        guard let table = ComputedTable(
            blockInformation: tableBlockInformation,
            infoContainer: document.infoContainer
        ) else { return }


        let selectedBlockIds = selectedBlocksIndexPaths
            .compactMap { table.cells[$0.section][$0.row].blockId }

        fillSelectedRows()

        switch action {
        case .clearContents:
            tableService.clearContents(contextId: document.objectId, blockIds: selectedBlockIds)
        case .color:
            onColorSelection(for: selectedBlockIds)
            return
        case .style:
            return
        case .clearStyle:
            tableService.clearStyle(contextId: document.objectId, blocksIds: selectedBlockIds)
        }

        editingState = .editing
        mainEditorSelectionManager?.didStopSimpleTableSelectionMode()
        selectedMenuTab = .cell
    }

    private func fillSelectedRows() {
        guard let table = ComputedTable(
            blockInformation: tableBlockInformation,
            infoContainer: document.infoContainer
        ) else { return }

        let selectedRows = Set(
            selectedBlocksIndexPaths
                .compactMap { table.cells[$0.section][$0.row].rowId }
        )

        tableService.rowListFill(contextId: document.objectId, targetIds: Array(selectedRows))
    }
}

extension SimpleTableStateManager: BlockSelectionHandler {
    func didSelectEditingState(info: BlockInformation) {
        guard let computedTable = ComputedTable(blockInformation: tableBlockInformation, infoContainer: document.infoContainer),
              let selectedIndexPath = computedTable.cells.indexPaths(for: info) else {
            return
        }

        editingState = .selecting(blocks: [info.id])
        selectedBlocks = [info.id]

        updateMenuItems(for: [selectedIndexPath])
    }
}

extension Array where Element == [ComputedTable.Cell] {
    func indexPaths(for blockInformation: BlockInformation) -> IndexPath? {
        for (sectionIndex, sections) in self.enumerated() {
            for (rowIndex, item) in sections.enumerated() {
                if item.blockInformation?.id == blockInformation.id {
                    return IndexPath(item: rowIndex, section: sectionIndex)
                }
            }
        }

        return nil
    }

    func blockIds(for indexPaths: [IndexPath]) -> [BlockId] {
        var blockIds = [BlockId]()

        for (sectionIndex, sections) in self.enumerated() {
            for (rowIndex, item) in sections.enumerated() {
                if indexPaths.contains(where: { $0.section == sectionIndex && $0.row == rowIndex }) {
                    if let blockInformation = item.blockInformation {
                        blockIds.append(blockInformation.id)
                    } else {
                        blockIds.append("\(item.rowId)-\(item.columnId)")
                    }
                }
            }
        }

        return blockIds
    }
}

private extension EditorItem {
     var blockId: BlockId? {
        switch self {
        case .header(let objectHeader):
            return nil
        case .block(let blockViewModel):
            return blockViewModel.blockId
        case .system(let systemContentConfiguationProvider):
            return nil
        }
    }
}
