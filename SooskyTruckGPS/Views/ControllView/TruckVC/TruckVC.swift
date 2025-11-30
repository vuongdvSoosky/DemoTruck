//
//  TruckVC.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 3/11/25.
//

import UIKit
import SnapKit
import MapKit
import Toast
import CoreLocation

class TruckVC: BaseViewController {
  // MARK: - UIView
  private lazy var mapView: MKMapView = {
    let view = MKMapView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  private lazy var tutorialView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor(rgb: 0x000000, alpha: 0.7)
    view.isHidden = true
    return view
  }()
  private lazy var fullScreenOverlayView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor(rgb: 0x000000, alpha: 1.0)
    view.isHidden = true
    return view
  }()
  private lazy var searchView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor(rgb: 0xFFFFFF)
    view.cornerRadius = 12
    view.layer.masksToBounds = true
    
    let iconSearch = UIImageView()
    iconSearch.contentMode = .scaleAspectFit
    iconSearch.image = .icSearch
    
    [iconSearch, searchTextField, iconRemoveText].forEach({view.addSubview($0)})
    
    iconSearch.snp.makeConstraints { make in
      make.width.height.equalTo(24)
      make.centerY.equalToSuperview()
      make.left.equalToSuperview().offset(12)
    }
    
    searchTextField.snp.makeConstraints { make in
      make.left.equalTo(iconSearch.snp.right).offset(8)
      make.centerY.equalToSuperview()
    }
    
    iconRemoveText.snp.makeConstraints { make in
      make.width.height.equalTo(22)
      make.centerY.equalTo(searchTextField.snp.centerY)
      make.left.equalTo(searchTextField.snp.right).offset(12)
      make.right.equalToSuperview().inset(18)
    }
    
    return view
  }()
  private lazy var caculatorRouteView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.isHidden = false
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapCaculatorRoute)))
    
    let icon = UIImageView()
    icon.contentMode = .scaleAspectFit
    icon.image = .icCaculatoRoute
    
    let label = UILabel()
    label.text = "Calculate Best Route"
    label.textColor = UIColor(rgb: 0xFFFFFF)
    label.font = AppFont.font(.boldText, size: 20)
    
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 4
    
    [icon, label].forEach({stackView.addArrangedSubview($0)})
    
    view.addSubviews(stackView)
    
    stackView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    
    return view
  }()
  private lazy var currentCalloutView: CustomAnnotationCalloutView = {
    let view = CustomAnnotationCalloutView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.isHidden = true
    view.onButtonTapped = { [weak self] in
      guard let self, let Place = self.currentPlace else { return }
      
      PlaceManager.shared.addLocation(Place)
      
      if PlaceManager.shared.placeGroup.places.count == 1 {
        self.view.insertSubview(searchView, aboveSubview: tutorialView)
        self.view.insertSubview(tableView, aboveSubview: tutorialView)
        self.iconTutorialSearch.image = .icSearchTutorial2
        self.iconTutorialSearch.isHidden = false
        self.hideCalloutAnimated()
        searchTextField.text = ""
      } else {
        self.view.bringSubviewToFront(tutorialView)
        self.view.insertSubview(viewList, aboveSubview: tutorialView)
        self.view.insertSubview(iconTutorialList, aboveSubview: tutorialView)
        self.iconTutorialSearch.isHidden = true
        self.iconTutorialList.isHidden = false
        self.hideCalloutAnimated()
        searchTextField.text = ""
        viewList.isHidden = false
        self.iconTutorialAddStop.isHidden = true
      }
      
      if PlaceManager.shared.exists(Place) {
        view.configureButton(title: "Remove Stop", icon: .icTrash)
      } else {
        view.configureButton(title: "Add Stop", icon: .icPlus)
        hideCalloutAnimated()
      }
    }
    return view
  }()
  private lazy var viewList: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.cornerRadius = 24
    view.backgroundColor = UIColor(rgb: 0xFFFFFF)
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapViewlist)))
    view.isHidden = true
    
    let label = UILabel()
    label.text = "View List"
    label.textAlignment = .center
    label.textColor = UIColor(rgb: 0xF26101)
    label.font = AppFont.font(.boldText, size: 19)
    
    view.addSubviews(label)
    
    label.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    return view
  }()
  
  private let tableContainer: UIView = {
    let view = UIView()
    view.backgroundColor = .clear
    view.layer.shadowColor = UIColor(rgb: 0x000000).cgColor
    view.layer.shadowOpacity = 0.4
    view.layer.shadowRadius = 8
    view.layer.shadowOffset = CGSize(width: 0, height: 4)
    return view
  }()
  
  // MARK: UIImageView
  private lazy var iconTruck: UIImageView = {
    let icon = UIImageView()
    icon.image = .icProfileTruck
    icon.contentMode = .scaleAspectFit
    icon.isUserInteractionEnabled = true
    icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapIconTruckProfile)))
    return icon
  }()
  private lazy var iconTutorialTruck: UIImageView = {
    let icon = UIImageView()
    icon.image = .icTutoriaTruckProfile
    icon.contentMode = .scaleAspectFit
    icon.isUserInteractionEnabled = true
    icon.isHidden = true
    return icon
  }()
  private lazy var iconTutorialSearch: UIImageView = {
    let icon = UIImageView()
    icon.image = .icSearchTutorial
    icon.contentMode = .scaleAspectFit
    icon.isUserInteractionEnabled = true
    icon.isHidden = true
    return icon
  }()
  private lazy var iconTutorialList: UIImageView = {
    let icon = UIImageView()
    icon.image = .icListTutorial
    icon.contentMode = .scaleAspectFit
    icon.isUserInteractionEnabled = true
    icon.isHidden = true
    return icon
  }()
  private lazy var iconTutorialAddStop: UIImageView = {
    let icon = UIImageView()
    icon.image = .icTutorialAddStop
    icon.contentMode = .scaleAspectFit
    icon.isUserInteractionEnabled = true
    icon.isHidden = true
    return icon
  }()
  private lazy var iconTutorialCaculate: UIImageView = {
    let icon = UIImageView()
    icon.image = .icTutorialCaculate
    icon.contentMode = .scaleAspectFit
    icon.isUserInteractionEnabled = true
    icon.isHidden = true
    return icon
  }()
  private lazy var iconRemoveText: UIImageView = {
    let icon = UIImageView()
    icon.contentMode = .scaleAspectFit
    icon.image = .icClearText
    icon.isUserInteractionEnabled = true
    icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapRemoveText)))
    icon.isHidden = true
    return icon
  }()
  private lazy var icDirection: UIImageView = {
    let image = UIImageView()
    image.translatesAutoresizingMaskIntoConstraints = false
    image.image = .icDirection
    image.isUserInteractionEnabled = true
    image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapDirection)))
    return image
  }()
  
  // MARK: - UIStackView
  private lazy var caculatorRouteStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.addArrangedSubview(caculatorRouteView)
    stackView.cornerRadius = 20
    stackView.layer.masksToBounds = true
    return stackView
  }()
  
  // MARK: - UITableView
  private lazy var tableView: UITableView = {
    let tableView = UITableView()
    
    return tableView
  }()
  
  // MARK: UICollectionView
  private lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.minimumInteritemSpacing = 1
    layout.minimumLineSpacing = 1
    layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.backgroundColor = .clear
    return collectionView
  }()
  
  // MARK: - UITextField
  private lazy var searchTextField: UITextField = {
    let textField = UITextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    return textField
  }()
  
  // MARK: Properties
  private lazy var arrayPlaces: [Place] = []
  private var currentPlace: Place?
  private var address: String = ""
  private var desAdress: String = ""
  private var currentQuery = ""
  private var currentType = ""
  private var searchDelayTimer: Timer?
  private var pendingAnnotation: MKAnnotation?
  private var isProgrammaticRegionChange = false
  private var currentTooltipView: CustomAnnotationView?
  private var currentAnnotation: CustomAnnotation?
  private var searchManager: LocationSearchManager!
  private var currentTooltipID: String?
  private var searchResults: [SearchItem] = []
  private var userMarker: DraggableAnnotation?
  private var trackingUser = false
  var userAnnotation: MKPointAnnotation?
  private var userLocationAnnotation: CustomAnnotation?
  private var isInitialLocationSet = false
  private var lastUpdateLocation: CLLocation?
  private var locationUpdateTimer: Timer?
  private lazy var locationManager: CLLocationManager = {
    let manager = CLLocationManager()
    manager.delegate = self
    manager.desiredAccuracy = kCLLocationAccuracyBest
    return manager
  }()
  
  var currentUserCoordinate: CLLocationCoordinate2D?
  
  private let viewModel = TruckViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupMap()
    setupTableView()
    showTutorial()
    
    UserDefaultsManager.shared.set(true, key: .tutorial)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    // Resume tracking nếu đã có location ban đầu
    if isInitialLocationSet {
      startTrackingUserLocation()
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    // Dừng tracking để tiết kiệm pin
    stopTrackingUserLocation()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    stopTrackingUserLocation()
  }
  
  private func showTutorial() {
    if UserDefaultsManager.shared.get(of: Bool.self, key: .tutorial) == false {
      showOverlay()
      iconTutorialTruck.isHidden = false
      tutorialView.isHidden = false
    }
  }
  
  func showOverlay() {
    (self.tabBarController as? TabbarVC)?.showTabbarOverlay()
  }
  
  func hideOverlay() {
    (self.tabBarController as? TabbarVC)?.hideOverlay()
  }
  
  func showFullScreenOverlay() {
    guard let window = view.window ?? UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
      // Nếu chưa có window, thêm vào tabBarController.view
      if let tabBarController = tabBarController {
        fullScreenOverlayView.removeFromSuperview()
        tabBarController.view.addSubview(fullScreenOverlayView)
        fullScreenOverlayView.snp.makeConstraints { make in
          make.edges.equalToSuperview()
        }
        fullScreenOverlayView.isHidden = false
      }
      return
    }
    
    // Thêm vào window để che toàn bộ màn hình
    fullScreenOverlayView.removeFromSuperview()
    window.addSubview(fullScreenOverlayView)
    fullScreenOverlayView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    fullScreenOverlayView.isHidden = false
  }
  
  func hideFullScreenOverlay() {
    fullScreenOverlayView.isHidden = true
    fullScreenOverlayView.removeFromSuperview()
  }
  
  override func addComponents() {
    self.view.addSubviews(mapView, searchView, viewList, collectionView, icDirection,
                          tutorialView, iconTruck, iconTutorialTruck, iconTutorialSearch, currentCalloutView, iconTutorialList, caculatorRouteStackView, iconTutorialAddStop, iconTutorialCaculate, tableContainer)
  }
  
  override func setConstraints() {
    mapView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    tutorialView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    searchView.snp.makeConstraints { make in
      make.top.equalTo(self.view.snp.topMargin).inset(15)
      make.height.equalTo(48)
      make.left.right.equalToSuperview().inset(20)
    }
    
    currentCalloutView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview().offset(-110)
    }
    
    iconTutorialAddStop.snp.makeConstraints { make in
      make.top.equalTo(currentCalloutView.snp.bottom).inset(-20)
      make.centerX.equalTo(currentCalloutView.snp.centerX)
    }
    
    iconTutorialSearch.snp.makeConstraints { make in
      make.top.equalTo(searchView.snp.bottom).inset(-20)
      make.centerX.equalTo(searchView.snp.centerX)
    }
    
    collectionView.snp.makeConstraints { make in
      make.top.equalTo(searchView.snp.bottom).offset(12)
      make.left.equalToSuperview().inset(16)
      make.right.equalToSuperview()
      make.height.equalTo(56)
    }
    
    iconTruck.snp.makeConstraints { make in
      make.top.equalTo(collectionView.snp.bottom).inset(-18)
      make.left.equalToSuperview().inset(20)
      make.width.height.equalTo(48)
    }
    
    iconTutorialTruck.snp.makeConstraints { make in
      make.centerY.equalTo(iconTruck.snp.centerY)
      make.left.equalTo(iconTruck.snp.right).inset(-10)
    }
    
    viewList.snp.makeConstraints { make in
      make.bottom.equalTo(caculatorRouteStackView.snp.top).inset(-12)
      make.centerX.equalToSuperview()
      make.width.equalTo(111)
      make.height.equalTo(47)
    }
    
    iconTutorialList.snp.makeConstraints { make in
      make.bottom.equalTo(viewList.snp.top).inset(-20)
      make.centerX.equalTo(viewList.snp.centerX)
    }
    
    caculatorRouteStackView.snp.makeConstraints { make in
      make.bottom.equalToSuperview().inset(110)
      make.left.right.equalToSuperview().inset(20)
    }
    
    iconTutorialCaculate.snp.makeConstraints { make in
      make.bottom.equalTo(caculatorRouteStackView.snp.top).inset(-20)
      make.centerX.equalTo(caculatorRouteStackView.snp.centerX)
    }
    
    caculatorRouteView.snp.makeConstraints { make in
      make.height.equalTo(60)
    }
    
    tableContainer.snp.makeConstraints { make in
      make.top.equalTo(searchView.snp.bottom).offset(8)
      make.left.right.equalToSuperview().inset(20)
      make.height.equalTo(288)
    }
    tableContainer.addSubview(tableView)
    
    tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(2)
    }
    
    icDirection.snp.makeConstraints { make in
      make.bottom.equalTo(caculatorRouteStackView.snp.top).inset(-12)
      make.width.height.equalTo(48)
      make.right.equalToSuperview().inset(20)
    }
    
    let compassButton = MKCompassButton(mapView: mapView)
    compassButton.compassVisibility = .visible
    
    mapView.addSubview(compassButton)
    
    compassButton.snp.makeConstraints { make in
      make.bottom.equalTo(icDirection.snp.top).inset(-30)
      make.right.equalToSuperview().inset(20)
      make.width.height.equalTo(44)
    }
  }
  
  override func setProperties() {
    searchManager = LocationSearchManager()
    
    searchTextField.delegate = self
    searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapCloseCalloutView(_:)))
    tapGesture.cancelsTouchesInView = false
    view.addGestureRecognizer(tapGesture)
    
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.register(cell: ItemServiceCell.self)
    
    searchTextField.setPlaceholder("Search location to add stop")
  }
  
  private func setupMap() {
    MapManager.shared.attachMap(to: mapView)
    mapView.delegate = self
    mapView.showsUserLocation = false
    //    MapManager.shared.startTrackingUser()
    //    // Lấy vị trí hiện tại và hiển thị dịch vụ xung quanh
    //    MapManager.shared.requestUserLocation { [weak self] location in
    //      self?.searchNearby()
    //    }
  }
  
  override func binding() {
    PlaceManager.shared.$placeGroup
      .receive(on: DispatchQueue.main)
      .sink { [weak self] places in
        guard let self else {
          return
        }
        self.arrayPlaces = places.places
        if self.arrayPlaces.count < 2 {
          caculatorRouteView.isHidden = true
        } else {
          caculatorRouteView.isHidden = false
          
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {[weak self] in
            guard let self else {
              return
            }
            caculatorRouteStackView.layoutIfNeeded()
            let colors = [UIColor(rgb: 0xF28E01), UIColor(rgb: 0xF26101)]
            caculatorRouteStackView.addArrayColorGradient(arrayColor: colors, startPoint: CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5))
          }
        }
        
        if self.arrayPlaces.isEmpty {
          viewList.isHidden = true
        } else {
          viewList.isHidden = false
        }
        
        self.updateAnnotations(for: places.places)
      }.store(in: &subscriptions)
    
    viewModel.index
      .receive(on: DispatchQueue.main)
      .sink { [weak self] index in
        guard let self else {
          return
        }
        collectionView.reloadData()
      }.store(in: &subscriptions)
    
    viewModel.actionTutorialTruckProFile
      .receive(on: DispatchQueue.main)
      .sink { [weak self] in
        guard let self else {
          return
        }
        tutorialView.isHidden = false
        self.view.insertSubview(searchView, aboveSubview: tutorialView)
        self.view.insertSubview(tableContainer, aboveSubview: tutorialView)
        iconTutorialSearch.isHidden = false
        showOverlay()
      }.store(in: &subscriptions)
    
    viewModel.showTutorialCaculate
      .receive(on: DispatchQueue.main)
      .sink { [weak self] in
        guard let self else {
          return
        }
        
        if UserDefaultsManager.shared.get(of: Bool.self, key: .tutorial) == false {
          self.iconTutorialCaculate.isHidden = false
          tutorialView.isHidden = false
          showOverlay()
          self.view.bringSubviewToFront(tutorialView)
          self.view.insertSubview(caculatorRouteStackView, aboveSubview: tutorialView)
          self.view.insertSubview(iconTutorialCaculate, aboveSubview: tutorialView)
        }
      }.store(in: &subscriptions)
    
    
    searchManager.$results
      .receive(on: DispatchQueue.main)
      .sink { [weak self] results in
        guard let self else {
          return
        }
        searchResults = results
        LogManager.show(results.count)
        updateTableHeight()
        tableView.reloadData()
        tableView.isHidden = results.isEmpty
      }
      .store(in: &subscriptions)
    
    // Lấy location lần đầu và zoom map
    LocationService.shared.requestCurrentLocation { [weak self] location in
      guard let self = self else { return }
      
      DispatchQueue.main.async {
        // Xóa annotation cũ nếu có
        self.removeUserLocationAnnotation()
        
        // Tạo CustomAnnotation cho user location
        let userAnnotation = CustomAnnotation(
          coordinate: location.coordinate,
          title: "My Location",
          subtitle: nil,
          type: "UserLocation",
          id: "user_location"
        )
        self.userLocationAnnotation = userAnnotation
        self.mapView.addAnnotation(userAnnotation)
        
        // Chỉ zoom map lần đầu tiên
        if !self.isInitialLocationSet {
          let region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 500,
            longitudinalMeters: 500
          )
          self.mapView.setRegion(region, animated: true)
          self.isInitialLocationSet = true
        }
        
        // Bắt đầu theo dõi location updates liên tục
        self.startTrackingUserLocation()
      }
    }
  }
  
  func updateTableHeight() {
    let count = searchResults.count
    let height: CGFloat
    
    if count >= 4 {
      height = 288
    } else {
      height = CGFloat(66 * count)
    }
    
    tableContainer.snp.updateConstraints { make in
      make.height.equalTo(height)
    }
    
    UIView.animate(withDuration: 0.1) {
      self.view.layoutIfNeeded()
    }
  }
  
  // MARK: - Helper: Cập nhật icon của service annotations dựa trên placeGroup
  private func updateServiceAnnotationsIcons() {
    for annotation in mapView.annotations {
      guard let serviceAnnotation = annotation as? CustomServiceAnimation,
            let annotationView = mapView.view(for: serviceAnnotation) as? CustomAnnotationView else {
        continue
      }
      
      // Kiểm tra xem service đã có trong placeGroup chưa (so sánh bằng coordinate và type)
      let place = Place(id: serviceAnnotation.id, address: serviceAnnotation.title ?? "", fullAddres: serviceAnnotation.subtitle ?? "", coordinate: serviceAnnotation.coordinate, state: nil, type: serviceAnnotation.type)
      let isInPlaceGroup = PlaceManager.shared.exists(place)
      
      // Cập nhật icon
      if isInPlaceGroup {
        // Đã thêm vào placeGroup → hiển thị icon theo type
        switch serviceAnnotation.type {
        case "Gas Station":
          annotationView.image = .icPinGas
        case "Bank":
          annotationView.image = .icPinBank
        case "Car Wash":
          annotationView.image = .icPinCarWash
        case "Pharmacy":
          annotationView.image = .icPinPharmacy
        case "Fast Food":
          annotationView.image = .icPinFastFood
        default:
          annotationView.image = .icPinBlank
        }
      } else {
        // Chưa thêm vào placeGroup → hiển thị icLocationEmpty
        annotationView.image = .icLocationEmpty
      }
    }
  }
  private func updateAnnotations(for places: [Place]) {
    let placeIds = Set(places.map { $0.id })
    
    // Lọc các annotation hiện tại
    let annotationsToRemove = mapView.annotations.compactMap { ann -> MKAnnotation? in
      guard let customAnn = ann as? CustomAnnotation else { return nil }
      // Nếu annotation không nằm trong placeIds → remove
      return placeIds.contains(customAnn.id) ? nil : customAnn
    }
    mapView.removeAnnotations(annotationsToRemove)
    for place in places {
      if let existingAnnotation = mapView.annotations.first(where: {
        guard let ann = $0 as? CustomAnnotation else { return false }
        return ann.id == place.id
      }) as? CustomAnnotation {
        // Update dữ liệu annotation
        existingAnnotation.coordinate = place.coordinate
        existingAnnotation.title = place.address
        existingAnnotation.subtitle = place.fullAddres
        // Giữ type từ place nếu có, nếu không thì set "Location"
        existingAnnotation.type = place.type ?? "Location"
        
        // Force update view để đảm bảo icon được cập nhật
        if let annotationView = mapView.view(for: existingAnnotation) as? CustomAnnotationView {
          // Chọn icon dựa vào type (có thể là Location hoặc Service type)
          switch existingAnnotation.type {
          case "Location":
            annotationView.image = .icLocationStop
          case "Gas Station":
            annotationView.image = .icPinGas
          case "Bank":
            annotationView.image = .icPinBank
          case "Car Wash":
            annotationView.image = .icPinCarWash
          case "Pharmacy":
            annotationView.image = .icPinPharmacy
          case "Fast Food":
            annotationView.image = .icPinFastFood
          default:
            // Nếu type không hợp lệ, kiểm tra lại từ place
            if place.type == "Location" {
              annotationView.image = .icLocationStop
            } else {
              annotationView.image = .icLocationEmpty
            }
          }
          
          if currentTooltipView?.annotationID == existingAnnotation.id {
            annotationView.configure(title: existingAnnotation.title ?? "", des: existingAnnotation.subtitle ?? "")
          }
        } else {
          // Nếu view chưa tồn tại, remove và add lại annotation để force tạo view mới
          mapView.removeAnnotation(existingAnnotation)
          mapView.addAnnotation(existingAnnotation)
        }
      } else {
        // Thêm mới annotation - giữ type từ place nếu có
        let newAnnotation = CustomAnnotation(
          coordinate: place.coordinate,
          title: place.address,
          subtitle: place.fullAddres,
          type: place.type ?? "Location",
          id: place.id
        )
        mapView.addAnnotation(newAnnotation)
      }
    }
  }
  
  func updateAnnotationPlace(for place: Place) {
    // Tìm annotation có id tương ứng
    if let existingAnnotation = mapView.annotations.first(where: {
      guard let ann = $0 as? CustomAnnotation else { return false }
      return ann.id == place.id
    }) as? CustomAnnotation {
      
      // Update thông tin annotation
      existingAnnotation.coordinate = place.coordinate
      existingAnnotation.title = place.address
      existingAnnotation.subtitle = place.fullAddres
      existingAnnotation.type = place.type ?? "Location"
      
      // Update giao diện
      if let annotationView = mapView.view(for: existingAnnotation) as? CustomAnnotationView {
        // update icon
        annotationView.image = icon(for: "Location")
        
        if currentTooltipView?.annotationID == existingAnnotation.id {
          annotationView.configure(title: existingAnnotation.title ?? "",
                                   des: existingAnnotation.subtitle ?? "")
        }
      } else {
        // Force reload view
        mapView.removeAnnotation(existingAnnotation)
        mapView.addAnnotation(existingAnnotation)
      }
      
    } else {
      // Nếu chưa có, thì thêm mới
      let newAnnotation = CustomAnnotation(coordinate: place.coordinate,
                                           title: place.address,
                                           subtitle: place.fullAddres,
                                           type: place.type ?? "Location",
                                           id: place.id)
      mapView.addAnnotation(newAnnotation)
    }
  }
  
  private func icon(for type: String?) -> UIImage? {
    switch type {
    case "Location": return .icLocationStop
    default: return .icLocationEmpty
    }
  }
  
  private func searchNearby(with nameService: String = "", type: String = "") {
    MapManager.shared.searchServiceAroundVisibleRegion(nameService, type: type)
  }
  
  private func setupTableView() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.registerCell(HomeSearchCell.self)
    tableView.registerCell(CurrentLocationCell.self)
    tableView.backgroundColor = .clear
    tableView.showsVerticalScrollIndicator = false
    tableView.showsHorizontalScrollIndicator = false
    tableView.separatorInset = UIEdgeInsets(top: 0, left: 21, bottom: 0, right: 21)
    tableView.clipsToBounds = true
    tableView.layer.cornerRadius = 12
    tableView.layer.masksToBounds = true
    
  }
  
  override func setColor() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      self.searchView.addShadow()
    }
  }
  
  @objc private func annotationTapped(_ sender: UITapGestureRecognizer) {
    guard let customView = sender.view as? CustomAnnotationView else { return }
    
    // Xử lý cả CustomAnnotation và CustomServiceAnimation
    if let anno = customView.annotation as? CustomAnnotation {
      showTooltipForAnnotation(anno)
    } else if let serviceAnno = customView.annotation as? CustomServiceAnimation {
      showTooltipForServiceAnnotation(serviceAnno)
    }
  }
  
  // MARK: - Helper: Hiển thị tooltip cho annotation
  private func showTooltipForAnnotation(_ annotation: CustomAnnotation) {
    guard let annotationView = mapView.view(for: annotation) as? CustomAnnotationView else {
      return
    }
    
    // Ẩn tooltip hiện tại nếu có
    if let current = currentTooltipView, current.annotationID != annotationView.annotationID {
      current.hideTooltip()
    }
    
    // Hiển thị tooltip cho annotation được chọn
    currentTooltipView = annotationView
    currentTooltipID = annotation.id
    annotationView.showTooltip()
    annotationView.configure(title: annotation.title ?? "", des: annotation.subtitle ?? "")
    
    // Kiểm tra xem đã có trong placeGroup chưa
    let place = Place(id: annotation.id, address: annotation.title ?? "", fullAddres: annotation.subtitle ?? "", coordinate: annotation.coordinate, state: nil, type: annotation.type)
    
    if PlaceManager.shared.exists(place) {
      annotation.type = "Location"
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        self.updateAnnotationPlace(for: place)
      }
      annotationView.configureButton(title: "Remove Stop", icon: .icTrash)
    } else {
      annotationView.configureButton(title: "Add Stop", icon: .icPlus)
    }
  }
  
  // MARK: - Helper: Hiển thị tooltip cho service annotation
  private func showTooltipForServiceAnnotation(_ annotation: CustomServiceAnimation) {
    guard let annotationView = mapView.view(for: annotation) as? CustomAnnotationView else {
      return
    }
    
    // Ẩn tooltip hiện tại nếu có
    if let current = currentTooltipView, current.annotationID != annotationView.annotationID {
      current.hideTooltip()
    }
    
    // Hiển thị tooltip cho service annotation được chọn
    currentTooltipView = annotationView
    currentTooltipID = annotation.id
    annotationView.showTooltip()
    annotationView.configure(title: annotation.title ?? "", des: annotation.subtitle ?? "")
    
    // Kiểm tra xem đã có trong placeGroup chưa
    let place = Place(id: annotation.id, address: annotation.title ?? "", fullAddres: annotation.subtitle ?? "", coordinate: annotation.coordinate, state: nil, type: annotation.type)
    if PlaceManager.shared.exists(place) {
      annotationView.configureButton(title: "Remove Stop", icon: .icTrash)
    } else {
      annotationView.configureButton(title: "Add Stop", icon: .icPlus)
    }
  }
}

