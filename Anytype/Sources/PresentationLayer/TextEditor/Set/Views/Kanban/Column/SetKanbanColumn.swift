import SwiftUI
import UniformTypeIdentifiers

struct SetKanbanColumn: View {
    let groupId: String
    let headerRelation: Relation?
    let configurations: [SetContentViewItemConfiguration]
    let isGroupBackgroundColors: Bool
    let backgroundColor: BlockBackgroundColor?
    let showPagingView: Bool
    
    let dragAndDropDelegate: KanbanDragAndDropDelegate
    @Binding var dropData: KanbanCardDropData
    
    let onShowMoreTap: () -> Void
    let onSettingsTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            content
            if configurations.isEmpty {
                emptyDroppableArea
            }
        }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            header
            column
        }
        .padding(.horizontal, 8)
        .padding(.bottom, configurations.isEmpty ? 0 : 8)
        .background(
            isGroupBackgroundColors ?
            backgroundColor?.swiftColor.opacity(0.5) : Color.backgroundPrimary
        )
        .cornerRadius(4)
        .frame(width: 270)
    }
    
    private var column: some View {
        VStack(spacing: 8) {
            ForEach(configurations) { configuration in
                SetGalleryViewCell(configuration: configuration)
                    .onDrag {
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        dropData.draggingCard = configuration
                        dropData.initialFromGroupId = groupId
                        dropData.fromGroupId = groupId
                        return NSItemProvider(object: configuration.id as NSString)
                    }
                    .onDrop(
                        of: [UTType.text],
                        delegate: KanbanCardDropInsideDelegate(
                            dragAndDropDelegate: dragAndDropDelegate,
                            droppingCard: configuration,
                            toGroupId: groupId,
                            data: $dropData
                        )
                    )
            }
            if showPagingView {
                pagingView
            }
        }
        .frame(width: 254)
    }
    
    private var header: some View {
        HStack(spacing: 0) {
            if let headerRelation {
                RelationValueView(
                    relation: RelationItemModel(relation: headerRelation),
                    style: .regular(allowMultiLine: false),
                    action: {}
                )
            } else {
                AnytypeText(
                    Loc.Set.View.Kanban.Column.Title.uncategorized,
                    style: .relation1Regular,
                    color: .textSecondary
                )
            }
            Spacer()
            Button {
                onSettingsTap()
            } label: {
                Image(asset: .more).foregroundColor(.buttonActive)
            }
            Spacer.fixedWidth(16)
            Button {} label: {
                Image(asset: .plus)
            }
        }
        .padding(.horizontal, 10)
        .frame(height: 44)
    }
    
    private var pagingView: some View {
        Button {
            onShowMoreTap()
        } label: {
            VStack(spacing: 0) {
                Spacer.fixedHeight(4)
                HStack(spacing: 0) {
                    Spacer.fixedWidth(3)
                    Image(asset: .arrowDown)
                        .foregroundColor(.textSecondary)
                        .frame(width: 18, height: 18)
                    Spacer.fixedWidth(7)
                    AnytypeText(
                        Loc.Set.View.Kanban.Column.Paging.Title.showMore,
                        style: .caption1Medium,
                        color: .textSecondary
                    )
                    Spacer()
                }
                Spacer.fixedHeight(4)
            }
        }
    }
    
    private var emptyDroppableArea: some View {
        Rectangle()
            .fill(Color.backgroundPrimary)
            .frame(height: 44)
            .onDrop(
                of: [UTType.text],
                delegate: KanbanCardDropInsideDelegate(
                    dragAndDropDelegate: dragAndDropDelegate,
                    droppingCard: nil,
                    toGroupId: groupId,
                    data: $dropData
                )
            )
    }
}
