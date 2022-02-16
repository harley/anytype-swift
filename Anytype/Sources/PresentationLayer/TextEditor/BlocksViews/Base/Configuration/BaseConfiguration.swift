import UIKit

protocol Configuration {
    associatedtype BlockConfiguration

    var configuration: BlockConfiguration { get }
    var currentConfigurationState: UICellConfigurationState? { get }
}

protocol BlockContentView where Self: UIView {
    associatedtype Configuration: BlockConfiguration

    func update(with configuration: Configuration)

    // Optional
    func update(with state: UICellConfigurationState)
}

extension BlockContentView {
    func update(with state: UICellConfigurationState) {}
}

class BaseView<View: BlockContentView>: UIView & UIContentView {
    typealias Configuration = CellBlockConfiguration<View.Configuration>

    var configuration: UIContentConfiguration {
        get {
            Configuration(
                blockConfiguration: blockConfiguration,
                currentConfigurationState: currentConfigurationState
            )
        }
        set {
            guard let newConfiguration = newValue as? Configuration else { return }

            if newConfiguration.blockConfiguration != blockConfiguration {
                blockConfiguration = newConfiguration.blockConfiguration
            }

            if newConfiguration.currentConfigurationState != currentConfigurationState {
                currentConfigurationState = newConfiguration.currentConfigurationState
            }
        }
    }

    var blockConfiguration: View.Configuration {
        didSet {
            view.update(with: blockConfiguration)
        }
    }

    var currentConfigurationState: UICellConfigurationState? {
        didSet {
            currentConfigurationState.map {
                update(with: $0)
                view.update(with: $0)
            }
        }
    }

    private let view = View(frame: .zero)
    private lazy var selectionView = BaseSelectionView()

    init(configuration: Configuration) {
        self.blockConfiguration = configuration.blockConfiguration
        self.currentConfigurationState = configuration.currentConfigurationState

        super.init(frame: .zero)

        setupSubviews()

        view.update(with: configuration.blockConfiguration)
        configuration.currentConfigurationState.map { view.update(with: $0) }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with state: UICellConfigurationState) {
        selectionView.updateStyle(isSelected: state.isSelected)

        isUserInteractionEnabled = state.isEditing

        if state.isMoving {
            backgroundColor = UIColor.Background.blue
        } else {
            backgroundColor = .clear
        }
    }


    func setupSubviews() {
        addSubview(view) {
             $0.pinToSuperview(insets: UIEdgeInsets(top: 0, left: 0, bottom: -1, right: 0))
        }

        addSubview(selectionView) {
            $0.pin(to: view, insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8))
        }
    }
}

protocol BlockConfiguration: Hashable where View.Configuration == Self {
    associatedtype View: BlockContentView
}

protocol CellBlockConfigurationProtocol where Self: UIContentConfiguration {
    associatedtype Configuration: BlockConfiguration
}

struct CellBlockConfiguration<Configuration: BlockConfiguration>: UIContentConfiguration {
    func makeContentView() -> UIView & UIContentView {
        BaseView<Configuration.View>(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> Self {
        guard let state = state as? UICellConfigurationState else { return self }

        var updatedConfig = self

        updatedConfig.currentConfigurationState = state

        return updatedConfig
    }

    var blockConfiguration: Configuration
    var currentConfigurationState: UICellConfigurationState?
}
