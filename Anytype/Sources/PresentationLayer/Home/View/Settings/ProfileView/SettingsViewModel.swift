import SwiftUI
import ProtobufMessages

final class SettingsViewModel: ObservableObject {
    @Published var loggingOut = false
    @Published var wallpaper = false
    @Published var keychain = false
    @Published var pincode = false
    @Published var other = false
    @Published var clearCacheAlert = false
    @Published var clearCacheSuccessful = false
    @Published var about = false
    @Published var debugMenu = false
    
    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func logout() {
        self.authService.logout() {
            windowHolder?.startNewRootView(MainAuthView(viewModel: MainAuthViewModel()))
        }
    }
    
    func clearCache() -> Bool {
        let result = Anytype_Rpc.FileList.Offload.Service.invoke(onlyIds: [], includeNotPinned: false)
        switch result {
        case .failure:
            return false
        case .success:
            return true
        }
    }
}
