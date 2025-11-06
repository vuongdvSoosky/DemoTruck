//
//  TruckVC.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 3/11/25.
//

import UIKit
import SnapKit
import MapKit

class TruckVC: BaseViewController {
  private lazy var mapView: MKMapView = {
    let view = MKMapView()
    view.translatesAutoresizingMaskIntoConstraints = false
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
    
    [iconSearch, searchTextField].forEach({view.addSubview($0)})
    
    iconSearch.snp.makeConstraints { make in
      make.width.height.equalTo(24)
      make.centerY.equalToSuperview()
      make.left.equalToSuperview().offset(12)
    }
    
    searchTextField.snp.makeConstraints { make in
      make.left.equalTo(iconSearch.snp.right).offset(8)
      make.centerY.equalToSuperview()
      make.right.equalToSuperview().offset(-12)
    }
    
    return view
  }()
  
  private lazy var arrayPlaces: [Place] = []
  private var currentPlace: Place?
  
  private lazy var searchTextField: UITextField = {
    let textField = UITextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.placeholder = "Search here"
    return textField
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
  // gas station, bank, car wash, supermarket, pharmacy, fast food
  private var address: String = ""
  
  private var currentQuery = "fast food"
  private var searchDelayTimer: Timer?
  private var pendingAnnotation: MKAnnotation?
  private var isProgrammaticRegionChange = false
  
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
  
  private let viewModel = TruckViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupMap()
  }
  
  override func setProperties() {
    searchTextField.delegate = self
    searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapCloseCalloutView)))
  }
  
  private func setupMap() {
    MapManager.shared.attachMap(to: mapView)
    mapView.delegate = self
    // Lấy vị trí hiện tại và hiển thị dịch vụ xung quanh
    MapManager.shared.requestUserLocation { [weak self] location in
      guard let self = self, let location = location else { return }
      MapManager.shared.centerMap(on: location, zoom: 0.05)
      // self.searchNearby()
    }
  }
  
  override func binding() {
    PlaceManager.shared.$places
      .receive(on: DispatchQueue.main)
      .sink { [weak self] places in
        guard let self else {
          return
        }
        self.arrayPlaces = places
        if self.arrayPlaces.isEmpty {
          hideCalloutAnimated()
        }
        self.updateAnnotations()
      }.store(in: &subscriptions)
  }
  
  private func updateAnnotations() {
    // Xoá các annotation cũ trừ vị trí người dùng
    let nonUserAnnotations = mapView.annotations.filter { !($0 is MKUserLocation) }
    mapView.removeAnnotations(nonUserAnnotations)
    
    // Tạo annotation mới từ arrayPlaces
    let annotations = arrayPlaces.map { place -> CustomAnnotation in
      return CustomAnnotation(
        coordinate: place.coordinate,
        type: "parking", // hoặc tuỳ type bạn có trong Place
        titlePlace: place.address
      )
    }
    
    mapView.addAnnotations(annotations)
  }
  
  private func searchNearby() {
    MapManager.shared.searchServiceAroundVisibleRegion(currentQuery) { items in
      LogManager.show("Tìm thấy \(items.count) kết quả cho \(self.currentQuery)")
    }
  }
  
  override func addComponents() {
    self.view.addSubviews(mapView, searchView, currentCalloutView, viewList)
  }
  
  override func setConstraints() {
    mapView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    searchView.snp.makeConstraints { make in
      make.top.equalTo(self.view.snp.topMargin).inset(15)
      make.height.equalTo(48)
      make.left.right.equalToSuperview().inset(20)
    }
    
    currentCalloutView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview().offset(-100)
      make.width.equalTo(210)
      make.height.equalTo(100)
    }
    
    viewList.snp.makeConstraints { make in
      make.bottom.equalToSuperview().inset(110)
      make.centerX.equalToSuperview()
      make.width.equalTo(111)
      make.height.equalTo(47)
    }
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
      // isProgrammaticRegionChange = true
    })
  }
}

// MARK: - MapView Delegate
extension TruckVC: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    // debounce tránh spam search khi người dùng kéo bản đồ liên tục
    //        searchDelayTimer?.invalidate()
    //        searchDelayTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
    //          // self?.searchNearby()
    //        }
   // isProgrammaticRegionChange = false
  }
  
  func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
//    if !isProgrammaticRegionChange {
//      hideCalloutAnimated()
//    }
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

// MARK: UITextFieldDelegate

extension TruckVC: UITextFieldDelegate {
  @objc private func textFieldDidChange(_ textField: UITextField) {
    guard let text = textField.text else {
      return
    }
    self.address = text
    // 410 ATLANTIC AVE, BROOKLYN
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    guard let keyword = textField.text, !keyword.isEmpty else { return true }
    
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = keyword
    let search = MKLocalSearch(request: request)
    request.region = mapView.region
    search.start { [weak self] response, error in
      guard let self = self,
            let coordinate = response?.mapItems.first?.placemark.coordinate else { return }
      
      // Di chuyển map để location nằm ở trung tâm
      DispatchQueue.main.async {
        let region = MKCoordinateRegion(
          center: coordinate,
          latitudinalMeters: 200,
          longitudinalMeters: 200
        )
        self.mapView.setRegion(region, animated: true)
        
        let annotation = CustomAnnotation(coordinate: coordinate, type: "parking", titlePlace: keyword)
        self.mapView.addAnnotation(annotation)
        self.pendingAnnotation = annotation
        self.currentPlace = Place(address: keyword, fullAddres: keyword , coordinate: coordinate)
        self.currentCalloutView.configureButton(title: "Add Stop", icon: .icPlus)
        self.showCalloutAnimated()
      }
    }
    return true
  }
}

// MARK: - Action

extension TruckVC {
  @objc private func annotationTapped(_ sender: UITapGestureRecognizer) {
    guard let annotationView = sender.view as? MKAnnotationView,
          let annotation = annotationView.annotation as? CustomAnnotation else { return }
    // xử lý hành vi khi bấm vào pin
    pendingAnnotation = annotation
    mapView.setCenter(annotation.coordinate, animated: true)
    
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
  
  @objc private func onTapCloseCalloutView() {
    hideCalloutAnimated()
  }
  
  @objc private func onTapViewlist() {
    viewModel.action.send(.viewList)
    hideCalloutAnimated()
  }
}
