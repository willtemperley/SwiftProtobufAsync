// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: Archive.proto
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

struct ArchiveMessage {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var messageType: ArchiveMessage.MessageType = .t0

  var timestamp: UInt64 = 0

  var objID: UInt32 = 0

  var body: Data = Data()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  enum MessageType: SwiftProtobuf.Enum {
    typealias RawValue = Int
    case t0 // = 0
    case t1 // = 1
    case t2 // = 2
    case t3 // = 3
    case t4 // = 4
    case t6 // = 6
    case UNRECOGNIZED(Int)

    init() {
      self = .t0
    }

    init?(rawValue: Int) {
      switch rawValue {
      case 0: self = .t0
      case 1: self = .t1
      case 2: self = .t2
      case 3: self = .t3
      case 4: self = .t4
      case 6: self = .t6
      default: self = .UNRECOGNIZED(rawValue)
      }
    }

    var rawValue: Int {
      switch self {
      case .t0: return 0
      case .t1: return 1
      case .t2: return 2
      case .t3: return 3
      case .t4: return 4
      case .t6: return 6
      case .UNRECOGNIZED(let i): return i
      }
    }

  }

  init() {}
}

#if swift(>=4.2)

extension ArchiveMessage.MessageType: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  static var allCases: [ArchiveMessage.MessageType] = [
    .t0,
    .t1,
    .t2,
    .t3,
    .t4,
    .t6,
  ]
}

#endif  // swift(>=4.2)

#if swift(>=5.5) && canImport(_Concurrency)
extension ArchiveMessage: @unchecked Sendable {}
extension ArchiveMessage.MessageType: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension ArchiveMessage: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "ArchiveMessage"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "messageType"),
    2: .same(proto: "timestamp"),
    3: .same(proto: "objId"),
    4: .same(proto: "body"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularEnumField(value: &self.messageType) }()
      case 2: try { try decoder.decodeSingularUInt64Field(value: &self.timestamp) }()
      case 3: try { try decoder.decodeSingularUInt32Field(value: &self.objID) }()
      case 4: try { try decoder.decodeSingularBytesField(value: &self.body) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.messageType != .t0 {
      try visitor.visitSingularEnumField(value: self.messageType, fieldNumber: 1)
    }
    if self.timestamp != 0 {
      try visitor.visitSingularUInt64Field(value: self.timestamp, fieldNumber: 2)
    }
    if self.objID != 0 {
      try visitor.visitSingularUInt32Field(value: self.objID, fieldNumber: 3)
    }
    if !self.body.isEmpty {
      try visitor.visitSingularBytesField(value: self.body, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: ArchiveMessage, rhs: ArchiveMessage) -> Bool {
    if lhs.messageType != rhs.messageType {return false}
    if lhs.timestamp != rhs.timestamp {return false}
    if lhs.objID != rhs.objID {return false}
    if lhs.body != rhs.body {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension ArchiveMessage.MessageType: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "T0"),
    1: .same(proto: "T1"),
    2: .same(proto: "T2"),
    3: .same(proto: "T3"),
    4: .same(proto: "T4"),
    6: .same(proto: "T6"),
  ]
}
