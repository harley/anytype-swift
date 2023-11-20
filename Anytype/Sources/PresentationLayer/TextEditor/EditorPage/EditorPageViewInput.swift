import Services
import UIKit

protocol EditorCollectionReloadable: AnyObject {
    func reload(items: [EditorItem])
    func reconfigure(items: [EditorItem])
    func itemDidChangeFrame(item: EditorItem)
    func scrollToBlock(blockId: BlockId) // Change to editorItem
    
    /// Tells the delegate when editing of the text block begins
    func textBlockDidBeginEditing(firstResponderView: UIView)
    func textBlockWillBeginEditing()
    func blockDidFinishEditing()
    func didSelectTextRangeSelection(blockId: BlockId, textView: UITextView)
}

/// Input data for document view
protocol EditorPageViewInput: EditorCollectionReloadable {
    func update(header: ObjectHeader)
    func update(details: ObjectDetails?, templatesCount: Int)
    func update(
        changes: CollectionDifference<EditorItem>?,
        allModels: [EditorItem],
        completion: @escaping () -> Void
    )
    func update(syncStatus: SyncStatus)
    

    func endEditing()

    func adjustContentOffset(relatively: UIView)

    func restoreEditingState()
}
