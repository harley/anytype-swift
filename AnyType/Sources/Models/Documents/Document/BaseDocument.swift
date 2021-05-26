import Foundation
import BlocksModels
import Combine
import os

protocol BaseDocument: AnyObject {
    var documentId: BlockId? { get }
    var defaultDetailsActiveModel: DetailsActiveModel { get }
    var userSession: BlockUserSessionModelProtocol? { get }
    var rootActiveModel: BlockActiveRecordModelProtocol? { get }
    
    func pageDetailsPublisher() -> AnyPublisher<DetailsProviderProtocol, Never>
    func open(_ value: ServiceSuccess)
    func handle(events: PackOfEvents)
    func updatePublisher() -> AnyPublisher<DocumentViewModelUpdateResult, Never>
    
    func getDetails(by id: DetailsId) -> DetailsActiveModel?
}

private extension LoggerCategory {
    static let baseDocument: Self = "BaseDocument"
}

private extension BaseDocumentImpl {
    struct UpdateResult {
        var updates: EventHandlerUpdate
        var models: [BlockActiveRecordModelProtocol]
    }
}

final class BaseDocumentImpl: BaseDocument {
    var rootActiveModel: BlockActiveRecordModelProtocol? {
        guard let rootId = rootModel?.rootId else { return nil }
        return rootModel?.blocksContainer.choose(by: rootId)
    }
    
    var userSession: BlockUserSessionModelProtocol? {
        rootModel?.blocksContainer.userSession
    }

    var documentId: BlockId? { self.rootId }
    
    private var rootId: BlockId? { self.rootModel?.rootId }
    
    /// RootModel
    private var rootModel: ContainerModel? {
        didSet {
            self.handleNewRootModel(self.rootModel)
        }
    }
    
    private let eventProcessor = EventProcessor()
    private let transformer = TreeBlockBuilder.defaultValue
    
    /// Details Active Models
    /// But we have a lot of them, so, we should keep a list of them.
    /// Or we could create them on the fly.
    ///
    /// This one is active model of default ( or main ) document id (smartblock id).
    ///
    let defaultDetailsActiveModel = DetailsActiveModel()
    
    /// This event subject is a subject for events from default details active model.
    ///
    /// When we set details, we need to listen for returned value ( success result ).
    /// This success result should be handled by our event processor.
    ///
    private var detailsEventSubject: PassthroughSubject<PackOfEvents, Never> = .init()
    
    /// It is simple event subject subscription.
    ///
    /// We use it to subscribe on event subject.
    ///
    private var detailsEventSubjectSubscription: AnyCancellable?
    
    /// Services
    private var smartblockService: BlockActionsServiceSingle = .init()
    
    deinit {
        rootId.flatMap { rootId in
            _ = self.smartblockService.close(contextID: rootId, blockID: rootId)
        }
    }
    
    private lazy var blocksConverter = CompoundViewModelConverter(self)
    func updatePublisher() -> AnyPublisher<DocumentViewModelUpdateResult, Never> {
        modelsAndUpdatesPublisher()
            .receiveOnMain()
            .map { [weak self] update in
                DocumentViewModelUpdateResult(
                    updates: update.updates,
                    models: self?.blocksConverter.convert(update.models) ?? []
                )
            }.eraseToAnyPublisher()
    }

    // MARK: - Handle Open
    private func open(_ blockId: BlockId) -> AnyPublisher<Void, Error> {
        self.smartblockService.open(contextID: blockId, blockID: blockId).map { [weak self] serviceSuccess in
            self?.handleOpen(serviceSuccess)
        }.eraseToAnyPublisher()
    }
    
    func open(_ value: ServiceSuccess) {
        self.handleOpen(value)
        
        // Event processor must receive event to send updates to subscribers.
        // Events are `blockShow`, actually.
        self.eventProcessor.handle(
            events: PackOfEvents(
                contextId: value.contextID,
                events: value.messages,
                ourEvents: []
            )
        )
    }
    
    private func handleOpen(_ value: ServiceSuccess) {
        let blocks = self.eventProcessor.handleBlockShow(
            events: .init(contextId: value.contextID, events: value.messages, ourEvents: [])
        )
        guard let event = blocks.first else { return }
        
        // Build blocks tree and create new container
        // And then, sync builders
        let rootId = value.contextID
        
        let blocksContainer = self.transformer.buildBlocksTree(from: event.blocks, with: rootId)
        let parsedDetails = event.details.map(TopLevelBuilderImpl.detailsBuilder.build(information:))
        
        let detailsStorage = TopLevelBuilderImpl.detailsBuilder.emptyStorage()
        parsedDetails.forEach { detailsStorage.add($0) }
        
        // Add details models to process.
        self.rootModel = TopLevelBuilderImpl.createRootContainer(rootId: rootId, blockContainer: blocksContainer, detailsContainer: detailsStorage)
    }

    // MARK: - Configure Details

    // Configure a subscription on events stream from details.
    // We need it for set details success result to process it in our event processor.
    private func listenDefaultDetails() {
        self.detailsEventSubjectSubscription = self.detailsEventSubject.sink(receiveValue: { [weak self] (value) in
            self?.handle(events: value)
        })
    }
    
