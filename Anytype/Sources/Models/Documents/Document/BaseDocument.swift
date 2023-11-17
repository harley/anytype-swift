import Services
import Combine
import AnytypeCore
import Foundation

final class BaseDocument: BaseDocumentProtocol {
    var syncStatus: AnyPublisher<SyncStatus, Never> { $_syncStatus.eraseToAnyPublisher() }
    @Published private var _syncStatus: SyncStatus = .unknown
    
    var childrenPublisher: AnyPublisher<[BlockInformation], Never> { $_children.eraseToAnyPublisher() }
    @Published private var _children = [BlockInformation]()
    
    private var _resetBlocksSubject = PassthroughSubject<Set<BlockId>, Never>()
    var resetBlocksSubject: PassthroughSubject<Set<BlockId>, Never> { _resetBlocksSubject }
    
    
    let objectId: BlockId
    private(set) var isOpened = false
    let forPreview: Bool
    
    let infoContainer: InfoContainerProtocol = InfoContainer()
    let relationLinksStorage: RelationLinksStorageProtocol = RelationLinksStorage()
    let restrictionsContainer: ObjectRestrictionsContainer = ObjectRestrictionsContainer()
    let detailsStorage = ObjectDetailsStorage()
    
    var objectRestrictions: ObjectRestrictions { restrictionsContainer.restrinctions }
    
    private let blockActionsService: BlockActionsServiceSingleProtocol
    private let eventsListener: EventsListenerProtocol
    private let relationBuilder: RelationsBuilder
    private let relationDetailsStorage = ServiceLocator.shared.relationDetailsStorage()
    private let viewModelSetter: DocumentViewModelSetterProtocol
    
    private var subscriptions = [AnyCancellable]()
    
    @Published private var sync: Void?
    var syncPublisher: AnyPublisher<Void, Never> {
        return $sync.compactMap { $0 }.eraseToAnyPublisher()
    }
    
    // MARK: - State
    private var parsedRelationsSubject = CurrentValueSubject<ParsedRelations, Never>(.empty)
    var parsedRelationsPublisher: AnyPublisher<ParsedRelations, Never> {
        parsedRelationsSubject.eraseToAnyPublisher()
    }
    // All places, where parsedRelations used, should be subscribe on parsedRelationsPublisher.
    var parsedRelations: ParsedRelations {
        let objectRelationsDetails = relationDetailsStorage.relationsDetails(
            for: relationLinksStorage.relationLinks,
            spaceId: spaceId
        )
        let recommendedRelations = relationDetailsStorage.relationsDetails(for: details?.objectType.recommendedRelations ?? [], spaceId: spaceId)
        let typeRelationsDetails = recommendedRelations.filter { !objectRelationsDetails.contains($0) }
        return relationBuilder.parsedRelations(
            relationsDetails: objectRelationsDetails,
            typeRelationsDetails: typeRelationsDetails,
            objectId: objectId,
            isObjectLocked: isLocked || isArchived,
            storage: detailsStorage
        )
    }
    
    var isLocked: Bool {
        return infoContainer.get(id: objectId)?.isLocked ?? false
    }
    
    var isArchived: Bool {
        return details?.isArchived ?? false
    }
    
    var details: ObjectDetails? {
        detailsStorage.get(id: objectId)
    }
    
