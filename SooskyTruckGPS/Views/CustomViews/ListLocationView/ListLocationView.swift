//
//  ListLocationView.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 6/11/25.
//

import UIKit
import SnapKit

class ListLocationView: BaseView {
  private lazy var containerView: UIView = {
    let view = UIView()
    return view
  }()
  
  private lazy var contentView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor(rgb: 0xF3F3F3)
    view.cornerRadius = 20
    return view
  }()
  
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = AppFont.font(.semiBoldText, size: 17)
    label.text = "Route name"
    label.textColor = UIColor(rgb: 0xF26101)
    label.textAlignment = .left
    return label
  }()
  
  private lazy var routeNameLabel: UILabel = {
    let label = UILabel()
    label.font = AppFont.font(.mediumText, size: 22)
    label.textColor = UIColor(rgb: 0x332644)
    label.text = "Highway Supply Chain Network"
    label.textAlignment = .left
    label.numberOfLines = 0
    return label
  }()
  
  private lazy var iconClose: UIImageView = {
    let icon = UIImageView()
    icon.translatesAutoresizingMaskIntoConstraints = false
    icon.image = .icClose
    icon.contentMode = .scaleAspectFit
    icon.isUserInteractionEnabled = true
    icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapClose)))
    return icon
  }()

  // MARK: - UICollectionView
  private lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumInteritemSpacing = 1
    layout.minimumLineSpacing = 1
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.showsVerticalScrollIndicator = false
    collectionView.isScrollEnabled = true
    return collectionView
  }()
  
  private lazy var places: [Place] = []
  
  override func addComponents() {
    addSubviews(containerView)
    addSubviews(contentView)
    contentView.addSubviews(iconClose, titleLabel, routeNameLabel, collectionView)
  }
  
  override func setConstraints() {
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    contentView.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.centerX.equalToSuperview()
      make.left.right.equalToSuperview().inset(20)
      make.height.equalTo(448)
    }
    
    iconClose.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(8)
      make.right.equalToSuperview().inset(12)
      make.width.height.equalTo(24)
    }
    
    titleLabel.snp.makeConstraints { make in
      make.top.equalTo(iconClose.snp.bottom).offset(0)
      make.left.equalToSuperview().inset(12)
    }
    
    routeNameLabel.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(8)
      make.left.right.equalToSuperview().inset(12)
    }
    
    collectionView.snp.makeConstraints { make in
      make.top.equalTo(routeNameLabel.snp.bottom).offset(24)
      make.left.right.equalToSuperview().inset(12)
      make.bottom.equalToSuperview().offset(-24)
    }
  }
  
  override func setProperties() {
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.register(cell: ListLocationCell.self)
    collectionView.backgroundColor = .clear
  }
  
  override func binding() {
    PlaceManager.shared.$places
      .receive(on: DispatchQueue.main)
      .sink { [weak self] places in
        guard let self else {
          return
        }
        self.places = places
        collectionView.reloadData()
      }.store(in: &subscriptions)
  }
  
  // MARK: - Action
  @objc private func onTapClose() {
    self.dismissSlideView()
  }
}

extension ListLocationView: UICollectionViewDelegate {
  
}

extension ListLocationView: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return places.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(ListLocationCell.self, for: indexPath)
    let item = self.places[indexPath.row]
    cell.configData(item)
    cell.onDeleteTapped = { [weak self]  in
      guard let self else {
        return
      }
      PlaceManager.shared.removePlace(item)
    }
    cell.onDeleteModeChanged = { [weak self] isDeleteMode in
      guard let self else { return }
      if isDeleteMode {
        self.hideDeleteModeForOtherCells(except: indexPath)
      }
    }
    return cell
  }
  
  private func hideDeleteModeForOtherCells(except currentIndexPath: IndexPath) {
    for indexPath in collectionView.indexPathsForVisibleItems {
      if indexPath != currentIndexPath {
        if let cell = collectionView.cellForItem(at: indexPath) as? ListLocationCell {
          cell.hideDeleteModeCell()
        }
      }
    }
  }
}

extension ListLocationView: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: self.collectionView.frame.width, height: 82)
  }
}
