import SwiftUI

struct RelationsListRowView: View {
    
    @Binding var editingMode: Bool
    let relation: Relation
    
    let onRemoveTap: (String) -> ()
    let onStarTap: (String) -> ()
    let onEditTap: (String) -> ()
    
    var body: some View {
        GeometryReader { gr in
            HStack(spacing: 8) {
                if editingMode {
                    if relation.isEditable {
                        removeButton
                    } else {
                        Spacer.fixedWidth(Constants.buttonWidth)
                    }
                }
                
                // If we will use spacing more than 0 it will be added to
                // `Spacer()` from both sides as a result
                // `Spacer` will take up more space
                HStack(spacing: 0) {
                    name
                        .frame(width: gr.size.width * 0.4, alignment: .leading)
                    Spacer.fixedWidth(8)
                    
                    if relation.isEditable {
                        valueViewButton
                    } else {
                        valueView
                    }
                    
                    Spacer(minLength: 8)
                    starImageView
                }
                .frame(height: gr.size.height)
                .modifier(DividerModifier(spacing:0))
            }
        }
        .frame(height: 48)
    }
    
    private var name: some View {
        HStack(spacing: 6) {
            if !relation.isEditable {
                Image.Relations.locked
                    .frame(width: 15, height: 12)
            }
            AnytypeText(relation.name, style: .relation1Regular, color: .textSecondary).lineLimit(1)
        }
    }
    
    private var valueViewButton: some View {
        Button {
            onEditTap(relation.id)
        } label: {
            valueView
        }
    }
    
    private var valueView: some View {
        HStack(spacing: 0) {
            RelationValueView(relation: relation, style: .regular(allowMultiLine: false), action: nil)
            Spacer()
        }
    }
    
    private var removeButton: some View {
        withAnimation(.spring()) {
            Button {
                onRemoveTap(relation.id)
            } label: {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
            }.frame(width: Constants.buttonWidth, height: Constants.buttonWidth)
        }
    }
    
    private var starImageView: some View {
        Button {
            onStarTap(relation.id)
        } label: {
            relation.isFeatured ?
            Image.Relations.removeFromFeatured :
            Image.Relations.addToFeatured
        }.frame(width: Constants.buttonWidth, height: Constants.buttonWidth)
    }
}

private extension RelationsListRowView {
    
    enum Constants {
        static let buttonWidth: CGFloat = 24
    }
    
}

struct ObjectRelationRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            RelationsListRowView(
                editingMode: .constant(false),
                relation: Relation.tag(
                    Relation.Tag(
                        id: "1",
                        name: "relation name",
                        isFeatured: false,
                        isEditable: true,
                        selectedTags: [
                            Relation.Tag.Option(
                                id: "id1",
                                text: "text1",
                                textColor: UIColor.Text.teal,
                                backgroundColor: .grayscaleWhite,
                                scope: .local
                            ),
                            Relation.Tag.Option(
                                id: "id2",
                                text: "text2",
                                textColor: UIColor.Text.red,
                                backgroundColor: UIColor.Background.teal,
                                scope: .local
                            ),
                            Relation.Tag.Option(
                                id: "id3",
                                text: "text3",
                                textColor: UIColor.Text.teal,
                                backgroundColor: UIColor.Background.teal,
                                scope: .local
                            ),
                            Relation.Tag.Option(
                                id: "id4",
                                text: "text4",
                                textColor: UIColor.Text.red,
                                backgroundColor: UIColor.Background.teal,
                                scope: .local
                            )
                        ],
                        allTags: [
                            Relation.Tag.Option(
                                id: "id1",
                                text: "text1",
                                textColor: UIColor.Text.teal,
                                backgroundColor: .grayscaleWhite,
                                scope: .local
                            ),
                            Relation.Tag.Option(
                                id: "id2",
                                text: "text2",
                                textColor: UIColor.Text.red,
                                backgroundColor: UIColor.Background.red,
                                scope: .local
                            ),
                            Relation.Tag.Option(
                                id: "id3",
                                text: "text3",
                                textColor: UIColor.Text.teal,
                                backgroundColor: UIColor.Background.teal,
                                scope: .local
                            ),
                            Relation.Tag.Option(
                                id: "id4",
                                text: "text4",
                                textColor: UIColor.Text.red,
                                backgroundColor: UIColor.Background.red,
                                scope: .local
                            )
                        ]
                    )
                ),
                onRemoveTap: { _ in },
                onStarTap: { _ in },
                onEditTap: { _ in }
            )
            RelationsListRowView(
                editingMode: .constant(false),
                relation: Relation.text(
                    Relation.Text(
                        id: "1",
                        name: "Relation name",
                        isFeatured: false,
                        isEditable: true,
                        value: "hello"
                    )
                ),
                onRemoveTap: { _ in },
                onStarTap: { _ in },
                onEditTap: { _ in }
            )
        }
    }
}
