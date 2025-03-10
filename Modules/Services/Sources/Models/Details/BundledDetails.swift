import Foundation
import AnytypeCore
import ProtobufMessages
import SwiftProtobuf

public enum BundledDetails {
    case name(String)
    case iconEmoji(String)
    case iconImageHash(Hash?)
    case coverId(String)
    case coverType(CoverType)
    case done(Bool)
}

extension BundledDetails {
    
    var key: String {
        switch self {
        case .name: return BundledRelationKey.name.rawValue
        case .iconEmoji: return BundledRelationKey.iconEmoji.rawValue
        case .iconImageHash: return BundledRelationKey.iconImage.rawValue
        case .coverId: return BundledRelationKey.coverId.rawValue
        case .coverType: return BundledRelationKey.coverType.rawValue
        case .done: return BundledRelationKey.done.rawValue
        }
    }
    
    var value: Google_Protobuf_Value {
        switch self {
        case .name(let string): return string.protobufValue
        case .iconEmoji(let string): return string.protobufValue
        case .iconImageHash(let hash): return (hash?.value ?? "").protobufValue
        case .coverId(let string): return string.protobufValue
        case .coverType(let coverType): return coverType.rawValue.protobufValue
        case .done(let bool): return bool.protobufValue
        }
    }
    
}
