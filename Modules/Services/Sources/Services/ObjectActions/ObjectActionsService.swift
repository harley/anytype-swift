import Foundation
import Combine
import SwiftProtobuf
import ProtobufMessages
import AnytypeCore

public final class ObjectActionsService: ObjectActionsServiceProtocol {
    
    public init() {}
    
    // MARK: - ObjectActionsServiceProtocol
    
    public func delete(objectIds: [BlockId]) async throws {
        try await ClientCommands.objectListDelete(.with {
            $0.objectIds = objectIds
        }).invoke()
    }
    
    public func setArchive(objectIds: [BlockId], _ isArchived: Bool) async throws {
        try await ClientCommands.objectListSetIsArchived(.with {
            $0.objectIds = objectIds
            $0.isArchived = isArchived
        }).invoke()
    }
    
    public func setFavorite(objectIds: [BlockId], _ isFavorite: Bool) async throws {
        try await ClientCommands.objectListSetIsFavorite(.with {
            $0.objectIds = objectIds
            $0.isFavorite = isFavorite
        }).invoke()
    }

    public func setLocked(_ isLocked: Bool, objectId: BlockId) async throws {
        typealias ProtobufDictionary = [String: Google_Protobuf_Value]
        var protoFields = ProtobufDictionary()
        protoFields[BlockFieldBundledKey.isLocked.rawValue] = isLocked.protobufValue

        let protobufStruct: Google_Protobuf_Struct = .init(fields: protoFields)
        let blockField = Anytype_Rpc.Block.ListSetFields.Request.BlockField.with {
            $0.blockID = objectId
            $0.fields = protobufStruct
        }

        try await ClientCommands.blockListSetFields(.with {
            $0.contextID = objectId
            $0.blockFields = [blockField]
        }).invoke()
    }
    
    /// NOTE: `CreatePage` action will return block of type `.link(.page)`.
    public func createPage(
        contextId: BlockId,
        targetId: BlockId,
        spaceId: String,
        details: [BundledDetails],
        typeUniqueKey: ObjectTypeUniqueKey,
        position: BlockPosition,
        templateId: String
    ) async throws -> BlockId {
        let protobufDetails = details.reduce([String: Google_Protobuf_Value]()) { result, detail in
            var result = result
            result[detail.key] = detail.value
            return result
        }
        let protobufStruct = Google_Protobuf_Struct(fields: protobufDetails)
        
        let internalFlags: [Anytype_Model_InternalFlag] = .builder {
            Anytype_Model_InternalFlag.with { $0.value = .editorSelectTemplate }
        }
        
        let response = try await ClientCommands.blockLinkCreateWithObject(.with {
            $0.contextID = contextId
            $0.details = protobufStruct
            $0.templateID = templateId
            $0.targetID = targetId
            $0.position = position.asMiddleware
            $0.internalFlags = internalFlags
            $0.spaceID = spaceId
            $0.objectTypeUniqueKey = typeUniqueKey.value
        }).invoke()
        
        return response.targetID
    }

    public func updateLayout(contextID: BlockId, value: Int) async throws  {
        guard let selectedLayout = Anytype_Model_ObjectType.Layout(rawValue: value) else {
            return
        }
        try await ClientCommands.objectSetLayout(.with {
            $0.contextID = contextID
            $0.layout = selectedLayout
        }).invoke()
    }
    
    public func duplicate(objectId: BlockId) async throws -> BlockId {
        let result = try await ClientCommands.objectDuplicate(.with {
            $0.contextID = objectId
        }).invoke()
        
        return result.id
    }

    // MARK: - ObjectActionsService / SetDetails
    public func updateBundledDetails(contextID: BlockId, details: [BundledDetails]) async throws {
        try await ClientCommands.objectSetDetails(.with {
            $0.contextID = contextID
            $0.details = details.map { details in
                Anytype_Rpc.Object.SetDetails.Detail.with {
                    $0.key = details.key
                    $0.value = details.value
                }
            }
        }).invoke()
    }
    
