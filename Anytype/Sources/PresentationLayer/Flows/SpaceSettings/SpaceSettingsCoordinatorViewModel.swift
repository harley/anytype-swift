import Foundation
import SwiftUI
import Combine

@MainActor
final class SpaceSettingsCoordinatorViewModel: ObservableObject, SpaceSettingsModuleOutput, RemoteStorageModuleOutput, PersonalizationModuleOutput {

    private let spaceSettingsModuleAssembly: SpaceSettingsModuleAssemblyProtocol
    private let navigationContext: NavigationContextProtocol
    private let objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol
    private let remoteStorageModuleAssembly: RemoteStorageModuleAssemblyProtocol
    private let widgetObjectListModuleAssembly: WidgetObjectListModuleAssemblyProtocol
    private let personalizationModuleAssembly: PersonalizationModuleAssemblyProtocol
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    private let newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    private let wallpaperPickerModuleAssembly: WallpaperPickerModuleAssemblyProtocol
    private let objectTypeProvider: ObjectTypeProviderProtocol
    private let urlOpener: URLOpenerProtocol
    private let documentService: OpenedDocumentsProviderProtocol
    
    @Published var showRemoteStorage = false
    @Published var showPersonalization = false
    @Published var showWallpaperPicker = false
    @Published var dismiss = false
    
    private var accountSpaceId: String
    private var subscriptions = [AnyCancellable]()
    
    init(
        spaceSettingsModuleAssembly: SpaceSettingsModuleAssemblyProtocol,
        navigationContext: NavigationContextProtocol,
        objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol,
        remoteStorageModuleAssembly: RemoteStorageModuleAssemblyProtocol,
        widgetObjectListModuleAssembly: WidgetObjectListModuleAssemblyProtocol,
        personalizationModuleAssembly: PersonalizationModuleAssemblyProtocol,
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol,
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol,
        wallpaperPickerModuleAssembly: WallpaperPickerModuleAssemblyProtocol,
        objectTypeProvider: ObjectTypeProviderProtocol,
        urlOpener: URLOpenerProtocol,
        documentService: OpenedDocumentsProviderProtocol
    ) {
        self.spaceSettingsModuleAssembly = spaceSettingsModuleAssembly
        self.navigationContext = navigationContext
        self.objectIconPickerModuleAssembly = objectIconPickerModuleAssembly
        self.remoteStorageModuleAssembly = remoteStorageModuleAssembly
        self.widgetObjectListModuleAssembly = widgetObjectListModuleAssembly
        self.personalizationModuleAssembly = personalizationModuleAssembly
        self.activeWorkspaceStorage = activeWorkspaceStorage
        self.newSearchModuleAssembly = newSearchModuleAssembly
        self.wallpaperPickerModuleAssembly = wallpaperPickerModuleAssembly
        self.objectTypeProvider = objectTypeProvider
        self.urlOpener = urlOpener
        self.documentService = documentService
        self.accountSpaceId = activeWorkspaceStorage.workspaceInfo.accountSpaceId
        startSubscriptions()
    }
    
    func settingsModule() -> AnyView {
        return spaceSettingsModuleAssembly.make(output: self)
    }
    
    func remoteStorageModule() -> AnyView {
        return remoteStorageModuleAssembly.make(output: self)
    }
    
    func personalizationModule() -> AnyView {
        return personalizationModuleAssembly.make(spaceId: accountSpaceId, output: self)
    }
    
    func wallpaperModule() -> AnyView {
        return wallpaperPickerModuleAssembly.make(spaceId: accountSpaceId)
    }
    
    // MARK: - SpaceSettingsModuleOutput
    
    func onChangeIconSelected(objectId: String) {
        let document = documentService.document(objectId: objectId, forPreview: true)
        let module = objectIconPickerModuleAssembly.makeSpaceView(document: document)
        navigationContext.present(module)
    }
    
    func onRemoteStorageSelected() {
        showRemoteStorage.toggle()
    }
    
    func onPersonalizationSelected() {
        showPersonalization.toggle()
    }
    
    // MARK: - RemoteStorageModuleOutput
    
    func onManageFilesSelected() {
        let module = widgetObjectListModuleAssembly.makeFiles()
        navigationContext.present(module)
    }
    
    func onLinkOpen(url: URL) {
        urlOpener.openUrl(url, presentationStyle: .pageSheet)
    }
    
    // MARK: - PersonalizationModuleOutput
    
    func onDefaultTypeSelected() {
        let module = newSearchModuleAssembly.objectTypeSearchModule(
            title: Loc.chooseDefaultObjectType,
            spaceId: activeWorkspaceStorage.workspaceInfo.accountSpaceId,
            showBookmark: true
        ) { [weak self] type in
            self?.objectTypeProvider.setDefaultObjectType(type: type, spaceId: type.spaceId)
            self?.navigationContext.dismissTopPresented(animated: true)
        }
        navigationContext.present(module)
    }
    
    func onWallpaperChangeSelected() {
        showWallpaperPicker.toggle()
    }
    
    // MARK: - Private
    
    private func startSubscriptions() {
        activeWorkspaceStorage.workspaceInfoPublisher
            .receiveOnMain()
            .sink { [weak self] info in
                guard let self else { return }
                if info.accountSpaceId != accountSpaceId {
                    dismissAll()
                }
            }
            .store(in: &subscriptions)
    }
    
    private func dismissAll() {
        showRemoteStorage = false
        showPersonalization = false
        showWallpaperPicker = false
        dismiss.toggle()
    }
}
