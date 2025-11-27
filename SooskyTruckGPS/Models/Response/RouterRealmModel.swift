
//
//  RouterRealmModel.swift
//  TractorGPS
//
//  Created by VuongDv on 20/11/25.
//

import RealmSwift
import Foundation
import MapKit

// MARK: - Realm Models

// Root
class RouteResponseRealm: BaseObject {
  @Persisted var hints: RouteHintsRealm?
  @Persisted var info: RouteInfoRealm?
  @Persisted var paths = List<RoutePathRealm>()
  @Persisted var places = List<PlaceRealm>()
  @Persisted var trackingRecords = List<TrackingRouterModel>()
  @Persisted var history: Bool = false
  @Persisted var nameRouter: String?
  @Persisted var createDate = Date()
  
  convenience init(from model: RouteResponse) {
    self.init()
    if let hints = model.hints {
      self.hints = RouteHintsRealm(from: hints)
    }
    if let info = model.info {
      self.info = RouteInfoRealm(from: info)
    }
    self.paths.append(objectsIn: model.paths.map { RoutePathRealm(from: $0) })
  }
  
  func addPlaces(_ Places: [Place]) {
    for Place in Places {
      let PlaceRealm = PlaceRealm(from: Place)
      // Kiểm tra tránh trùng kinh/vĩ độ
      if !self.places.contains(where: { $0.latitude == PlaceRealm.latitude && $0.longitude == PlaceRealm.longitude }) {
        self.places.append(PlaceRealm)
      }
    }
  }
}

// Hints
class RouteHintsRealm: BaseObject {
  @Persisted var visitedNodes: VisitedNodesRealm?
  
  convenience init(from model: RouteHints) {
    self.init()
    if let visitedNodes = model.visitedNodes {
      self.visitedNodes = VisitedNodesRealm(from: visitedNodes)
    }
  }
}

class VisitedNodesRealm: BaseObject {
  @Persisted var sum: Int = 0
  @Persisted var average: Int = 0
  
  convenience init(from model: VisitedNodes) {
    self.init()
    self.sum = model.sum
    self.average = model.average
  }
}

// Info
class RouteInfoRealm: BaseObject {
  @Persisted var copyrights = List<String>()
  @Persisted var took: Int = 0
  @Persisted var roadDataTimestamp: String?
  
  convenience init(from model: RouteInfo) {
    self.init()
    self.copyrights.append(objectsIn: model.copyrights)
    self.took = model.took
    self.roadDataTimestamp = model.roadDataTimestamp
  }
}

// Path
class RoutePathRealm: BaseObject {
  @Persisted var distance: Double = 0
  @Persisted var weight: Double = 0
  @Persisted var time: Int = 0
  @Persisted var transfers: Int = 0
  @Persisted var pointsEncoded: Bool = false
  @Persisted var bbox = List<Double>()
  @Persisted var points: RoutePointsRealm?
  @Persisted var instructions = List<RouteInstructionRealm>()
  @Persisted var details: RouteDetailsRealm?
  @Persisted var ascend: Double = 0
  @Persisted var descend: Double = 0
  @Persisted var snappedWaypoints: RoutePointsRealm?
  
  convenience init(from model: RoutePath) {
    self.init()
    self.distance = model.distance
    self.weight = model.weight
    self.time = model.time
    self.transfers = model.transfers
    self.pointsEncoded = model.pointsEncoded
    self.bbox.append(objectsIn: model.bbox)
    self.points = RoutePointsRealm(from: model.points)
    self.snappedWaypoints = RoutePointsRealm(from: model.snappedWaypoints)
    if let instructions = model.instructions {
      self.instructions.append(objectsIn: instructions.map { RouteInstructionRealm(from: $0) })
    }
    self.details = RouteDetailsRealm(from: model.details)
    self.ascend = model.ascend
    self.descend = model.descend
  }
}

// Points
class RoutePointsRealm: BaseObject {
  @Persisted var type: String = ""
  @Persisted var coordinates = List<CoordinateRealm>()
  
  convenience init(from model: RoutePoints) {
    self.init()
    self.type = model.type
    self.coordinates.append(objectsIn: model.coordinates.map { CoordinateRealm(lat: $0[1], lon: $0[0]) })
  }
}

class CoordinateRealm: EmbeddedObject {
  @Persisted var lat: Double = 0
  @Persisted var lon: Double = 0
  
  convenience init(lat: Double, lon: Double) {
    self.init()
    self.lat = lat
    self.lon = lon
  }
}

// Instruction
class RouteInstructionRealm: BaseObject {
  @Persisted var distance: Double = 0
  @Persisted var heading: Double?
  @Persisted var sign: Int = 0
  @Persisted var interval = List<Int>()
  @Persisted var text: String = ""
  @Persisted var time: Int = 0
  @Persisted var streetName: String = ""
  
  convenience init(from model: RouteInstruction) {
    self.init()
    self.distance = model.distance
    self.heading = model.heading
    self.sign = model.sign
    self.interval.append(objectsIn: model.interval)
    self.text = model.text
    self.time = model.time
    self.streetName = model.streetName
  }
}

