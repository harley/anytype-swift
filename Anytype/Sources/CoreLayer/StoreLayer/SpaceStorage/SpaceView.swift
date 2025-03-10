import Foundation
import Services

struct SpaceView: Identifiable {
    let id: String
    let name: String
    let title: String
    let objectIconImage: Icon?
    let targetSpaceId: String
    let createdDate: Date?
    let accountStatus: SpaceStatus?
    let spaceAccessibility: SpaceAccessibility?
}

extension SpaceView: DetailsModel {
    init(details: ObjectDetails) {
        self.id = details.id
        self.name = details.name
        self.title = details.title
        self.objectIconImage = details.objectIconImage
        self.targetSpaceId = details.targetSpaceId
        self.createdDate = details.createdDate
        self.accountStatus = try? SpaceStatus(from: details.spaceAccountStatusMiddlewareValue)
        self.spaceAccessibility = details.spaceAccessibilityValue
    }
    
    static var subscriptionKeys: [BundledRelationKey] = .builder {
        BundledRelationKey.id
        BundledRelationKey.name
        BundledRelationKey.titleKeys
        BundledRelationKey.objectIconImageKeys
        BundledRelationKey.targetSpaceId
        BundledRelationKey.createdDate
        BundledRelationKey.spaceAccessibility
        BundledRelationKey.spaceAccountStatus
    }
}
