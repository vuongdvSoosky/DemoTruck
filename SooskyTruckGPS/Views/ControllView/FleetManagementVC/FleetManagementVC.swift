//
//  DiaryVC.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 3/11/25.
//

import UIKit
import SnapKit
import Combine

class FleetManagementVC: BaseViewController {
  // MARK: - UIView
  private lazy var tabView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.cornerRadius = 20
    view.clipsToBounds = true
    
    view.addSubview(tabStackView)
    view.backgroundColor = UIColor(rgb: 0xFCFCFC)
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
  private lazy var historyTabView: UIView = {
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
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapCalendar)))
    
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
  private lazy var contentView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private lazy var saveView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.addSubviews(stackSaveNativeView, saveEmptyView, collectionView)
    
    stackSaveNativeView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.left.right.equalToSuperview()
      make.height.equalTo(110)
    }
    
    collectionView.snp.makeConstraints { make in
      make.top.equalTo(stackSaveNativeView.snp.bottom).inset(-10)
      make.left.right.equalToSuperview()
      make.bottom.equalToSuperview()
    }
    
    saveEmptyView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.equalTo(302)
      make.height.equalTo(76)
    }
    return view
  }()
  
  private lazy var saveNativeView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.cornerRadius = 12
    view.borderWidth = 1
    view.borderColor = UIColor(rgb: 0x808080)
    
    return view
  }()
  
  private lazy var stackSaveNativeView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [saveNativeView])
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()
  
  private lazy var historyNativeView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.cornerRadius = 12
    view.borderWidth = 1
    view.borderColor = UIColor(rgb: 0x808080)
    return view
  }()
  
  private lazy var historyStackNativeView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [historyNativeView])
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()
  
  private lazy var historyView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.addSubviews(historyStackNativeView, historyEmptyView, historyCollectionView)
    
    historyStackNativeView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.left.right.equalToSuperview()
      make.height.equalTo(110)
    }
    
    historyCollectionView.snp.makeConstraints { make in
      make.top.equalTo(historyStackNativeView.snp.bottom).inset(-10)
      make.left.right.equalToSuperview()
      make.bottom.equalToSuperview()
    }
    
    historyEmptyView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.equalTo(302)
      make.height.equalTo(76)
    }
    return view
  }()
  
  private let saveEmptyView = EmptyView(
    title: "No saved routes yet",
    description: "Start planning your first route to manage your fleet more efficiently"
  )
  
  private let historyEmptyView = EmptyView(
    title: "No reports available",
    description: "Reports will appear here once activity starts"
  )
  
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
    label.text = "Select a date range"
    label.textColor = UIColor(rgb: 0x909090)
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
    
    [saveRouteView, historyTabView].forEach({stackView.addArrangedSubview($0)})
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
  
  private lazy var historyCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumInteritemSpacing = 12
    layout.minimumLineSpacing = 12
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.showsVerticalScrollIndicator = false
    collectionView.isScrollEnabled = true
    return collectionView
  }()
  
  //  MARK: - MainScrollView
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
  
  // MARK: UIImageView
  private lazy var icPremium: UIImageView = {
    let image = UIImageView()
    image.translatesAutoresizingMaskIntoConstraints = false
    image.image = .icPremium
    image.isHidden = true
    image.isUserInteractionEnabled = true
    image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapPremium)))
    return image
  }()
  
  private var gradientLayers: [CAGradientLayer] = []
  
  private let viewModel = FleetManagementVM()
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    Publishers.Zip(viewModel.startDate, viewModel.endDate)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] startDate, endDate in
        guard let self, let startDate = startDate, let endDate = endDate else { return }
        self.dateLabel.text = "\(startDate.asString(format: "MMM d, yyyy")) - \(endDate.asString(format: "MMM d, yyyy"))"
        self.dateLabel.textColor = UIColor(rgb: 0x332644)
        viewModel.action.send(.filterData(selectedDate: (startDate, endDate)))
      }.store(in: &subscriptions)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupSaveNativeView()
  }
  
  var handlerActionDeleted: Handler?
  
  override func addComponents() {
    self.view.addSubviews(titleVC, icPremium, tabView, calenderView, mainScrollView)
    mainScrollView.addSubviews(contentView)
    contentView.addSubviews(saveView, historyView)
  }
  
  override func setConstraints() {
    titleVC.snp.makeConstraints { make in
      make.top.equalTo(self.view.snp.topMargin).inset(16)
      make.left.equalToSuperview().inset(20)
      make.height.equalTo(33)
    }
    
    icPremium.snp.makeConstraints { make in
      make.centerY.equalTo(titleVC.snp.centerY)
      make.right.equalToSuperview().inset(20)
      make.height.width.equalTo(40)
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
    
    mainScrollView.snp.makeConstraints { make in
      make.top.equalTo(calenderView.snp.bottom).inset(-16)
      make.left.right.equalToSuperview().inset(20)
      make.bottom.equalToSuperview().inset(110)
    }
    
    contentView.snp.makeConstraints { make in
      make.edges.equalTo(mainScrollView.contentLayoutGuide)
      make.height.equalTo(mainScrollView.frameLayoutGuide)
      make.width.equalTo(mainScrollView.frameLayoutGuide).multipliedBy(2)
    }
    
    saveView.snp.makeConstraints { make in
      make.top.bottom.left.equalToSuperview()
      make.width.equalTo(mainScrollView.snp.width)
    }
    
    historyView.snp.makeConstraints { make in
      make.top.bottom.right.equalToSuperview()
      make.left.equalTo(saveView.snp.right)
      make.width.equalTo(mainScrollView.snp.width)
    }
  }
  
  override func setColor() {
    self.view.backgroundColor = UIColor(rgb: 0xFCFCFC)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {[weak self] in
      guard let self else {
        return
      }
      let colors = [UIColor(rgb: 0xF28E01), UIColor(rgb: 0xF26101)]
      saveRouteView.addArrayColorGradient(arrayColor: colors, startPoint: CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5))
    }
    
    calenderView.addShadow()
    tabView.addShadow()
    stackSaveNativeView.addShadow()
    historyStackNativeView.addShadow()
  }
  
  override func setProperties() {
    saveRouteView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapSaveRouteView)))
    historyTabView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapHistory)))
    
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.register(cell: ItemFleetCell.self)
    collectionView.backgroundColor = .clear
    
    historyCollectionView.delegate = self
    historyCollectionView.dataSource = self
    historyCollectionView.register(cell: HistoryCell.self)
    historyCollectionView.backgroundColor = .clear
  }
  
  override func binding() {
    AppManager.shared.$hasSub
      .receive(on: DispatchQueue.main)
      .sink { [weak self] hasSub in
        guard let self else {
          return
        }
        icPremium.isHidden = hasSub
      }.store(in: &subscriptions)
    
    viewModel.saveRouteItems
      .receive(on: DispatchQueue.main)
      .sink { [weak self] places in
        guard let self else {
          return
        }
        
        if places?.isEmpty ?? true {
          saveEmptyView.isHidden = false
        } else {
          saveEmptyView.isHidden = true
        }
        collectionView.reloadData()
      }.store(in: &subscriptions)
    
    viewModel.itemHistory
      .receive(on: DispatchQueue.main)
      .sink { [weak self] itemHistory in
        guard let self else {
          return
        }
        
        if itemHistory?.count == 0 {
          historyEmptyView.isHidden = false
        } else {
          historyEmptyView.isHidden = true
        }
        
        historyCollectionView.reloadData()
      }.store(in: &subscriptions)
  }
  
  // Action
  @objc private func onTapSaveRouteView() {
    setSelectedTab(0)
    scrollToPage(index: 0)
  }
  
  @objc private func onTapHistory() {
    setSelectedTab(1)
    scrollToPage(index: 1)
  }
  
  @objc private func onTapCalendar() {
    viewModel.action.send(.calendar)
  }
  
  @objc private func onTapPremium() {
    viewModel.action.send(.iap)
  }
}

