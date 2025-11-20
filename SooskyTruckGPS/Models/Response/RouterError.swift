//
//  RouterError.swift
//  TractorGPS
//
//  Created by VuongDv on 20/11/25.
//

struct RouterError: Decodable {
  let message: String
  let hints: [Hint]?
  
  struct Hint: Decodable {
    let message: String
  }
}
