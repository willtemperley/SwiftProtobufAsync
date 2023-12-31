// Sources/SwiftProtobuf/Message+StreamDecodingIterator.swift - Iterator over binary delimited input streams
//
// Copyright (c) 2023 Apple Inc. and the project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See LICENSE.txt for license information:
// https://github.com/apple/swift-protobuf/blob/main/LICENSE.txt
//
// -----------------------------------------------------------------------------
///
/// Extensions to `Message` to provide an iterator for decoding binary delimited streams.
///
// -----------------------------------------------------------------------------

import Foundation
import SwiftProtobuf

fileprivate let defaultBufferLength = 32768

extension Message {
  
  public static func streamDecodingIterator(inputStream: InputStream, bufferLength: Int? = nil, errorDelegate: StreamErrorDelegate? = nil) -> StreamDecodingIterator<Self> {
    
    let bufferLength = bufferLength ?? defaultBufferLength
    let buffer = ReadAheadBuffer(inputStream: inputStream, bufferLength: bufferLength)
    return StreamDecodingIterator<Self>(buffer: buffer, errorDelegate: errorDelegate)
  }
}

/**
 Iterates over a binary-delimited protobuf input stream. This implementation uses a read-ahead buffer,
 therefore after a message is read, the caller should assume any subsequent reads on the InputStream
 will not begin at the start of a message.
 */
public struct StreamDecodingIterator<M: Message>: Sequence, IteratorProtocol {
  
  fileprivate let buffer: DecodingBuffer
  var errorDelegate: StreamErrorDelegate?
  
  init(buffer: DecodingBuffer, errorDelegate: StreamErrorDelegate?) {
    self.buffer = buffer
    self.errorDelegate = errorDelegate
  }
  
  public func next() -> M? {
    guard let messageLength = decodeVarint() else {
      return nil
    }
    guard messageLength <= 0x7fffffff else {
      errorDelegate?.onError(error: BinaryDecodingError.malformedProtobuf)
      return nil
    }
    if messageLength == 0 {
      return M()
    }
    let data = buffer.read(for: Int(messageLength))
    guard data.count == messageLength else {
      errorDelegate?.onError(error: BinaryDecodingError.truncated)
      return nil
    }
    do {
      return try M(serializedData: data)
    } catch {
      errorDelegate?.onError(error: error)
      return nil
    }
  }
  
  //Adapted from SwiftProtobuf BinaryDecoder
  private func decodeVarint() -> UInt64? {
    let slice = buffer.read(for: 1)
    if (slice.isEmpty) {
      return nil
    }
    var c = slice[slice.startIndex]
    if c & 0x80 == 0 {
      return UInt64(c)
    }
    var value = UInt64(c & 0x7f)
    var shift = UInt64(7)
    while true {
      if shift > 63 {
        errorDelegate?.onError(error: BinaryDecodingError.malformedProtobuf)
        return nil
      }
      let slice = buffer.read(for: 1)
      if slice.isEmpty {
        //truncated varint
        errorDelegate?.onError(error: BinaryDecodingError.truncated)
        return nil
      }
      c = slice[slice.startIndex]
      value |= UInt64(c & 0x7f) << shift
      if c & 0x80 == 0 {
        return value
      }
      shift += 7
    }
  }
}

private class ReadAheadBuffer: DecodingBuffer {
  
  let inputStream: InputStream
  var consumedBytes = 0
  var buffer: [UInt8]
  var lastReadResult = 0
  var bufferLength: Int
  
  init(inputStream: InputStream, bufferLength: Int) {
    self.inputStream = inputStream
    self.buffer = [UInt8](repeating: 0, count: bufferLength)
    self.bufferLength = bufferLength
  }
  
  /**
   Read the required data quantity from the buffer,
   loading more from the stream if necessary
   */
  func read(for nBytes: Int) -> Data {
    
    let availableByteCount = lastReadResult - consumedBytes
    //Ideally data will be already available
    if nBytes <= availableByteCount {
      let readUntil = consumedBytes + nBytes
      let messageData = buffer[consumedBytes..<readUntil]
      consumedBytes = readUntil
      return Data(messageData)
    }
    
    var messageData = lastReadResult == 0 ? Data() : Data(buffer[consumedBytes..<lastReadResult])
    var requiredBytes = nBytes - messageData.count
    
    //Taken all bytes from previous read, need to read from stream
    while requiredBytes > 0, inputStream.streamStatus == .open {
      let nPages = Int(ceil(Float(requiredBytes) / Float(bufferLength)))
      bufferLength = nPages * bufferLength
      self.buffer = [UInt8](repeating: 0, count: bufferLength)
      lastReadResult = inputStream.read(&buffer, maxLength: buffer.count)
      if (requiredBytes <= lastReadResult) {
        messageData += buffer.prefix(requiredBytes)
        consumedBytes = requiredBytes
        return messageData
      } else {
        //Use the entire last read
        messageData += buffer.prefix(lastReadResult)
        requiredBytes -= lastReadResult
        consumedBytes = 0
      }
    }
    return messageData
  }
}

public protocol StreamErrorDelegate {
  func onError(error: Error)
}

public protocol DecodingBuffer {
  func read(for nBytes: Int) -> Data
}
