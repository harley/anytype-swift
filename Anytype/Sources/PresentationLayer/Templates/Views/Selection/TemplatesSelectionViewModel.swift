import Foundation
import AnytypeCore
import Services
import Combine
import SwiftUI

@MainActor
final class TemplatesSelectionViewModel: ObservableObject {
    @Published var isEditingState = false
    @Published var templates = [TemplatePreviewViewModel]()
    @Published var objectTypes = [InstalledObjectTypeViewModel]()
    var isTemplatesAvailable = true
    
    var onObjectTypeSelection: ((BlockId?) -> Void)?
    var onTemplateSelection: ((_ objectTypeId: BlockId?, _ templateId: BlockId?) -> Void)?
    var templateEditingHandler: RoutingAction<BlockId>?
    var onObjectTypesSearchAction: (() -> Void)?
    
    private var userTemplates = [TemplatePreviewModel]() {
        didSet {
            updateTemplatesList()
        }
    }
    private var selectedObjectTypeId: String = ""
    
    private let mode: SetObjectSettingsMode
    private let interactor: TemplateSelectionInteractorProvider
    private let setDocument: SetDocumentProtocol
    private let templatesService: TemplatesServiceProtocol
    private let toastPresenter: ToastPresenterProtocol
    private var cancellables = [AnyCancellable]()
    
    init(
        mode: SetObjectSettingsMode,
        interactor: TemplateSelectionInteractorProvider,
        setDocument: SetDocumentProtocol,
        templatesService: TemplatesServiceProtocol,
        toastPresenter: ToastPresenterProtocol
    ) {
        self.mode = mode
        self.interactor = interactor
        self.setDocument = setDocument
        self.templatesService = templatesService
        self.toastPresenter = toastPresenter
        
        updateTemplatesList()
        setupSubscriptions()
    }
    
    func onTemplateTap(model: TemplatePreviewModel) {
        switch model.mode {
        case .installed(let templateModel):
            onTemplateSelection?(selectedObjectTypeId, templateModel.id)
            AnytypeAnalytics.instance().logTemplateSelection(
                objectType: templateModel.isBundled ? .object(typeId: templateModel.id) : .custom,
                route: setDocument.isCollection() ? .collection : .set
            )
        case .blank:
            onTemplateSelection?(selectedObjectTypeId, "")
            AnytypeAnalytics.instance().logTemplateSelection(
                objectType: nil,
                route: setDocument.isCollection() ? .collection : .set
            )
        case .addTemplate:
            onAddTemplateTap()
        }
    }
    
    func onAddTemplateTap() {
        let objectTypeId = interactor.defaultObjectTypeId.rawValue
        Task { [weak self] in
            do {
                guard let objectId = try await self?.templatesService.createTemplateFromObjectType(objectTypeId: objectTypeId) else {
                    return
                }
                AnytypeAnalytics.instance().logTemplateCreate(objectType: .object(typeId: objectTypeId))
                self?.templateEditingHandler?(objectId)
                self?.toastPresenter.showObjectCompositeAlert(
                    prefixText: Loc.Templates.Popup.wasAddedTo,
                    objectId: self?.interactor.defaultObjectTypeId.rawValue ?? "",
                    tapHandler: { }
                )
            } catch {
                anytypeAssertionFailure(error.localizedDescription)
            }
        }
    }
    
    func setSelectedObjectType(objectTypeId: BlockId) {
        selectedObjectTypeId = objectTypeId
    }
    
    func setTemplateAsDefault(templateId: BlockId) {
        Task {
            do {
                try await interactor.setDefaultTemplate(templateId: templateId)
                toastPresenter.show(message: Loc.Templates.Popup.default)
            }
        }
    }
    
    private func setupSubscriptions() {
        // Templates
        interactor.userTemplates.sink { [weak self] templates in
            if let userTemplates = self?.userTemplates,
                userTemplates != templates {
                self?.userTemplates = templates
            }
        }.store(in: &cancellables)
        
//        guard mode == .objectType else { return }
        
        // Object types
        interactor.objectTypesConfigPublisher.sink { [weak self] objectTypesConfig in
            guard let self else { return }
            let defaultObjectType = objectTypesConfig.objectTypes.first {
                $0.id == objectTypesConfig.defaultObjectTypeId.rawValue
            }
            isTemplatesAvailable = defaultObjectType?.recommendedLayout.isTemplatesAvailable ?? false
            selectedObjectTypeId = selectedObjectTypeId.isEmpty ? objectTypesConfig.defaultObjectTypeId.rawValue : selectedObjectTypeId
            updateObjectTypes(objectTypesConfig)
        }.store(in: &cancellables)
    }
    
    private func updateObjectTypes(_ objectTypesConfig: ObjectTypesConfiguration) {
        let selectedObjectTypeId = mode == .create ? selectedObjectTypeId : objectTypesConfig.defaultObjectTypeId.rawValue
        var convertedObjectTypes = objectTypesConfig.objectTypes.map {  type in
            let isSelected = type.id == selectedObjectTypeId
            return InstalledObjectTypeViewModel(
                id: type.id,
                icon: .object(.emoji(type.iconEmoji)),
                title: type.name,
                isSelected: isSelected,
                onTap: { [weak self] in
                    self?.selectedObjectTypeId = type.id
                    self?.onObjectTypeSelection?(type.id)
                }
            )
        }
        let searchItem = InstalledObjectTypeViewModel(
            id: "Search",
            icon: .asset(.X18.search),
            title: nil,
            isSelected: false,
            onTap: { [weak self] in
                self?.onObjectTypesSearchAction?()
            }
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
