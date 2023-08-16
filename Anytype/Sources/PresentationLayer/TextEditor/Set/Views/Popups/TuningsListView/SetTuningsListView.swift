import SwiftUI

protocol SetTuningsListViewModelProtocol: ObservableObject {
    var title: String { get }
    var isEmpty: Bool { get }
    var emptyStateTitle: String { get }
    
    func list() -> AnyView
    func onAddButtonTap()
}

struct SetTuningsListView<ViewModel: SetTuningsListViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    
    @State private var editMode = EditMode.inactive
    
    var body: some View {
        VStack(spacing: 0) {
            TitleView(
                title: viewModel.title,
                leftButton: {
                    if !viewModel.isEmpty {
                        EditButtonStyled()
                    }
                },
                rightButton: { addButton }
            )
            content
                .onChange(of: viewModel.isEmpty) { newValue in
                    if editMode == .active && viewModel.isEmpty {
                        editMode = .inactive
                    }
                }
        }
        .environment(\.editMode, $editMode)
    }
    
    private var addButton: some View {
        Group {
            if editMode == .inactive {
                Button {
                    viewModel.onAddButtonTap()
                } label: {
                    Image(asset: .X32.plus)
                        .foregroundColor(.Button.active)
                }
            }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if !viewModel.isEmpty {
            viewModel.list()
        } else {
            emptyState
        }
    }
    
    private var emptyState: some View {
        VStack {
            Spacer.fixedHeight(20)
            AnytypeText(
                viewModel.emptyStateTitle,
                style: .uxCalloutRegular,
                color: .Text.secondary
            )
                .frame(height: 68)
            Spacer()
        }
    }
}
