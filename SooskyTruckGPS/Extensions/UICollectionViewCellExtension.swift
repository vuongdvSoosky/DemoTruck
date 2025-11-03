//
//  UICollectionViewCellExtension.swift
//  SooskyBabyTracker
//
//  Created by VuongDV on 9/4/25.
//

import UIKit

extension UICollectionViewCell {
  // Lấy indexPath hiện tại của cell.
  func getIndexPath() -> IndexPath? {
    guard let collectionView = nearestAncestor(ofType: UICollectionView.self) else {
      return nil
    }
    return collectionView.indexPath(for: self)
  }
}
