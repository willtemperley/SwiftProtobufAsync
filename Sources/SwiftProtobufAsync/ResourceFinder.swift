import XCTest

//Adapted from https://gist.github.com/brennanMKE/b5453070f47ad2418f691884b1e9dfc0
struct ResourceFinder {
  
  let rootFilename = "Package.swift"
  let resourcesDir = "Resources"
  
  func findResource(filename: String) -> URL? {
    guard let resourcesURL = resourcesURL() else {
      return nil
    }
    let fileURL = resourcesURL.appendingPathComponent(filename)
    guard FileManager.default.fileExists(atPath: fileURL.path) else {
      return nil
    }
    
    return fileURL
  }
  
  func resourcesURL() -> URL? {
    guard let rootURL = findUp(filename: rootFilename) else {
      return nil
    }
    return rootURL.appendingPathComponent(resourcesDir)
  }
  
  func findUp(filename: String, baseURL: URL = URL(fileURLWithPath: #file).deletingLastPathComponent()) -> URL? {
    let fileURL = baseURL.appendingPathComponent(filename)
    if FileManager.default.fileExists(atPath: fileURL.path) {
      return baseURL
    } else {
      return baseURL.pathComponents.count > 1
      ? findUp(filename: filename, baseURL: baseURL.deletingLastPathComponent())
      : nil
    }
  }
}
