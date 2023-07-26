//
//  AsyncMessages.swift
//  TradeAnalyst
//
//  Created by Will Temperley on 25/07/2023.
//
import Foundation
import SwiftProtobuf

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public struct AsyncMessages<M: Message> : AsyncSequence, Sendable {
  
  let asyncBytesIterator: URL.AsyncBytes.AsyncIterator
  
  /// The message type in this asynchronous sequence.
  public typealias Element = M
  
  /// An asynchronous iterator that produces the messages of this asynchronous sequence
  @frozen public struct AsyncIterator : AsyncIteratorProtocol, Sendable {
    
    public var iter: URL.AsyncBytes.AsyncIterator
    
    /// Aysnchronously reads the next varint
    @inlinable public mutating func nextVarInt() async throws -> UInt64? {
      
      var messageSize: UInt64 = 0
      var shift: UInt64 = 0
      
      while let byte = try await iter.next() {
        messageSize |= UInt64(byte & 0x7f) << shift
        shift += UInt64(7)
        if shift > 63 {
          throw BinaryDecodingError.malformedProtobuf
        }
        if (byte == 0) {
          return 0
        } else if (byte & 0x80 == 0) {
          return messageSize
        }
      }
      return nil
    }
    
    /// Asynchronously advances to the next message and returns it, or ends the
    /// sequence if there is no next message.
    ///
    /// - Returns: The next message, if it exists, or `nil` to signal the end of
    ///   the sequence.
    @inlinable public mutating func next() async throws -> M? {
      
      guard let messageSize = try await nextVarInt() else {
        return nil
      }
      var buffer = [UInt8](repeating: 0, count: Int(messageSize))
      var consumedBytes = 0
      
      while let byte = try await iter.next() {
        buffer[consumedBytes] = byte
        consumedBytes += 1
        if (consumedBytes == messageSize) {
          return try M(contiguousBytes: buffer)
        }
      }
      throw BinaryDecodingError.truncated
    }
    
    public typealias Element = M
  }
  
  /// Creates the asynchronous iterator that produces elements of this
  /// asynchronous sequence.
  ///
  /// - Returns: An instance of the `AsyncIterator` type used to produce
  /// messages in the asynchronous sequence.
  public func makeAsyncIterator() -> AsyncMessages.AsyncIterator {
    return AsyncIterator(iter: asyncBytesIterator)
  }
}
