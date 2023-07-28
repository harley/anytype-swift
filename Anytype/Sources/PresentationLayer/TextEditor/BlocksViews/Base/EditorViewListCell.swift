import UIKit

final class EditorViewListCell: UICollectionViewListCell, CustomTypesAccessable {
    override var reuseIdentifier: String? {
        (contentConfiguration as? ReusableConfigurationProtocol)?.reusableIdentifier
    }
    var isMoving: Bool = false {
        didSet {
            // Ensure that an update is performed whenever this property changes.
            if oldValue != isMoving {
                setNeedsUpdateConfiguration()
            }
        }
    }

    var isLocked: Bool = false {
        didSet {
            // Ensure that an update is performed whenever this property changes.
            if oldValue != isLocked {
                setNeedsUpdateConfiguration()
            }
        }
    }

    override var configurationState: UICellConfigurationState {
        var state = super.configurationState

        state.isMoving = isMoving
        state.isLocked = isLocked

        return state
    }
}
