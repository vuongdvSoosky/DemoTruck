//
//  LogManager.swift
//  Base_MVVM_Combine
//
//  Created by VuongDv on 10/01/2025.
//

import Foundation

class LogManager {

  class func show(_ items: Any...,
                  separator: String = " ",
                  terminator: String = "\n",
                  file: String = #file,
                  function: String = #function,
                  line: Int = #line
  ) {
#if DEBUG
    let fileName = URL(fileURLWithPath: file).lastPathComponent
    let logLine = "[Debug] [\(fileName)] [\(line)] [\(function)]"
    print(logLine, items, separator: separator, terminator: terminator)
#endif
  }
}
