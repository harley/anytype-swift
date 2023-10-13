import UIKit
import Combine
import Services
import AnytypeCore

final class ChangeTypeAccessoryViewModel {
    typealias TypeItem = HorizontalListItem

    @Published private(set) var isTypesViewVisible: Bool = false
    @Published private(set) var supportedTypes = [TypeItem]()
    var onDoneButtonTap: (() -> Void)?

    private var allSupportedTypes = [TypeItem]()
    private let router: EditorRouterProtocol
    private let handler: BlockActionHandlerProtocol
    private let searchService: SearchServiceProtocol
    private let objectService: ObjectActionsServiceProtocol
    private let objectTypeProvider: ObjectTypeProviderProtocol
    private let document: BaseDocumentProtocol
    private lazy var searchItem = TypeItem.searchItem { [weak self] in self?.onSearchTap() }

    private var cancellables = [AnyCancellable]()

    init(
        router: EditorRouterProtocol,
        handler: BlockActionHandlerProtocol,
        searchService: SearchServiceProtocol,
        objectService: ObjectActionsServiceProtocol,
        objectTypeProvider: ObjectTypeProviderProtocol,
        document: BaseDocumentProtocol
    ) {
        self.router = router
        self.handler = handler
        self.searchService = searchService
        self.objectService = objectService
        self.objectTypeProvider = objectTypeProvider
        self.document = document

        subscribeOnDocumentChanges()
    }

    func handleDoneButtonTap() {
        onDoneButtonTap?()
    }

    func toggleChangeTypeState() {
        isTypesViewVisible.toggle()
    }

    private func fetchSupportedTypes() {
        Task { @MainActor [weak self] in
            let supportedTypes = try? await self?.searchService
                .searchObjectTypes(
                    text: "",
                    filteringTypeId: nil,
                    shouldIncludeSets: true,
                    shouldIncludeCollections: true,
                    shouldIncludeBookmark: false,
                    spaceId: document.spaceId
                ).map { type in
                    TypeItem(from: type, handler: { [weak self] in
                        self?.onTypeTap(type: ObjectType(details: type))
                    })
                }
            
            supportedTypes.map { self?.allSupportedTypes = $0 }
        }
    }

    private func onTypeTap(type: ObjectType) {
        defer { logSelectObjectType(type: type) }
        
        if type.recommendedLayout == .set {
            Task { @MainActor in
                document.resetSubscriptions() // to avoid glytch with premature document update
                try await handler.setObjectSetType()
                try await document.close()
                router.replaceCurrentPage(with: .set(.init(objectId: document.objectId, spaceId: document.spaceId, isSupportedForEdit: true)))
            }
            return
        }
        
        if type.recommendedLayout == .collection {
            Task { @MainActor in
                document.resetSubscriptions() // to avoid glytch with premature document update
                try await handler.setObjectCollectionType()
                try await document.close()
                router.replaceCurrentPage(with: .set(.init(objectId: document.objectId, spaceId: document.spaceId, isSupportedForEdit: true)))
            }
            return
        }

        Task { @MainActor in
            try await handler.setObjectType(type: type)
            applyDefaultTemplateIfNeeded(typeId: type.id)
        }
    }
    
    private func logSelectObjectType(type: ObjectType) {
        AnytypeAnalytics.instance().logSelectObjectType(type.analyticsType)
    }
    
    private func applyDefaultTemplateIfNeeded(typeId: String) {
        Task {
            guard let defaultTemplateId = try? objectTypeProvider.objectType(id: typeId).defaultTemplateId,
                      defaultTemplateId.isNotEmpty else { return }
            
            try await objectService.applyTemplate(objectId: document.objectId, templateId: defaultTemplateId)
        }
    }

    private func subscribeOnDocumentChanges() {
        document.updatePublisher.sink { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.fetchSupportedTypes()
                self?.updateSupportedTypes()
            }
            
        }.store(in: &cancellables)
    }
    
    private func updateSupportedTypes() {
        let filteredItems = allSupportedTypes.filter {
            $0.id != document.details?.type
        }
        supportedTypes = [searchItem] + filteredItems
        
    }
    
    private func fetchSupportedTypes() async {
        let supportedTypes = try? await searchService
            .searchObjectTypes(
                text: "",
                filteringTypeId: nil,
                shouldIncludeSets: true,
                shouldIncludeCollections: true,
                shouldIncludeBookmark: false,
                spaceId: document.spaceId
            ).map { type in
                TypeItem(from: type, handler: { [weak self] in
                    self?.onTypeTap(type: ObjectType(details: type))
                })
            }
        
        supportedTypes.map { allSupportedTypes = $0 }
    }
    
    private func onSearchTap() {
        router.showTypesForEmptyObject(
            selectedObjectId: document.details?.type,
            onSelect: { [weak self] type in
                self?.onTypeTap(type: type)
            }
        )
    }
}

extension ChangeTypeAccessoryViewModel: TypeListItemProvider {
    var typesPublisher: AnyPublisher<[HorizontalListItem], Never> {
        $supportedTypes.eraseToAnyPublisher()
    }
}
