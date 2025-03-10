import Foundation
import Services
import SwiftUI

protocol ObjectTypeSearchModuleAssemblyProtocol: AnyObject {
    
    func objectTypeSearchForCreateObject(
        spaceId: String,
        onSelect: @escaping (_ type: ObjectType) -> Void
    ) -> AnyView
}

final class ObjectTypeSearchModuleAssembly: ObjectTypeSearchModuleAssemblyProtocol {
    
    private let uiHelpersDI: UIHelpersDIProtocol
    private let serviceLocator: ServiceLocator
    
    init(uiHelpersDI: UIHelpersDIProtocol, serviceLocator: ServiceLocator) {
        self.uiHelpersDI = uiHelpersDI
        self.serviceLocator = serviceLocator
    }
    
    func objectTypeSearchForCreateObject(
        spaceId: String,
        onSelect: @escaping (_ type: ObjectType) -> Void
    ) -> AnyView {
        
        let interactor = ObjectTypesSearchInteractor(
            spaceId: spaceId,
            searchService: serviceLocator.searchService(),
            workspaceService: serviceLocator.workspaceService(),
            objectTypeProvider: serviceLocator.objectTypeProvider(),
            excludedObjectTypeId: nil,
            showBookmark: true,
            showSetAndCollection: true
        )
        
        let internalViewModel = ObjectTypesSearchViewModel(
            interactor: interactor,
            toastPresenter: uiHelpersDI.toastPresenter(),
            selectedObjectId: nil,
            hideMarketplace: true,
            showDescription: false,
            onSelect: onSelect
        )
        let viewModel = NewSearchViewModel(
            title: Loc.createNewObject,
            searchPlaceholder: Loc.ObjectType.search,
            focusedBar: false,
            style: .default,
            itemCreationMode: .unavailable,
            internalViewModel: internalViewModel
        )
        
        return NewSearchView(viewModel: viewModel).eraseToAnyView()
    }
}
