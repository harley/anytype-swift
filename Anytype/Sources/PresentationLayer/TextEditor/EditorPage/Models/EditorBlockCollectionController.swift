import UIKit
import Services

final class EditorBlockCollectionController: EditorCollectionReloadable {
    weak var viewInput: EditorCollectionReloadable?
    
    init(viewInput: EditorPageViewInput?) {
        self.viewInput = viewInput
    }
    
    func reloadItems(items: [EditorItem]) {
        viewInput?.reloadItems(items: items)
    }
    
    func blockDidChangeFrame() {
        viewInput?.blockDidChangeFrame()
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
