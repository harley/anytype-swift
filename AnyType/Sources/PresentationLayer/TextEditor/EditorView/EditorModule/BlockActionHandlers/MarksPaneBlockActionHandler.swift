//
//  MarksPaneBlockActionHandler.swift
//  AnyType
//
//  Created by Denis Batvinkin on 17.02.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import UIKit
import Combine
import OSLog
import BlocksModels


final class MarksPaneBlockActionHandler {
    typealias ActionsPayload = BlocksViews.New.Base.ViewModel.ActionsPayload
    typealias ActionsPayloadMarksPane = ActionsPayload.MarksPaneHolder.Action
    typealias Conversion = (ServiceLayerModule.Success) -> (EventListening.PackOfEvents)
    
    private let service: BlockActionService
    private let listService: ServiceLayerModule.List.BlockActionsService = .init()
    private let contextId: String
    private var subscriptions: [AnyCancellable] = []
    private weak var subject: PassthroughSubject<BlockActionsHandlersFacade.Reaction?, Never>?

    init(service: BlockActionService, contextId: String, subject: PassthroughSubject<BlockActionsHandlersFacade.Reaction?, Never>) {
        self.service = service
        self.contextId = contextId
        self.subject = subject
    }
    
    func handlingMarksPaneAction(_ block: BlockActiveRecordModelProtocol, _ action: ActionsPayloadMarksPane) {
        switch action {
        case let .style(range, styleAction):
            switch styleAction {
            case let .alignment(alignmentAction):
                self.setAlignment(block: block.blockModel.information, alignment: alignmentAction)
            case let .fontStyle(fontAction):
                self.handleFontAction(for: block, range: range, fontAction: fontAction)
            }
        case let .textColor(range, colorAction):
            switch colorAction {
            case let .setColor(color):
                self.setBlockColor(block: block.blockModel.information, color: color)
            }
        case let .backgroundColor(_, action):
            switch action {
            case let .setColor(value):
                self.service.setBackgroundColor(block: block.blockModel.information, color: value)
            }
        }
    }
}

private extension MarksPaneBlockActionHandler {

    func setBlockColor(block: BlockInformationModelProtocol, color: UIColor?) {
        let blockIds = [block.id]

        self.listService.setBlockColor(contextID: self.contextId, blockIds: blockIds, color: color)
            .sink(receiveCompletion: { (value) in
                switch value {
                case .finished: return
                case let .failure(error):
                    Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "MarksPane").error("setBlockColor: \(error.localizedDescription)")
                }
            }) { [weak self] (value) in
                let value = EventListening.PackOfEvents(contextId: value.contextID, events: value.messages, ourEvents: [])
                self?.subject?.send(.shouldHandleEvent(.init(actionType: nil, payload: .init(events: value))))
            }
            .store(in: &self.subscriptions)
    }

    func setAlignment(block: BlockInformationModelProtocol, alignment: MarksPane.Panes.StylePane.Alignment.Action) {
        let blockIds = [block.id]

        self.listService.setAlign.action(contextID: self.contextId, blockIds: blockIds, alignment: alignment.asModel())
            .sink(receiveCompletion: { (value) in
                switch value {
                case .finished: return
                case let .failure(error):
                    Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "MarksPane").error("setAlignment: \(error.localizedDescription)")
                }
            }) { [weak self] (value) in
                let value = EventListening.PackOfEvents(contextId: value.contextID, events: value.messages, ourEvents: [])
                self?.subject?.send(.shouldHandleEvent(.init(actionType: nil, payload: .init(events: value))))
            }
            .store(in: &self.subscriptions)
    }

    func handleFontAction(for block: BlockActiveRecordModelProtocol, range: NSRange, fontAction: MarksPane.Panes.StylePane.FontStyle.Action) {
        guard case var .text(textContentType) = block.blockModel.information.content else { return }
        var range = range
        var blockModel = block.blockModel

        // if range length == 0 then apply to whole block
        if range.length == 0 {
            range = NSRange(location: 0, length: textContentType.attributedText.length)
        }
        let newAttributedString = NSMutableAttributedString(attributedString: textContentType.attributedText)

        func applyNewStyle(trait: UIFontDescriptor.SymbolicTraits) {
            let hasTrait = textContentType.attributedText.hasTrait(trait: trait, at: range)

            textContentType.attributedText.enumerateAttribute(.font, in: range) { oldFont, range, shouldStop in
                guard let oldFont = oldFont as? UIFont else { return }
                var boldSymbolicTraits = oldFont.fontDescriptor.symbolicTraits

                if hasTrait {
                    boldSymbolicTraits.remove(trait)
                } else {
                    boldSymbolicTraits.insert(trait)
                }

                if let newFontDescriptor = oldFont.fontDescriptor.withSymbolicTraits(boldSymbolicTraits) {
                    let boldFont = UIFont(descriptor: newFontDescriptor, size: oldFont.pointSize)
                    newAttributedString.addAttributes([NSAttributedString.Key.font: boldFont], range: range)
                }
            }
            textContentType.attributedText = newAttributedString
            blockModel.information.content = .text(textContentType)
        }

        switch fontAction {
        case .bold:
            applyNewStyle(trait: .traitBold)
        case .italic:
            applyNewStyle(trait: .traitItalic)
        case .strikethrough:
            if textContentType.attributedText.hasAttribute(.strikethroughStyle, at: range) {
                newAttributedString.removeAttribute(.strikethroughStyle, range: range)
            } else {
                newAttributedString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single, range: range)
            }
            textContentType.attributedText = newAttributedString
            blockModel.information.content = .text(textContentType)
        case .keyboard:
            self.service.setBackgroundColor(block: block.blockModel.information, color: UIColor.lightGray)
        }
    }
    
}
