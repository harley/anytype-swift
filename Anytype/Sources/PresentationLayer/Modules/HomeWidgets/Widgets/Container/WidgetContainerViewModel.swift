import Foundation
import Combine
import Services
import UIKit
import AnytypeCore

@MainActor
final class WidgetContainerViewModel<ContentVM: WidgetContainerContentViewModelProtocol>: ObservableObject {
    
    // MARK: - DI
    
    private let widgetBlockId: BlockId
    private let widgetObject: BaseDocumentProtocol
    private let blockWidgetService: BlockWidgetServiceProtocol
    private let stateManager: HomeWidgetsStateManagerProtocol
    private let blockWidgetExpandedService: BlockWidgetExpandedServiceProtocol
    private let objectActionsService: ObjectActionsServiceProtocol
    private let searchService: SearchServiceProtocol
    private let alertOpener: AlertOpenerProtocol
    private weak var output: CommonWidgetModuleOutput?
    
    // MARK: - State
    
    private var contentModel: ContentVM
    @Published var isExpanded: Bool {
        didSet { expandedDidChange() }
    }
    @Published var isEditState: Bool = false
    @Published var toastData = ToastBarData.empty
    
    init(
        widgetBlockId: BlockId,
        widgetObject: BaseDocumentProtocol,
        blockWidgetService: BlockWidgetServiceProtocol,
        stateManager: HomeWidgetsStateManagerProtocol,
        blockWidgetExpandedService: BlockWidgetExpandedServiceProtocol,
        objectActionsService: ObjectActionsServiceProtocol,
        searchService: SearchServiceProtocol,
        alertOpener: AlertOpenerProtocol,
        contentModel: ContentVM,
        output: CommonWidgetModuleOutput?
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.blockWidgetService = blockWidgetService
        self.stateManager = stateManager
        self.blockWidgetExpandedService = blockWidgetExpandedService
        self.objectActionsService = objectActionsService
        self.searchService = searchService
        self.alertOpener = alertOpener
        self.contentModel = contentModel
        self.output = output
        
        isExpanded = blockWidgetExpandedService.isExpanded(widgetBlockId: widgetBlockId)
        
        stateManager.isEditStatePublisher
            .receiveOnMain()
            .assign(to: &$isEditState)
        
        contentModel.startHeaderSubscription()
        contentModel.startContentSubscription()
    }
    
    // MARK: - Actions
    
    func onDeleteWidgetTap() {
        if let info = widgetObject.widgetInfo(blockId: widgetBlockId) {
            AnytypeAnalytics.instance().logDeleteWidget(source: info.source.analyticsSource, context: analyticsContext())
        }
        
        Task {
            try? await blockWidgetService.removeWidgetBlock(
                contextId: widgetObject.objectId,
                widgetBlockId: widgetBlockId
            )
        }
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    func onEditTap() {
        AnytypeAnalytics.instance().logEditWidget()
        stateManager.setEditState(true)
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    func onChangeSourceTap() {
        output?.onChangeSource(widgetId: widgetBlockId, context: analyticsContext())
        UISelectionFeedbackGenerator().selectionChanged()
    }

    func onChangeTypeTap() {
        output?.onChangeWidgetType(widgetId: widgetBlockId, context: analyticsContext())
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    func onAddBelowTap() {
        AnytypeAnalytics.instance().logAddWidget(context: analyticsContext())
        output?.onAddBelowWidget(widgetId: widgetBlockId, context: analyticsContext())
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    func onEmptyBinTap() {
       Task {
           let binIds = try await searchService.searchArchiveObjectIds(spaceId: widgetObject.spaceId)
           guard binIds.isNotEmpty else {
               toastData = ToastBarData(text: Loc.Widgets.Actions.binConfirm(binIds.count), showSnackBar: true)
               return
           }
           AnytypeAnalytics.instance().logShowDeletionWarning(route: .bin)
           let alert = BottomAlertLegacy.binConfirmation(count: binIds.count) { [binIds, weak self] in
               Task { [weak self] in
                   AnytypeAnalytics.instance().logDeletion(count: binIds.count, route: .bin)
                   try await self?.objectActionsService.delete(objectIds: binIds)
                   self?.toastData = ToastBarData(text: Loc.Widgets.Actions.binConfirm(binIds.count), showSnackBar: true)
               }
           }
           alertOpener.showFloatAlert(model: alert)
        }
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    // MARK: - Private
    
    private func expandedDidChange() {
        UISelectionFeedbackGenerator().selectionChanged()
        if let info = widgetObject.widgetInfo(blockId: widgetBlockId) {
            if isExpanded {
                AnytypeAnalytics.instance().logOpenSidebarGroupToggle(source: info.source.analyticsSource)
            } else {
                AnytypeAnalytics.instance().logCloseSidebarGroupToggle(source: info.source.analyticsSource)
            }
        }
        blockWidgetExpandedService.setState(widgetBlockId: widgetBlockId, isExpanded: isExpanded)
    }
    
    private func analyticsContext() -> AnalyticsWidgetContext {
        return stateManager.isEditState ? .editor : .home
    }
}
