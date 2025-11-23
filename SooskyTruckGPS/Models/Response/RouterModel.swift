//
//  RouterModel.swift
//  TractorGPS
//
//  Created by VuongDv on 20/11/25.
//

import Foundation

// MARK: - Root
struct RouteResponse: Codable {
  let hints: RouteHints?
  let info: RouteInfo?
  var paths: [RoutePath]
}

// MARK: - Hints
struct RouteHints: Codable {
  let visitedNodes: VisitedNodes?
  
  enum CodingKeys: String, CodingKey {
    case visitedNodes = "visited_nodes"
  }
}

struct VisitedNodes: Codable {
  let sum: Int
  let average: Int
}

// MARK: - Info
struct RouteInfo: Codable {
  let copyrights: [String]
  let took: Int
  let roadDataTimestamp: String?
  
  enum CodingKeys: String, CodingKey {
    case copyrights, took
    case roadDataTimestamp = "road_data_timestamp"
  }
}

// MARK: - Path
struct RoutePath: Codable {
  let distance: Double
  let weight: Double
  let time: Int
  let transfers: Int
  let pointsEncoded: Bool
  let bbox: [Double]
  let points: RoutePoints
  let instructions: [RouteInstruction]?
  let details: RouteDetails
  let ascend: Double
  let descend: Double
  let snappedWaypoints: RoutePoints
  
  enum CodingKeys: String, CodingKey {
    case distance, weight, time, transfers
    case pointsEncoded = "points_encoded"
    case bbox, points, instructions, details, ascend, descend
    case snappedWaypoints = "snapped_waypoints"
  }
}

// MARK: - Points
struct RoutePoints: Codable {
  let type: String
  let coordinates: [[Double]]
}

// MARK: - Instruction
struct RouteInstruction: Codable {
  let distance: Double
  let heading: Double?
  let sign: Int
  let interval: [Int]
  let text: String
  let time: Int
  let streetName: String
  
  enum CodingKeys: String, CodingKey {
    case distance, heading, sign, interval, text, time
    case streetName = "street_name"
  }
}

// MARK: - Details
struct RouteDetails: Codable {
  let surface: [SurfaceDetail]?
  let roadClass: [RoadClassDetail]?
  
  enum CodingKeys: String, CodingKey {
    case surface
    case roadClass = "road_class"
  }
}

struct SurfaceDetail: Codable {
  let fromIndex: Int
  let toIndex: Int
  let surfaceType: String
  
  init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()
    fromIndex = try container.decode(Int.self)
    toIndex = try container.decode(Int.self)
    surfaceType = try container.decode(String.self)
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.unkeyedContainer()
    try container.encode(fromIndex)
    try container.encode(toIndex)
    try container.encode(surfaceType)
  }
}

extension SurfaceDetail {
  init(fromIndex: Int, toIndex: Int, surfaceType: String) {
    self.fromIndex = fromIndex
    self.toIndex = toIndex
    self.surfaceType = surfaceType
  }
}

struct RoadClassDetail: Codable {
  let fromIndex: Int
  let toIndex: Int
  let roadClass: String
  
  init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()
    fromIndex = try container.decode(Int.self)
    toIndex = try container.decode(Int.self)
    roadClass = try container.decode(String.self)
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.unkeyedContainer()
    try container.encode(fromIndex)
    try container.encode(toIndex)
    try container.encode(roadClass)
  }
}

extension RoadClassDetail {
  init(fromIndex: Int, toIndex: Int, roadClass: String) {
    self.fromIndex = fromIndex
    self.toIndex = toIndex
    self.roadClass = roadClass
  }
}
