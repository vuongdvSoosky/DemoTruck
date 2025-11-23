//
//  GoingVC.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 17/11/25.
//

import SnapKit
import UIKit
import MapKit

class GoingVC: BaseViewController {
  
  // MARK: - Managers
  private let calculationManager = CalculationManager.shared
  private let distanceCalculator = DistanceCalculator.shared
  private let timerManager = OperationTimerManager.shared
  
  // MARK: - UIView
  private lazy var containerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  private lazy var inforView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .white
    view.cornerRadius = 42
    
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 28
    
    view.addSubview(stackView)
    
    [durationView, distanceView, mainSpeedView].forEach{stackView.addArrangedSubview($0)}
    
    stackView.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview().inset(17)
      make.left.right.equalToSuperview().inset(16)
    }
    return view
  }()
  private lazy var durationView = TitleValueView(title: "Duration", value: "00:00:00")
  private lazy var distanceView = TitleValueView(title: "Distance(mi)", value: "3000")
  private lazy var speedView = TitleValueView(title: "100", value: "mph", titleColor: UIColor(rgb: 0xF26101),
                                              valueColor: UIColor(rgb: 0x909090),
                                              titleFont: AppFont.font(.boldText, size: 17),
                                              valueFont: AppFont.font(.mediumText, size: 15))
  private lazy var mainSpeedView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    
    let image = UIImageView()
    image.image = .icSpeed
    image.contentMode = .scaleAspectFill
    
    view.addSubviews(speedView, image)
    image.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    speedView.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(10)
      make.left.right.bottom.equalToSuperview()
    }
    return view
  }()
  private lazy var goView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.cornerRadius = 12
    view.clipsToBounds = true
    view.isUserInteractionEnabled = true
    
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 8
    stackView.distribution = .fill
    
    statusTrackingLabel.text = "Go"
    statusTrackingLabel.font = AppFont.font(.bold, size: 20)
    statusTrackingLabel.textColor = UIColor(rgb: 0xFFFFFF)
    
    [icStop, statusTrackingLabel].forEach({stackView.addArrangedSubview($0)})
    
    view.addSubview(stackView)
    
    stackView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    return view
  }()
  private lazy var finishView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor(rgb: 0xFFEFD3)
    view.cornerRadius = 12
    view.borderWidth = 3
    view.borderColor = UIColor(rgb: 0xF26101)
    view.isUserInteractionEnabled = true
    view.isHidden = true
    view.clipsToBounds = true
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapFinishView)))
    
    let label = UILabel()
    label.text = "Finish"
    label.textColor = UIColor(rgb: 0x332644)
    label.font = AppFont.font(.boldText, size: 20)
    
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 12
    stackView.distribution = .fill
    
    [label].forEach({stackView.addArrangedSubview($0)})
    
    view.addSubview(stackView)
    
    stackView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    
    return view
  }()
  private lazy var goingDetailView: GoingDetailView = {
    let view = GoingDetailView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.delegate = self
    return view
  }()
  
  // MARK: - UILabel
  private lazy var statusTrackingLabel: UILabel = {
    let label = UILabel()
    label.text = "Go"
    label.textColor = UIColor(rgb: 0xFFFFFF)
    label.font = AppFont.font(.semiBoldText, size: 20)
    label.textAlignment = .center
    label.isUserInteractionEnabled = false
    return label
  }()
  
  // MARK: - UIImage
  private lazy var icStop: UIImageView = {
    let icon = UIImageView()
    icon.image = .icPauseTrackVC
    icon.contentMode = .scaleAspectFill
    icon.isHidden = true
    icon.snp.makeConstraints { make in
      make.width.height.equalTo(24)
    }
    return icon
  }()
  
  // MARK: - UICollectionView
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
  
  private lazy var statusStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .horizontal
    stackView.spacing = 10
    stackView.distribution = .fillEqually
    
    [goView, finishView].forEach({stackView.addArrangedSubview($0)})
    
    return stackView
  }()
  
  // MARK: - MapView
  private lazy var mapView: MKMapView = {
    let map = MKMapView()
    map.translatesAutoresizingMaskIntoConstraints = false
    return map
  }()
  
  private lazy var arrayPlaces: [Place] = []
  private var currentPlace: Place?
  private var pendingAnnotation: MKAnnotation?
  private var isUpdatingAnnotations = false
  private var lastPlaceIds: Set<String?> = []
  private var currentTooltipView: CustomAnnotationView?
  private var currentTooltipID: String?
  private var currentQuery = ""
  private var currentType = ""
  private var searchDelayTimer: Timer?
  
  private let viewModel = GoingViewVM()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupMapView()
  }
  
  override func setProperties() {
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.register(cell: ItemServiceCell.self)
    let goTapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapGoView))
    goView.addGestureRecognizer(goTapGesture)
    setupSwipeGoingDetailView()
    timerManager.delegate = self
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapCloseCalloutView(_:)))
    tapGesture.cancelsTouchesInView = false
    view.addGestureRecognizer(tapGesture)
  }
  
  override func addComponents() {
    self.view.addSubview(containerView)
    self.containerView.addSubviews(mapView, inforView, collectionView, goingDetailView, statusStackView)
  }
  
  override func setConstraints() {
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    mapView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    inforView.snp.makeConstraints { make in
      make.top.equalTo(self.containerView.snp.topMargin).offset(8)
      make.left.right.equalToSuperview().inset(20)
      make.height.equalTo(83)
    }
    
    collectionView.snp.makeConstraints { make in
      make.top.equalTo(inforView.snp.bottom).offset(12)
      make.left.equalToSuperview().inset(16)
      make.right.equalToSuperview()
      make.height.equalTo(56)
    }
    
    goingDetailView.snp.makeConstraints { make in
      make.bottom.equalTo(statusStackView.snp.top).inset(-12)
      make.left.right.equalToSuperview().inset(20)
      make.height.equalTo(188)
    }
    
    statusStackView.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(20)
      make.height.equalTo(60)
      make.bottom.equalTo(self.containerView.snp.bottomMargin)
    }
  }
  
  override func setColor() {
    inforView.addShadow()
    
    let colors = [UIColor(rgb: 0xF28E01), UIColor(rgb: 0xF26101)]
    goView.addArrayColorGradient(arrayColor: colors, startPoint: CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5))
  }
  
  override func binding() {
    viewModel.index
      .receive(on: DispatchQueue.main)
      .sink { [weak self] index in
        guard let self else {
          return
        }
        collectionView.reloadData()
      }.store(in: &subscriptions)
    
    PlaceManager.shared.$placesRouter
      .receive(on: DispatchQueue.main)
      .sink { [weak self] router in
        guard let self, let router = router else {
          return
        }
        displayRouteOnMap(route: router, mapView: mapView)
      }.store(in: &subscriptions)
    
    PlaceManager.shared.$placeGroup
      .receive(on: DispatchQueue.main)
      .sink { [weak self] places in
        guard let self else {
          return
        }
        self.arrayPlaces = places.places
        self.updateAnnotations(for: places.places)
      }.store(in: &subscriptions)
    
    viewModel.timeTracking
      .receive(on: DispatchQueue.main)
      .sink { [weak self] time in
        guard let self else {
          return
        }
        durationView.updateValue(time)
      }.store(in: &subscriptions)
    
    // InformationTrack
    distanceCalculator.$totalDistanceMiles
      .receive(on: DispatchQueue.main)
      .sink { [weak self] distance in
        guard let self else {
          return
        }
        distanceView.updateValue("\(String(format: "%.2f", distance)) mi")
      }.store(in: &subscriptions)
    
    distanceCalculator.$currentSpeedMph
      .receive(on: DispatchQueue.main)
      .sink { [weak self] currentSpeed in
        guard let self else {
          return
        }
        if currentSpeed == 0 {
          speedView.updateTitle("--:--")
        } else {
          speedView.updateTitle("\(String(format: "%.2f", currentSpeed))")
        }
      }.store(in: &subscriptions)
  }
  
  private func setupMapView() {
    MapManager.shared.attachMap(to: mapView)
    mapView.delegate = self
  }
  
  private func updateAnnotations(for places: [Place]) {
    guard !isUpdatingAnnotations else { return }
    isUpdatingAnnotations = true
    defer { isUpdatingAnnotations = false }
    
    // Tạo id unique từ coordinate nếu place.id là nil
    let placesWithIds = places.map { place -> Place in
      var updatedPlace = place
      if updatedPlace.id == nil {
        // Tạo id unique dựa trên coordinate
        updatedPlace.id = "\(place.coordinate.latitude)_\(place.coordinate.longitude)"
      }
      return updatedPlace
    }
    
    let placeIds = Set(placesWithIds.compactMap { $0.id })
    
    // Kiểm tra xem có thay đổi không
    if placeIds == lastPlaceIds && placesWithIds.count == lastPlaceIds.count {
      // Không có thay đổi về số lượng và ids, chỉ update nếu cần
      return
    }
    lastPlaceIds = placeIds
    
    // Lọc các annotation hiện tại
    let annotationsToRemove = mapView.annotations.compactMap { ann -> MKAnnotation? in
      guard let customAnn = ann as? CustomAnnotation else { return nil }
      // Nếu annotation không nằm trong placeIds → remove
      return placeIds.contains(customAnn.id ?? "") ? nil : customAnn
    }
    
    if !annotationsToRemove.isEmpty {
      mapView.removeAnnotations(annotationsToRemove)
    }
    
    // Thêm hoặc update annotations
    for place in placesWithIds {
      // Tìm annotation đã tồn tại bằng id hoặc coordinate
      if let existingAnnotation = mapView.annotations.first(where: {
        guard let ann = $0 as? CustomAnnotation else { return false }
        // So sánh bằng id nếu có, nếu không thì so sánh bằng coordinate
        if let placeId = place.id, let annId = ann.id {
          return annId == placeId
        } else {
          // So sánh bằng coordinate với độ chính xác epsilon
          let epsilon = 1e-6
          return abs(ann.coordinate.latitude - place.coordinate.latitude) < epsilon &&
          abs(ann.coordinate.longitude - place.coordinate.longitude) < epsilon
        }
      }) as? CustomAnnotation {
        // Chỉ update nếu có thay đổi
        let needsUpdate = existingAnnotation.coordinate.latitude != place.coordinate.latitude ||
        existingAnnotation.coordinate.longitude != place.coordinate.longitude ||
        existingAnnotation.title != place.address ||
        existingAnnotation.subtitle != place.fullAddres ||
        existingAnnotation.type != (place.type ?? "Location")
        
        if needsUpdate {
          existingAnnotation.coordinate = place.coordinate
          existingAnnotation.title = place.address
          existingAnnotation.subtitle = place.fullAddres
          existingAnnotation.type = place.type ?? "Location"
          existingAnnotation.id = place.id
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
  
  private func scrollToFirstPlace() {
    guard let first = arrayPlaces.first else { return }
    
    let coordinate = first.coordinate
    let region = MKCoordinateRegion(
      center: coordinate,
      latitudinalMeters: 150,
      longitudinalMeters: 150
    )
    
    mapView.setRegion(region, animated: true)
  }
  
  private func searchNearby(with nameService: String = "", type: String = "") {
    MapManager.shared.searchServiceAroundVisibleRegion(nameService, type: type)
  }
}

extension GoingVC: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let item = ServiceType.allCases[indexPath.row]
    searchNearby(with: item.name, type: item.title)
    self.currentQuery = item.name
    self.currentType = item.title
    viewModel.action.send(.getIndex(int: indexPath.row))
  }
}

extension GoingVC: UICollectionViewDataSource {
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

// MARK: - Tracking
extension GoingVC {
  private func stateGo() {
    switch viewModel.trackingState {
    case .beginTracking:
      // Bắt đầu tracking lần đầu
      BlockQueueManager.shared.startFllow()
      // Bắt đầu tracking
      distanceCalculator.startTracking()
      timerManager.startOperationTimer()
      
      // Cập nhật UI: hiển thị "Pause" (vì đang tracking)
      icStop.isHidden = false
      statusTrackingLabel.text = "Pause"
      icStop.image = .icPauseTrackVC
      
      UIView.animate(withDuration: 0.25) {
        self.finishView.isHidden = true
        self.statusStackView.layoutIfNeeded()
        self.view.layoutIfNeeded()
      }
      
      // Chuyển sang trạng thái đang tracking
      DispatchQueue.main.async { [weak self] in
        self?.viewModel.action.send(.getTrackingState(state: .continueTracking))
      }
      
    case .continueTracking:
      // Đang tracking -> Tạm dừng
      // Dừng tracking
      distanceCalculator.pauseTracking()
      timerManager.stopOperationTimer()
      
      // Cập nhật UI: hiển thị "Continue" (vì đang pause)
      icStop.isHidden = false
      statusTrackingLabel.text = "Continue"
      icStop.image = .icContinueTracking
      
      UIView.animate(withDuration: 0.25) {
        self.finishView.isHidden = false
        self.finishView.alpha = 1.0
        self.statusStackView.layoutIfNeeded()
        self.view.layoutIfNeeded()
      }
      
      // Chuyển sang trạng thái pause
      DispatchQueue.main.async { [weak self] in
        guard let self else {
          return
        }
        self.viewModel.action.send(.getTrackingState(state: .pauseTracking))
        // Đảm bảo finishView vẫn hiển thị sau khi thay đổi state
        UIView.animate(withDuration: 0.25) {
          self.finishView.isHidden = false
          self.finishView.alpha = 1.0
          self.statusStackView.layoutIfNeeded()
          self.view.layoutIfNeeded()
        }
      }
      
      goingDetailView.enabelEditView()
      
    case .pauseTracking:
      // Đang pause -> Tiếp tục tracking
      // Tiếp tục tracking
      distanceCalculator.resumeTracking()
      timerManager.startOperationTimer()
      
      // Cập nhật UI: hiển thị "Pause" (vì đang tracking)
      icStop.isHidden = false
      statusTrackingLabel.text = "Pause"
      icStop.image = .icPauseTrackVC
      
      UIView.animate(withDuration: 0.25) {
        self.finishView.isHidden = true
        self.statusStackView.layoutIfNeeded()
      }
      
      // Chuyển sang trạng thái đang tracking
      DispatchQueue.main.async { [weak self] in
        self?.viewModel.action.send(.getTrackingState(state: .continueTracking))
      }
      goingDetailView.didsaabelEditView()
    case .finishTracking:
      icStop.isHidden = true
    }
  }
  
  private func startStateTracking() {
    LocationService.shared.checkAndRequestAuthorization { [weak self] status in
      guard let self else { return }
      switch status {
      case .notDetermined, .restricted:
        break
      case .denied:
        LocationService.shared.showSettingsAlert(from: self)
        UserDefaultsManager.shared.set(false, key: .requestLocation)
      case .authorizedWhenInUse, .authorizedAlways:
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {[weak self] in
          guard let self else {
            return
          }
          stateGo()
          
          UserDefaultsManager.shared.set(true, key: .requestLocation)
          showCurrentLocation(mapView)
        }
      @unknown default:
        LogManager.show("Unknown location status")
      }
    }
  }
}

// MARK: - Action

extension GoingVC {
  @objc private func onTapGoView() {
    startStateTracking()
  }
  
  @objc private func onTapFinishView() {
    viewModel.action.send(.finish)
  }
}

// MARK: - GoingDetaiView
extension GoingVC {
  private func setupSwipeGoingDetailView() {
    // Vuốt lên
    let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipeCustomPropertiesField(_:)))
    swipeUp.direction = .up
    goingDetailView.addGestureRecognizer(swipeUp)
    
    // Vuốt xuống
    let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeCustomPropertiesField(_:)))
    swipeDown.direction = .down
    goingDetailView.addGestureRecognizer(swipeDown)
    
    // Cho phép view nhận gesture
    goingDetailView.isUserInteractionEnabled = true
  }
  
  @objc private func swipeCustomPropertiesField(_ gesture: UISwipeGestureRecognizer) {
    switch gesture.direction {
    case .up:
      goingDetailView.snp.updateConstraints { make in
        make.height.equalTo(514)
      }
      
      goingDetailView.hideStopLabel()
      
      UIView.animate(withDuration: 0.3,
                     delay: 0,
                     usingSpringWithDamping: 0.85,
                     initialSpringVelocity: 0.5,
                     options: .curveEaseInOut) {
        self.view.layoutIfNeeded()
      }
      
    case .down:
      goingDetailView.snp.updateConstraints { make in
        make.height.equalTo(188)
      }
      
      goingDetailView.showStopLabel()
      
      UIView.animate(withDuration: 0.3,
                     delay: 0,
                     usingSpringWithDamping: 0.85,
                     initialSpringVelocity: 0.5,
                     options: .curveEaseInOut) {
        self.view.layoutIfNeeded()
      }
      
    default:
      break
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
  
  @objc private func onTapCloseCalloutView(_ gesture: UITapGestureRecognizer) {
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
  }
}

extension GoingVC: GoingDetailViewDelegate {
  func onTapEdit() {
    viewModel.action.send(.edit)
  }
  
  func didChooseItem(item: Place) {
    viewModel.action.send(.getItem(item: item))
  }
}

extension GoingVC {
  func displayRouteOnMap(route: RouteResponse, mapView: MKMapView) {
    guard let coordinates = route.paths.first?.points.coordinates else {
      LogManager.show("No coordinates found")
      return
    }
    mapView.removeOverlays(mapView.overlays)
    let polylineCoordinates = coordinates.map { CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0]) }
    let polyline = MKPolyline(coordinates: polylineCoordinates, count: polylineCoordinates.count)
    
    // Thêm tuyến đường vào bản đồ
    mapView.addOverlay(polyline)
    
    // Zoom vào khu vực chứa tuyến đường
    mapView.setVisibleMapRect(polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 50, left: 20, bottom: 50, right: 20), animated: true)
  }
}

