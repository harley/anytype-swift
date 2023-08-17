import SwiftUI
import Services

struct TemplatesSelectionView: View {
    // Popup height. Something is wrong with keyboard appearance on UIKit view. Intistic content size couldn't be calculated in FloatingPanel :/
    static let height: CGFloat = 312

    @ObservedObject var model: TemplatesSelectionViewModel

    var body: some View {
        VStack {
            navigation
            Spacer.fixedHeight(8)
            collection
            Spacer.fixedHeight(24)
        }
    }

    var navigation: some View {
        TitleView(
            title: Loc.TemplateSelection.selectTemplate,
            leftButton: {
                Button {
                    model.isEditingState.toggle()
                } label: {
                    AnytypeText(
                        model.isEditingState ? Loc.done : Loc.edit,
                        style: .calloutRegular,
                        color: .Button.active
                    )
                }
            },
            rightButton: {
                Button {
                    model.onAddTemplateTap()
                } label: {
                    Image(asset: .X32.plus)
                        .tint(.Button.active)
                }
            }
        )
    }
    
    var collection: some View {
        ScrollView(.horizontal) {
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
            .frame(height: 232)
            .padding(.horizontal, 16)
        }
    }
}

struct TemplatesSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        TemplatesSelectionView(
            model: .init(
                interactor: MockTemplateSelectionInteractorProvider(),
                setDocument: MockSetDocument(),
                templatesService: TemplatesService(),
                onTemplateSelection: { _ in },
                templateEditingHandler: { _ in }
            )
        )
        .previewLayout(.sizeThatFits)
        .border(8, color: .Stroke.primary)
        .padding()
        .previewDisplayName("Preview with title & icon")
    }
}
