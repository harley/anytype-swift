import Combine
import BlocksModels
import UIKit

struct TextBlockContentConfiguration: UIContentConfiguration {
    
    let blockDelegate: BlockDelegate
    let block: BlockModelProtocol
    let shouldDisplayPlaceholder: Bool
    let focusPublisher: AnyPublisher<BlockFocusPosition, Never>
    let actionHandler: EditorActionHandlerProtocol
    let accessoryViewBuilder: TextBlockAccessoryViewBuilder
    let showPage: (String) -> Void
    let openURL: (URL) -> Void
    let showStyleMenu: (BlockInformation) -> Void
    let pressingEnterTimeChecker = TimeChecker()
    let information: BlockInformation
    let isCheckable: Bool
    let upperBlock: BlockModelProtocol?
    let text: UIKitAnytypeText
    private(set) var isSelected: Bool = false
    
    init(
        blockDelegate: BlockDelegate,
        text: UIKitAnytypeText,
        block: BlockModelProtocol,
        upperBlock: BlockModelProtocol?,
        isCheckable: Bool,
        actionHandler: EditorActionHandlerProtocol,
        showPage: @escaping (String) -> Void,
        openURL: @escaping (URL) -> Void,
        showStyleMenu: @escaping (BlockInformation) -> Void,
        focusPublisher: AnyPublisher<BlockFocusPosition, Never>
    ) {
        self.blockDelegate = blockDelegate
        self.text = text
        self.block = block
        self.upperBlock = upperBlock
        self.actionHandler = actionHandler
        self.showPage = showPage
        self.openURL = openURL
        self.showStyleMenu = showStyleMenu
        self.focusPublisher = focusPublisher
        self.information = block.information
        self.isCheckable = isCheckable
        self.accessoryViewBuilder = TextBlockAccessoryViewBuilder(actionHandler: actionHandler)
        
        shouldDisplayPlaceholder = block.isToggled && block.information.childrenIds.isEmpty
    }
    
    func makeContentView() -> UIView & UIContentView {
        TextBlockContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> TextBlockContentConfiguration {
        guard let state = state as? UICellConfigurationState else { return self }
        var updatedConfig = self
        updatedConfig.isSelected = state.isSelected
        return updatedConfig
    }
}

extension TextBlockContentConfiguration: Hashable {
    
    static func == (lhs: TextBlockContentConfiguration, rhs: TextBlockContentConfiguration) -> Bool {
        lhs.information == rhs.information &&
        lhs.isSelected == rhs.isSelected &&
        lhs.shouldDisplayPlaceholder == rhs.shouldDisplayPlaceholder &&
        lhs.isCheckable == rhs.isCheckable
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(information.id)
        hasher.combine(information.alignment)
        hasher.combine(information.backgroundColor)
        hasher.combine(information.content)
        hasher.combine(isSelected)
        hasher.combine(shouldDisplayPlaceholder)
        hasher.combine(isCheckable)
    }
}
