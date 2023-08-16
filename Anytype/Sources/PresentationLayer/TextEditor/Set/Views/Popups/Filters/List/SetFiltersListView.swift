import SwiftUI

struct SetFiltersListView: View {
    let rows: [SetFilterRowConfiguration]
    let onDelete: (IndexSet) -> Void
    
    var body: some View {
        List {
            ForEach(rows) { configuration in
                SetFilterRow(configuration: configuration)
            }
            .onDelete {
                onDelete($0)
            }
        }
        .listStyle(.plain)
        .buttonStyle(BorderlessButtonStyle())
    }
}
