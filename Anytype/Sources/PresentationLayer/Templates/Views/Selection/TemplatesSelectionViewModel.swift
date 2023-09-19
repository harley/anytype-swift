import Foundation
import AnytypeCore
import Services
import Combine
import SwiftUI

@MainActor
final class TemplatesSelectionViewModel: ObservableObject {
    @Published var isEditingState = false
    @Published var templates = [TemplatePreviewViewModel]()
    @Published var objectTypes = [ObjectTypeConfiguration]()
    
    var templateEditingHandler: RoutingAction<BlockId>?
    
    private var userTemplates = [TemplatePreviewModel]() {
        didSet {
            updateTemplatesList()
        }
    }
    
    private let interactor: TemplateSelectionInteractorProvider
    private let setDocument: SetDocumentProtocol
    private let installedObjectTypesProvider: InstalledObjectTypesProviderProtocol
    private let templatesService: TemplatesServiceProtocol
    private let toastPresenter: ToastPresenterProtocol
    private let onTemplateSelection: (BlockId?) -> Void
    private let onObjectTypesSearchAction: () -> Void
    private var cancellables = [AnyCancellable]()
    
    init(
        interactor: TemplateSelectionInteractorProvider,
        setDocument: SetDocumentProtocol,
        installedObjectTypesProvider: InstalledObjectTypesProviderProtocol,
        templatesService: TemplatesServiceProtocol,
        toastPresenter: ToastPresenterProtocol,
        onTemplateSelection: @escaping (BlockId?) -> Void,
        onObjectTypesSearchAction: @escaping () -> Void
    ) {
        self.interactor = interactor
        self.setDocument = setDocument
        self.installedObjectTypesProvider = installedObjectTypesProvider
        self.templatesService = templatesService
        self.toastPresenter = toastPresenter
        self.onTemplateSelection = onTemplateSelection
        self.onObjectTypesSearchAction = onObjectTypesSearchAction
        
        updateTemplatesList()
        setupSubscriptions()
    }
    
    func onTemplateTap(model: TemplatePreviewModel) {
        switch model.mode {
        case .installed(let templateModel):
            onTemplateSelection(templateModel.id)
            AnytypeAnalytics.instance().logTemplateSelection(
                objectType: templateModel.isBundled ? .object(typeId: templateModel.id) : .custom,
                route: setDocument.isCollection() ? .collection : .set
            )
        case .blank:
            onTemplateSelection("")
            AnytypeAnalytics.instance().logTemplateSelection(
                objectType: nil,
                route: setDocument.isCollection() ? .collection : .set
            )
        case .addTemplate:
            onAddTemplateTap()
        }
    }
    
    func onAddTemplateTap() {
        let objectTypeId = interactor.objectTypeId.rawValue
        Task { [weak self] in
            do {
                guard let objectId = try await self?.templatesService.createTemplateFromObjectType(objectTypeId: objectTypeId) else {
                    return
                }
                AnytypeAnalytics.instance().logTemplateCreate(objectType: .object(typeId: objectTypeId))
                self?.templateEditingHandler?(objectId)
                self?.toastPresenter.showObjectCompositeAlert(
                    prefixText: Loc.Templates.Popup.wasAddedTo,
                    objectId: self?.interactor.objectTypeId.rawValue ?? "",
                    tapHandler: { }
                )
            } catch {
                anytypeAssertionFailure(error.localizedDescription)
            }
        }
    }
    
    func setTemplateAsDefault(templateId: BlockId) {
        Task {
            do {
                try await interactor.setDefaultTemplate(templateId: templateId)
                toastPresenter.show(message: Loc.Templates.Popup.default)
            }
        }
    }
    
    private func startSubscription() {
        Task { [weak self] in
            guard let self else { return }
            await installedObjectTypesProvider.startSubscription()
        }
    }
    
    private func setupSubscriptions() {
        // Object types
        startSubscription()
        installedObjectTypesProvider.objectTypesPublisher.sink { [weak self] objectTypes in
            guard let self else { return }
            updateObjectTypes(objectTypes)
        }.store(in: &cancellables)
        
        // Templates
        interactor.userTemplates.sink { [weak self] templates in
            if let userTemplates = self?.userTemplates,
                userTemplates != templates {
                self?.userTemplates = templates
            }
        }.store(in: &cancellables)
    }
    