extension FleetManagementVC {
  private func setSelectedTab(_ index: Int) {
    removeGradient(from: saveRouteView)
    removeGradient(from: historyTabView)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
      guard let self else {
        return
      }
      setTab(view: saveRouteView, labelFont: AppFont.font(.regularText, size: 14), textColor: UIColor(rgb: 0x727272))
      setTab(view: historyTabView, labelFont: AppFont.font(.regularText, size: 14), textColor: UIColor(rgb: 0x727272))
      
      let colors = [UIColor(rgb: 0xF28E01), UIColor(rgb: 0xF26101)]
      
      if index == 0 {
        saveRouteView.addArrayColorGradient(arrayColor: colors, startPoint: CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5))
        setTab(view: saveRouteView, labelFont: AppFont.font(.boldText, size: 15), textColor: .white)
      } else {
        historyTabView.addArrayColorGradient(arrayColor: colors, startPoint: CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5))
        setTab(view: historyTabView, labelFont: AppFont.font(.boldText, size: 15), textColor: .white)
        setupHistoryNativeView()
      }
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
    if collectionView === self.collectionView {
      return viewModel.saveRouteItems.value?.count ?? 0
    } else {
      return viewModel.itemHistory.value?.count ?? 0
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if collectionView === self.collectionView {
      let cell = collectionView.dequeueReusableCell(ItemFleetCell.self, for: indexPath)
      if let item = viewModel.saveRouteItems.value?[indexPath.row] {
        cell.configData(with: item)
        
        cell.onDeleteTapped = { [weak self]  in
          guard let self else {
            return
          }
          viewModel.action.send(.removeItemHistory(item: item))
          handlerActionDeleted?()
        }
        cell.onDeleteModeChanged = { [weak self] isDeleteMode in
          guard let self else { return }
          if isDeleteMode {
            self.hideDeleteModeForOtherSaveCells(except: indexPath)
          }
        }
        
        cell.onChooseItemPlace = {[weak self] item in
          guard let self else {
            return
          }
          viewModel.action.send(.getSaveRouteItem(index: indexPath.row))
        }
      }
      return cell
    } else {
      let item = viewModel.itemHistory.value?[indexPath.row]
      let cell = collectionView.dequeueReusableCell(HistoryCell.self, for: indexPath)
      cell.configData(item: item)
      cell.onDeleteTapped = { [weak self]  in
        guard let self else {
          return
        }
        viewModel.action.send(.removeItemHistory(item: item))
        handlerActionDeleted?()
      }
      
      cell.onDeleteModeChanged = { [weak self] isDeleteMode in
        guard let self else { return }
        if isDeleteMode {
          self.hideDeleteModeForOtherHistoryCells(except: indexPath)
        }
      }
      
      cell.onChooseItemPlace = {[weak self] item in
        guard let self else {
          return
        }
        viewModel.action.send(.getHistoryItem(index: indexPath.row))
      }
      return cell
    }
  }
  
  private func hideDeleteModeForOtherHistoryCells(except currentIndexPath: IndexPath) {
    for indexPath in historyCollectionView.indexPathsForVisibleItems {
      if indexPath != currentIndexPath {
        if let cell = historyCollectionView.cellForItem(at: indexPath) as? HistoryCell {
          cell.hideDeleteModeCell()
        }
      }
    }
  }
  
  private func hideDeleteModeForOtherSaveCells(except currentIndexPath: IndexPath) {
    for indexPath in collectionView.indexPathsForVisibleItems {
      if indexPath != currentIndexPath {
        if let cell = collectionView.cellForItem(at: indexPath) as? ItemFleetCell {
          cell.hideDeleteModeCell()
        }
      }
    }
  }
}

