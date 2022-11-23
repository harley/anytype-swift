import Foundation
import UIKit

final class RelationValueCoordinatorAssembly: RelationValueCoordinatorAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    private let modulesDI: ModulesDIProtocol
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(serviceLocator: ServiceLocator, modulesDI: ModulesDIProtocol, uiHelpersDI: UIHelpersDIProtocol) {
        self.serviceLocator = serviceLocator
        self.modulesDI = modulesDI
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - RelationValueCoordinatorAssemblyProtocol
    
    func make() -> RelationValueCoordinatorProtocol {
        
        let coordinator = RelationValueCoordinator(
            navigationContext: NavigationContext(rootViewController: uiHelpersDI.viewControllerProvider.rootViewController),
            relationValueModuleAssembly: modulesDI.relationValue,
            urlOpener: URLOpener(viewController: uiHelpersDI.viewControllerProvider.rootViewController)
        )
        
        return coordinator
    }
    
}
