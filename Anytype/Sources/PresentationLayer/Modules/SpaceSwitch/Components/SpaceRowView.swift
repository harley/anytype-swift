import Foundation
import SwiftUI

struct SpaceRowModel: Identifiable {
    let id: String
    let title: String
    let icon: Icon?
    let isSelected: Bool
    let onTap: () -> Void
    let onDelete: (() -> Void)?
}

struct SpaceRowView: View {
    
    private enum Constants {
        static let lineWidth: CGFloat = 3
    }
    
    static let width: CGFloat = 96
    
    let model: SpaceRowModel
    
    var body: some View {
        VStack {
            ZStack {
                // Fix shadow for contextMenu
                Color.black
                    .cornerRadius(2)
                    .frame(width: Self.width, height: Self.width)
                    .shadow(color: .Shadow.primary, radius: 20)
                ZStack {
                    // Outer border
                    if model.isSelected {
                        Color.Text.white
                            .cornerRadius(4)
                    }
                    IconView(icon: model.icon)
                        .frame(width: Self.width, height: Self.width)
                }
                .frame(width: Self.width + additionalSize, height: Self.width + additionalSize)
                .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 2))
                .contextMenu {
                    if let onDelete = model.onDelete {
                        Button(Loc.SpaceSettings.deleteButton, role: .destructive) {
                            onDelete()
                        }
                    }
                }
            }
            .frame(width: Self.width, height: Self.width)
            Spacer()
            AnytypeText(model.title, style: .caption1Medium, color: .Text.white)
        }
        .frame(width: Self.width, height: 126)
        .onTapGesture {
            if !model.isSelected {
                model.onTap()
            }
        }
    }
    
    private var additionalSize: CGFloat {
        return model.isSelected ? Constants.lineWidth * 2.0 : 0
    }
}
