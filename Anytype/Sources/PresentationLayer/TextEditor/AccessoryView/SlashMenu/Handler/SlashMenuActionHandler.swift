import Foundation
import Services
import AnytypeCore
import UIKit

final class SlashMenuActionHandler {
    private let actionHandler: BlockActionHandlerProtocol
    private let router: EditorRouterProtocol
    private let document: BaseDocumentProtocol
    private let pasteboardService: PasteboardServiceProtocol
    private let cursorManager: EditorCursorManager
    private weak var textView: UITextView?
    
    init(
        document: BaseDocumentProtocol,
        actionHandler: BlockActionHandlerProtocol,
        router: EditorRouterProtocol,
        pasteboardService: PasteboardServiceProtocol,
        cursorManager: EditorCursorManager
    ) {
        self.document = document
        self.actionHandler = actionHandler
        self.router = router
        self.pasteboardService = pasteboardService
        self.cursorManager = cursorManager
    }
    
    func handle(
        _ action: SlashAction,
        textView: UITextView?,
        blockInformation: BlockInformation,
        modifiedStringHandler: (NSAttributedString) -> Void
    ) {
        switch action {
        case let .actions(action):
            handleActions(action, textView: textView, blockId: blockInformation.id)
        case let .alignment(alignmnet):
            handleAlignment(alignmnet, blockIds: [blockInformation.id])
        case let .style(style):
            handleStyle(style, attributedString: textView?.attributedText, blockInformation: blockInformation, modifiedStringHandler: modifiedStringHandler)
        case let .media(media):
            actionHandler.addBlock(media.blockViewsType, blockId: blockInformation.id, blockText: textView?.attributedText)
        case let .objects(action):
            switch action {
            case .linkTo:
                router.showLinkTo { [weak self] details in
                    self?.actionHandler.addLink(targetDetails: details, blockId: blockInformation.id)
                }
            case .objectType(let object):
                let spaceId = document.spaceId
                Task { @MainActor [weak self] in
                    AnytypeAnalytics.instance().logCreateLink()
                    try await self?.actionHandler
                        .createPage(
                            targetId: blockInformation.id,
                            spaceId: spaceId,
                            typeUniqueKey: object.uniqueKeyValue,
                            templateId: object.defaultTemplateId
                        )
                        .flatMap { objectId in
                            AnytypeAnalytics.instance().logCreateObject(objectType: object.analyticsType, route: .powertool)
                            self?.router.showPage(
                                data: .page(EditorPageObject(objectId: objectId, spaceId: object.spaceId, isSupportedForEdit: true, isOpenedForPreview: false))
                            )
                        }
                }
            }
        case let .relations(action):
            switch action {
            case .newRealtion:
                router.showAddNewRelationView(document: document) { [weak self] relation, isNew in
                    self?.actionHandler.addBlock(.relation(key: relation.key), blockId: blockInformation.id, blockText: textView?.attributedText)
                    
                    AnytypeAnalytics.instance().logAddRelation(format: relation.format, isNew: isNew, type: .block)
                }
            case .relation(let relation):
                actionHandler.addBlock(.relation(key: relation.key), blockId: blockInformation.id, blockText: textView?.attributedText)
            }
        case let .other(other):
            switch other {
            case .table(let rowsCount, let columnsCount):
                let safeSendableAttributedText = SafeSendable(value: textView?.attributedText)
                Task { @MainActor in
                    guard let blockId = try? await actionHandler.createTable(
                        blockId: blockInformation.id,
                        rowsCount: rowsCount,
                        columnsCount: columnsCount,
                        blockText: safeSendableAttributedText
                    ) else { return }
                    
                    cursorManager.blockFocus = .init(id: blockId, position: .beginning)
                }
                
            default:
                actionHandler.addBlock(other.blockViewsType, blockId: blockInformation.id, blockText: textView?.attributedText)
            }
        case let .color(color):
            actionHandler.setTextColor(color, blockIds: [blockInformation.id])
        case let .background(color):
            actionHandler.setBackgroundColor(color, blockIds: [blockInformation.id])
        }
    }
    
    private func handleAlignment(_ alignment: SlashActionAlignment, blockIds: [BlockId]) {
        switch alignment {
        case .left :
            actionHandler.setAlignment(.left, blockIds: blockIds)
        case .right:
            actionHandler.setAlignment(.right, blockIds: blockIds)
        case .center:
            actionHandler.setAlignment(.center, blockIds: blockIds)
        }
    }
    
    private func handleStyle(
        _ style: SlashActionStyle,
        attributedString: NSAttributedString?,
        blockInformation: BlockInformation,
        modifiedStringHandler: (NSAttributedString) -> Void
    ) {
        switch style {
        case .text:
            actionHandler.turnInto(.text, blockId: blockInformation.id)
        case .title:
            actionHandler.turnInto(.header, blockId: blockInformation.id)
        case .heading:
            actionHandler.turnInto(.header2, blockId: blockInformation.id)
        case .subheading:
            actionHandler.turnInto(.header3, blockId: blockInformation.id)
        case .highlighted:
            actionHandler.turnInto(.quote, blockId: blockInformation.id)
        case .callout:
            actionHandler.turnInto(.callout, blockId: blockInformation.id)
        case .checkbox:
            actionHandler.turnInto(.checkbox, blockId: blockInformation.id)
        case .bulleted:
            actionHandler.turnInto(.bulleted, blockId: blockInformation.id)
        case .numberedList:
            actionHandler.turnInto(.numbered, blockId: blockInformation.id)
        case .toggle:
            actionHandler.turnInto(.toggle, blockId: blockInformation.id)
        case .bold:
            let modifiedAttributedString = actionHandler.toggleWholeBlockMarkup(
                attributedString,
                markup: .bold,
                info: blockInformation
            )
            
            modifiedAttributedString.map(modifiedStringHandler)
        case .italic:
            let modifiedAttributedString = actionHandler.toggleWholeBlockMarkup(
                attributedString,
                markup: .italic,
                info: blockInformation
            )
            
            modifiedAttributedString.map(modifiedStringHandler)
        case .strikethrough:
            let modifiedAttributedString = actionHandler.toggleWholeBlockMarkup(
                attributedString,
                markup: .strikethrough,
                info: blockInformation
            )
            
            modifiedAttributedString.map(modifiedStringHandler)
        case .code:
            let modifiedAttributedString = actionHandler.toggleWholeBlockMarkup(
                attributedString,
                markup: .keyboard,
                info: blockInformation
            )
            
            modifiedAttributedString.map(modifiedStringHandler)
        case .link:
            break
        }
    }
    
    private func handleActions(_ action: BlockAction, textView: UITextView?, blockId: BlockId) {
        switch action {
        case .delete:
            actionHandler.delete(blockIds: [blockId])
        case .duplicate:
            actionHandler.duplicate(blockId: blockId)
        case .moveTo:
            router.showMoveTo { [weak self] details in
                self?.actionHandler.moveToPage(blockId: blockId, pageId: details.id)
            }
        case .copy:
            Task {
                try await pasteboardService.copy(blocksIds: [blockId], selectedTextRange: NSRange())
            }
        case .paste:
            textView?.paste(self)
        }
    }
}
