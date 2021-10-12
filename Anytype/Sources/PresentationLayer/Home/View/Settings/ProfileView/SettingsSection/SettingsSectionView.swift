import SwiftUI

struct SettingsSectionView: View {
    @EnvironmentObject var viewModel: SettingSectionViewModel

    var body: some View {
        VStack(spacing: 12) {
            SettingsSectionItemView(
                name: "Wallpaper",
                icon: Image.settings.wallpaper,
                comingSoon: true,
                pressed: $viewModel.wallpaper
            )
            
            SettingsSectionItemView(
                name: "Keychain phrase",
                icon: Image.settings.keychain,
                comingSoon: false,
                pressed: $viewModel.keychain
            )
            .sheet(isPresented: $viewModel.keychain) {
                KeychainPhraseView(viewModel: .init())
            }
            
            SettingsSectionItemView(
                name: "Pin code",
                icon: Image.settings.pin,
                comingSoon: true,
                pressed: $viewModel.pincode
            )
            
            SettingsSectionItemView(
                name: "About",
                icon: Image.settings.about,
                comingSoon: false,
                pressed: $viewModel.about
            )
            .sheet(isPresented: $viewModel.about) {
                AboutView()
            }
            
            #if !RELEASE
            SettingsSectionItemView(
                name: "Debug",
                icon: Image.System.lassoAndSparkles,
                comingSoon: false,
                pressed: $viewModel.debugMenu
            )
            .sheet(isPresented: $viewModel.debugMenu) {
                FeatureFlagsView()
            }
            #endif
        }
        .padding([.leading, .trailing], 20)
        .background(Color.background)
        .cornerRadius(12.0)
    }
}


struct SettingsSectionView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSectionView()
            .environmentObject(SettingSectionViewModel())
            .previewLayout(.sizeThatFits)
    }
}