    /// Configure default details for a container.
    ///
    /// It is the first place where you can configure default details with various handlers and other stuff.
    ///
    /// - Parameter container: A container in which this details is default.
    private func configureDetails(for container: ContainerModel?) {
        guard let container = container,
              let rootId = container.rootId,
              let ourModel = container.detailsContainer.choose(by: rootId)
        else {
            Logger.create(.baseDocument).debug("configureDetails(for:). Our document is not ready yet")
            return
        }
        let publisher = ourModel.changeInformationPublisher()
        self.defaultDetailsActiveModel.configured(documentId: rootId)
        self.defaultDetailsActiveModel.configured(publisher: publisher)
        self.defaultDetailsActiveModel.configured(eventSubject: self.detailsEventSubject)
        self.listenDefaultDetails()
    }

    // MARK: - Handle new root model
    private func handleNewRootModel(_ container: ContainerModel?) {
        if let container = container {
            eventProcessor.configured(container)
        }
        configureDetails(for: container)
    }
    
    /// Returns a flatten list of active models of document.
    /// - Returns: A list of active models.
    private func getModels() -> [BlockActiveRecordModelProtocol] {
        guard let container = self.rootModel, let rootId = container.rootId, let activeModel = container.blocksContainer.choose(by: rootId) else {
            Logger.create(.baseDocument).debug("getModels. Our document is not ready yet")
            return []
        }
        return BlockFlattener.flatten(root: activeModel, in: container, options: .default)
    }
    
    // MARK: - Publishers

    
    /// A publisher of updates and current models.
    /// It could filter out updates with empty payload.
    ///
    /// - Returns: A publisher of updates and related models to these updates.
    private func modelsAndUpdatesPublisher(
    ) -> AnyPublisher<UpdateResult, Never> {
        self.updatesPublisher().filter(\.hasUpdate)
        .map { [weak self] updates in
            if let rootId = self?.rootId,
               let container = self?.rootModel,
               let rootModel = container.blocksContainer.choose(by: rootId) {
                BlockFlattener.flattenIds(root: rootModel, in: container, options: .default)
            }
            return UpdateResult(updates: updates, models: self?.models(from: updates) ?? [])
        }.eraseToAnyPublisher()
    }
    
    /// A publisher of event processor did process events.
    /// It fires when event processor did finish process events.
    ///
    /// - Returns: A publisher of updates.
    private func updatesPublisher() -> AnyPublisher<EventHandlerUpdate, Never> {
        self.eventProcessor.didProcessEventsPublisher
    }
    
    private func models(from updates: EventHandlerUpdate) -> [BlockActiveRecordModelProtocol] {
        switch updates {
        case .general:
            return getModels()
        case .update:
            return []
        }
    }

    // MARK: - Details
    /// Return configured details for provided id for listening events.
    ///
    /// Note.
    ///
    /// Provided `id` should be in `a list of details of opened document`.
    /// If you receive a error, assure yourself, that you've opened a document before accessing details.
    ///
    /// - Parameter id: Id of item for which we would like to listen events.
    /// - Returns: details active model.
    ///
    func getDetails(by id: DetailsId) -> DetailsActiveModel? {
        guard let value = self.rootModel?.detailsContainer.choose(by: id) else {
            Logger.create(.baseDocument).debug("getDetails(by:). Our document is not ready yet")
            return nil
        }
        let result: DetailsActiveModel = .init()
        result.configured(documentId: id)
        result.configured(publisher: value.changeInformationPublisher())
        return result
    }
    
    /// Convenient publisher for accessing default details properties by typed enum.
    /// - Returns: Publisher of default details properties.
    func pageDetailsPublisher() -> AnyPublisher<DetailsProviderProtocol, Never> {
        defaultDetailsActiveModel.$currentDetails.eraseToAnyPublisher()
    }

    // MARK: - Details Conversion to Blocks.
    /// Deprecated.
    ///
    /// Now we use view models that uses only blocks.
    /// So, we have to convert our details to blocks first.
    private func convert(_ detailsActiveModel: DetailsActiveModel, of kind: DetailsKind) -> BlockActiveRecordModelProtocol? {
        guard let rootId = self.rootId else {
            Logger.create(.baseDocument).debug("convert(_:of:). Our document is not ready yet.")
            return nil
        }
                
        let detailsContent: DetailsEntry<AnyHashable>? = {
            let details = detailsActiveModel.currentDetails

            switch kind {
            case .name:
                return DetailsEntry(
                    kind: .name,
                    value: details.name ?? ""
                )
            case .iconEmoji:
                return details.iconEmoji.flatMap {
                    DetailsEntry(
                        kind: .iconEmoji,
                        value: $0
                    )
                }
            case .iconImage:
                return DetailsEntry(
                    kind: .iconImage,
                    value: details.iconImage ?? ""
                )
            case .coverId:
                assertionFailure()
                return nil
            case .coverType:
                assertionFailure()
                return nil
            }
        }()
        
        guard let unwrappedDetailsContent = detailsContent else { return nil }
        
        let block = BlockInformation.DetailsAsBlockConverter(
            blockId: rootId
        ).convertDetailsToBlock(unwrappedDetailsContent)
        
        let blockFromContainer = self.rootModel?.blocksContainer.get(by: block.information.id)
        if !blockFromContainer.isNil {
            Logger.create(.baseDocument).debug("convert(_:of:). We have already added details with id: \(block.information.id)")
        }
        else {
            self.rootModel?.blocksContainer.add(block)
        }
        
        return self.rootModel?.blocksContainer.choose(by: block.information.id)
    }

    // MARK: - Events
    
    /// Handle events initiated by user.
    ///
    /// - Parameter events: A pack of events.
    ///
    func handle(events: PackOfEvents) {
        self.eventProcessor.handle(events: events)
    }
}
