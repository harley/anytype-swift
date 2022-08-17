import Foundation
import UIKit
import BlocksModels

final class TextRelationReloadContentActionViewModel: TextRelationActionViewModelProtocol {
    
    private let objectId: BlockId
    private let relation: Relation
    private let bookmarkService: BookmarkServiceProtocol
    
    var inputText: String = ""
    let title: String = Loc.RelationAction.reloadContent
    let iconAsset = ImageAsset.relationSmallReload
    
    init?(
        objectId: BlockId,
        relation: Relation,
        bookmarkService: BookmarkServiceProtocol
    ) {
        guard let objectInfo = ObjectDetailsStorage.shared.get(id: objectId),
              objectInfo.objectType.url == ObjectTypeUrl.bundled(.bookmark).rawValue,
              relation.isBundled else { return nil }
        
        self.objectId = objectId
        self.relation = relation
        self.bookmarkService = bookmarkService
    }
    
    var isActionAvailable: Bool {
        inputText.isValidURL()
    }
    
    func performAction() {
        UISelectionFeedbackGenerator().selectionChanged()
        bookmarkService.fetchBookmarkContent(bookmarkId: objectId, url: inputText)
    }
}
