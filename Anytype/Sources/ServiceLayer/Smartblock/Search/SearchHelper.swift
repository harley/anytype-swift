import ProtobufMessages
import SwiftProtobuf
import BlocksModels

class SearchHelper {
    static func sort(relation: RelationKey, type: Anytype_Model_Block.Content.Dataview.Sort.TypeEnum) -> Anytype_Model_Block.Content.Dataview.Sort {
        var sort = Anytype_Model_Block.Content.Dataview.Sort()
        sort.relationKey = relation.rawValue
        sort.type = type
        
        return sort
    }
    
    static func isArchivedFilter(isArchived: Bool) -> Anytype_Model_Block.Content.Dataview.Filter {
        var filter = Anytype_Model_Block.Content.Dataview.Filter()
        filter.condition = .equal
        filter.value = isArchived.protobufValue
        filter.relationKey = RelationKey.isArchived.rawValue
        filter.operator = .and
        
        return filter
    }
    
    static func notHiddenFilter() -> Anytype_Model_Block.Content.Dataview.Filter {
        var filter = Anytype_Model_Block.Content.Dataview.Filter()
        filter.condition = .equal
        filter.value = false.protobufValue
        filter.relationKey = RelationKey.isHidden.rawValue
        filter.operator = .and
        
        return filter
    }
    
    static func notDeletedFilter() -> Anytype_Model_Block.Content.Dataview.Filter {
        var filter = Anytype_Model_Block.Content.Dataview.Filter()
        filter.condition = .equal
        filter.value = false.protobufValue
        filter.relationKey = RelationKey.isDeleted.rawValue
        filter.operator = .and
        
        return filter
    }
    
    static func typeFilter(typeUrls: [String]) -> Anytype_Model_Block.Content.Dataview.Filter {
        var filter = Anytype_Model_Block.Content.Dataview.Filter()
        filter.condition = .in
        filter.value = typeUrls.protobufValue
        filter.relationKey = RelationKey.type.rawValue
        filter.operator = .and
        
        return filter
    }
    
    static func supportedObjectTypeUrlsFilter(_ typeUrls: [String]) -> Anytype_Model_Block.Content.Dataview.Filter {
        var filter = Anytype_Model_Block.Content.Dataview.Filter()
        filter.condition = .in
        filter.value = typeUrls.protobufValue
        filter.relationKey = RelationKey.id.rawValue
        filter.operator = .and
        
        return filter
    }
    
    static func sharedObjectsFilter() -> Anytype_Model_Block.Content.Dataview.Filter {
        var filter = Anytype_Model_Block.Content.Dataview.Filter()
        filter.condition = .notEmpty
        filter.value = nil
        filter.relationKey = RelationKey.workspaceId.rawValue
        filter.operator = .and
   
        return filter
    }
    
    static func excludedObjectTypeUrlFilter(_ typeUrl: String) -> Anytype_Model_Block.Content.Dataview.Filter {
        var filter = Anytype_Model_Block.Content.Dataview.Filter()
        filter.condition = .notEqual
        filter.value = typeUrl.protobufValue
        
        filter.relationKey = RelationKey.id.rawValue
        filter.operator = .and
        
        return filter
    }
}
