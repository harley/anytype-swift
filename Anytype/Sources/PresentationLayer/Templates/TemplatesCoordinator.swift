import UIKit
import SwiftUI
import Combine
import BlocksModels
import AnytypeCore

final class TemplatesCoordinator {
    private enum Constants {
        static let minimumTemplatesAvailableToPick = 2
    }

    private let rootViewController: UIViewController

    private let searchService: SearchServiceProtocol
    private let editorPageAssembly: EditorAssembly

    private let keyboardHeightListener: KeyboardHeightListener
    private var keyboardHeightSubscription: AnyCancellable?
    private weak var currentPopup: AnytypePopup?

    init(
        rootViewController: UIViewController,
        keyboardHeightListener: KeyboardHeightListener,
        searchService: SearchServiceProtocol,
        editorPageAssembly: EditorAssembly = EditorAssembly(browser: nil)
    ) {
        self.rootViewController = rootViewController
        self.keyboardHeightListener = keyboardHeightListener
        self.searchService = searchService
        self.editorPageAssembly = editorPageAssembly
    }

    func showTemplatesAvailabilityPopupIfNeeded(
        document: BaseDocumentProtocol,
        templatesTypeURL: ObjectTemplateType
    ) {
        guard FeatureFlags.isTemplatesAvailable else { return }

        currentPopup?.removePanelFromParent(animated: false, completion: nil)

        guard let availableTemplates = searchService.searchTemplates(for: templatesTypeURL) else {
            return
        }
        
        guard availableTemplates.count >= Constants.minimumTemplatesAvailableToPick else {
            return
        }
        
        let view = TemplateAvailabilityPopupView()
        let viewModel = AnytypeAlertViewModel(contentView: view, keyboardListener: keyboardHeightListener)

        let popup = AnytypePopup(
            viewModel: viewModel,
            floatingPanelStyle: true,
            configuration: .init(isGrabberVisible: true, dismissOnBackdropView: false, skipThroughGestures: true)
        )

        currentPopup = popup

        view.update(with: availableTemplates.count) { [weak self, weak popup] in
            popup?.removePanelFromParent(animated: true) {
                self?.showTemplatesPicker(document: document, availableTemplates: availableTemplates)
            }
        }

        popup.addPanel(toParent: rootViewController)
    }

    private func showTemplatesPicker(
        document: BaseDocumentProtocol,
        availableTemplates: [ObjectDetails]
    ) {
        let items = availableTemplates.enumerated().map { info -> TemplatePickerViewModel.Item in
            let item = info.element
            let data = EditorScreenData(pageId: item.id, type: .page, isOpenedForPreview: true)

            let editorController = editorPageAssembly.buildEditorController(data: data, editorBrowserViewInput: nil)

            return TemplatePickerViewModel.Item(
                id: info.offset,
                viewController: GenericUIKitToSwiftUIView(viewController: editorController),
                object: item
            )
        }

        let picker = TemplatePickerView(
            viewModel: .init(
                items: items,
                document: document,
                objectService: ServiceLocator.shared.objectActionsService(),
                onSkip: { [weak rootViewController] in
                    rootViewController?.dismiss(animated: true, completion: nil)
                }
            )
        )
        let hostViewController = UIHostingController(rootView: picker)

        hostViewController.modalPresentationStyle = .fullScreen
        rootViewController.present(hostViewController, animated: true, completion: nil)
    }
}
