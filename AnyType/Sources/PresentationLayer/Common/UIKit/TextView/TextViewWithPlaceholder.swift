import Foundation
import UIKit
import Combine

extension BlockTextView {
    
    // Menu displayed while text is selected
    enum ContextMenuAction: CaseIterable {
        case bold
        case italic
        case strikethrough
    }
    
}

// MARK: - TextStorageEvent

extension TextViewWithPlaceholder {
    
    enum TextStorageEvent {
        struct Payload {
            var attributedText: NSAttributedString
            var textAlignment: NSTextAlignment
        }
        case willProcessEditing(Payload)
        case didProcessEditing(Payload)
    }
    
}

// MARK: - TextView

final class TextViewWithPlaceholder: UITextView {
    
    // MARK: - Publishers
    
    private let contextMenuSubject: PassthroughSubject<BlockTextView.ContextMenuAction, Never> = .init()
    private(set) var contextMenuPublisher: AnyPublisher<BlockTextView.ContextMenuAction, Never> = .empty()

    private let firstResponderChangeSubject: PassthroughSubject<TextViewFirstResponderChange, Never> = .init()
    private(set) var firstResponderChangePublisher: AnyPublisher<TextViewFirstResponderChange, Never> = .empty()

    // MARK: - Views
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.textColor
        label.font = self.font
        label.textAlignment = self.textAlignment
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let blockLayoutManager: TextBlockLayoutManager = .init()

    private var placeholderConstraints: [NSLayoutConstraint] = []

    /// Block color
    var blockColor: UIColor? {
        didSet {
            blockLayoutManager.tertiaryColor = blockColor
        }
    }

    /// Default font color. Applied as the lowest priority color.
    var defaultFontColor: UIColor? {
        didSet {
            blockLayoutManager.defaultColor = defaultFontColor
        }
    }

    /// Color for selected state
    var selectedColor: UIColor? {
        didSet {
            blockLayoutManager.primaryColor = selectedColor
        }
    }

    // MARK: - Overrides
    
    override var textContainerInset: UIEdgeInsets {
        didSet {
            self.updatePlaceholderLayout()
        }
    }

    override var typingAttributes: [NSAttributedString.Key : Any] {
        didSet {
            if let font = super.typingAttributes[.font] as? UIFont {
                self.placeholderLabel.font = font
            }
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        let value = super.becomeFirstResponder()
        self.firstResponderChangeSubject.send(.become)
        return value
    }

    override func resignFirstResponder() -> Bool {
        let value = super.resignFirstResponder()
        self.firstResponderChangeSubject.send(.resign)
        return value
    }

    // MARK: - Initialization
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        let textStorage = NSTextStorage()
        textStorage.addLayoutManager(blockLayoutManager)
        let container = textContainer ?? NSTextContainer()
        blockLayoutManager.addTextContainer(container)

        super.init(frame: frame, textContainer: container)

        self.setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
}

// MARK: - Private extension

private extension TextViewWithPlaceholder {
    
    func setup() {
        setupPublishers()
        setupUIElements()
        updatePlaceholderLayout()
        setupMenu()
    }
    
    func setupPublishers() {
        self.contextMenuPublisher = self.contextMenuSubject.eraseToAnyPublisher()
        self.firstResponderChangePublisher = self.firstResponderChangeSubject.eraseToAnyPublisher()
    }

    func setupUIElements() {
        self.textStorage.delegate = self
        self.addSubview(self.placeholderLabel)
    }

    func updatePlaceholderLayout() {
        let view = self.placeholderLabel
        if let superview = view.superview {
            let insets = self.textContainerInset
            let lineFragmentPadding = self.textContainer.lineFragmentPadding

            if !self.placeholderConstraints.isEmpty {
                self.removeConstraints(self.placeholderConstraints)
            }

            self.placeholderConstraints = [
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.left + lineFragmentPadding),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -(insets.right + lineFragmentPadding)),
                view.topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom)
            ]

            NSLayoutConstraint.activate(self.placeholderConstraints)
        }
    }
    
    func setupMenu() {
        UIMenuController.shared.menuItems = BlockTextView.ContextMenuAction.allCases.map { item in
            let selector: Selector = {
                switch item {
                case .bold:
                    return #selector(didSelecteContextMenuActionBold)
                case .italic:
                    return #selector(didSelecteContextMenuActionItalic)
                case .strikethrough:
                    return #selector(didSelecteContextMenuActionStrikethrough)
                }
            }()
            
            return UIMenuItem(
                title: item.title,
                action: selector
            )
        }
    }
    
}

// MARK: - Contextual Menu

extension TextViewWithPlaceholder {
    
    @objc private func didSelecteContextMenuActionBold() {
        contextMenuSubject.send(.bold)
    }
    
    @objc private func didSelecteContextMenuActionItalic() {
        contextMenuSubject.send(.italic)
    }
    
    @objc private func didSelecteContextMenuActionStrikethrough() {
        contextMenuSubject.send(.strikethrough)
    }
    
}

// MARK: - NSTextStorageDelegate

extension TextViewWithPlaceholder: NSTextStorageDelegate {
    // We can't use this delegate func to update our block model as we don't know source of changes (middleware or user).
    // If in future we want here change attributes then we should send command to middleware.
    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
        self.syncPlaceholder()
    }
}

// MARK: - Placeholder

extension TextViewWithPlaceholder {
    
    private func syncPlaceholder() {
        self.placeholderLabel.isHidden = !self.text.isEmpty
    }
    
    func update(placeholder: NSAttributedString?) {
        self.placeholderLabel.attributedText = placeholder
    }
    
}

// MARK: - ContextMenuAction

private extension BlockTextView.ContextMenuAction {
    
    var title: String {
        switch self {
        case .bold:
            return "Bold".localized
        case .italic:
            return "Italic".localized
        case .strikethrough:
            return "Strikethrough".localized
        }
    }
    
}
