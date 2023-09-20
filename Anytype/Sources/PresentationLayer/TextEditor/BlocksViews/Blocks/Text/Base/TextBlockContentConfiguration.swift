import Combine
import Services
import UIKit

struct TextBlockContentConfiguration: BlockConfiguration {
    typealias View = TextBlockContentView
    
    struct Actions {
        let shouldPaste: (NSRange, UITextView) -> Bool
        let copy: (NSRange) -> Void
        let cut: (NSRange) -> Void
        let createEmptyBlock: () -> Void
        let showPage: (BlockId) -> Void
        let openURL: (URL) -> Void
        
        let changeTextStyle: (MarkupType, NSRange) -> Void
        let handleKeyboardAction: (CustomTextView.KeyboardAction, UITextView) -> Void
        let becomeFirstResponder: () -> Void
        let resignFirstResponder: () -> Void
        
        let textBlockSetNeedsLayout: (UITextView) -> Void
        
        let textViewDidChangeText: (UITextView) -> Void
        
        let textViewWillBeginEditing: (UITextView) -> Void
        let textViewDidBeginEditing: (UITextView) -> Void
        let textViewDidEndEditing: (UITextView) -> Void
        
        let textViewDidChangeCaretPosition: (UITextView, NSRange) -> Void
        let textViewShouldReplaceText: (UITextView, String, NSRange) -> Bool
        
        let toggleCheckBox: () -> Void
        let toggleDropDown: () -> Void
        let tapOnCalloutIcon: () -> Void
    }
    
    var blockId: BlockId
    var content: BlockText
    var attributedString: NSAttributedString
    var isCheckable: Bool
    var isToggled: Bool
    var isChecked: Bool
    var shouldDisplayPlaceholder: Bool
    var alignment: NSTextAlignment
    @EquatableNoop var textContainerInsets: UIEdgeInsets
    @EquatableNoop var placeholderAttributes: [NSAttributedString.Key: Any]
    @EquatableNoop var typingAttributes: (Int) -> [NSAttributedString.Key: Any]
    @EquatableNoop private(set) var focusPublisher: AnyPublisher<BlockFocusPosition, Never>
    @EquatableNoop private(set) var resetPublisher: AnyPublisher<TextBlockContentConfiguration?, Never>
    @EquatableNoop private(set) var actions: Actions
    
    init(
        blockId: BlockId,
        content: BlockText,
        attributedString: NSAttributedString,
        placeholderAttributes: [NSAttributedString.Key: Any],
        typingAttributes: @escaping (Int) -> [NSAttributedString.Key: Any],
        textContainerInsets: UIEdgeInsets,
        alignment: NSTextAlignment,
        isCheckable: Bool,
        isToggled: Bool,
        isChecked: Bool,
        shouldDisplayPlaceholder: Bool,
        focusPublisher: AnyPublisher<BlockFocusPosition, Never>,
        resetPublisher: AnyPublisher<TextBlockContentConfiguration?, Never>,
        actions: Actions
    ) {
        self.blockId = blockId
        self.content = content
        self.attributedString = attributedString
        self.placeholderAttributes = placeholderAttributes
        self.typingAttributes = typingAttributes
        self.textContainerInsets = textContainerInsets
        self.alignment = alignment
        self.isCheckable = isCheckable
        self.isToggled = isToggled
        self.isChecked = isChecked
        self.shouldDisplayPlaceholder = shouldDisplayPlaceholder
        self.focusPublisher = focusPublisher
        self.resetPublisher = resetPublisher
        
        self.actions = actions
    }
}

extension TextBlockContentConfiguration {
    var contentInsets: UIEdgeInsets {
        switch content.contentType {
        case .title:
            return .init(top: 0, left: 20, bottom: 0, right: 20)
        case .description:
            return .init(top: 8, left: 20, bottom: 0, right: 20)
        case .header:
            return .init(top: 24, left: 20, bottom: 2, right: 20)
        case .header2, .header3:
            return .init(top: 16, left: 20, bottom: 2, right: 20)
        default:
            return .init(top: 0, left: 20, bottom: 2, right: 20)
        }
    }
}
