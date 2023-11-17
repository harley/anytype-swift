import Services
import ProtobufMessages
import SwiftProtobuf
import UIKit
import Kingfisher
import AnytypeCore
import Combine

final class MentionsViewModel {
    @Published private(set) var mentions = ([MentionDisplayData](), "")
    @Published private(set) var newObjectName = ""
    let dismissSubject = PassthroughSubject<Void, Never>()
    
    var onSelect: RoutingAction<MentionObject>?
    
    private let document: BaseDocumentProtocol
    private let mentionService: MentionObjectsServiceProtocol
    private let pageService: PageRepositoryProtocol
    private var searchTask: Task<(), Error>?
    private var searchString = ""
    
    init(
        document: BaseDocumentProtocol,
        mentionService: MentionObjectsServiceProtocol,
        pageService: PageRepositoryProtocol
    ) {
        self.document = document
        self.mentionService = mentionService
        self.pageService = pageService
    }
    
    func obtainMentions(filterString: String) {
        searchString = filterString
        searchTask?.cancel()
        searchTask = Task { @MainActor [weak self] in
            guard let self else { return }
            let mentions = try await mentionService.searchMentions(
                spaceId: document.spaceId,
                text: filterString,
                excludedObjectIds: [document.objectId]
            )
            
            self.mentions = (mentions.map { .mention($0) }, filterString)
        }
    }
    
    func setFilterString(_ string: String) {
        obtainMentions(filterString: string)
    }
    
    func didSelectMention(_ mention: MentionObject) {
        onSelect?(mention)
        dismissSubject.send(())
    }
    
    func didSelectCreateNewMention() {
        Task { @MainActor in
            guard let newBlockDetails = try? await pageService.createDefaultPage(name: searchString, spaceId: document.spaceId) else { return }
            
            AnytypeAnalytics.instance().logCreateObject(objectType: newBlockDetails.analyticsType, route: .mention)
            let name = searchString.isEmpty ? Loc.Object.Title.placeholder : searchString
            let mention = MentionObject(
                id: newBlockDetails.id,
                objectIcon: newBlockDetails.objectIconImage,
                name: name,
                description: nil,
                type: nil,
                isDeleted: newBlockDetails.isDeleted,
                isArchived: newBlockDetails.isArchived
            )
            didSelectMention(mention)
        }
    }
}
