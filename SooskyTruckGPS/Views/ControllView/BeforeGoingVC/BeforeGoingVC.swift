//
//  BeforeGoingVC.swift
//  SooskyTruckGPS
//
//  Created by VuongDV on 13/11/25.
//

import UIKit
import MapKit
import SnapKit

class BeforeGoingVC: BaseViewController {
  
  // MARK: UIView
  private lazy var mapKitView: MKMapView = {
    let view = MKMapView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private lazy var mapView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(mapKitView)
    mapKitView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    return view
  }()
  private lazy var detailRouterView: DetailRouterView = {
    let view = DetailRouterView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor(rgb: 0xF2F2F2)
    return view
  }()
  private lazy var containerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
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
    view.backgroundColor = UIColor(rgb: 0xFFEFD3)
    view.cornerRadius = 16
    view.borderWidth = 2
    view.borderColor = UIColor(rgb: 0xF26101)
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapSave)))
    
    let label = UILabel()
    label.text = "Save"
    label.font = AppFont.font(.boldText, size: 20)
    label.textColor = UIColor(rgb: 0x332644)
    label.textAlignment = .center
    view.addSubviews(label)
    
    label.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    return view
  }()
  private lazy var goView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.cornerRadius = 16
    view.clipsToBounds = true
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapGo)))
    let label = UILabel()
    label.text = "Go"
    label.textColor = UIColor(rgb: 0xFFFFFF)
    label.textAlignment = .center
    label.font = AppFont.font(.boldText, size: 20)
    
    view.addSubview(label)
    
    label.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    
    return view
  }()
  private lazy var tabView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor(rgb: 0xFFFFFF)
    view.cornerRadius = 22
    
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 8
    stackView.distribution = .fillEqually
    
    [mapTabView, detailRouteTabView].forEach({stackView.addArrangedSubview($0)})
    view.addSubview(stackView)
    
    stackView.snp.makeConstraints { make in
      make.top.bottom.left.right.equalToSuperview().inset(4)
    }
    return view
  }()
  private lazy var mapTabView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor(rgb: 0xFFECC4)
    view.cornerRadius = 18
    view.isUserInteractionEnabled = true
    
    view.addSubview(iconMap)
    iconMap.snp.makeConstraints { make in
      make.width.height.equalTo(28)
      make.center.equalToSuperview()
    }
    return view
  }()
  
  private lazy var detailRouteTabView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .clear
    view.cornerRadius = 18
    view.isUserInteractionEnabled = true
    
    view.addSubview(iconDetailRoute)
    
    iconDetailRoute.snp.makeConstraints { make in
      make.width.height.equalTo(28)
      make.center.equalToSuperview()
    }
    return view
  }()
  
  
  // MARK: UIImageView
  private lazy var iconBack: UIImageView = {
    let icon = UIImageView()
    icon.image = .icBack
    icon.translatesAutoresizingMaskIntoConstraints = false
    icon.isUserInteractionEnabled = true
    icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapBack)))
    return icon
  }()
  
  private lazy var iconDetailRoute: UIImageView = {
    let icon = UIImageView()
    icon.image = .icDetailRoute
    icon.contentMode = .scaleAspectFill
    return icon
  }()
  
  private lazy var iconMap: UIImageView = {
    let icon = UIImageView()
    icon.image = .icMapSeleted
    icon.contentMode = .scaleAspectFill
    return icon
  }()
  
  
  // MARK: - UILabel
  private lazy var titleVC: UILabel = {
    let label = UILabel()
    label.text = "Route Planned"
    label.textColor = UIColor(rgb: 0x332644)
    label.font = AppFont.font(.boldText, size: 28)
    return label
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
    return scrollView
  }()
  
  // MARK: - UIStackView
  private lazy var stateStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 4
    stackView.distribution = .fillEqually
    [saveView, goView].forEach({stackView.addArrangedSubview($0)})
    return stackView
  }()
  
  private let viewModel = BeforeGoingVM()
  var currentTooltipView: CustomAnnotationView?
  var currentTooltipID: String?
  
  override func addComponents() {
    self.view.addSubviews(iconBack, titleVC, containerView, stateStackView, tabView)
    containerView.addSubviews(mainScrollView)
    mainScrollView.addSubviews(contentView)
    contentView.addSubviews(mapView, detailRouterView)
  }
  
  override func setConstraints() {
    iconBack.snp.makeConstraints { make in
      make.top.equalTo(self.view.snp.topMargin).offset(16)
      make.left.equalToSuperview().inset(20)
      make.width.height.equalTo(36)
    }
    
    titleVC.snp.makeConstraints { make in
      make.centerY.equalTo(iconBack.snp.centerY)
      make.left.equalTo(self.iconBack.snp.right).offset(15)
    }
    
    containerView.snp.makeConstraints { make in
      make.top.equalTo(titleVC.snp.bottom).offset(16)
      make.left.right.bottom.equalToSuperview()
    }
    
    mainScrollView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    contentView.snp.makeConstraints { make in
      make.edges.equalTo(mainScrollView.contentLayoutGuide)
      make.height.equalTo(mainScrollView.frameLayoutGuide)
      make.width.equalTo(mainScrollView.frameLayoutGuide).multipliedBy(2)
    }
    
    mapView.snp.makeConstraints { make in
      make.top.bottom.left.equalToSuperview()
      make.width.equalTo(containerView.snp.width)
    }
    
    detailRouterView.snp.makeConstraints { make in
      make.top.bottom.right.equalToSuperview()
      make.left.equalTo(mapView.snp.right)
      make.width.equalTo(containerView.snp.width)
    }
    
    tabView.snp.makeConstraints { make in
      make.bottom.equalTo(stateStackView.snp.top).inset(-8)
      make.centerX.equalToSuperview()
      make.width.equalTo(155)
      make.height.equalTo(44)
    }
    
    stateStackView.snp.makeConstraints { make in
      make.bottom.equalTo(self.view.snp.bottomMargin).offset(-20)
      make.left.right.equalToSuperview().inset(20)
      make.height.equalTo(60)
    }
  }
  
  override func setProperties() {
    let detailRouteTapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapDetailRoute))
    detailRouteTabView.addGestureRecognizer(detailRouteTapGesture)
    
    let mapTapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapMapView))
    mapTabView.addGestureRecognizer(mapTapGesture)
  }
  
  private lazy var arrayPlaces: [Place] = []
  private var currentPlace: Place?
  private var pendingAnnotation: MKAnnotation?
  private var address: String = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupMap()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    updateAnnotations()
  }
  
  private func setupMap() {
    MapManager.shared.attachMap(to: mapKitView)
    mapKitView.delegate = self
  }
  
  override func setColor() {
    self.view.backgroundColor = UIColor(rgb: 0xFFFFFF)
    let colors = [UIColor(rgb: 0xF28E01), UIColor(rgb: 0xF26101)]
    goView.addArrayColorGradient(arrayColor: colors, startPoint: CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5))
  }
  
  override func binding() {
    viewModel.indexForMainScrollView
      .receive(on: DispatchQueue.main)
      .sink { [weak self] index in
        guard let self else {
          return
        }
        scrollToPage(index: index)
      }.store(in: &subscriptions)
    
    PlaceManager.shared.$placeGroup
      .receive(on: DispatchQueue.main)
      .sink { [weak self] places in
        guard let self else {
          return
        }
        self.arrayPlaces = places.places
        self.updateAnnotations()
      }.store(in: &subscriptions)
    
    PlaceManager.shared.$placesRouter
      .receive(on: DispatchQueue.main)
      .sink { [weak self] router in
        guard let self, let router = router else {
          return
        }
        displayRouteOnMap(route: router, mapView: mapKitView)
      }.store(in: &subscriptions)
  }
  
  private func updateAnnotations() {
    // Xoá các annotation cũ trừ vị trí người dùng
    let nonUserAnnotations = mapKitView.annotations.filter { !($0 is MKUserLocation) }
    mapKitView.removeAnnotations(nonUserAnnotations)
    
    // Tạo annotation mới từ arrayPlaces
    let annotations = arrayPlaces.map { place -> CustomAnnotation in
      return CustomAnnotation(
        coordinate: place.coordinate,
        title: "parking", subtitle: place.fullAddres,
        type: place.address, id: place.address)
    }
    
    mapKitView.addAnnotations(annotations)
    scrollToFirstPlace()
  }
  
  private func scrollToFirstPlace() {
    guard let first = arrayPlaces.first else { return }
    
    let coordinate = first.coordinate
    let region = MKCoordinateRegion(
      center: coordinate,
      latitudinalMeters: 150,
      longitudinalMeters: 150
    )
    
    mapKitView.setRegion(region, animated: true)
  }
    
  func scrollToPage(index: Int, animated: Bool = true) {
    mainScrollView.isScrollEnabled = true
    let pageWidth = mainScrollView.frame.size.width
    let targetOffset = CGPoint(x: CGFloat(index) * pageWidth, y: 0)
    mainScrollView.setContentOffset(targetOffset, animated: animated)
    mainScrollView.isScrollEnabled = false
  }
  
  
  @objc private func onTapDetailRoute() {
    changeStateDetailRouteTabView(UIColor(rgb: 0xFFECC4), image: .icDetaiRouteSelected)
    changeStateMapTabView(.clear, image: .icMap)
    viewModel.action.send(.getIndexToScroll(index: 1))
    self.view.backgroundColor = UIColor(rgb: 0xF2F2F2)
  }
  
  @objc private func onTapMapView() {
    changeStateMapTabView(UIColor(rgb: 0xFFECC4), image: .icMapSeleted)
    changeStateDetailRouteTabView(.clear, image: .icDetailRoute)
    viewModel.action.send(.getIndexToScroll(index: 0))
    self.view.backgroundColor = UIColor(rgb: 0xFFFFFF)
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
  
  @objc private func onTapBack() {
    viewModel.action.send(.back)
  }
  
  @objc private func onTapSave() {
    viewModel.action.send(.save)
  }
  
  @objc private func onTapGo() {
    viewModel.action.send(.go)
  }
}

