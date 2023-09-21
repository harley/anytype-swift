import Combine
import Services
import AnytypeCore

protocol TemplateSelectionInteractorProvider {
    var userTemplates: AnyPublisher<[TemplatePreviewModel], Never> { get }
    
    var defaultObjectTypeId: ObjectTypeId { get }
    var objectTypesConfigPublisher: AnyPublisher<ObjectTypesConfiguration, Never> { get }
    
    func setDefaultObjectType(objectTypeId: BlockId) async throws
    func setDefaultTemplate(templateId: BlockId) async throws
}

final class DataviewTemplateSelectionInteractorProvider: TemplateSelectionInteractorProvider {
    var userTemplates: AnyPublisher<[TemplatePreviewModel], Never> {
        Publishers.CombineLatest3($templatesDetails, $defaultTemplateId, $typeDefaultTemplateId)
            .map { details, defaultTemplateId, typeDefaultTemplateId in
                let templateId = defaultTemplateId.isNotEmpty ? defaultTemplateId : typeDefaultTemplateId
                return details.map {
                    TemplatePreviewModel(
                        objectDetails: $0,
                        isDefault: $0.id == templateId
                    )
                }
            }
            .eraseToAnyPublisher()
    }
    
    var objectTypesConfigPublisher: AnyPublisher<ObjectTypesConfiguration, Never> {
        Publishers.CombineLatest(installedObjectTypesProvider.objectTypesPublisher, $defaultObjectTypeId)
            .map { objectTypes, defaultObjectTypeId in
                return ObjectTypesConfiguration(
                    objectTypes: objectTypes,
                    defaultObjectTypeId: defaultObjectTypeId
                )
            }
            .eraseToAnyPublisher()
    }
    
    private let setDocument: SetDocumentProtocol
    private let viewId: String
    
    private let subscriptionService: TemplatesSubscriptionServiceProtocol
    private let installedObjectTypesProvider: InstalledObjectTypesProviderProtocol
    private let dataviewService: DataviewServiceProtocol
    
    @Published private var templatesDetails = [ObjectDetails]()
    @Published private var defaultTemplateId: BlockId
    @Published private var typeDefaultTemplateId: BlockId = .empty
    @Published var defaultObjectTypeId: ObjectTypeId
    
    private var dataView: DataviewView
    
    private var cancellables = [AnyCancellable]()
    
    init(
        setDocument: SetDocumentProtocol,
        viewId: String,
        installedObjectTypesProvider: InstalledObjectTypesProviderProtocol,
        subscriptionService: TemplatesSubscriptionServiceProtocol,
        dataviewService: DataviewServiceProtocol
    ) {
        self.setDocument = setDocument
        self.viewId = viewId
        self.dataView = setDocument.view(by: viewId)
        self.defaultTemplateId = dataView.defaultTemplateID ?? .empty
        self.subscriptionService = subscriptionService
        self.installedObjectTypesProvider = installedObjectTypesProvider
        self.dataviewService = dataviewService
        
        let defaultObjectTypeID = dataView.defaultObjectTypeIDWithFallback
        if setDocument.isTypeSet() {
            if let firstSetOf = setDocument.details?.setOf.first {
                self.defaultObjectTypeId = .dynamic(firstSetOf)
            } else {
                self.defaultObjectTypeId = .dynamic(defaultObjectTypeID)
                anytypeAssertionFailure("Couldn't find default object type in sets", info: ["setId": setDocument.objectId])
            }
        } else {
            self.defaultObjectTypeId = .dynamic(defaultObjectTypeID)
        }
        
        subscribeOnDocmentUpdates()
        loadTemplates()
    }
    
    private func subscribeOnDocmentUpdates() {
        setDocument.syncPublisher.sink { [weak self] in
            guard let self else { return }
            dataView = setDocument.view(by: dataView.id)
            if defaultTemplateId != dataView.defaultTemplateID {
                defaultTemplateId = dataView.defaultTemplateID ?? .empty
            }
            if !setDocument.isTypeSet(), defaultObjectTypeId.rawValue != dataView.defaultObjectTypeIDWithFallback {
                defaultObjectTypeId = .dynamic(dataView.defaultObjectTypeIDWithFallback)
                loadTemplates()
            }
        }.store(in: &cancellables)
        
        startObjectTypesSubscription()
        installedObjectTypesProvider.objectTypesPublisher.sink { [weak self] objectTypes in
            guard let self else { return }
            let defaultTemplateId = objectTypes.first { [weak self] in
                guard let self else { return false }
                return $0.id == defaultObjectTypeId.rawValue
            }?.defaultTemplateId ?? .empty
            if typeDefaultTemplateId != defaultTemplateId {
                typeDefaultTemplateId = defaultTemplateId
            }
        }.store(in: &cancellables)
    }
    
    private func startObjectTypesSubscription() {
        Task { [weak self] in
            guard let self else { return }
            await installedObjectTypesProvider.startSubscription()
        }
    }
    
    private func loadTemplates() {
        subscriptionService.startSubscription(objectType: defaultObjectTypeId) { [weak self] _, update in
            self?.templatesDetails.applySubscriptionUpdate(update)
        }
    }
    
    func setDefaultObjectType(objectTypeId: BlockId) async throws {
        let updatedDataView = dataView.updated(defaultObjectTypeID: objectTypeId)
        try await dataviewService.updateView(updatedDataView)
    }
    
    func setDefaultTemplate(templateId: BlockId) async throws {
        let updatedDataView = dataView.updated(defaultTemplateID: templateId)
        try await dataviewService.updateView(updatedDataView)
    }
    
    deinit {
        installedObjectTypesProvider.stopSubscription()
    }
}
