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
  
  private lazy var currentCalloutView: CustomAnnotationCalloutView = {
    let view = CustomAnnotationCalloutView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.isHidden = true
    view.onButtonTapped = { [weak self] in
      guard let self, let place = self.currentPlace else { return }
      
      PlaceManager.shared.addLocationToArray(place)
      
      if PlaceManager.shared.isExistLocation(place) {
        view.configureButton(title: "Remove Stop", icon: .icTrash)
      } else {
        view.configureButton(title: "Add Stop", icon: .icPlus)
        hideCalloutAnimated()
      }
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
    
    PlaceManager.shared.$places
      .receive(on: DispatchQueue.main)
      .sink { [weak self] places in
        guard let self else {
          return
        }
        self.arrayPlaces = places
        LogManager.show(places.count)
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
        type: "parking",
        titlePlace: place.address
      )
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
  
  private func showCalloutAnimated() {
    let adress = self.address.shortAddress
    currentCalloutView.configure(title: adress)
    currentCalloutView.alpha = 0
    currentCalloutView.transform = CGAffineTransform(translationX: 0, y: 20)
    currentCalloutView.isHidden = false
    
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
  
  private func hideCalloutAnimated() {
    guard !currentCalloutView.isHidden else { return }
    
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
  
  @objc private func onTapDetailRoute() {
    changeStateDetailRouteTabView(UIColor(rgb: 0xFFECC4), image: .icDetaiRouteSelected)
    changeStateMapTabView(.clear, image: .icMap)
    viewModel.action.send(.getIndexToScroll(index: 1))
  }
  
  @objc private func onTapMapView() {
    changeStateMapTabView(UIColor(rgb: 0xFFECC4), image: .icMapSeleted)
    changeStateDetailRouteTabView(.clear, image: .icDetailRoute)
    viewModel.action.send(.getIndexToScroll(index: 0))
  }
  
  @objc private func annotationTapped(_ sender: UITapGestureRecognizer) {
    guard let annotationView = sender.view as? MKAnnotationView,
          let annotation = annotationView.annotation as? CustomAnnotation else { return }
    // xử lý hành vi khi bấm vào pin
    pendingAnnotation = annotation
    mapKitView.setCenter(annotation.coordinate, animated: true)
    
    if let matchedPlace = arrayPlaces.first(where: { $0.address == annotation.titlePlace }) {
      self.currentPlace = matchedPlace
      self.address = matchedPlace.address
      self.currentCalloutView.configureButton(title: "Remove Stop", icon: .icTrash)
    } else {
      let adress = annotation.titlePlace.shortAddress
      self.currentCalloutView.configure(title: adress)
      self.currentCalloutView.configureButton(title: "Add Stop", icon: .icPlus)
    }
    showCalloutAnimated()
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
      case "hospital":
        view?.image = .icLocationStop
      case "parking":
        view?.image = .icLocationStop
      case "coffee":
        view?.image = .icLocationStop
      default:
        view?.image = .icLocationStop
      }
    } else {
      view?.image = .icLocationStop
    }
    
    view?.centerOffset = CGPoint(x: 0, y: -15)
    let tap = UITapGestureRecognizer(target: self, action: #selector(annotationTapped(_:)))
    view?.addGestureRecognizer(tap)
    return view
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
