import Foundation
import Combine
import Services

protocol WorkspacesStorageProtocol: AnyObject {
    var workspaces: [SpaceView] { get }
    var workspsacesPublisher: AnyPublisher<[SpaceView], Never> { get }
    func startSubscription() async
    func stopSubscription()
}

final class WorkspacesStorage: WorkspacesStorageProtocol {
    
    // MARK: - DI
    
    private let subscriptionsService: SubscriptionsServiceProtocol
    private let subscriptionBuilder: WorkspacesSubscriptionBuilderProtocol
    
    // MARK: - State
    
    @Published private(set) var workspaces: [SpaceView] = []
    var workspsacesPublisher: AnyPublisher<[SpaceView], Never> { $workspaces.eraseToAnyPublisher() }
    
    init(subscriptionsService: SubscriptionsServiceProtocol, subscriptionBuilder: WorkspacesSubscriptionBuilderProtocol) {
        self.subscriptionsService = subscriptionsService
        self.subscriptionBuilder = subscriptionBuilder
    }
    
    func startSubscription() async {
        let data = subscriptionBuilder.build()
        await subscriptionsService.startSubscriptionAsync(data: data) { [weak self] _, update in
            self?.workspaces.applySubscriptionUpdate(update, transform: { SpaceView(details: $0) })
        }
    }
    
    func stopSubscription() {
        subscriptionsService.stopAllSubscriptions()
    }
}
