// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: pkg/lib/pb/model/protos/localstore.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

public struct Anytype_Model_ObjectInfo {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var id: String = String()

  /// DEPRECATED
  public var objectTypeUrls: [String] = []

  public var details: SwiftProtobuf.Google_Protobuf_Struct {
    get {return _details ?? SwiftProtobuf.Google_Protobuf_Struct()}
    set {_details = newValue}
  }
  /// Returns true if `details` has been explicitly set.
  public var hasDetails: Bool {return self._details != nil}
  /// Clears the value of `details`. Subsequent reads from it will return its default value.
  public mutating func clearDetails() {self._details = nil}

  /// DEPRECATED
  public var relations: [Anytype_Model_Relation] = []

  public var snippet: String = String()

  /// DEPRECATED
  public var hasInboundLinks_p: Bool = false

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _details: SwiftProtobuf.Google_Protobuf_Struct? = nil
}

public struct Anytype_Model_ObjectDetails {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var details: SwiftProtobuf.Google_Protobuf_Struct {
    get {return _details ?? SwiftProtobuf.Google_Protobuf_Struct()}
    set {_details = newValue}
  }
  /// Returns true if `details` has been explicitly set.
  public var hasDetails: Bool {return self._details != nil}
  /// Clears the value of `details`. Subsequent reads from it will return its default value.
  public mutating func clearDetails() {self._details = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _details: SwiftProtobuf.Google_Protobuf_Struct? = nil
}

public struct Anytype_Model_ObjectLinks {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var inboundIds: [String] = []

