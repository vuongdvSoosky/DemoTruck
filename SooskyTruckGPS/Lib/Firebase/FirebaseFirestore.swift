//
//  FirebaseFirestore.swift
//  ThermalCameraSub
//
//  Created by HaiTu on 21/11/24.
//

import UIKit
import FirebaseFirestore

struct ConfigFS : Codable {
  var showAds: Bool
  var displaySub: Int
}

extension Notification.Name {
  static let configFirebase = Notification.Name("configFirebase")
}

class FireBaseFirestore {
  static let sharedInstance = FireBaseFirestore()
  
  let db = Firestore.firestore()
  var listener : ListenerRegistration? = nil
  init() {}
  
  func getConfigApp(complete: @escaping ((Bool) -> Void)) {
    listener = db.collection("Config").document("vfon5Ab9F2mIiLkWxjBL").addSnapshotListener { documentSnapshot, error in
      if error != nil{
        NotificationCenter.default.post(name: .configFirebase, object: nil)
        return
      }
      
      // If we don't have documents, exit the function
      guard let documents = documentSnapshot, documents.exists else {
        LogManager.show("xxx Error fetching documents: \(String(describing: error))")
        NotificationCenter.default.post(name: .configFirebase, object: nil)
        return
      }
      
      do{
        let configFBDB = try documents.data(as: ConfigFS.self)
        AppManager.shared.getStateAds(showAds: configFBDB.showAds)
        AppManager.shared.displaySub = configFBDB.displaySub
        complete(configFBDB.showAds)
      }catch{
        LogManager.show("xxx \(error.localizedDescription)")
      }
      
      NotificationCenter.default.post(name: .configFirebase, object: nil)
    }
  }
  
  func stopListener() {
    listener?.remove()
  }
}