    public func updateDetails(contextId: String, relationKey: String, value: DataviewGroupValue) async throws {
        let protobufValue: Google_Protobuf_Value?
        switch value {
        case .tag(let tag):
            protobufValue = tag.ids.protobufValue
        case .status(let status):
            protobufValue = status.id.protobufValue
        case .checkbox(let checkbox):
            protobufValue = checkbox.checked.protobufValue
        default:
            protobufValue = nil
        }
        
        guard let protobufValue else {
            anytypeAssertionFailure("DataviewGroupValue doesnt support")
            return
        }
        
        _ = try await ClientCommands.objectSetDetails(.with {
            $0.contextID = contextId
            $0.details = [
                Anytype_Rpc.Object.SetDetails.Detail.with {
                    $0.key = relationKey
                    $0.value = protobufValue
                }
            ]
        }).invoke()
    }

    public func convertChildrenToPages(contextID: BlockId, blocksIds: [BlockId], typeUniqueKey: ObjectTypeUniqueKey) async throws -> [BlockId] {
        let response = try await ClientCommands.blockListConvertToObjects(.with {
            $0.contextID = contextID
            $0.blockIds = blocksIds
            $0.objectTypeUniqueKey = typeUniqueKey.value
        }).invoke()
        
        return response.linkIds
    }
    
    public func move(dashboadId: BlockId, blockId: BlockId, dropPositionblockId: BlockId, position: Anytype_Model_Block.Position) async throws {
        try await ClientCommands.blockListMoveToExistingObject(.with {
            $0.contextID = dashboadId
            $0.blockIds = [blockId]
            $0.targetContextID = dashboadId
            $0.dropTargetID = dropPositionblockId
            $0.position = position
        }).invoke()
    }
    
    public func setObjectType(objectId: BlockId, typeUniqueKey: ObjectTypeUniqueKey) async throws {
        _ = try await ClientCommands.objectSetObjectType(.with {
            $0.contextID = objectId
            $0.objectTypeUniqueKey = typeUniqueKey.value
        }).invoke()
    }

    public func setObjectSetType(objectId: BlockId) async throws {
        try await ClientCommands.objectToSet(.with {
            $0.contextID = objectId
        }).invoke()
    }
    
    public func addObjectsToCollection(contextId: BlockId, objectIds: [String]) async throws {
        try await ClientCommands.objectCollectionAdd(.with {
            $0.contextID = contextId
            $0.objectIds = objectIds
        }).invoke()
    }
    
    public func setObjectCollectionType(objectId: BlockId) async throws {
        try await ClientCommands.objectToCollection(.with {
            $0.contextID = objectId
        }).invoke()
    }

    public func applyTemplate(objectId: BlockId, templateId: BlockId) async throws {
        try await ClientCommands.objectApplyTemplate(.with {
            $0.contextID = objectId
            $0.templateID = templateId
        }).invoke()
    }
    
    public func setSource(objectId: BlockId, source: [String]) async throws {
        try await ClientCommands.objectSetSource(.with {
            $0.contextID = objectId
            $0.source = source
        }).invoke()
    }

    public func undo(objectId: BlockId) async throws {
        do {
            try await ClientCommands.objectUndo(.with {
                $0.contextID = objectId
            }).invoke()
        } catch let error as Anytype_Rpc.Object.Undo.Response.Error where error.code == .canNotMove {
            throw ObjectActionsServiceError.nothingToUndo
        }
    }

    public func redo(objectId: BlockId) async throws {
        do {
            try await ClientCommands.objectRedo(.with {
                $0.contextID = objectId
            }).invoke()
        }  catch let error as Anytype_Rpc.Object.Redo.Response.Error where error.code == .canNotMove {
            throw ObjectActionsServiceError.nothingToRedo
        }
    }
    
    public func setInternalFlags(contextId: BlockId, internalFlags: [Int]) async throws {
        let flags: [Anytype_Model_InternalFlag] = internalFlags.compactMap { flag in
            guard let value = Anytype_Model_InternalFlag.Value(rawValue: flag) else { return nil }
            return Anytype_Model_InternalFlag.with { $0.value = value }
        }
        try await ClientCommands.objectSetInternalFlags(.with {
            $0.contextID = contextId
            $0.internalFlags = flags
        }).invoke()
    }
}
