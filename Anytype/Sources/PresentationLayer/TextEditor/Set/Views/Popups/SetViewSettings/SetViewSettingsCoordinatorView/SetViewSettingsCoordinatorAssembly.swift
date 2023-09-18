import SwiftUI
import Services

protocol SetViewSettingsCoordinatorAssemblyProtocol {
    @MainActor
    func make(
        setDocument: SetDocumentProtocol,
        viewId: String,
        mode: SetViewSettingsMode,
        subscriptionDetailsStorage: ObjectDetailsStorage,
        navigationContext: NavigationContextProtocol
    ) -> AnyView
}

final class SetViewSettingsCoordinatorAssembly: SetViewSettingsCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    private let coordinatorsDI: CoordinatorsDIProtocol
    
    init(modulesDI: ModulesDIProtocol, coordinatorsDI: CoordinatorsDIProtocol) {
        self.modulesDI = modulesDI
        self.coordinatorsDI = coordinatorsDI
    }
    
    // MARK: - SetViewSettingsCoordinatorModuleAssemblyProtocol
    
    @MainActor
    func make(
        setDocument: SetDocumentProtocol,
        viewId: String,
        mode: SetViewSettingsMode,
        subscriptionDetailsStorage: ObjectDetailsStorage,
        navigationContext: NavigationContextProtocol
    ) -> AnyView {
        let templateSelectionCoordinator = TemplateSelectionCoordinator(
            navigationContext: navigationContext,
            templatesModulesAssembly: modulesDI.templatesAssembly(),
            editorAssembly: coordinatorsDI.editor(),
            newSearchModuleAssembly: modulesDI.newSearch(),
            objectSettingCoordinator: coordinatorsDI.objectSettings().make(browserController: nil)
        )
        return SetViewSettingsCoordinatorView(
            model: SetViewSettingsCoordinatorViewModel(
                setDocument: setDocument,
                viewId: viewId,
                mode: mode,
                subscriptionDetailsStorage: subscriptionDetailsStorage,
                templateSelectionCoordinator: templateSelectionCoordinator,
                setViewSettingsListModuleAssembly: self.modulesDI.setViewSettingsList(),
                setLayoutSettingsCoordinatorAssembly: self.coordinatorsDI.setLayoutSettings(),
                setRelationsCoordinatorAssembly: self.coordinatorsDI.setRelations(),
                setFiltersListCoordinatorAssembly: self.coordinatorsDI.setFiltersList(),
                setSortsListCoordinatorAssembly: self.coordinatorsDI.setSortsList()
            )
        ).eraseToAnyView()
    }
}
