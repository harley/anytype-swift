import Foundation
import Services
import AnytypeCore
import Combine

extension BaseDocumentProtocol {
    // without description, type and editable setOf if needed
    var featuredRelationsForEditor: [Relation] {
        
        var enhancedRelations = parsedRelations.featuredRelations
        
        enhancedRelations.reorder(
            by: [
                BundledRelationKey.type.rawValue,
                BundledRelationKey.setOf.rawValue
            ]
        ) { $0.key }
        
        enhancedRelations.removeAll { relation in
            relation.key == BundledRelationKey.description.rawValue
        }
        
        let setOfIndex = enhancedRelations.firstIndex { $0.key == BundledRelationKey.setOf.rawValue }
        if !isLocked,
           let setOfIndex,
           let editableRelation = enhancedRelations[setOfIndex].editableRelation
        {
            enhancedRelations[setOfIndex] = editableRelation
        }
        
        return enhancedRelations
    }
    
    var flattenBlockIds: AnyPublisher<[BlockId], Never> {
        childrenPublisher
            .map { $0.map { $0.id } }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    var rowsInformation: AnyPublisher<[IndexPath: RowInformation], Never> {
        childrenPublisher
            .map { indexPathMapping(for: $0) }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
