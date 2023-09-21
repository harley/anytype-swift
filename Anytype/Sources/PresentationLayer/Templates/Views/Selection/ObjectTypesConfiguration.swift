import AnytypeCore
import Services

struct ObjectTypesConfiguration {
    let objectTypes: [ObjectType]
    let defaultObjectTypeId: ObjectTypeId
    
    static let empty = ObjectTypesConfiguration(
        objectTypes: [],
        defaultObjectTypeId: .dynamic("")
    )
}

struct InstalledObjectTypeViewModel: Identifiable {
    let id: String
    let icon: Icon
    let title: String?
    let isSelected: Bool
    let onTap: () -> Void
}
