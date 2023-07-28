import UIKit
import Combine
import Services


final class TextBlockContentView: UIView, BlockContentView, DynamicHeightView, FirstResponder {
    // MARK: - DynamicHeightView
    var heightDidChanged: (() -> Void)?

    // MARK: - FirstResponder
    var isFirstResponderValueChangeHandler: ((Bool) -> Void)?

    // MARK: - Views
    private let contentView = UIView()
    private(set) lazy var textView = CustomTextView()
    private(set) lazy var createEmptyBlockButton = EmptyToggleButtonBuilder.create { [weak self] in
        self?.actions?.createEmptyBlock()
    }
    private lazy var textBlockLeadingView = TextBlockLeadingView()

    private let mainStackView: UIStackView = makeMainStackView()
    private let contentStackView: UIStackView = makeContentStackView()

    private var topContentConstraint: NSLayoutConstraint?
    private var bottomContentnConstraint: NSLayoutConstraint?
    private var focusSubscription: AnyCancellable?
    private var resetSubscription: AnyCancellable?

    private(set) var actions: TextBlockContentConfiguration.Actions?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupLayout()
    }

    func update(with configuration: TextBlockContentConfiguration) {
        actions = configuration.actions
        applyNewConfiguration(configuration: configuration)
        
        focusSubscription = configuration.focusPublisher.sink { [weak self] focus in
            self?.textView.setFocus(focus)
        }
        
        resetSubscription = configuration.resetPublisher.sink { [weak self] configuration in
            printTimeElapsedWhenRunningCode(title: "TextBlockContentView.applyNewConfiguration") {
                configuration.map {
                    self?.applyNewConfiguration(configuration: $0)
                }
            }
        }
    }

    func update(with state: UICellConfigurationState) {
        textView.textView.isLockedForEditing = state.isLocked
        createEmptyBlockButton.isEnabled = !state.isLocked
        textBlockLeadingView.checkboxView?.isUserInteractionEnabled = !state.isLocked
        textBlockLeadingView.calloutIconView?.isUserInteractionEnabled = !state.isLocked
        textView.textView.isUserInteractionEnabled = state.isEditing
    }

    // MARK: - Setup views
    
    private func setupLayout() {
        addSubview(textView) {
            $0.pinToSuperview()
            $0.height.greaterThanOrEqual(to: 40)
        }
//        contentStackView.addArrangedSubview(textBlockLeadingView)
//        contentStackView.addArrangedSubview(textView)
//
//        textView.widthAnchor.constraint(lessThanOrEqualTo: textView.widthAnchor, constant: 24).isActive = true
//
//        contentView.addSubview(contentStackView) {
//            topContentConstraint = $0.top.equal(to: contentView.topAnchor)
//            bottomContentnConstraint = $0.bottom.equal(to: contentView.bottomAnchor)
//            $0.leading.equal(to: contentView.leadingAnchor)
//            $0.trailing.equal(to: contentView.trailingAnchor)
//        }
//
//        createEmptyBlockButton.layoutUsing.anchors {
//            $0.height.equal(to: 26)
//        }
//
//        mainStackView.addArrangedSubview(contentView)
//        contentView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor).isActive = true
//
//        mainStackView.addArrangedSubview(createEmptyBlockButton)
//
//        addSubview(mainStackView) {
//            $0.pinToSuperview()
//        }
    }

    // MARK: - Apply configuration
    
    private func applyNewConfiguration(configuration: TextBlockContentConfiguration) {
        printTimeElapsedWhenRunningCode(title: "TextBlockContentView.Set text") {
            if textView.textView.textStorage != configuration.anytypeText.attrString {
//                textView.textView = configuration.anytypeText.attrString
                textView.textView.textStorage.setAttributedString(configuration.anytypeText.attrString)
            }
        }
        
        
        
        printTimeElapsedWhenRunningCode(title: "TextBlockContentView.Apply stype") {
            TextBlockLeftViewStyler.applyStyle(contentStackView: contentStackView, configuration: configuration)
        }
        
        
        printTimeElapsedWhenRunningCode(title: "TextBlockContentView.Update configuration") {
            textBlockLeadingView.update(style: .init(with: configuration))
        }

        printTimeElapsedWhenRunningCode(title: "TextBlockContentView.Apply style one more time") {
            let restrictions = BlockRestrictionsBuilder.build(textContentType: configuration.content.contentType)
            TextBlockTextViewStyler.applyStyle(textView: textView, configuration: configuration, restrictions: restrictions)
        }
                

        printTimeElapsedWhenRunningCode(title: "TextBlockContentView.Contraint") {
            updateAllConstraint(blockTextStyle: configuration.content.contentType)
        }
        
        
        textView.delegate = self
        
        
        printTimeElapsedWhenRunningCode(title: "TextBlockContentView. EmptyBlockButton") {
            let displayPlaceholder = configuration.content.contentType == .toggle && configuration.shouldDisplayPlaceholder
            createEmptyBlockButton.isHidden = !displayPlaceholder
        }
        

        printTimeElapsedWhenRunningCode(title: "TextBlockContentView. isLayoutNeeded") {
            if textView.textView.isLayoutNeeded {
                heightDidChanged?()
                actions?.textBlockSetNeedsLayout(textView.textView)
            }
        }
    }
    
    private func updateAllConstraint(blockTextStyle: BlockText.Style) {
        let contentInset = TextBlockLayout.contentInset(textBlockStyle: blockTextStyle)

        topContentConstraint?.constant = contentInset.top
        bottomContentnConstraint?.constant = -contentInset.bottom
    }
}

private extension TextBlockContentView {
    
    static func makeMainStackView() -> UIStackView {
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.alignment = .fill
        return mainStackView
    }
    
    static func makeContentStackView() -> UIStackView {
        let contentStackView = UIStackView()
        contentStackView.axis = .horizontal
        contentStackView.distribution = .fill
        contentStackView.spacing = 4
        contentStackView.alignment = .fill
        return contentStackView
    }
    
}

//func printTimeElapsedWhenRunningCode(title:String, operation:()->()) {
//    return printTimeElapsedWhenRunningCode(title: title, operation: operation)
//}

func printTimeElapsedWhenRunningCode<T>(title:String, operation:()->(T)) -> T  {
    let startTime = CFAbsoluteTimeGetCurrent()
    let something = operation()
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    
    if timeElapsed > 0.01 {
        print("⚠️ Time elapsed for \(title): \(timeElapsed) s.")
    }
    
    return something
}
