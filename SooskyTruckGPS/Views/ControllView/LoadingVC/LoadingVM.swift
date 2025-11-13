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
  }
  
  let distance = CurrentValueSubject<Double?, Never>(0.0)
  let duration = CurrentValueSubject<Double?, Never>(0.0)
  let pace = CurrentValueSubject<String?, Never>(nil)
  let speed = CurrentValueSubject<Double?, Never>(nil)
  let rpe = CurrentValueSubject<Int?, Never>(nil)
  let startAt = CurrentValueSubject<String, Never>("")
  let endAt = CurrentValueSubject<String, Never>("")
  let trainingType = CurrentValueSubject<String?, Never>(nil)
 // let itemHorse = CurrentValueSubject<HorseModel?, Never>(nil)
  let bodyData: Data?
  let imageThumb: Data?
  var patch: [[CLLocationCoordinate2D]]?
//  var trackingModel: TrackingHorseModel?
  let showConfirmView = PassthroughSubject<Void, Never>()
  private let router = LoadingRouter()
  
  let action = PassthroughSubject<Action, Never>()
  
  init(_ bodyData: Data, distance: Double, duration: Double, pace: String,
       speed: Double, rpe: Int, startAt: String,
       endAt: String, trainingType: String, imageThumb: Data,
       path: [[CLLocationCoordinate2D]]) {
    self.bodyData = bodyData
    self.distance.value = distance
    self.duration.value = duration
    self.endAt.value = endAt
    self.pace.value = pace
    self.rpe.value = rpe
    self.trainingType.value = trainingType
    self.startAt.value = startAt
   // self.itemHorse.value = itemHorse
    self.imageThumb = imageThumb
    self.patch = path
    self.speed.value = speed
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
      requestAPIHorse()
    case .confirm:
//      router.route(to: .pushSummaryVC, parameters: ["HorseModel": itemHorse.value as Any,
//                                                    "TrackingHorseModel": trackingModel as Any])
      break
    case .iap:
      router.route(to: .iap)
    }
  }
}

extension LoadingVM {
  private func requestAPIHorse() {
//    Task { [weak self] in
//      guard let self else { return }
//      var lastError: Error?
//      
//      for attempt in 1...3 {
//        do {
//          let durationInMinutes = (self.duration.value ?? 0.1) / 60.0
//          let avgSpeed = (self.distance.value ?? 0.1) / durationInMinutes
//          let response: PostSessionResponse = try await APIService().request(from: .analyzeSession, body: bodyData)
//          CreditManager.shared.createCredit(for: .session)
//          
//          let record = TrackingHorseModel(
//            distanceRace: self.distance.value?.roundToDecimals(decimals: 4) ?? 0.0,
//            duration: self.duration.value ?? 0.0,
//            pace: self.pace.value,
//            speed: avgSpeed,
//            rpe: rpe.value,
//            aiCoach: AICoachModel(postSessionStatus: response.data?.postSessionStatus,
//                                  summary: response.data?.summary?.first,
//                                  trainingType: response.data?.trainingType?.first,
//                                  coolDown: response.data?.recommendations?.coolDown?.first,
//                                  recovery: response.data?.recommendations?.recovery?.first,
//                                  nextSession: response.data?.recommendations?.nextSession?.first,
//                                  error: response.reason),
//            trainingType: trainingType.value,
//            startAt: self.startAt.value,
//            endAt: self.endAt.value,
//            imageThumb: self.imageThumb ?? Data(),
//            patch: List<LocationGroupModel>(nestedCoordinates: patch ?? [[]]),
//            showInforAI: CreditManager.shared.isCreditExceeded(for: .session)
//          )
//          
//          let postSessionStatus = record.aiCoach?.postSessionStatus ?? "healthy"
//          
//          await MainActor.run {
//            self.callAPIForListSession(rpe.value ?? 1, postSessionStatus: postSessionStatus)
//          }
//          
//          self.trackingModel = record
//          showConfirmView.send(())
//          return
//          
//        } catch {
//          lastError = error
//          LogManager.show("Attempt \(attempt) failed: \(error)")
//          if attempt < 3 {
//            try? await Task.sleep(nanoseconds: 1_000_000_000)
//          }
//        }
//      }
//      
//      if let lastError {
//        LogManager.show("All attempts failed: \(lastError)")
//        showConfirmView.send(())
//      }
//    }
  }
    
