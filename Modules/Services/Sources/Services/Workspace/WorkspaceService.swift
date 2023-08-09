import Foundation
import ProtobufMessages
import AnytypeCore

public protocol WorkspaceServiceProtocol {
    func installObjects(spaceId: String, objectIds: [String]) async throws -> [String]
    func installObject(spaceId: String, objectId: String) async throws -> ObjectDetails
    func createWorkspace(name: String, gradient: GradientId) async throws -> String
    func deleteWorkspace(objectId: String) async throws
    func workspaceInfo(spaceId: String) async throws -> AccountInfo
}

public final class WorkspaceService: WorkspaceServiceProtocol {
    
    public init() {}
    
    // MARK: - WorkspaceServiceProtocol
    
    public func installObjects(spaceId: String, objectIds: [String]) async throws -> [String] {
        try await ClientCommands.workspaceObjectListAdd(.with {
            $0.objectIds = objectIds
            $0.spaceID = spaceId
		}).invoke()
			.objectIds
    }
    
    public func installObject(spaceId: String, objectId: String) async throws -> ObjectDetails {
        let result = try await ClientCommands.workspaceObjectAdd(.with {
            $0.objectID = objectId
            $0.spaceID = spaceId
        }).invoke()
        
		return try ObjectDetails(protobufStruct: result.details)
    }
    
    public func createWorkspace(name: String, gradient: GradientId) async throws -> String {
        let result = try await ClientCommands.workspaceCreate(.with {
            $0.details.fields[BundledRelationKey.name.rawValue] = name.protobufValue
            $0.details.fields[BundledRelationKey.iconOption.rawValue] = gradient.rawValue.protobufValue
        }).invoke()
        return result.spaceID
    }
    
    public func deleteWorkspace(objectId: String) async throws {
        try await ClientCommands.objectListDelete(.with {
            $0.objectIds = [objectId]
        }).invoke()
    }
    
    public func workspaceInfo(spaceId: String) async throws -> AccountInfo {
        let result = try await ClientCommands.workspaceInfo(.with {
            $0.spaceID = spaceId
        }).invoke()
        
        return result.info.asModel
    }
}