// MARK: - MapView Delegate
extension TruckVC: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    searchDelayTimer?.invalidate()
    searchDelayTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
      self?.searchNearby(with: self?.currentQuery ?? "", type: self?.currentType ?? "")
    }
  }
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if annotation is MKUserLocation { return nil }
    if UserDefaultsManager.shared.get(of: Bool.self, key: .tutorial) == false {
      let identifier = "customPinView"
      var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
      
      if view == nil {
        view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        view?.canShowCallout = false
      } else {
        view?.annotation = annotation
      }
      
      if let custom = annotation as? CustomAnnotation {
        switch custom.type {
        case "Location":
          view?.image = .icLocationStop
          view?.centerOffset = CGPoint(x: 0, y: -5)
        case "UserLocation":
          // Custom image cho current location
          view?.image = .icCurrentLocation
          view?.centerOffset = CGPoint(x: 0, y: 0)
        default:
          view?.image = .icLocationEmpty
          view?.centerOffset = CGPoint(x: 0, y: -5)
        }
        return view
      }
    } else {
    // MARK: - CustomAnnotation
    if let customAnno = annotation as? CustomAnnotation {
      // Xử lý riêng cho UserLocation với MKAnnotationView đơn giản
      if customAnno.type == "UserLocation" {
        let identifier = "UserLocationMarker"
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if view == nil {
          view = MKAnnotationView(annotation: customAnno, reuseIdentifier: identifier)
          view?.canShowCallout = false
        } else {
          view?.annotation = customAnno
        }
        
        view?.image = .icCurrentLocation
        view?.centerOffset = CGPoint(x: 0, y: 0)
        return view
      }
      
      // Xử lý các CustomAnnotation khác
      self.currentAnnotation = customAnno
      let identifier = customAnno.identifier
      var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? CustomAnnotationView
      
      if view == nil {
        view = CustomAnnotationView(annotation: customAnno, reuseIdentifier: identifier)
        view?.delegate = self
      } else {
        view?.annotation = customAnno
      }
      
      // Gán ID annotation
      view?.annotationID = customAnno.id
      
      // Configure tooltip đúng dữ liệu của annotation hiện tại
      view?.configure(title: customAnno.title ?? "", des: customAnno.subtitle ?? "")
      
      // Chọn icon dựa vào type
      switch customAnno.type {
      case "Location":
        view?.image = .icLocationStop
      case "Gas Station":
        view?.image = .icPinGas
      case "Bank":
        view?.image = .icPinBank
      case "Car Wash":
        view?.image = .icPinCarWash
      case "Pharmacy":
        view?.image = .icPinPharmacy
      case "Fast Food":
        view?.image = .icPinFastFood
      default:
        view?.image = .icLocationEmpty
      }
      // Ẩn tooltip mặc định (chỉ hiển thị khi tap)
      view?.hideTooltip()
      
      // Tap gesture
      if view?.gestureRecognizers?.isEmpty ?? true {
        let tap = UITapGestureRecognizer(target: self, action: #selector(annotationTapped(_:)))
        view?.addGestureRecognizer(tap)
      }
      
      return view
    }
    
    // MARK: - CustomServiceAnimation
    else if let customService = annotation as? CustomServiceAnimation {
      let identifier = customService.identifier
      var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? CustomAnnotationView
      
      if view == nil {
        view = CustomAnnotationView(annotation: customService, reuseIdentifier: identifier)
        view?.delegate = self
      } else {
        view?.annotation = customService
      }
      
      // Gán ID annotation
      view?.annotationID = customService.id
      
      // Configure tooltip đúng dữ liệu của annotation hiện tại
      view?.configure(title: customService.title ?? "", des: customService.subtitle ?? "")
      
      // Kiểm tra xem service đã được thêm vào placeGroup chưa
      let place = Place(id: customService.id, address: customService.title ?? "", fullAddres: customService.subtitle ?? "", coordinate: customService.coordinate, state: nil, type: customService.type)
        let isInPlaceGroup = PlaceManager.shared.exists(place)
      
      // Chọn icon: nếu chưa thêm vào placeGroup → icLocationEmpty, nếu đã thêm → icon theo type
      if isInPlaceGroup {
        // Đã thêm vào placeGroup → hiển thị icon theo type
        switch customService.type {
        case "Gas Station":
          view?.image = .icPinGas
        case "Bank":
          view?.image = .icPinBank
        case "Car Wash":
          view?.image = .icPinCarWash
        case "Pharmacy":
          view?.image = .icPinPharmacy
        case "Fast Food":
          view?.image = .icPinFastFood
        default:
          view?.image = .icPinBlank
        }
      } else {
        // Chưa thêm vào placeGroup → hiển thị icLocationEmpty
        view?.image = .icLocationEmpty
      }
      
      // Ẩn tooltip mặc định (chỉ hiển thị khi tap)
      view?.hideTooltip()
      
      // Tap gesture để hiển thị tooltip
      if view?.gestureRecognizers?.isEmpty ?? true {
        let tap = UITapGestureRecognizer(target: self, action: #selector(annotationTapped(_:)))
        view?.addGestureRecognizer(tap)
      }
      
      return view
    }
    }
    return nil
  }
}

