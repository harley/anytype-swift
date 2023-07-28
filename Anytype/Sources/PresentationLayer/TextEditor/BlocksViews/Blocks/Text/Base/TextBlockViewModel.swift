import Combine
import UIKit
import Services

final class TextBlockViewModel: BlockViewModelProtocol {
    enum Style {
        case none
        case todo
    }
    
    private(set) var info: BlockInformation
    private var document: BaseDocumentProtocol
    private var style: Style = .none
    
    private var content: BlockText = .empty(contentType: .text)
    private var anytypeText: UIKitAnytypeText = .init(text: "", style: .bodyRegular, lineBreakModel: .byWordWrapping)
    private var isCheckable: Bool = false
    private var toggled: Bool = false

    private let focusSubject: PassthroughSubject<BlockFocusPosition, Never>
    private let actionHandler: TextBlockActionHandlerProtocol
    private var customBackgroundColor: UIColor?
    
    var hashable: AnyHashable {
        [info.id] as [AnyHashable]
    }
    
    private var cancellables = [AnyCancellable]()
    
    private var contentConfiguration: TextBlockContentConfiguration?
    
    init(
        document: BaseDocumentProtocol,
        blockInformation: BlockInformation,
        blockInformamtionPublisher: AnyPublisher<BlockInformation, Never>,
        stylePublisher: AnyPublisher<Style, Never>,
        focusSubject: PassthroughSubject<BlockFocusPosition, Never>,
        actionHandler: TextBlockActionHandlerProtocol,
        customBackgroundColor: UIColor? = nil
    ) {
        self.info = blockInformation
        self.document = document
        self.focusSubject = focusSubject
        self.actionHandler = actionHandler
        self.customBackgroundColor = customBackgroundColor
        
        blockInformamtionPublisher.debounce(
            for: .seconds(0.5),
            scheduler: RunLoop.main
        ).receiveOnMain().sink { [weak self] info in
            self?.update(with: info)
        }.store(in: &cancellables)
        
        stylePublisher.receiveOnMain().sink { [weak self] style in
            self?.style = style
        }.store(in: &cancellables)
    }
    
    
    private func update(with info: BlockInformation) {
//        if self.info == info { return }
        
        guard case let .text(content) = info.content else {
            fatalError()
        }
        
        printTimeElapsedWhenRunningCode(title: "TextBlockViewModel.update(info:)") {
            let isCheckable = content.contentType == .title ? style == .todo : false
            let anytypeText = content.anytypeText(document: document)
            
            self.info = info
            self.isCheckable = isCheckable
            self.anytypeText = anytypeText
            self.toggled = info.isToggled
        }
        
        
        printTimeElapsedWhenRunningCode(title: "TextBlockViewModel.resetSubject") {
            actionHandler.resetSubject.send()
        }
    }

    func set(focus: BlockFocusPosition) {
        focusSubject.send(focus)
    }
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}

    func textBlockContentConfiguration() -> TextBlockContentConfiguration {
//        if let contentConfiguration = contentConfiguration {
//            return contentConfiguration
//        }
//
        let contentConfiguration = TextBlockContentConfiguration(
            blockId: id ?? "",
            content: content,
            anytypeText: anytypeText,
            alignment: info.horizontalAlignment.asNSTextAlignment,
            isCheckable: isCheckable,
            isToggled: info.isToggled,
            isChecked: content.checked,
            shouldDisplayPlaceholder: info.isToggled && info.childrenIds.isEmpty,
            focusPublisher: focusSubject.eraseToAnyPublisher(),
            resetPublisher: actionHandler.resetSubject
                .map { [weak self] _ in self?.textBlockContentConfiguration() }
                .eraseToAnyPublisher(),
            actions: actionHandler.textBlockActions()
        )
        
        
//        self.contentConfiguration = contentConfiguration
        return contentConfiguration
    }
    
    func makeContentConfiguration(maxWidth _ : CGFloat) -> UIContentConfiguration {
        let contentConfiguration = textBlockContentConfiguration()

        let isDragConfigurationAvailable =
            content.contentType != .description && content.contentType != .title

        return contentConfiguration.cellBlockConfiguration(
            indentationSettings: .init(with: info.configurationData),
            dragConfiguration:
                isDragConfigurationAvailable ? .init(id: info.id) : nil
        )
    }

    func makeSpreadsheetConfiguration() -> UIContentConfiguration {
        let color: UIColor = info.configurationData.backgroundColor.map { UIColor.VeryLight.uiColor(from: $0) }
            ?? customBackgroundColor
            ?? .Background.primary

        return textBlockContentConfiguration()
            .spreadsheetConfiguration(
                dragConfiguration: .init(id: info.id),
                styleConfiguration: .init(backgroundColor: color)
            )
    }
}
