import Services
import Combine
import AnytypeCore

protocol BaseDocumentGeneralProtocol: AnyObject {
    var syncStatus: AnyPublisher<SyncStatus, Never> { get }
    
    var objectId: BlockId { get }
    var spaceId: String { get }
    var details: ObjectDetails? { get }
    var detailsPublisher: AnyPublisher<ObjectDetails, Never> { get }
    var syncPublisher: AnyPublisher<Void, Never> { get }
    var forPreview: Bool { get }
    
    @MainActor
    func open() async throws
    @MainActor
    func openForPreview() async throws
    @MainActor
    func close() async throws
}

protocol BaseDocumentProtocol: AnyObject, BaseDocumentGeneralProtocol {
    var infoContainer: InfoContainerProtocol { get }
    var objectRestrictions: ObjectRestrictions { get }
    var detailsStorage: ObjectDetailsStorage { get }
    var children: [BlockInformation] { get }
    var parsedRelations: ParsedRelations { get }
    var isLocked: Bool { get }
    var isEmpty: Bool { get }
    var isOpened: Bool { get }
    var isArchived: Bool { get }
    
    var parsedRelationsPublisher: AnyPublisher<ParsedRelations, Never> { get }
    var childrenPublisher: AnyPublisher<[BlockInformation], Never> { get }
    var syncPublisher: AnyPublisher<Void, Never> { get }
    var resetBlocksSubject: PassthroughSubject<Set<BlockId>, Never> { get }
    
    func resetSubscriptions()
}
