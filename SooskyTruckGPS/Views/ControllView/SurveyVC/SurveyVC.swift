//
//  SurveyVC.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 1/12/25.
//

import UIKit
import SnapKit

class SurveyVC: BaseViewController {
  private var containerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor(rgb: 0xFFF8EC)
    return view
  }()
  
  private lazy var overView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    let label = UILabel()
    label.text = "Overview"
    label.font = AppFont.font(.regularText, size: 17)
    label.textColor = UIColor(rgb: 0x000000)
    
    view.addSubviews(label, stackProgressView)
    
    label.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.left.equalToSuperview()
    }
    
    stackProgressView.snp.makeConstraints { make in
      make.top.equalTo(label.snp.bottom).inset(-10)
      make.left.equalToSuperview()
    }
    
    return view
  }()
  
  private lazy var stackProgressView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.spacing = 4
    [line1View, line2View].forEach({stackView.addArrangedSubview($0)})
    
    return stackView
  }()
  
  private lazy var line1View: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor(rgb: 0xF26101)
    view.cornerRadius = 4
    view.snp.makeConstraints { make in
      make.height.equalTo(8)
      make.width.equalTo(100)
    }
    return view
  }()
  
  private lazy var line2View: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor(rgb: 0xEFBE9B)
    view.cornerRadius = 4
    view.snp.makeConstraints { make in
      make.height.equalTo(8)
      make.width.equalTo(100)
    }
    return view
  }()
  
  private lazy var smallTruckView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .clear
    
    let label = UILabel()
    label.text = "Please specify your vehicle type or model"
    label.textColor = UIColor(rgb: 0x332644)
    label.font = AppFont.font(.heavy, size: 28)
    label.numberOfLines = 0
    label.textAlignment = .center
    
    view.addSubviews(label, smallTruckCollectionView)
    
    label.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.left.right.equalToSuperview().inset(20)
    }
    
    smallTruckCollectionView.snp.makeConstraints { make in
      make.top.equalTo(label.snp.bottom).inset(-24)
      make.left.right.bottom.equalToSuperview().inset(20)
    }
    
    return view
  }()
  
  private lazy var ownerTypeView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .clear
    
    let label = UILabel()
    label.text = "Which best describes \n you?"
    label.textColor = UIColor(rgb: 0x332644)
    label.font = AppFont.font(.heavy, size: 25)
    label.numberOfLines = 0
    label.textAlignment = .center
    
    view.addSubviews(label, ownerCollectionView)
    
    label.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.left.right.equalToSuperview().inset(20)
    }
    
    ownerCollectionView.snp.makeConstraints { make in
      make.top.equalTo(label.snp.bottom).inset(-24)
      make.left.right.bottom.equalToSuperview().inset(20)
    }
    
    return view
  }()
  
  private lazy var ownerCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumInteritemSpacing = 12
    layout.minimumLineSpacing = 12
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.showsVerticalScrollIndicator = false
    collectionView.isScrollEnabled = true
    return collectionView
  }()
  
  private lazy var smallTruckCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumInteritemSpacing = 12
    layout.minimumLineSpacing = 12
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.showsVerticalScrollIndicator = false
    collectionView.isScrollEnabled = true
    return collectionView
  }()
  
  private lazy var skipView: UIButton = {
    let view = UIButton()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.cornerRadius = 20
    view.isUserInteractionEnabled = true
    view.setTitle("Skip", for: .normal)
    view.titleLabel?.font = AppFont.font(.lightText, size: 17)
    view.setTitleColor(UIColor(rgb: 0x585858), for: .normal)
    return view
  }()
  
  private lazy var saveView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor(rgb: 0x909090)
    view.cornerRadius = 20
    view.isUserInteractionEnabled = false
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapSave)))
    
    view.snp.makeConstraints { make in
      make.height.equalTo(60)
    }
    
    let label = UILabel()
    label.text = "Continue"
    label.font = AppFont.font(.bold, size: 20)
    label.textColor = UIColor(rgb: 0xFFFFFF)
    label.textAlignment = .center
    
    view.addSubview(label)
    
    label.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    
    return view
  }()
  
  
  // MARK: - UIScrollView
  private lazy var mainScrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.isPagingEnabled = true
    scrollView.isScrollEnabled = false
    scrollView.contentInsetAdjustmentBehavior = .never
    scrollView.backgroundColor = .clear
    return scrollView
  }()
  
  private lazy var contentView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private var indexItemOnwer: Int?
  private var indexItemVehicle: Int?
  
  private let viewModel = OnboardVM()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    AppManager.shared.setStateShouldShowOpenAds(false)
  }
  
  override func addComponents() {
    self.view.addSubviews(containerView)
    containerView.addSubviews(overView, saveView, skipView, mainScrollView)
    mainScrollView.addSubview(contentView)
    contentView.addSubviews(ownerTypeView, smallTruckView)
    
  }
  
  override func setConstraints() {
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    overView.snp.makeConstraints { make in
      make.top.equalTo(self.view.snp.topMargin).inset(14)
      make.left.right.equalToSuperview().inset(20)
      make.height.equalTo(44)
    }
    
    skipView.snp.makeConstraints { make in
      make.centerY.equalTo(stackProgressView.snp.centerY)
      make.right.equalToSuperview().inset(20)
      make.width.equalTo(35)
    }
    
    mainScrollView.snp.makeConstraints { make in
      make.top.equalTo(self.overView.snp.bottom).inset(-20)
      make.left.right.equalToSuperview()
    }
    
    saveView.snp.makeConstraints { make in
      make.top.equalTo(mainScrollView.snp.bottom).inset(-10)
      make.left.right.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().inset(68)
      make.height.equalTo(60)
    }
    
    contentView.snp.makeConstraints { make in
      make.edges.equalTo(mainScrollView.contentLayoutGuide)
      make.height.equalTo(mainScrollView.frameLayoutGuide)
      make.width.equalTo(mainScrollView.frameLayoutGuide).multipliedBy(2)
    }
    
    ownerTypeView.snp.makeConstraints { make in
      make.top.bottom.left.equalToSuperview()
      make.width.equalTo(containerView.snp.width)
    }
    
    smallTruckView.snp.makeConstraints { make in
      make.top.bottom.right.equalToSuperview()
      make.left.equalTo(ownerTypeView.snp.right)
      make.width.equalTo(containerView.snp.width)
      make.height.equalToSuperview()
    }
  }
  
  override func setProperties() {
    skipView.addTarget(self, action: #selector(onTapSkip), for: .touchUpInside)
  }
  
  override func setColor() {
    ownerCollectionView.backgroundColor = .clear
    smallTruckCollectionView.backgroundColor = .clear
    
    ownerCollectionView.delegate = self
    ownerCollectionView.dataSource = self
    ownerCollectionView.register(cell: ItemSurveyCell.self)
    
    smallTruckCollectionView.delegate = self
    smallTruckCollectionView.dataSource = self
    smallTruckCollectionView.register(cell: ItemSurveyCell.self)
  }
}

