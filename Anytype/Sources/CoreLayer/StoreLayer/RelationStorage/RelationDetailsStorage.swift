import Foundation
import BlocksModels
import AnytypeCore
import Combine

extension RelationDetails: IdProvider {}

final class RelationDetailsStorage: RelationDetailsStorageProtocol {
    
    private let subscriptionsService: SubscriptionsServiceProtocol
    private let subscriptionDataBuilder: RelationSubscriptionDataBuilderProtocol
    
    private var details = [RelationDetails]()
    private var searchDetailsByKey = [String: RelationDetails]()

    private var relationsDetailsSubject = CurrentValueSubject<[RelationDetails], Never>([])
    var relationsDetailsPublisher: AnyPublisher<[RelationDetails], Never> {
        relationsDetailsSubject.eraseToAnyPublisher()
    }
    
    init(
        subscriptionsService: SubscriptionsServiceProtocol,
        subscriptionDataBuilder: RelationSubscriptionDataBuilderProtocol
    ) {
        self.subscriptionsService = subscriptionsService
        self.subscriptionDataBuilder = subscriptionDataBuilder
    }
    // MARK: - RelationDetailsStorageProtocol
    
    func relationsDetails(for links: [RelationLink]) -> [RelationDetails] {
//        return links.map { searchDetailsByKey[$0.key] ?? createDeletedRelation(link: $0) }
        return links.map { link in
            if link.key == "address" {
                return createDeletedRelation(link: link)
            }
            return searchDetailsByKey[link.key] ?? createDeletedRelation(link: link)
        }
    }
    
    func relationsDetails() -> [RelationDetails] {
        return details
    }
    
    func startSubscription() {
        subscriptionsService.startSubscription(data: subscriptionDataBuilder.build()) { [weak self] subId, update in
            self?.handleEvent(update: update)
        }
    }
    
    func stopSubscription() {
        subscriptionsService.stopSubscription(id: .relation)
        details.removeAll()
        updateSearchCache()
        relationsDetailsSubject.send(details)
    }
    
    // MARK: - Private
    
    private func handleEvent(update: SubscriptionUpdate) {
        details.applySubscriptionUpdate(update, transform: { RelationDetails(objectDetails: $0) })
        updateSearchCache()
        relationsDetailsSubject.send(details)
        
        switch update {
        case .initialData(let details):
            let relationKeys = details.map { $0.relationKey }
            sendLocalEvents(relationKeys: relationKeys)
        case .update(let objectDetails):
            sendLocalEvents(relationKeys: [objectDetails.relationKey])
        case .remove, .add, .move, .pageCount:
            break
        }
    }
    
    private func sendLocalEvents(relationKeys: [String]) {
        RelationEventsBunch(events: [.relationChanged(relationKeys: relationKeys)])
            .send()
    }
    
    private func updateSearchCache() {
        searchDetailsByKey.removeAll()
        details.forEach {
            if searchDetailsByKey[$0.key] != nil {
                anytypeAssertionFailure(
                    "Dublicate relation found for key \($0.key), id: \($0.id)",
                    domain: .relationDetailsStorage
                )
            }
            searchDetailsByKey[$0.key] = $0
        }
    }
    
    private func createDeletedRelation(link: RelationLink) -> RelationDetails {
        return RelationDetails(
            id: "",
            key: link.key,
            name: "",
            format: .shortText,
            isHidden: false,
            isReadOnly: true,
            isReadOnlyValue: true,
            objectTypes: [],
            maxCount: 1,
            sourceObject: "",
            isDeleted: true
        )
    }
}
