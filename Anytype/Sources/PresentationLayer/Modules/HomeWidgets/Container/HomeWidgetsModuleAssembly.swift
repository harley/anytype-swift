import Foundation
import SwiftUI

protocol HomeWidgetsModuleAssemblyProtocol {
    @MainActor
    func make(
        widgetObjectId: String,
        output: HomeWidgetsModuleOutput,
        widgetOutput: CommonWidgetModuleOutput?
    ) -> AnyView
}

final class HomeWidgetsModuleAssembly: HomeWidgetsModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    private let widgetsDI: WidgetsDIProtocol
    
    init(serviceLocator: ServiceLocator, uiHelpersDI: UIHelpersDIProtocol, widgetsDI: WidgetsDIProtocol) {
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
        self.widgetsDI = widgetsDI
    }
    
    // MARK: - HomeWidgetsModuleAssemblyProtocol
    @MainActor
    func make(
        widgetObjectId: String,
        output: HomeWidgetsModuleOutput,
        widgetOutput: CommonWidgetModuleOutput?
    ) -> AnyView {
        let model = HomeWidgetsViewModel(
            widgetObject: HomeWidgetsObject(
                objectId: widgetObjectId,
                objectDetailsStorage: serviceLocator.objectDetailsStorage()
            ),
            registry: widgetsDI.homeWidgetsRegistry(widgetOutput: widgetOutput),
            blockWidgetService: serviceLocator.blockWidgetService(),
            accountManager: serviceLocator.accountManager(),
            bottomPanelProviderAssembly: widgetsDI.bottomPanelProviderAssembly(),
            toastPresenter: uiHelpersDI.toastPresenter,
            output: output
        )
        let view = HomeWidgetsView(model: model)
        return view.eraseToAnyView()
    }
}
