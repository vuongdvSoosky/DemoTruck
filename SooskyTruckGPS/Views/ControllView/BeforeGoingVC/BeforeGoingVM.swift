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
    guard let router = PlaceManager.shared.placesRouter else {
      return
    }
    let routeRealm = RouteResponseRealm(from: router)
    routeRealm.nameRouter = PlaceManager.shared.placeGroup.nameRouter
    routeRealm.addPlaces(PlaceManager.shared.placeGroup.places)
    
    let item = RealmService.shared.fetch(ofType: RouteResponseRealm.self)
    LogManager.show(item)
    
    LogManager.show(routeRealm.id)
    RealmService.shared.add(routeRealm)
    self.router.route(to: .save)
    
    PlaceManager.shared.setPlaceGroup([], name: "My Route")
  }
}
