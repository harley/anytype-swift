import UIKit
import BlocksModels
import AnytypeCore


struct RelationBlockViewModel: BlockViewModelProtocol {
    var info: BlockInformation

    var relation: Relation
    var actionOnValue: ((_ relation: Relation) -> Void)?

    // MARK: - BlockViewModelProtocol methods

    var hashable: AnyHashable {
        [
            info,
            relation
        ] as [AnyHashable]
    }

    func didSelectRowInTableView() {}

    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        if FeatureFlags.uikitRelationBlock {
            return RelationBlockContentConfiguration(actionOnValue: actionOnValue, relation: relation).asCellBlockConfiguration
        }
        return DepricatedRelationBlockContentConfiguration(actionOnValue: actionOnValue, relation: relation).asCellBlockConfiguration
    }
    
}
