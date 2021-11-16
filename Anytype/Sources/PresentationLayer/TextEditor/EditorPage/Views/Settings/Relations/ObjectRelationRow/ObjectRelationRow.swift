//
//  ObjectRelationRow.swift
//  Anytype
//
//  Created by Konstantin Mordan on 04.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI

struct ObjectRelationRow: View {
    
    let viewModel: ObjectRelationRowData
    let onRemoveTap: (String) -> ()
    let onStarTap: (String) -> ()
    
    var body: some View {
        GeometryReader { gr in
            HStack(spacing: 8) {
                if viewModel.isEditable {
                    removeButton
                } else {
                    Spacer.fixedWidth(Constants.buttonWidth)
                }
                
                // If we will use spacing more than 0 it will be added to
                // `Spacer()` from both sides as a result
                // `Spacer` will take up more space
                HStack(spacing: 0) {
                    if !viewModel.isEditable {
                        Image.Relations.locked
                            .frame(width: 15, height: 12)
                        Spacer.fixedWidth(6)
                    }
                    
                    name
                        .frame(width: gr.size.width * 0.4, alignment: .leading)
                    Spacer.fixedWidth(8)
                    valueView
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
        AnytypeText(viewModel.name, style: .relation1Regular, color: .textSecondary)
    }
    
    private var valueView: some View {
        Group {
            let value = viewModel.value
            let hint = viewModel.hint
            switch value {
            case .text(let string):
                TextRelationView(value: string, hint: hint)
                
            case .status(let statusRelation):
                StatusRelationView(value: statusRelation, hint: hint)
                
            case .checkbox(let bool):
                CheckboxRelationView(isChecked: bool)
                
            case .tag(let tags):
                TagRelationView(value: tags, hint: hint)
                
            case .object(let objectRelation):
                ObjectRelationView(value: objectRelation, hint: hint)
                
            case .unknown(let string):
                ObjectRelationRowHintView(hint: string)
            }
        }
    }
    
    private var removeButton: some View {
        Button {
            onRemoveTap(viewModel.id)
        } label: {
            Image(systemName: "minus.circle.fill")
                .foregroundColor(.red)
        }.frame(width: Constants.buttonWidth, height: Constants.buttonWidth)
    }
    
    private var starImageView: some View {
        Button {
            onStarTap(viewModel.id)
        } label: {
            viewModel.isFeatured ?
            Image.Relations.removeFromFeatured :
            Image.Relations.addToFeatured
        }.frame(width: Constants.buttonWidth, height: Constants.buttonWidth)
    }
}

private extension ObjectRelationRow {
    
    enum Constants {
        static let buttonWidth: CGFloat = 24
    }
    
}

struct ObjectRelationRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            ObjectRelationRow(
                viewModel: ObjectRelationRowData(
                    id: "1", name: "Relation name",
                    value: .tag([
                        TagRelation(text: "text", textColor: .darkTeal, backgroundColor: .grayscaleWhite),
                        TagRelation(text: "text2", textColor: .darkRed, backgroundColor: .lightRed),
                        TagRelation(text: "text", textColor: .darkTeal, backgroundColor: .lightTeal),
                        TagRelation(text: "text2", textColor: .darkRed, backgroundColor: .lightRed)
                    ]),
                    hint: "hint",
                    isFeatured: false,
                    isEditable: true
                ),
                onRemoveTap: { _ in },
                onStarTap: { _ in }
            )
            ObjectRelationRow(
                viewModel: ObjectRelationRowData(
                    id: "1", name: "Relation name",
                    value: .text("hello"),
                    hint: "hint",
                    isFeatured: false,
                    isEditable: false
                ),
                onRemoveTap: { _ in },
                onStarTap: { _ in }
            )
        }
    }
}
