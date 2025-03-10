import Foundation
import SwiftUI
import Services

struct HomeWidgetsCoordinatorView: View {
    
    @StateObject var model: HomeWidgetsCoordinatorViewModel
    
    var body: some View {
        HomeBottomPanelContainer(
            path: $model.editorPath,
            content: {
                AnytypeNavigationView(path: $model.editorPath, pathChanging: $model.pathChanging) { builder in
                    builder.appendBuilder(for: AccountInfo.self) { info in
                        model.homeWidgetsModule(info: info)
                    }
                    builder.appendBuilder(for: EditorScreenData.self) { data in
                        model.editorModule(data: data)
                    }
                }
            },
            bottomPanel: {
                model.homeBottomNavigationPanelModule()
            }
        )
        .onAppear {
            model.onAppear()
        }
        .environment(\.pageNavigation, model.pageNavigation)
        .snackbar(toastBarData: $model.toastBarData)
        .sheet(item: $model.showChangeSourceData) { data in
            model.changeSourceModule(data: data)
        }
        .sheet(item: $model.showChangeTypeData) { data in
            model.changeTypeModule(data: data)
        }
        .sheet(item: $model.showSearchData) { data in
            model.searchModule(data: data)
        }
        .sheet(item: $model.showCreateWidgetData) { data in
            model.createWidgetModule(data: data)
        }
        .sheet(isPresented: $model.showSpaceSwitch) {
            model.createSpaceSwitchModule()
        }
        .sheet(isPresented: $model.showSpaceSettings) {
            model.createSpaceSeetingsModule()
        }
        .sheet(isPresented: $model.showSharing) {
            model.createSharingModule()
        }
        .sheet(isPresented: $model.showCreateObjectWithType) {
            model.createObjectWithTypeModule()
        }
        .anytypeSheet(isPresented: $model.showGalleryImport) {
            GalleryUnavailableView()
        }
    }
}
