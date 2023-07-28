//import UIKit
//import Combine
//import Services
//
//final class TextBlockContentViewAdditional: UIView, BlockContentView, DynamicHeightView, FirstResponder {
//    // MARK: - DynamicHeightView
//    var heightDidChanged: (() -> Void)?
//    
//    // MARK: - FirstResponder
//    var isFirstResponderValueChangeHandler: ((Bool) -> Void)?
//    
//    private let textView = UITextView(frame: .zero)
//        
//    private var focusSubscription: AnyCancellable?
//    private var resetSubscription: AnyCancellable?
//    
//    private(set) var actions: TextBlockContentConfiguration.Actions?
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        setupLayout()
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        
//        setupLayout()
//    }
//    
//    func update(with configuration: TextBlockContentConfiguration) {
//        actions = configuration.actions
//        applyNewConfiguration(configuration: configuration)
//        
//        focusSubscription = configuration.focusPublisher.sink { [weak self] focus in
//            self?.textView.setFocus(focus)
//        }
//        
//        resetSubscription = configuration.resetPublisher.sink { [weak self] configuration in
//            configuration.map {
//                self?.applyNewConfiguration(configuration: $0)
//            }
//        }
//    }
//    
//    func update(with state: UICellConfigurationState) {
////        textView.textView.isLockedForEditing = state.isLocked
////        createEmptyBlockButton.isEnabled = !state.isLocked
////        textBlockLeadingView.checkboxView?.isUserInteractionEnabled = !state.isLocked
////        textBlockLeadingView.calloutIconView?.isUserInteractionEnabled = !state.isLocked
////        textView.textView.isUserInteractionEnabled = state.isEditing
//    }
//    
//    // MARK: - Setup views
//    
//    private func setupLayout() {
//        textView.isScrollEnabled = false
//        
//        
//        addSubview(textView) {
//            $0.pinToSuperview()
//            
//            $0.height.greaterThanOrEqual(to: 40)
//        }
//        
//        layoutUsing.anchors {
//            $0.height.greaterThanOrEqual(to: 40)
//        }
//        
//        
//        textView.textColor = .Text.white
////        contentStackView.addArrangedSubview(textBlockLeadingView)
////        contentStackView.addArrangedSubview(textView)
////
////        textView.widthAnchor.constraint(lessThanOrEqualTo: textView.widthAnchor, constant: 24).isActive = true
////
////        contentView.addSubview(contentStackView) {
////            topContentConstraint = $0.top.equal(to: contentView.topAnchor)
////            bottomContentnConstraint = $0.bottom.equal(to: contentView.bottomAnchor)
////            $0.leading.equal(to: contentView.leadingAnchor)
////            $0.trailing.equal(to: contentView.trailingAnchor)
////        }
////
////        createEmptyBlockButton.layoutUsing.anchors {
////            $0.height.equal(to: 26)
////        }
////
////        mainStackView.addArrangedSubview(contentView)
////        contentView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor).isActive = true
////
////        mainStackView.addArrangedSubview(createEmptyBlockButton)
////
////        addSubview(mainStackView) {
////            $0.pinToSuperview()
////        }
//    }
//    
//    // MARK: - Apply configuration
//    
//    private func applyNewConfiguration(configuration: TextBlockContentConfiguration) {
//        if textView.text != configuration.anytypeText.attrString.string {
//            textView.text = configuration.anytypeText.attrString.string
//        }
////        textView.text = configuration.te
////        printTimeElapsedWhenRunningCode(title: "Set text") {
////            guard textView.textView.text.isEmpty else { return }
////            if textView.textView.text != configuration.anytypeText.attrString.string {
////                textView.textView.textStorage.setAttributedString(configuration.anytypeText.attrString)
////            }
////        }
////
////
////
////        let restrictions = BlockRestrictionsBuilder.build(textContentType: configuration.content.contentType)
////
////
////        printTimeElapsedWhenRunningCode(title: "Apply stype") {
////            TextBlockLeftViewStyler.applyStyle(contentStackView: contentStackView, configuration: configuration)
////        }
////
////
////        printTimeElapsedWhenRunningCode(title: "Update configuration") {
////            textBlockLeadingView.update(style: .init(with: configuration))
////        }
////
////        printTimeElapsedWhenRunningCode(title: "Aply style one more time") {
////            TextBlockTextViewStyler.applyStyle(textView: textView, configuration: configuration, restrictions: restrictions)
////        }
////
////
////        printTimeElapsedWhenRunningCode(title: "Contraint") {
////            updateAllConstraint(blockTextStyle: configuration.content.contentType)
////        }
////
////
////        textView.delegate = self
////
////        let displayPlaceholder = configuration.content.contentType == .toggle && configuration.shouldDisplayPlaceholder
////        createEmptyBlockButton.isHidden = !displayPlaceholder
////
//        
//    }
//}
