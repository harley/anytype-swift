import SwiftUI

struct SetSortsListView: View {
    
    let rows: [SetSortRowConfiguration]
    let onDelete: (IndexSet) -> Void
    let onMove: (IndexSet, Int) -> Void
    
    var body: some View {
        List {
            ForEach(rows) { configuration in
                SetSortRow(configuration: configuration)
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
