import SwiftUI

protocol SetFiltersDateCoordinatorAssemblyProtocol {
    @MainActor
    func make(filter: SetFilter, completion: @escaping (SetFiltersDate) -> Void) -> AnyView
}

final class SetFiltersDateCoordinatorAssembly: SetFiltersDateCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    
    init(modulesDI: ModulesDIProtocol) {
        self.modulesDI = modulesDI
    }
    
    // MARK: - SetFiltersDateCoordinatorAssemblyProtocol
    
    @MainActor
    func make(filter: SetFilter, completion: @escaping (SetFiltersDate) -> Void) -> AnyView {
        return SetFiltersDateCoordinatorView(
            model: SetFiltersDateCoordinatorViewModel(
                filter: filter,
                completion: completion,
                setFiltersDateViewModuleAssembly: self.modulesDI.setFiltersDateView(),
                setTextViewModuleAssembly: self.modulesDI.setTextView()
            )
        ).eraseToAnyView()
    }
}