// MARK: UITextFieldDelegate
extension TruckVC: UITextFieldDelegate {
  @objc private func textFieldDidChange(_ textField: UITextField) {
    guard let text = textField.text, !text.isEmpty else {
      tableContainer.isHidden = true
      if UserDefaultsManager.shared.get(of: Bool.self, key: .tutorial) == false {
        iconTutorialSearch.isHidden = false
      }
      iconRemoveText.isHidden = true
      searchResults.removeAll()
      return
    }
    
    iconRemoveText.isHidden = false
    self.address = text
    tableContainer.isHidden = false
    iconTutorialSearch.isHidden = true
    
    searchManager.query = text
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    guard let keyword = textField.text, !keyword.isEmpty else { return true }
      tableContainer.isHidden = true
    
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = keyword
    let search = MKLocalSearch(request: request)
    request.region = mapView.region
    
    search.start { [weak self] response, error in
      guard let self = self,
            let mapItem = response?.mapItems.first else { return }
      
      let coordinate = mapItem.placemark.coordinate
      DispatchQueue.main.async {
        let region = MKCoordinateRegion(
          center: coordinate,
          latitudinalMeters: 200,
          longitudinalMeters: 200
        )
        self.mapView.setRegion(region, animated: true)
        
        // Lấy thông tin đầy đủ từ mapItem giống như tableView
        let placemark = mapItem.placemark
        let title = mapItem.name ?? keyword
        
        // Format địa chỉ đầy đủ từ placemark
        var addressParts: [String] = []
        
        if let city = placemark.locality {
          addressParts.append(city)
        }
        if let state = placemark.administrativeArea {
          addressParts.append(state)
        }
        
        if let country = placemark.country {
          addressParts.append(country)
        }
        
        let subtitle = addressParts.isEmpty ? (placemark.title ?? "") : addressParts.joined(separator: ", ")
        
          let annotation = CustomAnnotation(coordinate: coordinate, title: title, subtitle: subtitle, type: "Location", id: keyword)
  
          // Xoá annotation cũ nếu tồn tại
          if let existingAnnotation = self.mapView.annotations.first(where: {
            guard let ann = $0 as? CustomAnnotation else { return false }
            return ann.id == keyword
          }) as? CustomAnnotation {
            self.mapView.removeAnnotation(existingAnnotation)
          }
  
          let place = Place(address: title, fullAddres: subtitle , coordinate: coordinate, state: nil)
  
          if PlaceManager.shared.exists(place) {
            annotation.type = "Location"
          } else {
            annotation.type = ""
          }
  
        self.mapView.addAnnotation(annotation)
        
          if !UserDefaultsManager.shared.get(of: Bool.self, key: .tutorial) {
            self.currentPlace = Place(address: title, fullAddres: subtitle , coordinate: coordinate, state: nil)
            self.desAdress = subtitle
            self.address = title
            self.currentCalloutView.configureButton(title: "Add Stop", icon: .icPlus)
            self.showCalloutAnimated()
          } else {
        // Hiển thị tooltip sau khi tìm kiếm
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
          self.showTooltipForAnnotation(annotation)
            }
        }
      }
    }
    return true
  }
}

