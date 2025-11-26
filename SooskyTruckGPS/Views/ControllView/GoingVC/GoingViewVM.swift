//
//  GoingViewModel.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 17/11/25.
//

import Foundation
import Combine

class GoingViewVM: BaseViewModel {
  enum Action {
    case getIndex(int: Int)
    case getTrackingState(state: TrackingState)
    case getItem(item: Place)
    case getTimeTracking(time: String)
    case getDuration(time: Double)
    case finish
    case edit
  }
  
  let action = PassthroughSubject<Action, Never>()
  let index = CurrentValueSubject<Int?, Never>(nil)
  var trackingState: TrackingState = .beginTracking
  let timeTracking = CurrentValueSubject<String, Never>("00:00:00")
  let speed: Double = 0.0
  var duration: Double = 0.0
  private let router = GoingRouter()
  
  override init() {
    super.init()
    
    action.sink(receiveValue: {[weak self] action in
      guard let self else {
        return
      }
      progressAction(action)
    }).store(in: &subscriptions)
  }
}

extension GoingViewVM {
  private func progressAction(_ action: Action) {
    switch action {
    case .getIndex(let index):
      self.index.send(index)
    case .getTrackingState(state: let state):
      trackingState = state
    case .getItem(item: let item):
      router.route(to: .arrievedView, parameters: ["Place": item])
    case .getTimeTracking(time: let time):
      timeTracking.value = time
    case .finish:
     
      guard let router = PlaceManager.shared.placesRouter else {
        return
      }
      let routeRealm = RouteResponseRealm(from: router)
      routeRealm.history = true
      
      let trackingRecords = TrackingRouterModel()
      trackingRecords.duration = duration
      trackingRecords.speed = DistanceCalculator.shared.currentSpeed
      trackingRecords.distanceRace = DistanceCalculator.shared.totalDistanceMiles
      
      RealmService.shared.appendToList(
        parent: routeRealm,
        keyPath: \.trackingRecords,
        object: trackingRecords
      )
      
      LogManager.show(PlaceManager.shared.placeGroup.nameRouter)
      routeRealm.nameRouter = PlaceManager.shared.placeGroup.nameRouter
      routeRealm.addPlaces(PlaceManager.shared.placeGroup.places)
      RealmService.shared.add(routeRealm)
      
      PlaceManager.shared.setPlaceGroup([], name: "My Route")
      self.router.route(to: .finish)
      
    case .getDuration(time: let time):
      duration = time
    case .edit:
      router.route(to: .edit)
    }
  }
}

