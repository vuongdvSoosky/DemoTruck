//
//  UICollectionViewExtension.swift
//  SooskyBabyTracker
//
//  Created by VuongDV on 9/4/25.
//

import UIKit

extension UICollectionView {
  enum Kind {
    case header
    case footer
    
    var value: String {
      switch self {
      case .header:
        return UICollectionView.elementKindSectionHeader
      case .footer:
        return UICollectionView.elementKindSectionFooter
      }
    }
  }
  
  func register(ofType type: AnyClass) {
    register(type, forCellWithReuseIdentifier: String(describing: type.self))
  }
  
  func register(ofType type: AnyClass, ofKind kind: Kind) {
    register(type,
             forSupplementaryViewOfKind: kind.value,
             withReuseIdentifier: String(describing: type.self))
  }
  
  func registerNib(ofType type: AnyClass, bundle: Bundle = .main) {
    register(UINib(nibName: String(describing: type.self), bundle: bundle),
             forCellWithReuseIdentifier: String(describing: type.self))
  }
  
  func registerNib(ofType type: AnyClass, ofKind kind: Kind, bundle: Bundle = .main) {
    register(UINib(nibName: String(describing: type.self), bundle: bundle),
             forSupplementaryViewOfKind: kind.value,
             withReuseIdentifier: String(describing: type.self))
  }
  
  func dequeue<T>(ofType type: T.Type, indexPath: IndexPath) -> T {
    return dequeueReusableCell(withReuseIdentifier: String(describing: T.self), for: indexPath) as! T
  }
  
  func dequeue<T>(ofType type: T.Type, ofKind kind: Kind, indexPath: IndexPath) -> T {
    return dequeueReusableSupplementaryView(ofKind: kind.value,
                                            withReuseIdentifier: String(describing: T.self),
                                            for: indexPath) as! T
  }
}
