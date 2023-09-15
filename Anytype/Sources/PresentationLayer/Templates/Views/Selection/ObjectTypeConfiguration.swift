import AnytypeCore

struct ObjectTypeConfiguration: Identifiable {
    let id: String
    let icon: Icon
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
}
