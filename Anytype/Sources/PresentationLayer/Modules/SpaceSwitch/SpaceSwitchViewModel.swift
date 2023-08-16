import Foundation
import Combine
import Services

@MainActor
final class SpaceSwitchViewModel: ObservableObject {
    
    // MARK: - DI
    
    private let workspacesStorage: WorkspacesStorageProtocol
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    private let subscriptionService: SingleObjectSubscriptionServiceProtocol
    private weak var output: SpaceSwitchModuleOutput?
    
    // MARK: - State
    
    private let profileSubId = "Profile-\(UUID().uuidString)"
    private var workspaces: [ObjectDetails]?
    private var activeWorkspaceInfo: AccountInfo?
    private var subscriptions = [AnyCancellable]()
    
    @Published var rows = [SpaceRowModel]()
    @Published var dismiss: Bool = false
    @Published var profileName: String = ""
    @Published var profileIcon: Icon?
    @Published var spaceCreateLoading: Bool = false
    @Published var scrollToRowId: String? = nil
    
    init(
        workspacesStorage: WorkspacesStorageProtocol,
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol,
        subscriptionService: SingleObjectSubscriptionServiceProtocol,
        output: SpaceSwitchModuleOutput?
    ) {
        self.workspacesStorage = workspacesStorage
        self.activeWorkspaceStorage = activeWorkspaceStorage
        self.subscriptionService = subscriptionService
        self.output = output
        startProfileSubscriotions()
        startSpacesSubscriotions()
    }
    
    func onTapAddSpace() {
        output?.onCreateSpaceSelected()
    }
    
    func onTapProfile() {
        output?.onSettingsSelected()
    }
    
    // MARK: - Private
    
    private func startProfileSubscriotions() {
        subscriptionService.startSubscription(
            subIdPrefix: profileSubId,
            objectId: activeWorkspaceStorage.workspaceInfo.profileObjectID
        ) { [weak self] details in
            self?.updateProfile(profile: details)
        }
    }
    
    private func startSpacesSubscriotions() {
        
        workspacesStorage.workspsacesPublisher
            .receiveOnMain()
            .sink { [weak self] workspaces in
                self?.workspaces = workspaces
                self?.updateViewModel()
            }
            .store(in: &subscriptions)
        
        activeWorkspaceStorage.workspaceInfoPublisher
            .receiveOnMain()
            .sink { [weak self] activeWorkspaceInfo in
                self?.activeWorkspaceInfo = activeWorkspaceInfo
                self?.updateViewModel()
            }
            .store(in: &subscriptions)
    }
    
    private func stopSpacesSubscriotions() {
        subscriptions.removeAll()
    }
    
    private func updateViewModel() {
        guard let activeWorkspaceInfo, let workspaces else {
            rows = []
            return
        }
        let activeSpaceId = activeWorkspaceInfo.accountSpaceId
        rows = workspaces.map { workspace -> SpaceRowModel in
            SpaceRowModel(
                id: workspace.id,
                title: workspace.title,
                icon: workspace.objectIconImage,
                isSelected: activeSpaceId == workspace.spaceId
            ) { [weak self] in
                self?.onTapWorkspace(workspace: workspace)
            }
        }
        
        if scrollToRowId.isNil, let selectedRow = rows.first(where: { $0.isSelected }) {
            scrollToRowId = selectedRow.id
        }
    }
    
    private func updateProfile(profile: ObjectDetails) {
        profileName = profile.title
        profileIcon = profile.objectIconImage
    }
    
    private func onTapWorkspace(workspace: ObjectDetails) {
        Task {
            try await activeWorkspaceStorage.setActiveSpace(spaceId: workspace.spaceId)
        }
    }
}