extension BeforeGoingVC {
  private func changeStateDetailRouteTabView(_ backgoundColor: UIColor, image: UIImage = .icDetaiRouteSelected) {
    detailRouteTabView.backgroundColor = backgoundColor
    iconDetailRoute.image = image
  }
  
  private func changeStateMapTabView(_ backgoundColor: UIColor, image: UIImage = .icMapSeleted) {
    mapTabView.backgroundColor = backgoundColor
    iconMap.image = image
  }
}

extension BeforeGoingVC: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    // debounce tránh spam search khi người dùng kéo bản đồ liên tục
    //        searchDelayTimer?.invalidate()
    //        searchDelayTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
    //          // self?.searchNearby()
    //        }
    // isProgrammaticRegionChange = false
  }
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if let polyline = overlay as? MKPolyline {
      let renderer = MKPolylineRenderer(overlay: polyline)
      renderer.strokeColor = UIColor(rgb: 0xFFC26D)
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
      } else {
        view?.annotation = customService
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


extension BeforeGoingVC {
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

extension BeforeGoingVC {
  private func showTooltipForAnnotation(_ annotation: CustomAnnotation) {
    guard let annotationView = mapKitView.view(for: annotation) as? CustomAnnotationView else {
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
  
  private func showTooltipForServiceAnnotation(_ annotation: CustomServiceAnimation) {
    guard let annotationView = mapKitView.view(for: annotation) as? CustomAnnotationView else {
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
//    let place = Place(id: annotation.id, address: annotation.title ?? "", fullAddres: annotation.subtitle ?? "", coordinate: annotation.coordinate, state: nil, type: annotation.type)
//    if PlaceManager.shared.isExistLocation(place) {
//      annotationView.configureButton(title: "Remove Stop", icon: .icTrash)
//    } else {
//      annotationView.configureButton(title: "Add Stop", icon: .icPlus)
//    }
  }
}
