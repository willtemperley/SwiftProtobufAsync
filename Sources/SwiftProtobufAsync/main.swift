//
//  main.swift
//
//  Created by Will Temperley on 02/08/2023.
//
// -----------------------------------------------------------------------------
///
/// Performance comparisons between AsyncSequence and InputStream based protobuf stream parsing
///
// -----------------------------------------------------------------------------

import Foundation
import SwiftProtobuf

let resourceFinder = ResourceFinder()
let filename = "1590800400000-D.pbf"
let file = resourceFinder.findResource(filename: filename)

guard let file else {
  print("file \(filename) not found")
  exit(EXIT_FAILURE)
}
print("Using \(file.absoluteString)")

let timer = Timer()
let repeats = 5

if #available(macOS 12, *) {
  print("Running \(AsyncMessages<ArchiveMessage>.self)")
  for _ in 1...repeats {
    let date = Date()
    try await asyncMessagesPerformance(url: file)
    print(Date().timeIntervalSince(date))
  }
}

print("\nRunning \(StreamDecodingIterator<ArchiveMessage>.self)")
for _ in 1...repeats {
  let date = Date()
  streamDecodingIteratorPerformance(url: file)
  print(Date().timeIntervalSince(date))
}

print("\nRunning parse directly from inputstream")
for _ in 1...repeats {
  let date = Date()
  try parseDelimitedFrom(url: file)
  print(Date().timeIntervalSince(date))
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
func asyncMessagesPerformance(url: URL) async throws {
  let messages = AsyncMessages<ArchiveMessage>(asyncBytesIterator: url.resourceBytes.makeAsyncIterator())
  var count = 0
  for try await _ in messages {
    count += 1
  }
}

func streamDecodingIteratorPerformance(url: URL) {
  let inputStream = InputStream(url: url)
  guard let inputStream else {
    exit(EXIT_FAILURE)
  }
  inputStream.open()
  let messages = ArchiveMessage.streamDecodingIterator(inputStream: inputStream)
  var count = 0
  for _ in messages {
    count += 1
  }
  inputStream.close()
}

func parseDelimitedFrom(url: URL) throws {
  let inputStream = InputStream(url: url)
  var count = 0
  guard let inputStream else {
    exit(EXIT_FAILURE)
  }
  inputStream.open()
  while inputStream.hasBytesAvailable {
    do {
      _ = try BinaryDelimited.parse(messageType: ArchiveMessage.self, from: inputStream)
      count += 1
    } catch {
      //Currently no way around catching a truncated error
      print(error)
    }
  }
}