// MARK: - Action
extension TruckVC {
  @objc private func onTapCloseCalloutView(_ gesture: UITapGestureRecognizer) {
    view.endEditing(true)
    let location = gesture.location(in: mapView)
    
    // Nếu tap nằm trong tooltip => bỏ qua
    if let tooltip = currentTooltipView?.containerView, !tooltip.isHidden,
       tooltip.frame.contains(location) {
      return
    }
    
    // Nếu tap nằm trên pin => bỏ qua
    let tappedAnnotations = mapView.annotations.filter { annotation in
      guard let view = mapView.view(for: annotation) else { return false }
      return view.frame.contains(location)
    }
    if !tappedAnnotations.isEmpty { return }
    
    // Tap ngoài tooltip và pin => ẩn tooltip
    UIView.animate(withDuration: 0.25) {
      self.currentTooltipView?.hideTooltip()
    }
    
    guard let annotation = currentAnnotation else { return }
    
    let place = Place(address: annotation.title ?? "", fullAddres: annotation.subtitle ?? "", coordinate: annotation.coordinate)
    if !PlaceManager.shared.exists(place) {
      if let annotation = currentAnnotation {
        mapView.removeAnnotation(annotation)
        currentAnnotation = nil
      }
    }
  }
  
  @objc private func onTapViewlist() {
    viewModel.action.send(.viewList)
    iconTutorialList.isHidden = true
    tutorialView.isHidden = true
    hideOverlay()
  }
  
