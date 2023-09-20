import Services
import AnytypeCore
import UIKit

protocol BlockDelegate: AnyObject {
    func willBeginEditing(with configuration: TextViewAccessoryConfiguration)
    func didBeginEditing(view: UIView)
    func didEndEditing(with configuration: TextViewAccessoryConfiguration)

    func textWillChange(changeType: TextChangeType)
    func textDidChange(data: TextViewAccessoryConfiguration)
    func textBlockSetNeedsLayout()
    func selectionDidChange(data: TextViewAccessoryConfiguration, range: NSRange)
    func scrollToBlock(blockId: BlockId)
}

final class BlockDelegateImpl: BlockDelegate {
    private var changeType: TextChangeType?

    weak private var viewInput: EditorPageViewInput?

    private let accessoryState: AccessoryViewStateManager
    private let cursorManager: EditorCursorManager
    
    init(
        viewInput: EditorPageViewInput?,
        accessoryState: AccessoryViewStateManager,
        cursorManager: EditorCursorManager
    ) {
        self.viewInput = viewInput
        self.accessoryState = accessoryState
        self.cursorManager = cursorManager
    }

    func didBeginEditing(view: UIView) {
        viewInput?.textBlockDidBeginEditing(firstResponderView: view)
    }

    func willBeginEditing(with configuration: TextViewAccessoryConfiguration) {
//        viewInput?.textBlockWillBeginEditing()
//        accessoryState.willBeginEditing(with configuration: data)
    }
    
    func didEndEditing(with configuration: TextViewAccessoryConfiguration) {
//        viewInput?.blockDidFinishEditing(blockId: data.info.id)
//        accessoryState.didEndEditing(with configuration: data)
    }
    
    func textWillChange(changeType: TextChangeType) {
        self.changeType = changeType
    }
    
    func textDidChange(data: TextViewAccessoryConfiguration) {
        guard let changeType = changeType else { return }

        accessoryState.textDidChange(changeType: changeType)
    }

    func textBlockSetNeedsLayout() {
//        viewInput?.itemDidChangeFrame(item: .header(.empty(usecase: .editor, onTap: {} /)))
    }

    func selectionDidChange(data: TextViewAccessoryConfiguration, range: NSRange) {
//        accessoryState.selectionDidChange(range: range)
//        cursorManager.didChangeCursorPosition(at: data.info.id, position: .at(range))
//        viewInput?.didSelectTextRangeSelection(blockId: data.info.id, textView: data.textView)
    }
    
    func scrollToBlock(blockId: BlockId) {
        viewInput?.scrollToBlock(blockId: blockId)
    }
}
