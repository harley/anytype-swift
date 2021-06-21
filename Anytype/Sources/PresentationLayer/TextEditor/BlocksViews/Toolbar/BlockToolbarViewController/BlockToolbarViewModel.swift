import SwiftUI
import Combine

final class BlockToolbarViewModel {
    // MARK: Variables
    var action: AnyPublisher<BlockToolbarAction, Never> = .empty()
    var dismissControllerPublisher: AnyPublisher<Void, Never> = .empty()
    private var style: Style
    
    // MARK: Subscriptions
    private var subscriptions: Set<AnyCancellable> = []
            
    // MARK: Models
    @ObservedObject private var addBlockViewModel: BlockToolbarAddBlockViewModel
    @ObservedObject private var bookmarkViewModel: BlockToolbarBookmark.ViewModel
    
    // MARK: Setup
    private func publisher(style: Style) -> AnyPublisher<BlockToolbarAction, Never> {
        switch style {
        case .addBlock: return self.addBlockViewModel.chosenBlockTypePublisher.safelyUnwrapOptionals().map { value in
            BlockToolbarAction.addBlock(value)
        }.eraseToAnyPublisher()
        case .bookmark: return self.bookmarkViewModel.userAction.map({ value in
            BlockToolbarAction.bookmark(.fetch(value))
        }).eraseToAnyPublisher()
        }
    }
    private func setup(style: Style) {
        self.action = self.publisher(style: style)
        self.dismissControllerPublisher = self.action.successToVoid().eraseToAnyPublisher()
    }
    
    // MARK: Initialization
    init(_ style: Style) {
        self.style = style
        self.addBlockViewModel = BlockToolbarAddBlockViewModelBuilder.create()
        self.bookmarkViewModel = BlockToolbarBookmark.ViewModelBuilder.create()
        
        self.setup(style: style)
    }
            
    // MARK: Get Chosen View
    func chosenView() -> StyleAndViewAndPayload {
        switch style {
        case .addBlock: return .init(style: self.style, view: BlockToolbarAddBlockInputViewBuilder.createView(self._addBlockViewModel), payload: .init(title: self.addBlockViewModel.title))
        case .bookmark: return .init(style: self.style, view: BlockToolbarBookmark.InputViewBuilder.createView(self._bookmarkViewModel), payload: .init(title: self.bookmarkViewModel.title))
        }
    }
}

// MARK: Subscriptions
// TODO: Move this method to protocol.
// Theoretically each class can get power of this method.
extension BlockToolbarViewModel {
    func subscribe<S, T>(subject: S, keyPath: KeyPath<BlockToolbarViewModel, T>) where T: Publisher, S: Subject, T.Output == S.Output, T.Failure == S.Failure {
        self[keyPath: keyPath].subscribe(subject).store(in: &self.subscriptions)
    }
}

// MARK: StyleAndViewAndPayload
extension BlockToolbarViewModel {
    struct StyleAndViewAndPayload {
        struct Payload {
            let title: String
        }
        let style: Style
        let view: UIView?
        let payload: Payload?
    }
}

// MARK: Style
extension BlockToolbarViewModel {
    enum Style {
        case addBlock, bookmark
    }
}