  @objc private func onTapCaculatorRoute() {
    viewModel.action.send(.caculatorRoute)
    UserDefaultsManager.shared.set(true, key: .tutorial)
    
    hideOverlay()
    tutorialView.isHidden = true
  }
  
  @objc private func onTapIconTruckProfile() {
    if UserDefaultsManager.shared.get(of: Bool.self, key: .tutorial) == false {
      iconTutorialTruck.isHidden = true
      self.view.insertSubview(tutorialView, aboveSubview: iconTruck)
      tutorialView.isHidden = true
    }
    viewModel.action.send(.truckProfile)
    iconTutorialCaculate.isHidden = true
    hideOverlay()
  }
  
  @objc private func onTapRemoveText() {
    self.searchTextField.text = ""
    self.tableContainer.isHidden = true
    self.address = ""
    self.iconRemoveText.isHidden = true
  }
  
  @objc private func onTapDirection() {
    self.showCurrentLocation(mapView)
  }
}

// MARK: - UITableView
extension TruckVC: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return searchResults.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let item = searchResults[indexPath.row]
    switch item {
    case .suggestion(let data):
    let cell = tableView.dequeueReusableCell(HomeSearchCell.self, for: indexPath)
    cell.backgroundColor = .white
    cell.selectionStyle = .none
    cell.configData(data: data)
      return cell
      
    case .manual(let title):
      let cell = tableView.dequeueReusableCell(HomeSearchCell.self, for: indexPath)
      cell.configDataManual(data: title)
      return cell
    case .userLocation(title: _, subtitle: _, coordinate: _):
      let cell = tableView.dequeueReusableCell(CurrentLocationCell.self, for: indexPath)
    return cell
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard indexPath.row < searchResults.count else { return }
    let item = searchResults[indexPath.row]
    
    tableContainer.isHidden = true
    searchTextField.resignFirstResponder()
    
    switch item {
      // MARK: - APPLE SUGGESTION
    case .suggestion(let dataSuggestion):
      searchTextField.text = dataSuggestion.title
      performSearch(query: dataSuggestion.title, subtitle: dataSuggestion.subtitle)
      
      // MARK: - MANUAL INPUT
    case .manual(let title):
      searchTextField.text = title
      performSearch(query: title, subtitle: nil)
      
      // MARK: - USER LOCATION
    case .userLocation(title: _, subtitle: _, coordinate: _):
      LocationService.shared.requestCurrentLocation { [weak self] location in
        guard let self else { return }
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
          guard let placemark = placemarks?.first, error == nil else { return }
          
          let number = placemark.subThoroughfare ?? ""
          let street = placemark.thoroughfare ?? ""
          let city = placemark.locality ?? ""
          let state = placemark.administrativeArea ?? ""
          let country = placemark.country ?? ""
          
          let houseAddress = [number, street].filter { !$0.isEmpty }.joined(separator: " ")
          let fullAddress = [city, state, country].filter { !$0.isEmpty }.joined(separator: ", ")
          
          DispatchQueue.main.async {
            self.handleLocationSelection(
              title: houseAddress.isEmpty ? "My Location" : houseAddress,
              subtitle: fullAddress,
              coordinate: location.coordinate
            )
          }
        }
      }
      
      break
    }
  }
  
  // MARK: - Perform MKLocalSearch and only act if real result exists
  private func performSearch(query: String, subtitle: String?) {
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = query
    
    let search = MKLocalSearch(request: request)
    search.start { [weak self] response, error in
      guard let self = self else { return }
      
      guard let firstItem = response?.mapItems.first else {
        // Không có kết quả → không làm gì
        return
      }
      
      let placemarkTitle = firstItem.placemark.title ?? ""
    
      
      let coordinate = firstItem.placemark.coordinate
      let resolvedSubtitle = subtitle ?? placemarkTitle
      
      DispatchQueue.main.async {
        self.handleLocationSelection(title: query, subtitle: resolvedSubtitle, coordinate: coordinate)
      }
    }
  }
  
  private func handleLocationSelection(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
    let region = MKCoordinateRegion(center: coordinate,
          latitudinalMeters: 200,
                                    longitudinalMeters: 200)
    
    mapView.setRegion(region, animated: true)
    
    let annotation = CustomAnnotation(
      coordinate: coordinate,
      title: title,
      subtitle: subtitle,
      type: "",
      id: title
    )
    
    let place = Place(address: title, fullAddres: subtitle, coordinate: coordinate, state: nil)
    annotation.type = PlaceManager.shared.exists(place) ? "Location" : ""
    
    mapView.addAnnotation(annotation)
    
    if UserDefaultsManager.shared.get(of: Bool.self, key: .tutorial) == false {
      // Setup callout
      currentPlace = place
      desAdress = subtitle
      address = title
      currentCalloutView.configureButton(title: "Add Stop", icon: .icPlus)
      showCalloutAnimated()
    } else {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
          self.showTooltipForAnnotation(annotation)
      }
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 66
  }
}

