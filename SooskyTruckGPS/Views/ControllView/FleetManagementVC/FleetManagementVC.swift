//
//  DiaryVC.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 3/11/25.
//

import UIKit
import SnapKit

class FleetManagementVC: BaseViewController {
  // MARK: - UIView
  private lazy var tabView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.cornerRadius = 20
    view.clipsToBounds = true
    
    view.addSubview(tabStackView)
    view.backgroundColor = UIColor(rgb: 0xFFFFFF)
    tabStackView.snp.makeConstraints { make in
      make.top.left.right.bottom.equalToSuperview().inset(4)
    }
    return view
  }()
  private lazy var saveRouteView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.cornerRadius = 17
    view.clipsToBounds = true
    
    let label = UILabel()
    label.text = "Saved Route"
    label.font = AppFont.font(.semiBoldText, size: 15)
    label.textColor = UIColor(rgb: 0xFFFFFF)
    label.textAlignment = .center
    
    view.addSubview(label)
    
    label.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    
    return view
  }()
  private lazy var historyView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.cornerRadius = 17
    view.clipsToBounds = true
    
    let label = UILabel()
    label.text = "History"
    label.font = AppFont.font(.regularText, size: 14)
    label.textColor = UIColor(rgb: 0x727272)
    label.textAlignment = .center
    
    view.addSubview(label)
    
    label.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    
    return view
  }()
  private lazy var calenderView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.cornerRadius = 12
    view.clipsToBounds = true
    view.backgroundColor = UIColor(rgb: 0xFEFEFE)
    
    let icon = UIImageView()
    icon.image = .icCalendar
    icon.snp.makeConstraints { make in
      make.width.height.equalTo(24)
    }
    
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.distribution = .equalCentering
    
    [dateLabel, icon].forEach({stackView.addArrangedSubview($0)})
    
    view.addSubview(stackView)
    
    stackView.snp.makeConstraints { make in
      make.top.bottom.left.right.equalToSuperview().inset(12)
    }
    
    return view
  }()
  
  // MARK: - UILabel
  private lazy var titleVC: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Fleet Management"
    label.font = AppFont.font(.boldText, size: 28)
    label.textColor = UIColor(rgb: 0x332644)
    return label
  }()
  private lazy var dateLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Wednesday, April 2, 2025"
    label.textColor = UIColor(rgb: 0x1A1A1A)
    label.font = AppFont.font(.regularText, size: 17)
    return label
  }()
  
  // MARK: - StackView
  private lazy var tabStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .horizontal
    stackView.spacing = 8
    stackView.distribution = .fillEqually
    
    [saveRouteView, historyView].forEach({stackView.addArrangedSubview($0)})
    return stackView
  }()
  
  // MARK: - UICollectionView
  private lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumInteritemSpacing = 12
    layout.minimumLineSpacing = 12
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.showsVerticalScrollIndicator = false
    collectionView.isScrollEnabled = true
    return collectionView
  }()
  
  
  private var selectedTab: Int = 0
  private var gradientLayers: [CAGradientLayer] = []
  
  override func addComponents() {
    self.view.addSubviews(titleVC, tabView, calenderView, collectionView)
  }
  
  override func setConstraints() {
    titleVC.snp.makeConstraints { make in
      make.top.equalTo(self.view.snp.topMargin).inset(16)
      make.left.equalToSuperview().inset(20)
      make.height.equalTo(33)
    }
    
    tabView.snp.makeConstraints { make in
      make.top.equalTo(self.titleVC.snp.bottom).inset(-16)
      make.left.right.equalToSuperview().inset(20)
      make.height.equalTo(40)
    }
    
    calenderView.snp.makeConstraints { make in
      make.top.equalTo(self.tabView.snp.bottom).inset(-16)
      make.left.right.equalToSuperview().inset(20)
      make.height.equalTo(49)
    }
    
    collectionView.snp.makeConstraints { make in
      make.top.equalTo(calenderView.snp.bottom).inset(-16)
      make.left.right.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().inset(110)
    }
  }
  
  override func setColor() {
    self.view.backgroundColor = UIColor(rgb: 0xF2F2F2)
    let colors = [UIColor(rgb: 0xF28E01), UIColor(rgb: 0xF26101)]
    saveRouteView.addArrayColorGradient(arrayColor: colors, startPoint: CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5))
    
    calenderView.addShadow()
    tabView.addShadow()
  }
  
  override func setProperties() {
    saveRouteView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapSaveRouteView)))
    historyView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapHistory)))
    setSelectedTab(0)
    
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.register(cell: ItemFleetCell.self)
    collectionView.backgroundColor = .clear
  }
  
  override func binding() {
    PlaceManager.shared.$places
      .receive(on: DispatchQueue.main)
      .sink { [weak self] places in
        guard let self else {
          return
        }
        collectionView.reloadData()
      }.store(in: &subscriptions)
  }
  
  // Action
  @objc private func onTapSaveRouteView() {
    setSelectedTab(0)
  }
  
  @objc private func onTapHistory() {
    setSelectedTab(1)
  }
}

extension FleetManagementVC {
  private func setSelectedTab(_ index: Int) {
    selectedTab = index
    
    removeGradient(from: saveRouteView)
    removeGradient(from: historyView)
    
    setTab(view: saveRouteView, labelFont: AppFont.font(.regularText, size: 14), textColor: UIColor(rgb: 0x727272))
    setTab(view: historyView,   labelFont: AppFont.font(.regularText, size: 14), textColor: UIColor(rgb: 0x727272))
    
    let colors = [UIColor(rgb: 0xF28E01), UIColor(rgb: 0xF26101)]
    
    if index == 0 {
      saveRouteView.addArrayColorGradient(arrayColor: colors, startPoint: CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5))
      setTab(view: saveRouteView, labelFont: AppFont.font(.semiBoldText, size: 15), textColor: .white)
    } else {
      historyView.addArrayColorGradient(arrayColor: colors, startPoint: CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5))
      setTab(view: historyView, labelFont: AppFont.font(.semiBoldText, size: 15), textColor: .white)
    }
  }
  
  private func setTab(view: UIView, labelFont: UIFont, textColor: UIColor) {
    if let label = view.subviews.first as? UILabel {
      label.font = labelFont
      label.textColor = textColor
    }
  }
  
  private func removeGradient(from view: UIView) {
    view.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
  }
}

extension FleetManagementVC: UICollectionViewDelegate {
  
}

extension FleetManagementVC: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//    return PlaceManager.shared.places.count
    return 2
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(ItemFleetCell.self, for: indexPath)
    return cell
  }
}

extension FleetManagementVC: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: self.collectionView.frame.width, height: 196.0)
  }
}
