import SwiftUI
import Services

protocol SetFiltersSelectionCoordinatorAssemblyProtocol {
    @MainActor
    func make(with filter: SetFilter, completion: @escaping (SetFilter) -> Void) -> AnyView
}

final class SetFiltersSelectionCoordinatorAssembly: SetFiltersSelectionCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    private let coordinatorsDI: CoordinatorsDI
    
    init(modulesDI: ModulesDIProtocol, coordinatorsDI: CoordinatorsDI) {
        self.modulesDI = modulesDI
        self.coordinatorsDI = coordinatorsDI
    }
    
    // MARK: - SetFiltersSelectionCoordinatorAssemblyProtocol
    
    @MainActor
    func make(with filter: SetFilter, completion: @escaping (SetFilter) -> Void) -> AnyView {
        return SetFiltersSelectionCoordinatorView(
            model: SetFiltersSelectionCoordinatorViewModel(
                filter: filter,
                completion: completion,
                setFiltersSelectionHeaderModuleAssembly: self.modulesDI.setFiltersSelectionHeader(),
                setFiltersSelectionViewModuleAssembly: self.modulesDI.setFiltersSelectionView(),
                setFiltersDateCoordinatorAssembly: self.coordinatorsDI.setFiltersDate(),
                setFilterConditionsModuleAssembly:  self.modulesDI.setFilterConditions(),
                newSearchModuleAssembly: self.modulesDI.newSearch()
            )
        ).eraseToAnyView()
    }
}