  public var outboundIds: [String] = []

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct Anytype_Model_ObjectLinksInfo {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var inbound: [Anytype_Model_ObjectInfo] = []

  public var outbound: [Anytype_Model_ObjectInfo] = []

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct Anytype_Model_ObjectInfoWithLinks {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var id: String = String()

  public var info: Anytype_Model_ObjectInfo {
    get {return _info ?? Anytype_Model_ObjectInfo()}
    set {_info = newValue}
  }
  /// Returns true if `info` has been explicitly set.
  public var hasInfo: Bool {return self._info != nil}
  /// Clears the value of `info`. Subsequent reads from it will return its default value.
  public mutating func clearInfo() {self._info = nil}

  public var links: Anytype_Model_ObjectLinksInfo {
    get {return _links ?? Anytype_Model_ObjectLinksInfo()}
    set {_links = newValue}
  }
  /// Returns true if `links` has been explicitly set.
  public var hasLinks: Bool {return self._links != nil}
  /// Clears the value of `links`. Subsequent reads from it will return its default value.
  public mutating func clearLinks() {self._links = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _info: Anytype_Model_ObjectInfo? = nil
  fileprivate var _links: Anytype_Model_ObjectLinksInfo? = nil
}

public struct Anytype_Model_ObjectInfoWithOutboundLinks {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var id: String = String()

  public var info: Anytype_Model_ObjectInfo {
    get {return _info ?? Anytype_Model_ObjectInfo()}
    set {_info = newValue}
  }
  /// Returns true if `info` has been explicitly set.
  public var hasInfo: Bool {return self._info != nil}
  /// Clears the value of `info`. Subsequent reads from it will return its default value.
  public mutating func clearInfo() {self._info = nil}

  public var outboundLinks: [Anytype_Model_ObjectInfo] = []

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _info: Anytype_Model_ObjectInfo? = nil
}

public struct Anytype_Model_ObjectInfoWithOutboundLinksIDs {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var id: String = String()

  public var info: Anytype_Model_ObjectInfo {
    get {return _info ?? Anytype_Model_ObjectInfo()}
    set {_info = newValue}
  }
  /// Returns true if `info` has been explicitly set.
  public var hasInfo: Bool {return self._info != nil}
  /// Clears the value of `info`. Subsequent reads from it will return its default value.
  public mutating func clearInfo() {self._info = nil}

  public var outboundLinks: [String] = []

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _info: Anytype_Model_ObjectInfo? = nil
}

public struct Anytype_Model_ObjectStoreChecksums {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var bundledObjectTypes: String = String()

  public var bundledRelations: String = String()

  public var bundledLayouts: String = String()

  /// increased in order to trigger all objects reindex
  public var objectsForceReindexCounter: Int32 = 0

  /// increased in order to fully reindex all objects
  public var filesForceReindexCounter: Int32 = 0

  /// increased in order to remove indexes and reindex everything. Automatically triggers objects and files reindex(one time only)
  public var idxRebuildCounter: Int32 = 0

  /// increased in order to perform fulltext indexing for all type of objects (useful when we change fulltext config)
  public var fulltextRebuild: Int32 = 0

  public var bundledTemplates: String = String()

  /// anytypeProfile and maybe some others in the feature
  public var bundledObjects: Int32 = 0

  public var filestoreKeysForceReindexCounter: Int32 = 0

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Anytype_Model_ObjectInfo: @unchecked Sendable {}
extension Anytype_Model_ObjectDetails: @unchecked Sendable {}
extension Anytype_Model_ObjectLinks: @unchecked Sendable {}
extension Anytype_Model_ObjectLinksInfo: @unchecked Sendable {}
extension Anytype_Model_ObjectInfoWithLinks: @unchecked Sendable {}
extension Anytype_Model_ObjectInfoWithOutboundLinks: @unchecked Sendable {}
extension Anytype_Model_ObjectInfoWithOutboundLinksIDs: @unchecked Sendable {}
extension Anytype_Model_ObjectStoreChecksums: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "anytype.model"

extension Anytype_Model_ObjectInfo: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".ObjectInfo"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "id"),
    2: .same(proto: "objectTypeUrls"),
    3: .same(proto: "details"),
    4: .same(proto: "relations"),
    5: .same(proto: "snippet"),
    6: .same(proto: "hasInboundLinks"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.id) }()
      case 2: try { try decoder.decodeRepeatedStringField(value: &self.objectTypeUrls) }()
      case 3: try { try decoder.decodeSingularMessageField(value: &self._details) }()
      case 4: try { try decoder.decodeRepeatedMessageField(value: &self.relations) }()
      case 5: try { try decoder.decodeSingularStringField(value: &self.snippet) }()
      case 6: try { try decoder.decodeSingularBoolField(value: &self.hasInboundLinks_p) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if !self.id.isEmpty {
      try visitor.visitSingularStringField(value: self.id, fieldNumber: 1)
    }
    if !self.objectTypeUrls.isEmpty {
      try visitor.visitRepeatedStringField(value: self.objectTypeUrls, fieldNumber: 2)
    }
    try { if let v = self._details {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    } }()
    if !self.relations.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.relations, fieldNumber: 4)
    }
    if !self.snippet.isEmpty {
      try visitor.visitSingularStringField(value: self.snippet, fieldNumber: 5)
    }
    if self.hasInboundLinks_p != false {
      try visitor.visitSingularBoolField(value: self.hasInboundLinks_p, fieldNumber: 6)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Anytype_Model_ObjectInfo, rhs: Anytype_Model_ObjectInfo) -> Bool {
    if lhs.id != rhs.id {return false}
    if lhs.objectTypeUrls != rhs.objectTypeUrls {return false}
    if lhs._details != rhs._details {return false}
    if lhs.relations != rhs.relations {return false}
    if lhs.snippet != rhs.snippet {return false}
    if lhs.hasInboundLinks_p != rhs.hasInboundLinks_p {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Anytype_Model_ObjectDetails: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".ObjectDetails"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "details"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._details) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._details {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Anytype_Model_ObjectDetails, rhs: Anytype_Model_ObjectDetails) -> Bool {
    if lhs._details != rhs._details {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Anytype_Model_ObjectLinks: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".ObjectLinks"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "inboundIDs"),
    2: .same(proto: "outboundIDs"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedStringField(value: &self.inboundIds) }()
      case 2: try { try decoder.decodeRepeatedStringField(value: &self.outboundIds) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.inboundIds.isEmpty {
      try visitor.visitRepeatedStringField(value: self.inboundIds, fieldNumber: 1)
    }
    if !self.outboundIds.isEmpty {
      try visitor.visitRepeatedStringField(value: self.outboundIds, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Anytype_Model_ObjectLinks, rhs: Anytype_Model_ObjectLinks) -> Bool {
    if lhs.inboundIds != rhs.inboundIds {return false}
    if lhs.outboundIds != rhs.outboundIds {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Anytype_Model_ObjectLinksInfo: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".ObjectLinksInfo"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "inbound"),
    2: .same(proto: "outbound"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedMessageField(value: &self.inbound) }()
      case 2: try { try decoder.decodeRepeatedMessageField(value: &self.outbound) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.inbound.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.inbound, fieldNumber: 1)
    }
    if !self.outbound.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.outbound, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Anytype_Model_ObjectLinksInfo, rhs: Anytype_Model_ObjectLinksInfo) -> Bool {
    if lhs.inbound != rhs.inbound {return false}
    if lhs.outbound != rhs.outbound {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Anytype_Model_ObjectInfoWithLinks: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".ObjectInfoWithLinks"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "id"),
    2: .same(proto: "info"),
    3: .same(proto: "links"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.id) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._info) }()
      case 3: try { try decoder.decodeSingularMessageField(value: &self._links) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if !self.id.isEmpty {
      try visitor.visitSingularStringField(value: self.id, fieldNumber: 1)
    }
    try { if let v = self._info {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    try { if let v = self._links {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Anytype_Model_ObjectInfoWithLinks, rhs: Anytype_Model_ObjectInfoWithLinks) -> Bool {
    if lhs.id != rhs.id {return false}
    if lhs._info != rhs._info {return false}
    if lhs._links != rhs._links {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Anytype_Model_ObjectInfoWithOutboundLinks: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".ObjectInfoWithOutboundLinks"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "id"),
    2: .same(proto: "info"),
    3: .same(proto: "outboundLinks"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.id) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._info) }()
      case 3: try { try decoder.decodeRepeatedMessageField(value: &self.outboundLinks) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if !self.id.isEmpty {
      try visitor.visitSingularStringField(value: self.id, fieldNumber: 1)
    }
    try { if let v = self._info {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    if !self.outboundLinks.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.outboundLinks, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Anytype_Model_ObjectInfoWithOutboundLinks, rhs: Anytype_Model_ObjectInfoWithOutboundLinks) -> Bool {
    if lhs.id != rhs.id {return false}
    if lhs._info != rhs._info {return false}
    if lhs.outboundLinks != rhs.outboundLinks {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Anytype_Model_ObjectInfoWithOutboundLinksIDs: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".ObjectInfoWithOutboundLinksIDs"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "id"),
    2: .same(proto: "info"),
    3: .same(proto: "outboundLinks"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.id) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._info) }()
      case 3: try { try decoder.decodeRepeatedStringField(value: &self.outboundLinks) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if !self.id.isEmpty {
      try visitor.visitSingularStringField(value: self.id, fieldNumber: 1)
    }
    try { if let v = self._info {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    if !self.outboundLinks.isEmpty {
      try visitor.visitRepeatedStringField(value: self.outboundLinks, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Anytype_Model_ObjectInfoWithOutboundLinksIDs, rhs: Anytype_Model_ObjectInfoWithOutboundLinksIDs) -> Bool {
    if lhs.id != rhs.id {return false}
    if lhs._info != rhs._info {return false}
    if lhs.outboundLinks != rhs.outboundLinks {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Anytype_Model_ObjectStoreChecksums: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".ObjectStoreChecksums"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "bundledObjectTypes"),
    2: .same(proto: "bundledRelations"),
    3: .same(proto: "bundledLayouts"),
    4: .same(proto: "objectsForceReindexCounter"),
    5: .same(proto: "filesForceReindexCounter"),
    6: .same(proto: "idxRebuildCounter"),
    7: .same(proto: "fulltextRebuild"),
    8: .same(proto: "bundledTemplates"),
    9: .same(proto: "bundledObjects"),
    10: .same(proto: "filestoreKeysForceReindexCounter"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.bundledObjectTypes) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.bundledRelations) }()
      case 3: try { try decoder.decodeSingularStringField(value: &self.bundledLayouts) }()
      case 4: try { try decoder.decodeSingularInt32Field(value: &self.objectsForceReindexCounter) }()
      case 5: try { try decoder.decodeSingularInt32Field(value: &self.filesForceReindexCounter) }()
      case 6: try { try decoder.decodeSingularInt32Field(value: &self.idxRebuildCounter) }()
      case 7: try { try decoder.decodeSingularInt32Field(value: &self.fulltextRebuild) }()
      case 8: try { try decoder.decodeSingularStringField(value: &self.bundledTemplates) }()
      case 9: try { try decoder.decodeSingularInt32Field(value: &self.bundledObjects) }()
      case 10: try { try decoder.decodeSingularInt32Field(value: &self.filestoreKeysForceReindexCounter) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.bundledObjectTypes.isEmpty {
      try visitor.visitSingularStringField(value: self.bundledObjectTypes, fieldNumber: 1)
    }
    if !self.bundledRelations.isEmpty {
      try visitor.visitSingularStringField(value: self.bundledRelations, fieldNumber: 2)
    }
    if !self.bundledLayouts.isEmpty {
      try visitor.visitSingularStringField(value: self.bundledLayouts, fieldNumber: 3)
    }
    if self.objectsForceReindexCounter != 0 {
      try visitor.visitSingularInt32Field(value: self.objectsForceReindexCounter, fieldNumber: 4)
    }
    if self.filesForceReindexCounter != 0 {
      try visitor.visitSingularInt32Field(value: self.filesForceReindexCounter, fieldNumber: 5)
    }
    if self.idxRebuildCounter != 0 {
      try visitor.visitSingularInt32Field(value: self.idxRebuildCounter, fieldNumber: 6)
    }
    if self.fulltextRebuild != 0 {
      try visitor.visitSingularInt32Field(value: self.fulltextRebuild, fieldNumber: 7)
    }
    if !self.bundledTemplates.isEmpty {
      try visitor.visitSingularStringField(value: self.bundledTemplates, fieldNumber: 8)
    }
    if self.bundledObjects != 0 {
      try visitor.visitSingularInt32Field(value: self.bundledObjects, fieldNumber: 9)
    }
    if self.filestoreKeysForceReindexCounter != 0 {
      try visitor.visitSingularInt32Field(value: self.filestoreKeysForceReindexCounter, fieldNumber: 10)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Anytype_Model_ObjectStoreChecksums, rhs: Anytype_Model_ObjectStoreChecksums) -> Bool {
    if lhs.bundledObjectTypes != rhs.bundledObjectTypes {return false}
    if lhs.bundledRelations != rhs.bundledRelations {return false}
    if lhs.bundledLayouts != rhs.bundledLayouts {return false}
    if lhs.objectsForceReindexCounter != rhs.objectsForceReindexCounter {return false}
    if lhs.filesForceReindexCounter != rhs.filesForceReindexCounter {return false}
    if lhs.idxRebuildCounter != rhs.idxRebuildCounter {return false}
    if lhs.fulltextRebuild != rhs.fulltextRebuild {return false}
    if lhs.bundledTemplates != rhs.bundledTemplates {return false}
    if lhs.bundledObjects != rhs.bundledObjects {return false}
    if lhs.filestoreKeysForceReindexCounter != rhs.filestoreKeysForceReindexCounter {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
