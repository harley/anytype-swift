import UIKit
import Services
import AnytypeCore


struct RelationBlockViewModel: BlockViewModelProtocol {
    let info: BlockInformation

    let relation: Relation
    let actionOnValue: (() -> Void)?

    // MARK: - BlockViewModelProtocol methods

    var hashable: AnyHashable {
        [
            info,
            relation
        ] as [AnyHashable]
    }

    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}

    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        return RelationBlockContentConfiguration(
            actionOnValue: { _ in actionOnValue?() },
            relation: RelationItemModel(relation: relation)
        ).cellBlockConfiguration(
            dragConfiguration: .init(id: info.id),
            styleConfiguration: .init(backgroundColor: info.backgroundColor?.backgroundColor.color)
        )
    }
    
}
