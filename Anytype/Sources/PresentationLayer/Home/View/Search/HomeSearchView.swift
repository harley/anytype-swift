import SwiftUI

struct HomeSearchView: View {
    @EnvironmentObject var viewModel: HomeViewModel
        
    var body: some View {
        SearchView(kind: .objects, title: nil) { id in
            viewModel.showPage(pageId: id)
        }
    }
}
