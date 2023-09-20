import Services
import AnytypeCore

struct MentionObject {
    let id: String
    let objectIcon: Icon?
    let name: String
    let description: String?
    let type: ObjectType?
    let isDeleted: Bool
    let isArchived: Bool
    
    init(
        id: String,
        objectIcon: Icon?,
        name: String,
        description: String?,
        type: ObjectType?,
        isDeleted: Bool,
        isArchived: Bool
    ) {
        self.id = id
        self.objectIcon = objectIcon
        self.name = name
        self.description = description
        self.type = type
        self.isDeleted = isDeleted
        self.isArchived = isArchived
    }
    
    init(details: ObjectDetails) {
        self.init(
            id: details.id,
            objectIcon: details.objectIconImage,
            name: details.mentionTitle,
            description: details.description,
            type: details.objectType,
            isDeleted: details.isDeleted,
            isArchived: details.isArchived
        )
    }
}

extension MentionObject: Hashable {
    
    static func == (lhs: MentionObject, rhs: MentionObject) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension MentionObject {
    static func noDetails(blockId: BlockId) -> MentionObject {
        MentionObject(
            id: blockId,
            objectIcon: Icon.asset(.ghost),
            name: "",
            description: nil,
            type: nil,
            isDeleted: true,
            isArchived: false
        )
    }
}

