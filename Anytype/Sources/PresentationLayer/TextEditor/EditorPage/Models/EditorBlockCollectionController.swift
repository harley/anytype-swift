import UIKit
import Services

final class EditorBlockCollectionController: EditorCollectionReloadable {
    weak var viewInput: EditorCollectionReloadable?
    
    init(viewInput: EditorPageViewInput?) {
        self.viewInput = viewInput
    }
    
    func reload(items: [EditorItem]) {
        viewInput?.reload(items: items)
    }
    
    func reconfigure(items: [EditorItem]) {
        viewInput?.reconfigure(items: items)
    }
    
    func itemDidChangeFrame(item: EditorItem) {
        viewInput?.itemDidChangeFrame(item: item)
    }
    
    func scrollToBlock(blockId: BlockId) {
        viewInput?.scrollToBlock(blockId: blockId)
    }
    
    func textBlockDidBeginEditing(firstResponderView: UIView) {
        viewInput?.textBlockDidBeginEditing(firstResponderView: firstResponderView)
    }
    
    func textBlockWillBeginEditing() {
        viewInput?.textBlockWillBeginEditing()
    }
    
    func blockDidFinishEditing() {
        viewInput?.blockDidFinishEditing()
    }
    
    func didSelectTextRangeSelection(blockId: BlockId, textView: UITextView) {
        viewInput?.didSelectTextRangeSelection(blockId: blockId, textView: textView)
    }
}