    private func updateObjectTypes(_ objectTypes: [ObjectType]) {
        var convertedObjectTypes = objectTypes.map { type in
            ObjectTypeConfiguration(
                id: type.id,
                icon: .object(.emoji(type.iconEmoji)),
                title: type.name,
                isSelected: false,
                onTap: {}
            )
        }
        let searchItem = ObjectTypeConfiguration(
            id: "Search",
            icon: .asset(.X18.search),
            title: nil,
            isSelected: false,
            onTap: onObjectTypesSearchAction
        )
        convertedObjectTypes.insert(searchItem, at: 0)
        self.objectTypes = convertedObjectTypes
    }
    
    private func handleTemplateOption(
        option: TemplateOptionAction,
        templateViewModel: TemplatePreviewModel
    ) {
        Task {
            do {
                switch option {
                case .delete:
                    try await templatesService.deleteTemplate(templateId: templateViewModel.id)
                    toastPresenter.show(message: Loc.Templates.Popup.removed)
                case .duplicate:
                    try await templatesService.cloneTemplate(blockId: templateViewModel.id)
                    toastPresenter.show(message: Loc.Templates.Popup.duplicated)
                case .editTemplate:
                    templateEditingHandler?(templateViewModel.id)
                case .setAsDefault:
                    setTemplateAsDefault(templateId: templateViewModel.id)
                }
                
                handleAnalytics(option: option, templateViewModel: templateViewModel)
            } catch {
                anytypeAssertionFailure(error.localizedDescription)
            }
        }
    }
    
    private func handleAnalytics(option: TemplateOptionAction, templateViewModel: TemplatePreviewModel) {
        guard case let .installed(templateModel) = templateViewModel.mode else {
            return
        }
        
        let objectType: AnalyticsObjectType = templateModel.isBundled ? .object(typeId: templateModel.id) : .custom
        
        
        switch option {
        case .editTemplate:
            AnytypeAnalytics.instance().logTemplateEditing(objectType: objectType, route: setDocument.isCollection() ? .collection : .set)
        case .delete:
            AnytypeAnalytics.instance().logMoveToBin(true)
        case .duplicate:
            AnytypeAnalytics.instance().logTemplateDuplicate(objectType: objectType, route: setDocument.isCollection() ? .collection : .set)
        case .setAsDefault:
            break // Interactor resposibility
        }
    }
    
    private func updateTemplatesList() {
        var templates = [TemplatePreviewModel]()

        if !userTemplates.contains(where: { $0.isDefault }) {
            templates.append(.init(mode: .blank, alignment: .left, isDefault: true))
        } else {
            templates.append(.init(mode: .blank, alignment: .left, isDefault: false))
        }
        
        templates.append(contentsOf: userTemplates)
        templates.append(.init(mode: .addTemplate, alignment: .center, isDefault: false))
        
        withAnimation {
            self.templates = templates.map { model in
                TemplatePreviewViewModel(
                    model: model,
                    onOptionSelection: { [weak self] option in
                        self?.handleTemplateOption(option: option, templateViewModel: model)
                    }
                )
            }
        }
    }
    
    deinit {
        installedObjectTypesProvider.stopSubscription()
    }
}

extension TemplatePreviewModel {
    init(objectDetails: ObjectDetails, isDefault: Bool) {
        self = .init(
            mode: .installed(.init(
                id: objectDetails.id,
                title: objectDetails.title,
                header: HeaderBuilder.buildObjectHeader(
                    details: objectDetails,
                    usecase: .templatePreview,
                    presentationUsecase: .editor,
                    onIconTap: {},
                    onCoverTap: {}
                ),
                isBundled: objectDetails.templateIsBundled,
                style: objectDetails.layoutValue == .todo ? .todo(objectDetails.isDone) : .none
            )
            ),
            alignment: objectDetails.layoutAlignValue,
            isDefault: isDefault
        )
    }
}

extension TemplatePreviewModel {
    var isEditable: Bool {
        switch mode {
        case .blank, .installed:
            return true
        case .addTemplate:
            return false
        }
    }
}
