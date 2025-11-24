//
//  DetailRouterView.swift
//  SooskyTruckGPS
//
//  Created by VuongDV on 13/11/25.
//

import UIKit
import SnapKit

class DetailRouterView: BaseView {
  private lazy var containerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private lazy var titleRoute: UILabel = {
    let label = UILabel()
    label.text = "Highway Supply Chain Network"
    label.textColor = UIColor(rgb: 0x332644)
    label.numberOfLines = 0
    label.font = AppFont.font(.boldText, size: 21)
    
    return label
  }()
  
  private lazy var totalDistanceView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    let icon = UIImageView()
    icon.image = .icTotalDistance
    icon.contentMode = .scaleAspectFit
    
    view.addSubviews(icon, totalDistanceValue, totalDistanceTitle)
    
    icon.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.width.height.equalTo(28)
      make.left.equalToSuperview()
    }
    
    totalDistanceValue.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(5)
      make.left.equalTo(icon.snp.right).inset(-8)
      make.right.equalToSuperview()
    }
    
    totalDistanceTitle.snp.makeConstraints { make in
      make.top.equalTo(totalDistanceValue.snp.bottom).inset(-2)
      make.left.equalTo(icon.snp.right).inset(-8)
      make.right.equalToSuperview()
    }
    return view
  }()
  
  private lazy var timeEstimateView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    
    let icon = UIImageView()
    icon.image = .icTimeEstimate
    icon.contentMode = .scaleAspectFit
    
    
    view.addSubviews(icon, totalTimeValue, totalTimeTitle)
    
    icon.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.width.height.equalTo(28)
      make.left.equalToSuperview()
    }
    
    totalTimeValue.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(5)
      make.left.equalTo(icon.snp.right).inset(-8)
      make.right.equalToSuperview()
    }
    
    totalTimeTitle.snp.makeConstraints { make in
      make.top.equalTo(totalTimeValue.snp.bottom).inset(-2)
      make.left.equalTo(icon.snp.right).inset(-8)
      make.right.equalToSuperview()
    }
    
    return view
  }()
  
  private lazy var totalTimeValue: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "1h59m"
    label.textColor = UIColor(rgb: 0xF26101)
    label.font = AppFont.font(.boldText, size: 17)
    return label
  }()
  
  private lazy var totalTimeTitle: UILabel = {
    let label = UILabel()
    label.text = "Time Estimate"
    label.textColor = UIColor(rgb: 0x909090)
    label.font = AppFont.font(.regularText, size: 12)
    return label
  }()
  
  // MARK: - UILabel
  private lazy var totalDistanceValue: UILabel = {
    let label = UILabel()
    label.text = "5000"
    label.textColor = UIColor(rgb: 0xF26101)
    label.font = AppFont.font(.boldText, size: 17)
    return label
  }()
  
  private lazy var totalDistanceTitle: UILabel = {
    let label = UILabel()
    label.text = "Total Distance(mi)"
    label.textColor = UIColor(rgb: 0x909090)
    label.font = AppFont.font(.regularText, size: 12)
    return label
  }()
  
  // MARK: - UICollectionView
  private lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumInteritemSpacing = 16
    layout.minimumLineSpacing = 16
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.showsVerticalScrollIndicator = false
    collectionView.isScrollEnabled = true
    return collectionView
  }()
  
  private var disableButtonEdit: Bool = false
  
  override func addComponents() {
    self.addSubviews(containerView)
    containerView.addSubviews(titleRoute, totalDistanceView, timeEstimateView, collectionView)
  }
  
  override func setConstraints() {
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    titleRoute.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.left.right.equalToSuperview().inset(30)
    }
    
    totalDistanceView.snp.makeConstraints { make in
      make.top.equalTo(titleRoute.snp.bottom).inset(-20)
      make.left.equalToSuperview().inset(32)
      make.height.equalTo(36)
      make.width.equalTo(143)
    }
    
    timeEstimateView.snp.makeConstraints { make in
      make.top.equalTo(titleRoute.snp.bottom).inset(-20)
      make.right.equalToSuperview().inset(32)
      make.height.equalTo(37)
      make.width.equalTo(117)
    }
    
    collectionView.snp.makeConstraints { make in
      make.top.equalTo(timeEstimateView.snp.bottom).inset(-20)
      make.left.right.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().inset(132)
    }
  }
  
  override func setProperties() {
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.register(cell: DetailRouteCell.self)
    collectionView.backgroundColor = .clear
  }
  
  override func binding() {
    PlaceManager.shared.$placeGroup
      .receive(on: DispatchQueue.main)
      .sink { [weak self] Places in
        guard let self else {
          return
        }
        collectionView.reloadData()
      }.store(in: &subscriptions)
    
    PlaceManager.shared.$placesRouter
      .receive(on: DispatchQueue.main)
      .sink { [weak self] placeRouter in
        guard let self else {
          return
        }
        
        guard let distance = placeRouter?.paths.first?.distance,
        let time = placeRouter?.paths.first?.time else {
          return
        }
        
        self.totalDistanceValue.text = "\(distance.milesString)"
        self.totalTimeValue.text = "\(time.toTimeString)"
      }.store(in: &subscriptions)
  }
}

extension DetailRouterView: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return PlaceManager.shared.placeGroup.places.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(DetailRouteCell.self, for: indexPath)
    let item = PlaceManager.shared.placeGroup.places[indexPath.row]
    let lastIndex = PlaceManager.shared.placeGroup.places.count - 1
    cell.configData(item)
    if indexPath.row == lastIndex {
      cell.hideLineView()
    } else {
      cell.showLineView()
    }
    
    return cell
  }
}

extension DetailRouterView: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: self.collectionView.frame.width, height: 58)
  }
}

extension DetailRouterView {
  func disableButton() {
    self.disableButtonEdit = true
  }
}