extension TruckVC {
  func geocodeAndFormatAddress(_ address: String, completion: @escaping (String) -> Void) {
    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString(address) { Placemarks, error in
      guard let Place = Placemarks?.first else {
        completion(address)
        return
      }
      
      let street = [Place.subThoroughfare, Place.thoroughfare].compactMap { $0 }.joined(separator: " ")
      let city = Place.locality ?? ""
      let state = Place.administrativeArea ?? ""
      let zip = Place.postalCode ?? ""
      let countryCode = Place.isoCountryCode ?? ""
      
      let formatted =
      """
      \(street)
      \(city), \(state) \(zip)
      \(countryCode)
      """
      completion(formatted)
    }
  }
}

extension TruckVC: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if viewModel.index.value == indexPath.row {
      viewModel.action.send(.getIndex(int: -1))
      MapManager.shared.removeAllServiceAnnotations()
      self.currentQuery = ""
      self.currentType = ""
      self.searchNearby(with: self.currentQuery, type: self.currentType)
    } else {
      // Chọn ô mới
      let item = ServiceType.allCases[indexPath.item]
    self.searchNearby(with: item.name, type: item.title)
    self.currentQuery = item.name
    self.currentType = item.title
    viewModel.action.send(.getIndex(int: indexPath.row))
    }
    
    collectionView.reloadData()
  }
}

