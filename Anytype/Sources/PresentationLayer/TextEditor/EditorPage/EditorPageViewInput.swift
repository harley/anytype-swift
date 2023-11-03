import Services
import UIKit

protocol EditorCollectionReloadable: AnyObject {
    func reloadItems(items: [EditorItem])
}

/// Input data for document view
protocol EditorPageViewInput: RelativePositionProvider, EditorCollectionReloadable {
    
    func update(header: ObjectHeader)
    func update(details: ObjectDetails?, templatesCount: Int)
    func update(
        changes: CollectionDifference<EditorItem>?,
        allModels: [EditorItem],
        completion: @escaping () -> Void
    )
    func update(syncStatus: SyncStatus)
        
    /// Tells the delegate when editing of the text block begins
    func textBlockDidBeginEditing(firstResponderView: UIView)

    func blockDidChangeFrame()

    func textBlockDidChangeText()

    /// Tells the delegate when editing of the text block will begin
    func textBlockWillBeginEditing()

    func blockDidFinishEditing()
    
    func scrollToBlock(blockId: BlockId)

    func endEditing()

    func adjustContentOffset(relatively: UIView)

    func restoreEditingState()

    func didSelectTextRangeSelection(blockId: BlockId, textView: UITextView)
}
