import SwiftUI
import AnytypeCore

struct PersonalizationView: View {
    @EnvironmentObject private var model: SettingsViewModel

    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            
            Spacer.fixedHeight(12)
            AnytypeText("Personalization".localized, style: .uxTitle1Semibold, color: .textPrimary)
            Spacer.fixedHeight(12)
            
            defaultType
            Spacer.fixedHeight(20)
        }
        .background(Color.backgroundSecondary)
        .cornerRadius(16, corners: .top)
        
        .onAppear {
            AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.personalizationSettingsShow)
        }
    }

    private var defaultType: some View {
        Button(action: { model.defaultType = true }) {
            HStack(spacing: 0) {
                AnytypeText("Default object type".localized, style: .uxBodyRegular, color: .textPrimary)
                Spacer()
                AnytypeText(ObjectTypeProvider.shared.defaultObjectType.name, style: .uxBodyRegular, color: .textSecondary)
                Spacer.fixedWidth(10)
                Image.arrow.foregroundColor(.textTertiary)
            }
            .padding(.vertical, 14)
            .divider()
            .padding(.horizontal, 20)
        }
        .sheet(isPresented: $model.defaultType) {
            DefaultTypePicker()
                .environmentObject(model)
        }
    }
}

struct PersonalizationView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.System.blue
            PersonalizationView()
        }
    }
}
