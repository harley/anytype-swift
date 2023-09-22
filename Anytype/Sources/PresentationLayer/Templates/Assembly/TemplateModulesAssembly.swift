import Services
import SwiftUI

protocol TemplateModulesAssemblyProtocol {
    @MainActor
    func buildTemplateSelection(
        setDocument: SetDocumentProtocol,
        viewId: String,
        mode: SetObjectSettingsMode
    ) -> TemplatesSelectionView
}

final class TemplateModulesAssembly: TemplateModulesAssemblyProtocol {
    private let serviceLocator: ServiceLocator
    private let uiHelperDI: UIHelpersDIProtocol
    
    init(serviceLocator: ServiceLocator, uiHelperDI: UIHelpersDIProtocol) {
        self.serviceLocator = serviceLocator
        self.uiHelperDI = uiHelperDI
    }
    
    @MainActor
    func buildTemplateSelection(
        setDocument: SetDocumentProtocol,
        viewId: String,
        mode: SetObjectSettingsMode
    ) -> TemplatesSelectionView {
        TemplatesSelectionView(
            model: .init(
                mode: mode,
                interactor: DataviewTemplateSelectionInteractorProvider(
                    setDocument: setDocument,
                    viewId: viewId,
                    installedObjectTypesProvider: self.serviceLocator.installedObjectTypesProvider(),
                    subscriptionService: TemplatesSubscriptionService(subscriptionService: self.serviceLocator.subscriptionService()),
                    dataviewService: DataviewService(
                        objectId: setDocument.objectId,
                        blockId: nil,
                        prefilledFieldsBuilder: SetPrefilledFieldsBuilder()
                    )
                ),
                setDocument: setDocument,
                templatesService: self.serviceLocator.templatesService,
                toastPresenter: self.uiHelperDI.toastPresenter()
            )
        )
    }
}