extension SurveyVC {
  @objc private func onTapBigTruckView() {
    enableSaveView()
    TruckTypeManager.shared.setType(.big)
  }
  
  @objc private func onTapSmallTruckView() {
    
    enableSaveView()
    TruckTypeManager.shared.setType(.small)
  }
  
  @objc private func onTapSave() {
    
    guard (indexItemVehicle != nil) else {
      guard (indexItemOnwer != nil) else {
        return
      }
      
      scrollToPage(index: 1)
      return
    }
    
    viewModel.action.send(.onb2)
    UserDefaultsManager.shared.set(TruckTypeManager.shared.truckTypes?.rawValue, key: .truckType)
  }
  
  @objc private func onTapSkip() {
    TruckTypeManager.shared.setType(.small)
    viewModel.action.send(.onb2)
  }
  
  private func enableSaveView() {
    DispatchQueue.main.async {
      let colors = [UIColor(rgb: 0xF28E01), UIColor(rgb: 0xF26101)]
      self.saveView.addArrayColorGradient(arrayColor: colors, startPoint: CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5))
      self.saveView.isUserInteractionEnabled = true
      self.saveView.cornerRadius = 20
      self.saveView.clipsToBounds = true
    }
  }
  
  func scrollToPage(index: Int, animated: Bool = true) {
    mainScrollView.isScrollEnabled = true
    let pageWidth = mainScrollView.frame.size.width
    let targetOffset = CGPoint(x: CGFloat(index) * pageWidth, y: 0)
    mainScrollView.setContentOffset(targetOffset, animated: animated)
    mainScrollView.isScrollEnabled = false
    if index == 1 {
      line2View.backgroundColor = UIColor(rgb: 0xF26101)
      saveView.removeGradient()
      saveView.isUserInteractionEnabled = false
    }
  }
}

extension SurveyVC: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if collectionView === self.ownerCollectionView {
      self.indexItemOnwer = indexPath.row
      enableSaveView()
    } else {
      self.indexItemVehicle = indexPath.row
      switch VehicleType.allCases[indexPath.row] {

      case .semiTruck, .heavyBox, .largeMotorhome:
        TruckTypeManager.shared.setType(.big)
        
      case .cargoVan, .smallBox, .pickupTruck, .campervan:
        TruckTypeManager.shared.setType(.small)
      }
      enableSaveView()
    }
    
    collectionView.reloadData()
  }
}

extension SurveyVC: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if collectionView === self.ownerCollectionView {
      return OwnerType.allCases.count
    } else {
      return VehicleType.allCases.count
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if collectionView === self.ownerCollectionView {
      let cell = self.ownerCollectionView.dequeueReusableCell(ItemSurveyCell.self, for: indexPath)
      let item = OwnerType.allCases[indexPath.row]
      cell.binding(with: item)
      if indexItemOnwer == indexPath.row {
        cell.chooseItem(isSelected: true)
      } else {
        cell.chooseItem(isSelected: false)
      }
      return cell
      
    } else {
      let cell = self.smallTruckCollectionView.dequeueReusableCell(ItemSurveyCell.self, for: indexPath)
      let item = VehicleType.allCases[indexPath.row]
      cell.bindingForWorkType(with: item)
      if indexItemVehicle == indexPath.row {
        cell.chooseItem(isSelected: true)
      } else {
        cell.chooseItem(isSelected: false)
      }
      return cell
    }
  }
}

extension SurveyVC: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.frame.width, height: 60)
  }
}
