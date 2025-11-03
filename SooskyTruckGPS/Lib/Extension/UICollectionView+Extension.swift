//
//  UICollectionView+Extension.swift
//  BaseSubscription
//
//  Created by Việt Nguyễn on 13/1/25.
//

import UIKit

extension UICollectionView {
  
  // MARK: - register cell
  func register<T: UICollectionViewCell>(cell: T.Type) {
    register(cell, forCellWithReuseIdentifier: "\(cell.self)")
  }
  
  // MARK: - dequeue reusable cell
  func dequeueReusableCell<T: UICollectionViewCell>(_  cell: T.Type,
                                                    for indexPath: IndexPath) -> T {
    guard let cell = dequeueReusableCell(withReuseIdentifier: "\(cell.self)",
                                         for: indexPath) as? T
    else {
      fatalError("Could not dequeue cell with identifier: \(cell.self)")
    }
    return cell
  }
  
  // MARK: - resgister header
  func register<T: UICollectionReusableView>(header: T.Type) {
    register(T.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "\(header.self)")
  }
  
  // MARK: - dequeue reusable header
  func dequeueReusableSupplementaryView<T: UICollectionReusableView>(header: T.Type, indexPath: IndexPath) -> T {
    guard let supplementaryView = dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "\(header.self)", for: indexPath) as? T else {
      fatalError("Could not dequeue supplementary view with identifier: \(header.self)")
    }
    return supplementaryView
  }
}
