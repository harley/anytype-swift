import SwiftUI
import AnytypeCore
import BlocksModels


struct NewRelationCell: View {
    let cellKind: NewRelationCell.CellKind

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            cellKind.icon
                .frame(width: 24, height: 24)
            Spacer.fixedWidth(12)
            AnytypeText(cellKind.title, style: .uxBodyRegular, color: .textPrimary)
                .lineLimit(1)
            Spacer()
        }
        .frame(height: 52)
    }
}

extension NewRelationCell {
    enum CellKind {
        case createNew
        case relation(realtionMetadata: RelationMetadata)

        var icon: Image {
            switch self {
            case .createNew:
                return Image.Relations.createOption
            case .relation(let realtionMetadata):
                return Image.Relations.relationIcon(format: realtionMetadata.format)
            }
        }

        var title: String {
            switch self {
            case .createNew:
                return "Create from scratch".localized
            case .relation(let realtionMetadata):
                return realtionMetadata.name
            }
        }
    }
}
