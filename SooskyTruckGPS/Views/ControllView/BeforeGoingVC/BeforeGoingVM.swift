//
//  BeforeGoingVM.swift
//  SooskyTruckGPS
//
//  Created by VuongDV on 13/11/25.
//

import Combine

class BeforeGoingVM: BaseViewModel {
  enum Action {
    case back
    case getIndexToScroll(index: Int)
    case save
    case go
  }
  
  let action = PassthroughSubject<Action, Never>()
  let indexForMainScrollView = CurrentValueSubject<Int, Never>(0)
  let PlaceRouter = CurrentValueSubject<RouteResponse?, Never>(nil)
  private let router = BeforeGoingRouter()
  
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

extension BeforeGoingVM {
  private func progressAction(_ action: Action) {
    switch action {
    case .back:
      router.route(to: .back)
    case .getIndexToScroll(let index):
      indexForMainScrollView.value = index
    case .save:
      saveToRealm()
    case .go:
      router.route(to: .go)
    }
  }
}

extension BeforeGoingVM {
  private func saveToRealm() {
    guard let router = PlaceManager.shared.placesRouter else { return }

    let newRoute = RouteResponseRealm(from: router)
    newRoute.nameRouter = PlaceManager.shared.placeGroup.nameRouter
    newRoute.addPlaces(PlaceManager.shared.placeGroup.places)
    
      // Lấy tất cả Route đang active (history = false)
      let itemNormal = RealmService.shared.fetch(ofType: RouteResponseRealm.self)
        .filter { $0.history == false }

      if let existItem = itemNormal.first(where: { $0.id == newRoute.id }) {
        // >>> UPDATE EXISTING RECORD <<<
        let data: [String: Any] = [
          "hints": newRoute.hints as Any,
          "info": newRoute.info as Any,
          "paths": newRoute.paths as Any,
          "places": newRoute.places as Any,
          "trackingRecords": newRoute.trackingRecords as Any,
          "history": newRoute.history as Any,
          "createDate": newRoute.createDate as Any,
          "nameRouter": newRoute.nameRouter as Any
        ]
        RealmService.shared.update(existItem, data: data)
        LogManager.show("Updated existing route id:", existItem.id)
      } else {
        // >>> ADD NEW <<<
        RealmService.shared.add(newRoute)
        LogManager.show("Added new route id:", newRoute.id)
      }
    // Route Done
    PlaceManager.shared.createPlaceRouterID()
    self.router.route(to: .save)
    PlaceManager.shared.setPlaceGroup([], name: "My Route")
  }
}
