//
//  HorseStatus.swift
//  SooskyHorseTracking
//
//  Created by VuongDV on 27/9/25.
//

import RealmSwift

enum HorseStatus: String, PersistableEnum {
  case healthy = "Healthy"
  case moderate = "Moderate"
  case fatigue = "Fatigued"
}