extension TruckVC: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return ServiceType.allCases.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(ItemServiceCell.self, for: indexPath)
    let item = ServiceType.allCases[indexPath.item]
    cell.binding(item: item)
    
    if indexPath.row == viewModel.index.value {
      cell.didSelectedItem(item: item)
    } else {
      cell.unSelectedItem(item: item)
    }
    return cell
  }
}

extension TruckVC: CustomAnnotationViewDelagate {
  func customAnnotationView(_ annotationView: CustomAnnotationView, place: Place?) {
    guard let place = place else { return }
    
    if PlaceManager.shared.goingPlaceGroup.places.count >= 30 {
      var style = ToastStyle()
      style.backgroundColor = UIColor(rgb: 0xF03C3C)
      style.cornerRadius = 16
      style.titleColor = .white
      style.titleAlignment = .center
      style.titleFont = AppFont.font(.semiBoldText, size: 15)
      style.messageColor = .white
      style.displayShadow = false
      style.imageSize = CGSize(width: 24.0, height: 24.0)
      
      self.view.makeToast("You can only get an optimal route with 30 stops or fewer",
                          duration: 3.0,
                          position: .top,
                          image: .icAlert,
                          style: style)
      return
    }
    
    if PlaceManager.shared.placeGroup.places.count < 1 {
      addPlaceToPlaceGourp(annotationView, place: place)
    } else {
      annotationView.showLoadingView()
      MapManager.shared.checkRouteAvailable(from: PlaceManager.shared.currentPlace?.coordinate ?? CLLocationCoordinate2D(), to: place.coordinate) { [weak self] available in
        guard let self else {
          return
        }
        if available {
          annotationView.hideLoadingView()
          addPlaceToPlaceGourp(annotationView, place: place)
        } else {
          annotationView.hideLoadingView()
          var style = ToastStyle()
          style.backgroundColor = UIColor(rgb: 0xF03C3C)
          style.cornerRadius = 16
          style.titleColor = .white
          style.titleAlignment = .center
          style.titleFont = AppFont.font(.semiBoldText, size: 15)
          style.messageColor = .white
          style.displayShadow = false
          style.imageSize = CGSize(width: 24.0, height: 24.0)
          
          self.view.makeToast("Cannot calculate a route with these stops",
                              duration: 3.0,
                              position: .top,
                              image: .icAlert,
                              style: style)
        }
      }
    }
  }
  
  private func addPlaceToPlaceGourp(_ annotationView: CustomAnnotationView, place: Place) {
    let wasInPlaceGroup = PlaceManager.shared.exists(place)
    PlaceManager.shared.addLocation(place)
    let isInPlaceGroup = PlaceManager.shared.exists(place)
    
    // Cập nhật lại button state sau khi thêm/xóa
    if isInPlaceGroup {
      annotationView.configureButton(title: "Remove Stop", icon: .icTrash)
    } else {
      annotationView.configureButton(title: "Add Stop", icon: .icPlus)
    }
    
    // Chỉ cập nhật icon cho service annotation đang được thao tác (thêm/xóa)
    if let serviceAnnotation = annotationView.annotation as? CustomServiceAnimation {
      // Chỉ update icon nếu trạng thái thay đổi (từ có → không có hoặc ngược lại)
      if wasInPlaceGroup != isInPlaceGroup {
        if isInPlaceGroup {
          // Đã thêm vào placeGroup → hiển thị icon theo type
          switch serviceAnnotation.type {
          case "Gas Station":
            annotationView.image = .icPinGas
          case "Bank":
            annotationView.image = .icPinBank
          case "Car Wash":
            annotationView.image = .icPinCarWash
          case "Pharmacy":
            annotationView.image = .icPinPharmacy
          case "Fast Food":
            annotationView.image = .icPinFastFood
          default:
            annotationView.image = .icPinBlank
          }
        } else {
          // Chưa thêm vào placeGroup → hiển thị icLocationEmpty
          annotationView.image = .icLocationEmpty
        }
      }
    }
    
    // Cập nhật lại tooltip nếu đang hiển thị
    if currentTooltipView?.annotationID == annotationView.annotationID {
      annotationView.configureButton(title: isInPlaceGroup ? "Remove Stop" : "Add Stop",
                                     icon: isInPlaceGroup ? .icTrash : .icPlus)
    }
  }
}