    var detailsPublisher: AnyPublisher<ObjectDetails, Never> {
        syncPublisher
            .receiveOnMain()
            .compactMap { [weak self, objectId] in
                self?.detailsStorage.get(id: objectId)
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    @available(*, deprecated, message: "Use `DocumentsProvider` instead")
    init(objectId: BlockId, forPreview: Bool = false) {
        self.objectId = objectId
        self.forPreview = forPreview
        
        self.eventsListener = EventsListener(
            objectId: objectId,
            infoContainer: infoContainer,
            relationLinksStorage: relationLinksStorage,
            restrictionsContainer: restrictionsContainer,
            detailsStorage: detailsStorage
        )
        
        self.viewModelSetter = DocumentViewModelSetter(
            detailsStorage: detailsStorage,
            relationLinksStorage: relationLinksStorage,
            restrictionsContainer: restrictionsContainer,
            infoContainer: infoContainer
        )
        
        self.blockActionsService = ServiceLocator.shared.blockActionsServiceSingle()
        self.relationBuilder = RelationsBuilder()
        
        setup()
    }
    
    deinit {
        guard !forPreview, isOpened, UserDefaultsConfig.usersId.isNotEmpty else { return }
        Task.detached(priority: .userInitiated) { [blockActionsService, objectId] in
            try await blockActionsService.close(contextId: objectId)
        }
    }
    
    // MARK: - BaseDocumentProtocol
    
    var spaceId: String {
        details?.spaceId ?? ""
    }
    
    @MainActor
    func open() async throws {
        if isOpened {
            return
        }
        guard !forPreview else {
            anytypeAssertionFailure("Document created for preview. You should use openForPreview() method.")
            return
        }
        let model = try await blockActionsService.open(contextId: objectId)
        setupView(model)
    }
    
    @MainActor
    func openForPreview() async throws {
        guard forPreview else {
            anytypeAssertionFailure("Document created for handling. You should use open() method.")
            return
        }
        let model = try await blockActionsService.openForPreview(contextId: objectId)
        setupView(model)
    }
    
    @MainActor
    func close() async throws {
        guard !forPreview, isOpened, UserDefaultsConfig.usersId.isNotEmpty else { return }
        try await blockActionsService.close(contextId: objectId)
        isOpened = false
    }
    
    func resetSubscriptions() {
        subscriptions = []
        eventsListener.stopListening()
    }
    
    var children: [BlockInformation] {
        print("Children count in document \(_children.count)")
        return _children
    }
    
    var isEmpty: Bool {
        let filteredBlocks = _children.filter { $0.isFeaturedRelations || $0.isText }
        
        if filteredBlocks.count > 0 { return false }
        let allTextChilds = _children.filter(\.isText)
        
        if allTextChilds.count > 1 { return false }
        
        return allTextChilds.first?.content.isEmpty ?? false
    }
    
    // MARK: - Private methods
    private func setup() {
        eventsListener.onUpdatesReceive = { [weak self] updates in
            DispatchQueue.main.async { [weak self] in
                self?.triggerSync(updates: updates)
            }
        }
        if !forPreview {
            eventsListener.startListening()
        }
    }
    
    private func reorderChilder() -> Bool {
        guard let model = infoContainer.get(id: objectId) else {
            return false
        }
        let flatten = model.flatChildrenTree(container: infoContainer)
        
        let isTheSame = flatten.map { $0.id } == _children.map { $0.id }
       
        _children = flatten
        
        return isTheSame
    }
    
    private func triggerSync(updates: [DocumentUpdate]) {
        
        print("updates: triggerSync")
        print("updates: \(updates.merged)")
        
        for update in updates.merged {
            guard update.hasUpdate else { return }
            
            switch update {
            case .general:
                infoContainer.publishAllValues()
                reorderChilder()
            case .children(let blockIds):
                blockIds.forEach { infoContainer.publishValue(for: $0) }
                _resetBlocksSubject.send(blockIds)
                
                let shouldUpdate = reorderChilder()
                
            case .blocks(let blockIds):
                blockIds.forEach { infoContainer.publishValue(for: $0) }
                _resetBlocksSubject.send(blockIds)
            case .unhandled(let blockIds):
                blockIds.forEach { infoContainer.publishValue(for: $0) }
            case .syncStatus:
                break
            case .details(let id):
                if id == objectId {
                    print("This object -> 000")
                } else {
                    print("Another object -> 000")
                }
                
                // Document details usually updates after sync()
                //            if objectId == id {
                //
                //            } // => Update documentDetails
            }
        }
        
        parsedRelationsSubject.send(parsedRelations)
    
        sync = ()
    }
    
    private func setupView(_ model: ObjectViewModel) {
        viewModelSetter.objectViewUpdate(model)
        isOpened = true
        triggerSync(updates: [.general])
    }
}

extension Array where Element == DocumentUpdate {
    var merged: Self {
        if contains(.general) { return [.general] }
        var childIds = Set<BlockId>()
        var blockIds = Set<BlockId>()
        var unhandled = Set<BlockId>()
        
        var output = [DocumentUpdate]()
        
        self.forEach { update in
            switch update {
            case let .blocks(ids):
                blockIds.formUnion(ids)
            case let .children(ids):
                childIds.formUnion(ids)
            case let .unhandled(ids):
                unhandled.formUnion(ids)
            case .details, .syncStatus:
                output.append(update)
            case .general:
                break
            }
        }
        
        
        if childIds.isNotEmpty {
            childIds.formUnion(blockIds)
            output.append(.children(blockIds: childIds))
        } else {
            if blockIds.isNotEmpty {
                output.append(.blocks(blockIds: blockIds))
            }
        }
        
        if unhandled.isNotEmpty {
            output.append(.unhandled(blockIds: unhandled))
        }
        
        return output
    }
}