extension GoingVC: MKMapViewDelegate {
  
  func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    // debounce tránh spam search khi người dùng kéo bản đồ liên tục
    searchDelayTimer?.invalidate()
    searchDelayTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
       self?.searchNearby(with: self?.currentQuery ?? "", type: self?.currentType ?? "")
    }
  }
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if let polyline = overlay as? MKPolyline {
      let renderer = MKPolylineRenderer(overlay: polyline)
      renderer.strokeColor = UIColor(rgb: 0xF26101)
      renderer.lineWidth = 4
      return renderer
    }
    return MKOverlayRenderer(overlay: overlay)
  }
    
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if annotation is MKUserLocation { return nil }
    
    // MARK: - CustomAnnotation
    if let customAnno = annotation as? CustomAnnotation {
      let identifier = customAnno.identifier
      var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? CustomAnnotationView
      
      if view == nil {
        view = CustomAnnotationView(annotation: customAnno, reuseIdentifier: identifier)
        view?.hideButton()
      } else {
        view?.annotation = customAnno
        view?.hideButton()
      }
      
      // Gán ID annotation
      view?.annotationID = customAnno.id
      
      // Configure tooltip đúng dữ liệu của annotation hiện tại
      view?.configure(title: customAnno.title ?? "", des: customAnno.subtitle ?? "")
      
      // Tìm Place tương ứng từ arrayPlaces để lấy state
      let correspondingPlace = arrayPlaces.first { place in
        if let placeId = place.id, let annoId = customAnno.id {
          return placeId == annoId
        } else {
          // So sánh bằng coordinate nếu id không có
          let epsilon = 1e-6
          return abs(place.coordinate.latitude - customAnno.coordinate.latitude) < epsilon &&
                 abs(place.coordinate.longitude - customAnno.coordinate.longitude) < epsilon
        }
      }
      
      // Chọn icon dựa vào state nếu có, nếu không thì dựa vào type
      if let place = correspondingPlace, let state = place.state {
        // Hiển thị icon dựa trên state (true/false)
        if state {
          // state == true → hiển thị icFinish
          view?.image = .icLocationFinish
        } else {
          // state == false → hiển thị icFailedRoute
          view?.image = .icLocationFailed
        }
      } else {
        // Nếu state là nil, hiển thị icon dựa vào type
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
        view?.hideButton()
      } else {
        view?.annotation = customService
        view?.hideButton()
      }
      
      // Gán ID annotation
      view?.annotationID = customService.id
      
      // Configure tooltip đúng dữ liệu của annotation hiện tại
      view?.configure(title: customService.title ?? "", des: customService.subtitle ?? "")
      
      // Kiểm tra xem service đã được thêm vào placeGroup chưa
      let place = Place(id: customService.id, address: customService.title ?? "", fullAddres: customService.subtitle ?? "", coordinate: customService.coordinate, state: nil, type: customService.type)
      let isInPlaceGroup = PlaceManager.shared.isExistLocation(place)
      
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
    
    return nil
  }
}

extension GoingVC: OperationTimerManagerDelegate {
  func setCurrentTimeDouble(_ time: Double) {
    viewModel.action.send(.getDuration(time: time))
  }
  
  func updateTimeDisplay(_ time: String) {
    viewModel.action.send(.getTimeTracking(time: time))
  }
}

extension GoingVC {
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
    annotationView.hideButton()
  }
  
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
    if PlaceManager.shared.isExistLocation(place) {
      annotationView.configureButton(title: "Remove Stop", icon: .icTrash)
    } else {
      annotationView.configureButton(title: "Add Stop", icon: .icPlus)
    }
  }
}
