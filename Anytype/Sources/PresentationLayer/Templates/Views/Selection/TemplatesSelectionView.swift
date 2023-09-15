import SwiftUI
import Services

struct TemplatesSelectionView: View {
    // Popup height. Something is wrong with keyboard appearance on UIKit view. Intistic content size couldn't be calculated in FloatingPanel :/
    static let height: CGFloat = 450

    @StateObject var model: TemplatesSelectionViewModel

    var body: some View {
        VStack {
            Spacer.fixedHeight(8)
            navigation
            objectTypeView
            templatesView
            Spacer.fixedHeight(24)
        }
    }

    private var navigation: some View {
        ZStack {
            AnytypeText(Loc.TemplateSelection.selectTemplate, style: .uxTitle2Medium, color: .Text.primary)
            HStack(spacing: 0) {
                Button {
                    model.isEditingState.toggle()
                } label: {
                    AnytypeText(
                        model.isEditingState ? Loc.done : Loc.edit,
                        style: .calloutRegular,
                        color: .Button.active
                    )
                }
                Spacer()
                Button {
                    model.onAddTemplateTap()
                } label: {
                    Image(asset: .X32.plus)
                        .tint(.Button.active)
                }
            }
            .padding(.leading, 16)
            .padding(.trailing, 12)
        }
    }
    
    private var objectTypeView: some View {
        VStack(spacing: 0) {
            SectionHeaderView(title: Loc.TemplateSelection.ObjectType.subtitle)
                .padding(.horizontal, 16)
            Spacer.fixedHeight(4)
            objectTypesCollection
        }
    }
    
    private var objectTypesCollection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(model.objectTypes) { item in
                    HStack(spacing: 0) {
                        IconView(icon: item.icon)
                        AnytypeText(item.title, style: .uxCalloutMedium, color: .Text.primary)
                    }
                    .padding(.vertical, 13)
                    .padding(.leading, 14)
                    .padding(.trailing, 16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.Stroke.primary, lineWidth: 1)
                    )
                }
            }
            .frame(height: 48)
            .padding(.leading, 16)
        }
    }
    
    private var templatesView: some View {
        VStack(spacing: 0) {
            SectionHeaderView(title: Loc.TemplateSelection.Template.subtitle)
                .padding(.horizontal, 16)
            Spacer.fixedHeight(4)
            templatesCollection
        }
    }
    
    private var templatesCollection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(model.templates) { item in
                    EditableView<TemplatePreview>(
                        content: TemplatePreview(viewModel: item),
                        onTap: { model.onTemplateTap(model: item.model) },
                        canBeEdited: item.model.isEditable,
                        isEditing: $model.isEditingState
                    )
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 232)
        }
    }
}

struct TemplatesSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        TemplatesSelectionView(
            model: .init(
                interactor: MockTemplateSelectionInteractorProvider(),
                setDocument: MockSetDocument(),
                objectTypeProvider: DI.preview.serviceLocator.objectTypeProvider(),
                templatesService: TemplatesService(),
                toastPresenter: ToastPresenter(
                    viewControllerProvider: ViewControllerProvider(sceneWindow: UIWindow()),
                    keyboardHeightListener: KeyboardHeightListener()
                ),
                onTemplateSelection: { _ in }
            )
        )
        .previewLayout(.sizeThatFits)
        .border(8, color: .Stroke.primary)
        .padding()
        .previewDisplayName("Preview with title & icon")
    }
}
