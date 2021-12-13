import Foundation

extension Relation {
    
    struct Date: RelationProtocol, Hashable, Identifiable {
        let id: String
        let name: String
        let isFeatured: Bool
        let isEditable: Bool
        
        let value: DateRelationValue?
    }
    
}