  private func callAPIForListSession(_ rpe: Int, postSessionStatus: String) {
//    let startAtDate = self.itemHorse.value?.lastRace ?? Date()
//    let endAt = startAtDate.endOfDayUTC
//    let startAt = startAtDate.daysBeforeEndOfDay(7)
//    
//    guard let horse = self.itemHorse.value else { return }
//    
//    let data = RealmService.shared.convertToArray(list: horse.trackingRecords)
//    
//    let results = data.filter({
//      $0.startAt?.fromISO8601Date() ?? Date() >= startAt &&
//      $0.startAt?.fromISO8601Date() ?? Date() <= endAt()
//    })
//    
//    func safeDistance(_ value: Double?) -> Double {
//      let dist = value ?? 0.0
//      return dist < 0.1 ? 0.1 : dist
//    }
//    
//    let manualSession: [String: Any] = [
//      "startAt": self.startAt.value,
//      "endAt": self.endAt.value,
//      "postSessionStatus": postSessionStatus,
//      "distanceInMiles": safeDistance(self.distance.value),
//      "durationInSeconds": Int(self.duration.value ?? 0.0),
//      "trainingType": self.trainingType.value ?? "General-Riding",
//      "rpe": rpe
//    ]
//    
//    let sessionsArray: [[String: Any]] = results.map { record in
//      return [
//        "startAt": record.startAt ?? "",
//        "endAt": record.endAt ?? "",
//        "postSessionStatus": record.aiCoach?.postSessionStatus?.lowercasingFirstLetter() ?? "healthy",
//        "distanceInMiles": safeDistance(record.distanceRace),
//        "durationInSeconds": Int(record.duration ?? 0.0),
//        "trainingType": record.trainingType ?? "General-Riding",
//        "rpe": record.rpe ?? 1
//      ]
//    } + [manualSession]
//    
//    let bodyRequest: [String: Any] = [
//      "from": ISO8601DateFormatter().string(from: startAt),
//      "to": ISO8601DateFormatter().string(from: endAt()),
//      "sessions": sessionsArray
//    ]
//    
//    let bodyData = try? JSONSerialization.data(withJSONObject: bodyRequest, options: [])
//    
//    Task {
//      var lastError: Error?
//      
//      for attempt in 1...3 {
//        do {
//          LogManager.show("Attempt \(attempt)/3 - calling analyzeSessionsHistory")
//          let response: SessionHistoryResponse = try await APIService().request(from: .analyzeSessionsHistory, body: bodyData)
//          
//          let data: [String: Any] = [
//            "summary": response.data?.summary as Any,
//            "keyObservations": response.data?.keyObservations as Any,
//            "recommendations": response.data?.recommendations as Any,
//            "aiCoachState": response.ok as Any,
//            "showAICoach" : CreditManager.shared.isCreditExceeded(for: .session) as Any
//          ]
//          
//          await MainActor.run {
//            guard let item = RealmService.shared.getById(ofType: HorseModel.self, id: horse.id) else { return }
//            RealmService.shared.update(item, data: data)
//          }
//          
//          return
//          
//        } catch {
//          lastError = error
//          LogManager.show("Attempt \(attempt) failed: \(error)")
//          if attempt < 3 {
//            try? await Task.sleep(nanoseconds: 1_000_000_000)
//          }
//        }
//      }
//      
//      if let lastError {
//        LogManager.show("All attempts for analyzeSessionsHistory failed: \(lastError)")
//      }
//    }
  }
}
