//
//  LoadingVM.swift
//  SooskyTruckGPS
//
//  Created by VuongDV on 13/11/25.
//

import Combine
import Foundation
import MapKit
import RealmSwift

class LoadingVM: BaseViewModel {
  enum Action {
    case getRequest
    case confirm
    case iap
    case cancelRequest
    case beforGoing
  }

  private let router = LoadingRouter()
  private var requestTask: Task<Void, Never>?
  let showConfirmView = PassthroughSubject<Void, Never>()
  
  let action = PassthroughSubject<Action, Never>()
  
  // Filtered places để gọi API (không bao gồm places có state != nil)
  var filteredPlacesForAPI: [Place]?
  
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

extension LoadingVM {
  private func progressAction(_ action: Action) {
    switch action {
    case .getRequest:
      requestAPIPlaces()
    case .confirm:
      //      router.route(to: .pushSummaryVC, parameters: ["HorseModel": itemHorse.value as Any,
      //                                                    "TrackingHorseModel": trackingModel as Any])
      break
    case .iap:
      router.route(to: .iap)
    case .cancelRequest:
      requestTask?.cancel()
      requestTask = nil
      LogManager.show("[Action] Cancel API request")
      router.route(to: .back)
    case .beforGoing:
      router.route(to: .beforGoing)
    }
  }
}

extension LoadingVM {
  private func requestAPIPlaces() {
    // Sử dụng filtered places nếu có, nếu không thì dùng places từ PlaceManager
    let placesToUse = filteredPlacesForAPI ?? PlaceManager.shared.placeGroup.places
    let points: [[Double]] = placesToUse.map { [$0.coordinate.longitude, $0.coordinate.latitude] }
    requestTask?.cancel()
    
    requestTask = Task { [weak self] in
      guard let self else { return }
      
      do {
        let data = try await APIService.shared.fetchData(with: points)
        
        if Task.isCancelled {
          LogManager.show("[Debug] request canceled")
          return
        }
        
        DispatchQueue.main.async { [weak self] in
          guard let self else {
            return
          }
          guard let data = data else { return }
          showConfirmView.send(())
          PlaceManager.shared.updateRoute(data)
        }
      } catch let error {
        LogManager.show(error)
        router.route(to: .showError)
      }
    }
  }
}
