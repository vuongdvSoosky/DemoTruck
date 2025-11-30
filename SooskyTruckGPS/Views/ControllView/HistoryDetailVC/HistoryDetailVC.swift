//
//  HistoryDetailVC.swift
//  SooskyTruckGPS
//
//  Created by VuongDV on 23/11/25.
//

import SnapKit
import UIKit
import MapKit

class HistoryDetailVC: BaseViewController {
  
  // MARK: - UIView
  private lazy var containerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    
    return view
  }()
 
  private lazy var viewList: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.cornerRadius = 24
    view.backgroundColor = UIColor(rgb: 0xFFFFFF)
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapViewlist)))
    
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
  
  private lazy var iconBack: UIImageView = {
    let icon = UIImageView()
    icon.image = .icBack
    icon.translatesAutoresizingMaskIntoConstraints = false
    icon.isUserInteractionEnabled = true
    icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapBack)))
    return icon
  }()
  
  private lazy var viewListStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .horizontal
    stackView.spacing = 10
    stackView.distribution = .fillEqually
    
    [viewList].forEach({stackView.addArrangedSubview($0)})
    
    return stackView
  }()
  
  private lazy var icDirection: UIImageView = {
    let image = UIImageView()
    image.translatesAutoresizingMaskIntoConstraints = false
    image.image = .icDirection
    image.isUserInteractionEnabled = true
    image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapDirection)))
    return image
  }()
  
  // MARK: - MapView
  private lazy var mapView: MKMapView = {
    let map = MKMapView()
    map.translatesAutoresizingMaskIntoConstraints = false
    return map
  }()
  
  private lazy var arrayPlaces: [Place] = []
  private var isUpdatingAnnotations = false
  private var lastPlaceIds: Set<String?> = []
  private var currentTooltipView: CustomAnnotationView?
  private var currentTooltipID: String?
  
  private var viewModel: HistoryDetailVM!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupMapView()
  }
  
  override func setProperties() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapCloseCalloutView(_:)))
    tapGesture.cancelsTouchesInView = false
    view.addGestureRecognizer(tapGesture)
  }
  
  override func addComponents() {
    self.view.addSubview(containerView)
    self.containerView.addSubviews(mapView, iconBack, viewListStackView, icDirection)
  }
  
  override func setConstraints() {
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    iconBack.snp.makeConstraints { make in
      make.top.equalTo(self.view.snp.topMargin).offset(16)
      make.left.equalToSuperview().inset(20)
      make.width.height.equalTo(36)
    }
    
    mapView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  
    viewListStackView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.width.equalTo(111)
      make.height.equalTo(47)
      make.bottom.equalTo(self.containerView.snp.bottomMargin)
    }
    
    icDirection.snp.makeConstraints { make in
      make.bottom.equalTo(viewListStackView.snp.top).inset(-40)
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
  
  override func setColor() {
    viewList.addShadow()
  }
  
  override func binding() {
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
  }
  
  private func setupMapView() {
    MapManager.shared.attachMap(to: mapView)
    mapView.delegate = self
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
          id: place.id, state: place.state
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

// MARK: - GoingDetaiView
extension HistoryDetailVC {
  @objc private func annotationTapped(_ sender: UITapGestureRecognizer) {
    guard let customView = sender.view as? CustomAnnotationView else { return }
    
    // Xử lý cả CustomAnnotation và CustomServiceAnimation
    if let anno = customView.annotation as? CustomAnnotation {
      showTooltipForAnnotation(anno)
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
  
  @objc private func onTapBack() {
    viewModel.action.send(.back)
    // Reset Places
    PlaceManager.shared.setPlaceGroup([], name: "My Route")
  }
  
  @objc private func onTapViewlist() {
    viewModel.action.send(.viewList)
  }
  
  @objc private func onTapDirection() {
    self.showCurrentLocation(mapView)
  }
}

extension HistoryDetailVC {
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

extension HistoryDetailVC: MKMapViewDelegate {
  
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
    
    return nil
  }
}

extension HistoryDetailVC {
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
      annotationView.configureButton(title: "Remove Stop", icon: .icTrash)
    } else {
      annotationView.configureButton(title: "Add Stop", icon: .icPlus)
    }
  }
}

extension HistoryDetailVC {
  func setViewModel(_ viewModel: HistoryDetailVM) {
    self.viewModel = viewModel
  }
}
