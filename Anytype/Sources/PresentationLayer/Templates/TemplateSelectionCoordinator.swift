import UIKit
import Services
import SwiftUI
import AnytypeCore

enum SetObjectSettingsMode {
    case create
    case `default`
    
    var title: String {
        switch self {
        case .create:
            return Loc.createObject
        case .default:
            return Loc.TemplateSelection.selectTemplate
        }
    }
}


protocol TemplateSelectionCoordinatorProtocol: AnyObject {
    @MainActor
    func showTemplatesSelection(
        setDocument: SetDocumentProtocol,
        viewId: String,
        floatingPanelStyle: Bool,
        onObjectTypeSelection: @escaping (BlockId?) -> (),
        onTemplateSelection: @escaping (BlockId?, BlockId?) -> ()
    )
    
    func showTemplateEditing(
        objectTypeId: BlockId,
        blockId: BlockId,
        onTemplateSelection: @escaping (BlockId, BlockId) -> Void,
        onSetAsDefaultTempalte: @escaping (BlockId) -> Void
    )
}

final class TemplateSelectionCoordinator: TemplateSelectionCoordinatorProtocol {
    private let mode: SetObjectSettingsMode
    private let navigationContext: NavigationContextProtocol
    private let templatesModuleAssembly: TemplateModulesAssembly
    private let editorAssembly: EditorAssembly
    private let newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    private let objectSettingCoordinator: ObjectSettingsCoordinatorProtocol
    private var handler: TemplateSelectionObjectSettingsHandler?
    
    init(
        mode: SetObjectSettingsMode,
        navigationContext: NavigationContextProtocol,
        templatesModulesAssembly: TemplateModulesAssembly,
        editorAssembly: EditorAssembly,
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol,
        objectSettingCoordinator: ObjectSettingsCoordinatorProtocol
    ) {
        self.mode = mode
        self.navigationContext = navigationContext
        self.templatesModuleAssembly = templatesModulesAssembly
        self.newSearchModuleAssembly = newSearchModuleAssembly
        self.editorAssembly = editorAssembly
        self.objectSettingCoordinator = objectSettingCoordinator
    }
    
    @MainActor
    func showTemplatesSelection(
        setDocument: SetDocumentProtocol,
        viewId: String,
        floatingPanelStyle: Bool,
        onObjectTypeSelection: @escaping (BlockId?) -> (),
        onTemplateSelection: @escaping (BlockId?, BlockId?) -> ()
    ) {
        let view = templatesModuleAssembly.buildTemplateSelection(
            setDocument: setDocument,
            viewId: viewId,
            mode: mode
        )
        let model = view.model
        
        view.model.onObjectTypeSelection = { objectTypeId in
            onObjectTypeSelection(objectTypeId)
        }
        
        view.model.onTemplateSelection = { [weak self] objectTypeId, templateId in
            guard let self else { return }
            switch mode {
            case .create:
                navigationContext.dismissTopPresented(animated: true) {
                    onTemplateSelection(objectTypeId, templateId)
                }
            case .default:
                onTemplateSelection(objectTypeId, templateId)
            }
        }
        
        view.model.templateEditingHandler = { [weak self, weak model, weak navigationContext] templateId in
            self?.showTemplateEditing(
                objectTypeId: "",
                blockId: templateId,
                onTemplateSelection: onTemplateSelection,
                onSetAsDefaultTempalte: { templateId in
                    model?.setTemplateAsDefault(templateId: templateId)
                    navigationContext?.dismissTopPresented(animated: true, completion: nil)
                }
            )
        }
        
        view.model.onObjectTypesSearchAction = { [weak self] in
            self?.showTypesSearch(
                setDocument: setDocument,
                selectedObjectId: nil,
                onSelect: { objectTypeId in
                    onObjectTypeSelection(objectTypeId)
                }
            )
        }
        
        let viewModel = AnytypePopupViewModel(
            contentView: view,
            popupLayout: .constantHeight(height: TemplatesSelectionView.height, floatingPanelStyle: true, needBottomInset: false))
        let popup = AnytypePopup(
            viewModel: viewModel,
            floatingPanelStyle: floatingPanelStyle,
            configuration: .init(isGrabberVisible: false, dismissOnBackdropView: true, skipThroughGestures: false)
        )
        navigationContext.present(popup)
    }
    
    func showTemplateEditing(
        objectTypeId: BlockId,
        blockId: BlockId,
        onTemplateSelection: @escaping (BlockId, BlockId) -> Void,
        onSetAsDefaultTempalte: @escaping (BlockId) -> Void
    ) {
        let editorPage = editorAssembly.buildEditorModule(
            browser: nil,
            data: .page(
                .init(
                    objectId: blockId,
                    isSupportedForEdit: true,
                    isOpenedForPreview: false,
                    usecase: .templateEditing
                )
            )
        )
        handler = TemplateSelectionObjectSettingsHandler(useAsTemplateAction: onSetAsDefaultTempalte)
        let editingTemplateViewController = TemplateEditingViewController(
            editorViewController: editorPage.vc,
            onSettingsTap: { [weak self] in
                guard let self = self, let handler = self.handler else { return }
                
                self.objectSettingCoordinator.startFlow(objectId: blockId, delegate: handler, output: nil)
            }, onSelectTemplateTap: { [weak self] in
                guard let self else { return }
                switch mode {
                case .create:
                    navigationContext.dismissAllPresented(animated: true) {
                        onTemplateSelection(objectTypeId, blockId)
                    }
                case .default:
                    navigationContext.dismissTopPresented(animated: true) {
                        onTemplateSelection(objectTypeId, blockId)
                    }
                }
            }
        )

        navigationContext.present(editingTemplateViewController)
    }
    
    private func showTypesSearch(
        setDocument: SetDocumentProtocol,
        selectedObjectId: BlockId?,
        onSelect: @escaping (BlockId) -> ()
    ) {
        let view = newSearchModuleAssembly.objectTypeSearchModule(
            title: Loc.changeType,
            selectedObjectId: selectedObjectId,
            excludedObjectTypeId: setDocument.details?.type,
            showBookmark: true,
            showSetAndCollection: true,
            browser: nil
        ) { [weak self] type in
            self?.navigationContext.dismissTopPresented()
            onSelect(type.id)
        }
        
        navigationContext.presentSwiftUIView(view: view)
    }
}

final class TemplateSelectionObjectSettingsHandler: ObjectSettingsModuleDelegate {
    let useAsTemplateAction: (BlockId) -> Void
    
    init(useAsTemplateAction: @escaping (BlockId) -> Void) {
        self.useAsTemplateAction = useAsTemplateAction
    }
    
    func didCreateLinkToItself(selfName: String, data: EditorScreenData) {
        anytypeAssertionFailure("Should be disabled in restrictions. Check template restrinctions")
    }
    
    func didCreateTemplate(templateId: BlockId) {
        anytypeAssertionFailure("Should be disabled in restrictions. Check template restrinctions")
    }
    
    func didTapUseTemplateAsDefault(templateId: BlockId) {
        useAsTemplateAction(templateId)
    }
}
