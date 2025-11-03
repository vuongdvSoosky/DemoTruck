//
//  Purchasable.swift
//  SooskyBabyTracker
//
//  Created by VuongDv on 8/8/25.
//

protocol Purchasable: AnyObject {
  func purchaseProduct(type: RegisteredPurchase)
}