extension FleetManagementVC: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if collectionView === self.collectionView {
      return CGSize(width: self.collectionView.frame.width, height: 196.0)
    } else {
      return CGSize(width: self.historyCollectionView.frame.width, height: 110.0)
    }
  }
}

extension FleetManagementVC {
  func reloadDataHistoryTab() {
    viewModel.fetchData()
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {[weak self] in
      guard let self else {
        return
      }
      setSelectedTab(1)
      scrollToPage(index: 1)
    }
  }
  
  func reloadDataForSavedTab() {
    viewModel.fetchData()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {[weak self] in
      guard let self else {
        return
      }
      setSelectedTab(0)
      scrollToPage(index: 0)
    }
  }
}

extension FleetManagementVC {
  func scrollToPage(index: Int, animated: Bool = true) {
    mainScrollView.isScrollEnabled = true
    let pageWidth = mainScrollView.frame.size.width
    let targetOffset = CGPoint(x: CGFloat(index) * pageWidth, y: 0)
    mainScrollView.setContentOffset(targetOffset, animated: animated)
    mainScrollView.isScrollEnabled = false
  }
}

extension FleetManagementVC {
  func setupSaveNativeView() {
    guard let topVC = UIApplication.topViewController() else {
      return
    }
    
    AdMobManager.shared.addAdNative(
      unitId: AdUnitID(rawValue: SampleAdUnitID.adFormatNativeAdvanced1),
      rootVC: topVC,
      views: [saveNativeView],
      type: .custom,
      ratio: .portrait
    )
  }
  
  func setupHistoryNativeView() {
    guard let topVC = UIApplication.topViewController() else {
      return
    }
    
    AdMobManager.shared.addAdNative(
      unitId: AdUnitID(rawValue: SampleAdUnitID.adFormatNativeAdvanced2),
      rootVC: topVC,
      views: [historyNativeView],
      type: .custom,
      ratio: .portrait
    )
  }
}
