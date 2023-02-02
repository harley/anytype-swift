import SwiftUI

struct SetTableView: View {
    @ObservedObject private(set) var model: EditorSetViewModel
    
    @Binding var tableHeaderSize: CGSize
    @Binding var offset: CGPoint
    var headerMinimizedSize: CGSize

    var body: some View {
        if #available(iOS 15.0, *) {
            SingleAxisGeometryReader { fullWidth in
                scrollView(fullWidth: fullWidth)
            }
        } else {
            scrollView(fullWidth: UIApplication.shared.keyWindow!.frame.width)
        }
    }
    
    private func scrollView(fullWidth: CGFloat) -> some View {
        OffsetAwareScrollView(
            axes: [.horizontal],
            showsIndicators: false,
            offsetChanged: { offset.x = $0.x }
        ) {
            OffsetAwareScrollView(
                axes: [.vertical],
                showsIndicators: false,
                offsetChanged: {
                    offset.y = $0.y
                    UIApplication.shared.hideKeyboard()
                }
            ) {
                Spacer.fixedHeight(tableHeaderSize.height)
                LazyVStack(
                    alignment: .leading,
                    spacing: 0,
                    pinnedViews: [.sectionHeaders]
                ) {
                    content
                    pagination
                }
                .frame(minWidth: fullWidth)
                .padding(.top, -headerMinimizedSize.height)
            }
        }
    }
    
    private var content: some View {
        Group {
            if model.isEmptyViews {
                EmptyView()
            } else if model.isEmptyQuery {
                emptyCompoundHeader
            } else {
                Section(header: compoundHeader) {
                    ForEach(model.configurationsDict.keys, id: \.self) { groupId in
                        if let configurations = model.configurationsDict[groupId] {
                            ForEach(configurations) { configuration in
                                SetTableViewRow(configuration: configuration, xOffset: xOffset)
                            }
                        }
                    }
                }
            }
        }
    }

    private var xOffset: CGFloat {
        max(-offset.x, 0)
    }

    private var compoundHeader: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(headerMinimizedSize.height)
            VStack {
                headerSettingsView
                SetTableViewHeader()
            }
        }
        .background(Color.Background.primary)
    }
    
    private var emptyCompoundHeader: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(headerMinimizedSize.height)
            headerSettingsView
            AnytypeDivider()
            Spacer.fixedHeight(48)
            EditorSetEmptyView(
                model: EditorSetEmptyViewModel(
                    mode: .set,
                    onTap: model.showSetOfTypeSelection
                )
            )
        }
        .frame(maxWidth: .infinity)
    }
    
    private var headerSettingsView: some View {
        HStack {
            SetHeaderSettingsView(
                model: SetHeaderSettingsViewModel(
                    setDocument: model.setDocument,
                    isActive: !model.isEmptyQuery,
                    onViewTap: model.showViewPicker,
                    onSettingsTap: model.showSetSettings,
                    onCreateTap: model.createObject
                )
            )
            .offset(x: xOffset, y: 0)
            .frame(width: tableHeaderSize.width)
            Spacer()
        }
    }
    
    private var pagination: some View {
        EditorSetPaginationView(
            paginationData: model.pagitationData(by: SubscriptionId.set.value),
            groupId: SubscriptionId.set.value
        )
        .frame(width: tableHeaderSize.width)
        .offset(x: xOffset, y: 0)
    }
}


struct SetTableView_Previews: PreviewProvider {
    static var previews: some View {
        SetTableView(
            model: EditorSetViewModel.emptyPreview,
            tableHeaderSize: .constant(.zero),
            offset: .constant(.zero),
            headerMinimizedSize: .zero
        )
    }
}

