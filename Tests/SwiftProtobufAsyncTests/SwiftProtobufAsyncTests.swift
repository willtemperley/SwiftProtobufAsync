import XCTest
@testable import SwiftProtobufAsync

final class SwiftProtobufAsyncTests: XCTestCase {
  
  let resourceFinder = ResourceFinder()
  
  func testAsyncRead() async throws {
    
    let file = resourceFinder.findResource(filename: "1590800400000-D.pbf")
    guard let file else {
      XCTFail("Unable to find resource.")
      return
    }
    
    let messages = AsyncMessages<ArchiveMessage>(asyncBytesIterator: file.resourceBytes.makeAsyncIterator())
    
    var count = 0
    for try await _ in messages {
      count += 1
    }
    XCTAssertEqual(count, 598100)
  }
}