// Details
class RouteDetailsRealm: BaseObject {
  @Persisted var surface = List<SurfaceDetailRealm>()
  @Persisted var roadClass = List<RoadClassDetailRealm>()
  
  convenience init(from model: RouteDetails) {
    self.init()
    if let surfaces = model.surface {
      self.surface.append(objectsIn: surfaces.map { SurfaceDetailRealm(from: $0) })
    }
    if let roadClasses = model.roadClass {
      self.roadClass.append(objectsIn: roadClasses.map { RoadClassDetailRealm(from: $0) })
    }
  }
}

class SurfaceDetailRealm: EmbeddedObject {
  @Persisted var fromIndex: Int = 0
  @Persisted var toIndex: Int = 0
  @Persisted var surfaceType: String = ""
  
  convenience init(from model: SurfaceDetail) {
    self.init()
    self.fromIndex = model.fromIndex
    self.toIndex = model.toIndex
    self.surfaceType = model.surfaceType
  }
}

class RoadClassDetailRealm: EmbeddedObject {
  @Persisted var fromIndex: Int = 0
  @Persisted var toIndex: Int = 0
  @Persisted var roadClass: String = ""
  
  convenience init(from model: RoadClassDetail) {
    self.init()
    self.fromIndex = model.fromIndex
    self.toIndex = model.toIndex
    self.roadClass = model.roadClass
  }
}

class PlaceRealm: BaseObject {
  @Persisted var address: String = ""
  @Persisted var fullAddress: String = ""
  @Persisted var latitude: Double = 0
  @Persisted var longitude: Double = 0
  @Persisted var date: Date = Date()
  @Persisted var state: Bool?
  
  convenience init(from Place: Place) {
    self.init()
    self.address = Place.address
    self.fullAddress = Place.fullAddres
    self.latitude = Place.coordinate.latitude
    self.longitude = Place.coordinate.longitude
    self.date = Place.date
    self.state = Place.state
  }
  
  var coordinate: CLLocationCoordinate2D {
    CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
}

class TrackingRouterModel: BaseObject {
  @Persisted var duration: Double?
  @Persisted var distanceRace: Double?
  @Persisted var speed: Double?
}

extension RouteHintsRealm {
  func toModel() -> RouteHints {
    return RouteHints(
      visitedNodes: self.visitedNodes?.toModel()
    )
  }
}

extension VisitedNodesRealm {
  func toModel() -> VisitedNodes {
    return VisitedNodes(sum: self.sum, average: self.average)
  }
}

extension RouteInfoRealm {
  func toModel() -> RouteInfo {
    return RouteInfo(
      copyrights: Array(self.copyrights),
      took: self.took,
      roadDataTimestamp: self.roadDataTimestamp
    )
  }
}

extension RoutePathRealm {
  func toModel() -> RoutePath {
    return RoutePath(
      distance: self.distance,
      weight: self.weight,
      time: self.time,
      transfers: self.transfers,
      pointsEncoded: self.pointsEncoded,
      bbox: Array(self.bbox),
      points: self.points?.toModel() ?? RoutePoints(type: "", coordinates: []),
      instructions: self.instructions.map { $0.toModel() },
      details: self.details?.toModel() ?? RouteDetails(surface: nil, roadClass: nil),
      ascend: self.ascend,
      descend: self.descend,
      snappedWaypoints: self.snappedWaypoints?.toModel() ?? RoutePoints(type: "", coordinates: [])
    )
  }
}

extension RoutePointsRealm {
  func toModel() -> RoutePoints {
    let coords = Array(self.coordinates.map { [$0.lon, $0.lat] })
    return RoutePoints(type: self.type, coordinates: coords)
  }
}

extension RouteInstructionRealm {
  func toModel() -> RouteInstruction {
    return RouteInstruction(
      distance: self.distance,
      heading: self.heading,
      sign: self.sign,
      interval: Array(self.interval),
      text: self.text,
      time: self.time,
      streetName: self.streetName
    )
  }
}

extension RouteDetailsRealm {
  func toModel() -> RouteDetails {
    return RouteDetails(
      surface: self.surface.map { $0.toModel() },
      roadClass: self.roadClass.map { $0.toModel() }
    )
  }
}

extension SurfaceDetailRealm {
  func toModel() -> SurfaceDetail {
    SurfaceDetail(fromIndex: self.fromIndex,
                  toIndex: self.toIndex,
                  surfaceType: self.surfaceType)
  }
}

extension RoadClassDetailRealm {
  func toModel() -> RoadClassDetail {
    RoadClassDetail(fromIndex: self.fromIndex,
                    toIndex: self.toIndex,
                    roadClass: self.roadClass)
  }
}

extension PlaceRealm {
  func toModel() -> Place {
    return Place(
      address: self.address,
      fullAddres: self.fullAddress,
      coordinate: CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude),
      date: self.date,
      state: self.state
    )
  }
}

extension RouteResponseRealm {
  func toModel() -> RouteResponse {
    return RouteResponse(hints: self.hints?.toModel(),
                         info: self.info?.toModel(),
                         paths: self.paths.map { $0.toModel()})
  }
}