extension TruckVC {
  private func hideCalloutAnimated() {
    guard !currentCalloutView.isHidden else { return }
    if !UserDefaultsManager.shared.get(of: Bool.self, key: .tutorial) {
      self.iconTutorialAddStop.isHidden = true
    }
    
    UIView.animate(withDuration: 0.25,
                   delay: 0,
                   options: .curveEaseIn,
                   animations: {
      self.currentCalloutView.alpha = 0
      self.currentCalloutView.transform = CGAffineTransform(translationX: 0, y: 20)
    }, completion: { _ in
      self.currentCalloutView.isHidden = true
      self.mapView.isUserInteractionEnabled = true
      self.currentCalloutView.transform = .identity
    })
  }
  
  private func showCalloutAnimated() {
    let adress = self.address
    currentCalloutView.configure(title: adress, des: desAdress)
    currentCalloutView.alpha = 0
    currentCalloutView.transform = CGAffineTransform(translationX: 0, y: 20)
    currentCalloutView.isHidden = false
    if !UserDefaultsManager.shared.get(of: Bool.self, key: .tutorial) {
      self.iconTutorialAddStop.isHidden = false
    }
    self.view.insertSubview(tutorialView, aboveSubview: searchView)
    // Animation hiện lên
    UIView.animate(withDuration: 0.5,
                   delay: 0,
                   usingSpringWithDamping: 0.8,
                   initialSpringVelocity: 0.5,
                   options: .curveEaseOut,
                   animations: {
      self.currentCalloutView.alpha = 1
      self.currentCalloutView.transform = .identity
    }, completion: { [weak self] _ in
      guard let self else {
        return
      }
      mapView.isUserInteractionEnabled = false
    })
  }
  
  // MARK: - User Location Tracking
  private func removeUserLocationAnnotation() {
    // Xóa annotation cũ nếu có
    if let existingAnnotation = userLocationAnnotation {
      mapView.removeAnnotation(existingAnnotation)
      userLocationAnnotation = nil
    }
    
    // Xóa tất cả annotations có id "user_location" hoặc title "My Location"
    let annotationsToRemove = mapView.annotations.filter { annotation in
      if let customAnn = annotation as? CustomAnnotation {
        return customAnn.id == "user_location" || customAnn.type == "UserLocation"
      }
      return annotation.title == "My Location"
    }
    mapView.removeAnnotations(annotationsToRemove)
  }
  
  private func startTrackingUserLocation() {
    let authStatus = locationManager.authorizationStatus
    switch authStatus {
    case .notDetermined:
      locationManager.requestWhenInUseAuthorization()
    case .authorizedWhenInUse, .authorizedAlways:
      locationManager.startUpdatingLocation()
    default:
      break
    }
  }
  
  private func stopTrackingUserLocation() {
    locationManager.stopUpdatingLocation()
    locationUpdateTimer?.invalidate()
    locationUpdateTimer = nil
  }
  
  private func updateUserLocationAnnotation(coordinate: CLLocationCoordinate2D) {
    guard let annotation = userLocationAnnotation else {
      // Nếu không có annotation, tạo mới
      let userAnnotation = CustomAnnotation(
        coordinate: coordinate,
        title: "My Location",
        subtitle: nil,
        type: "UserLocation",
        id: "user_location"
      )
      userLocationAnnotation = userAnnotation
      mapView.addAnnotation(userAnnotation)
      return
    }
    
    // Debounce: Hủy timer cũ nếu có
    locationUpdateTimer?.invalidate()
    
    // Tạo timer mới để update sau 0.5 giây
    locationUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
      guard let self = self, let annotation = self.userLocationAnnotation else { return }
      
      // Kiểm tra xem location có thay đổi đáng kể không (ít nhất 3m)
      if let lastLocation = self.lastUpdateLocation {
        let distance = CLLocation(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude)
          .distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
        
        // Chỉ update nếu di chuyển ít nhất 3 mét
        if distance < 3 {
          return
        }
      }
      
      // Đảm bảo chỉ có một annotation: xóa tất cả annotations có id "user_location" trước
      let annotationsToRemove = self.mapView.annotations.filter { ann in
        if let customAnn = ann as? CustomAnnotation {
          return customAnn.id == "user_location" && ann !== annotation
        }
        return false
      }
      if !annotationsToRemove.isEmpty {
        self.mapView.removeAnnotations(annotationsToRemove)
      }
      
      // Cập nhật coordinate và remove/add lại annotation để MapKit cập nhật vị trí
      annotation.coordinate = coordinate
      self.mapView.removeAnnotation(annotation)
      self.mapView.addAnnotation(annotation)
      
      self.lastUpdateLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
  }
}

// MARK: - CLLocationManagerDelegate
extension TruckVC: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }
    
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      
      // Cập nhật annotation mà không di chuyển map
      self.updateUserLocationAnnotation(coordinate: location.coordinate)
      self.currentUserCoordinate = location.coordinate
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    LogManager.show("Location update error: \(error.localizedDescription)")
  }
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .authorizedWhenInUse, .authorizedAlways:
      if !isInitialLocationSet {
        // Nếu chưa có location ban đầu, lấy location
        LocationService.shared.requestCurrentLocation { [weak self] location in
          guard let self = self else { return }
          DispatchQueue.main.async {
            // Xóa annotation cũ nếu có
            self.removeUserLocationAnnotation()
            
            let userAnnotation = CustomAnnotation(
              coordinate: location.coordinate,
              title: "My Location",
              subtitle: nil,
              type: "UserLocation",
              id: "user_location"
            )
            self.userLocationAnnotation = userAnnotation
            self.mapView.addAnnotation(userAnnotation)
            
            if !self.isInitialLocationSet {
              let region = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: 500,
                longitudinalMeters: 500
              )
              self.mapView.setRegion(region, animated: true)
              self.isInitialLocationSet = true
            }
            
            self.startTrackingUserLocation()
          }
        }
      } else {
        // Nếu đã có location, tiếp tục theo dõi
        startTrackingUserLocation()
      }
    default:
      break
    }
  }
}
