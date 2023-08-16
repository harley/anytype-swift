import SwiftUI
import Services

struct EditorSetViewRow: View {
    @Environment(\.editMode) var editMode
    
    let configuration: EditorSetViewRowConfiguration
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 5) {
            content
            editButton
        }
        .divider()
        .listRowSeparator(.hidden)
        .listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
    
    private var content: some View {
        Button(action: {
            onTap()
        }) {
            HStack(spacing: 0) {
                AnytypeText(
                    configuration.name,
                    style: .uxBodyRegular,
                    color: configuration.isSupported ? .Text.primary : .Text.secondary
                )
                Spacer(minLength: 5)
                accessoryView
            }
        }
        .disabled(
            editMode?.wrappedValue != .inactive ||
            !configuration.isSupported
        )
        .frame(height: 52)
    }
    
    private var accessoryView: some View {
        Group {
            if configuration.isSupported {
                if configuration.isActive, editMode?.wrappedValue == .inactive {
                    Image(asset: .X24.tick)
                        .foregroundColor(.Button.button)
                }
            } else {
                if editMode?.wrappedValue == .inactive {
                    AnytypeText(
                        Loc.EditorSetViewPicker.View.Not.Supported.title,
                        style: .uxBodyRegular,
                        color: .Text.secondary
                    )
                }
            }
        }
    }
    
    private var editButton: some View {
        Group {
            if editMode?.wrappedValue == .active {
                Button(action: {
                    configuration.onEditTap()
                }) {
                    Image(asset: .X32.edit)
                        .foregroundColor(.Button.active)
                }
            }
        }
    }
}
