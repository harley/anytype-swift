import SwiftUI

struct RelationOptionsListView: View {
    
    @ObservedObject var viewModel: RelationOptionsListViewModel
            
    var body: some View {
        VStack(spacing: 0) {
            TitleView(
                title: viewModel.title,
                leftButton: {
                    if viewModel.selectedOptions.count > 0 {
                        EditButtonStyled()
                            .disabled(!viewModel.isEditable)
                    }
                },
                rightButton: {
                    addButton
                }
            )
            content
        }
    }
    
    private var content: some View {
        Group {
            if viewModel.selectedOptions.isEmpty {
                emptyView
            } else {
                optionsList
            }
        }
        .sheet(isPresented: $viewModel.isSearchPresented) { viewModel.makeSearchView() }
    }
    
    private var emptyView: some View {
        VStack(spacing: 0) {
            AnytypeText(viewModel.emptyPlaceholder, style: .uxCalloutRegular, color: .Text.tertiary)
                .frame(height: 48)
            Spacer()
        }
    }
    
    private var optionsList: some View {
        List {
            ForEach(viewModel.selectedOptions) {
                $0.makeView()
            }
            .onMove { source, destination in
                viewModel.move(source: source, destination: destination)
            }
            .onDelete {
                viewModel.delete($0)
            }
        }
        .padding(.bottom, 20)
        .listStyle(.plain)
    }
    
}

// MARK: - NavigationBarView

private extension RelationOptionsListView {
    
    var addButton: some View {
        Button {
            viewModel.didTapAddButton()
        } label: {
            Image(asset: .X32.plus)
                .foregroundColor(.Button.active)
        }
        .disabled(!viewModel.isEditable)
    }
    
}
