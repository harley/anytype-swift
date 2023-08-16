import SwiftUI

struct EditorSetViewsList: View {
    
    @Environment(\.presentationMode) @Binding private var presentationMode
    
    let rows: [EditorSetViewRowConfiguration]
    let disableDeletion: Bool
    let onDelete: (IndexSet) -> Void
    let onMove: (IndexSet, Int) -> Void
    
    var body: some View {
        List {
            ForEach(rows) { configuration in
                EditorSetViewRow(configuration: configuration, onTap: {
                    presentationMode.dismiss()
                    configuration.onTap()
                })
                .deleteDisabled(disableDeletion)
                .animation(nil, value: UUID())
            }
            .onMove { from, to in
                onMove(from, to)
            }
            .onDelete {
                onDelete($0)
            }
        }
        .listStyle(.plain)
        .buttonStyle(BorderlessButtonStyle())
    }
}
    
