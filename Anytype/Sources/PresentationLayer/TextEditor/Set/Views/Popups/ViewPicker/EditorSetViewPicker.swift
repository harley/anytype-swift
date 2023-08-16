import SwiftUI

struct EditorSetViewPicker: View {
    @ObservedObject var viewModel: EditorSetViewPickerViewModel
    @State private var editMode = EditMode.inactive
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        DragIndicator()
        NavigationView {
            viewsList
                .navigationBarTitleDisplayMode(.inline)
                .environment(\.editMode, $editMode)
                .onChange(of: viewModel.rows) { newValue in
                    if editMode == .active && viewModel.rows.count == 0 {
                        editMode = .inactive
                    }
                }
        }
        .navigationViewStyle(.stack)
    }
    
    private var viewsList: some View {
        List {
            ForEach(viewModel.rows) {
                if #available(iOS 15.0, *) {
                    row(with: $0)
                        .divider()
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
                        .deleteDisabled(viewModel.disableDeletion)
                } else {
                    row(with: $0)
                        .deleteDisabled(viewModel.disableDeletion)
                }
            }
            .onMove { from, to in
                viewModel.move(from: from, to: to)
            }
            .onDelete {
                viewModel.delete($0)
            }
        }
        .listStyle(.plain)
        .buttonStyle(BorderlessButtonStyle())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButtonStyled()
            }
            ToolbarItem(placement: .principal) {
                AnytypeText(Loc.views, style: .navigationBarTitle, color: .Text.primary)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                addButton
            }
        }
    }
    
    private var addButton: some View {
        Group {
            if editMode == .inactive {
                Button {
                    viewModel.addButtonTapped()
                } label: {
                    Image(asset: .X32.plus).foregroundColor(.Button.active)
                }
            }
        }
    }
    
    private func row(with configuration: EditorSetViewRowConfiguration) -> some View {
        EditorSetViewRow(configuration: configuration, onTap: {
            presentationMode.wrappedValue.dismiss()
            configuration.onTap()
        })
        .environment(\.editMode, $editMode)
        .animation(nil, value: editMode)
    }
}
    
