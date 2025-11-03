//
//  URLExtension.swift
//  SooskyBabyTracker
//
//  Created by VuongDV on 9/4/25.
//

import Foundation

extension URL {
  static func createFolder(folderName: String, directory: FileManager.SearchPathDirectory) -> URL? {
    let fileManager = FileManager.default
    // Get document directory for device, this should succeed
    if let directoryURL = fileManager.urls(for: directory,
                                                in: .userDomainMask).first {
      // Construct a URL with desired folder name
      let folderURL = directoryURL.appendingPathComponent(folderName)
      // If folder URL does not exist, create it
      if !fileManager.fileExists(atPath: folderURL.path) {
        do {
          // Attempt to create folder
          try fileManager.createDirectory(atPath: folderURL.path,
                                          withIntermediateDirectories: true,
                                          attributes: nil)
        } catch {
          // Creation failed. Print error & return nil
          print(error.localizedDescription)
          return nil
        }
      }
      // Folder either exists, or was created. Return URL
      return folderURL
    }
    // Will only be called if document directory not found
    return nil
  }
}
