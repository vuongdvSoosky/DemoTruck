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
  
  private lazy var routeStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.addArrangedSubview(caculatorRouteView)
    stackView.cornerRadius = 20
    stackView.layer.masksToBounds = true
    return stackView
  }()
  
  private lazy var tableView: UITableView = {
    let tableView = UITableView()
    
    return tableView
  }()
  
  private lazy var arrayPlaces: [Place] = []
  var currentTooltipView: CustomAnnotationView?
  var currentTooltipID: String?
  
  private lazy var searchTextField: UITextField = {
    let textField = UITextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.placeholder = "Search here"
    return textField
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
  private var desAdress: String = ""
  
  private var currentQuery = ""
  private var currentType = ""
  private var searchDelayTimer: Timer?
  private var pendingAnnotation: MKAnnotation?
  private var isProgrammaticRegionChange = false
  
  private let viewModel = TruckViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupMap()
    setupTableView()
    setupSearchCompleter()
  }
  
  override func setProperties() {
    searchTextField.delegate = self
    searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapCloseCalloutView(_:)))
    tapGesture.cancelsTouchesInView = false
    view.addGestureRecognizer(tapGesture)
    
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.register(cell: ItemServiceCell.self)
  }
  
  private func setupMap() {
    MapManager.shared.attachMap(to: mapView)
    mapView.delegate = self
    // Lấy vị trí hiện tại và hiển thị dịch vụ xung quanh
    MapManager.shared.requestUserLocation { [weak self] location in
      guard let self = self, let location = location else { return }
      MapManager.shared.centerMap(on: location, zoom: 0.02)
      // self.searchNearby()
    }
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
            routeStackView.layoutIfNeeded()
            let colors = [UIColor(rgb: 0xF28E01), UIColor(rgb: 0xF26101)]
            routeStackView.addArrayColorGradient(arrayColor: colors, startPoint: CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5))
          }
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
        existingAnnotation.type = "Location"
        
        if let annotationView = mapView.view(for: existingAnnotation) as? CustomAnnotationView {
          switch existingAnnotation.type {
          case "Location":
            annotationView.image = .icLocationStop
          default:
            annotationView.image = .icLocationEmpty
          }
          
          if currentTooltipView?.annotationID == existingAnnotation.id {
            annotationView.configure(title: existingAnnotation.title ?? "", des: existingAnnotation.subtitle ?? "")
          }
        }
      } else {
        // Thêm mới annotation
        let newAnnotation = CustomAnnotation(
          coordinate: place.coordinate,
          title: place.address,
          subtitle: place.fullAddres,
          type: "Location",
          id: place.id
        )
        mapView.addAnnotation(newAnnotation)
      }
    }
  }
  
  private func searchNearby(with nameService: String = "", type: String = "") {
    MapManager.shared.searchServiceAroundVisibleRegion(nameService, type: type) { items in
      LogManager.show("Tìm thấy \(items.count) kết quả cho \(self.currentQuery)")
    }
  }
  
  private func setupTableView() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.registerCell(HomeSearchCell.self)
    tableView.backgroundColor = .clear
    tableView.showsVerticalScrollIndicator = false
    tableView.showsHorizontalScrollIndicator = false
    tableView.isHidden = true
    tableView.separatorInset = UIEdgeInsets(top: 0, left: 21, bottom: 0, right: 21)
    
    tableView.setShadow(
      radius: 6,
      opacity: 1,
      offset: CGSize(width: 0, height: 3)
    )
    tableView.setRoundCorners(corners: .allCorners, radius: 12)
  }
  private func setupSearchCompleter() {
    viewModel.searchCompleter.delegate = self
    viewModel.searchCompleter.region = MKCoordinateRegion()
    viewModel.searchCompleter.resultTypes = .address
  }
  
  override func addComponents() {
    self.view.addSubviews(mapView, searchView, viewList, routeStackView, collectionView, tableView)
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
    
    collectionView.snp.makeConstraints { make in
      make.top.equalTo(searchView.snp.bottom).offset(12)
      make.left.equalToSuperview().inset(16)
      make.right.equalToSuperview()
      make.height.equalTo(56)
    }
    
    viewList.snp.makeConstraints { make in
      make.bottom.equalTo(routeStackView.snp.top).inset(-12)
      make.centerX.equalToSuperview()
      make.width.equalTo(111)
      make.height.equalTo(47)
    }
    
    routeStackView.snp.makeConstraints { make in
      make.bottom.equalToSuperview().inset(110)
      make.left.right.equalToSuperview().inset(20)
    }
    
    caculatorRouteView.snp.makeConstraints { make in
      make.height.equalTo(60)
    }
    
    tableView.snp.makeConstraints { make in
      make.top.equalTo(searchView.snp.bottom).offset(8)
      make.left.equalToSuperview().offset(20)
      make.centerX.equalToSuperview()
      make.height.equalTo(288)
    }
  }
  
  @objc private func annotationTapped(_ sender: UITapGestureRecognizer) {
    guard let customView = sender.view as? CustomAnnotationView,
          let anno = customView.annotation as? CustomAnnotation else { return }
    
    if let current = currentTooltipView, current.annotationID != customView.annotationID {
      current.hideTooltip()
    }
    
    currentTooltipView = customView
    customView.showTooltip()
    
    // luôn update UI theo annotation mới nhất
    currentTooltipView?.configure(title: anno.title ?? "", des: anno.subtitle ?? "")
  }
}

// MARK: - MapView Delegate
extension TruckVC: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    // debounce tránh spam search khi người dùng kéo bản đồ liên tục
    searchDelayTimer?.invalidate()
    searchDelayTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
      // self?.searchNearby(with: self?.currentQuery ?? "", type: self?.currentType ?? "")
    }
  }
  
  
  func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
    guard let first = views.first as? CustomAnnotationView else { return }
    
    // Nếu hiện không có tooltip nào, tự show tooltip đầu tiên
    if currentTooltipView == nil {
      first.showTooltip()
      currentTooltipView = first
    }
  }
  
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if annotation is MKUserLocation { return nil }
    
    // MARK: - CustomAnnotation
    if let customAnno = annotation as? CustomAnnotation {
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
      default:
        view?.image = .icLocationEmpty
      }
      
      // Tap gesture
      if view?.gestureRecognizers?.isEmpty ?? true {
        let tap = UITapGestureRecognizer(target: self, action: #selector(annotationTapped(_:)))
        view?.addGestureRecognizer(tap)
      }
      
      return view
    }
    
    // MARK: - CustomServiceAnimation
    else if let customService = annotation as? CustomServiceAnimation {
      let identifier = customService.id
      var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
      
      if view == nil {
        view = MKAnnotationView(annotation: customService, reuseIdentifier: identifier)
      } else {
        view?.annotation = customService
      }
      
      // Chọn icon dựa vào type
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
      
      return view
    }
    
    return nil
  }
}

// MARK: UITextFieldDelegate
extension TruckVC: UITextFieldDelegate {
  @objc private func textFieldDidChange(_ textField: UITextField) {
    guard let text = textField.text else {
      tableView.isHidden = true
      viewModel.searchSuggestions.removeAll()
      tableView.reloadData()
      return
    }
    self.address = text
    // 410 ATLANTIC AVE, BROOKLYN
    viewModel.searchCompleter.queryFragment = text
    tableView.isHidden = false
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    guard let keyword = textField.text, !keyword.isEmpty else { return true }
    tableView.isHidden = true
    
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = keyword
    let search = MKLocalSearch(request: request)
    request.region = mapView.region
    
    search.start { [weak self] response, error in
      guard let self = self,
            let coordinate = response?.mapItems.first?.placemark.coordinate else { return }
      DispatchQueue.main.async {
        let region = MKCoordinateRegion(
          center: coordinate,
          latitudinalMeters: 200,
          longitudinalMeters: 200
        )
        self.mapView.setRegion(region, animated: true)
        
        let annotation = CustomAnnotation(coordinate: coordinate, title: keyword , subtitle: keyword, type: "parking", id: keyword)
        self.mapView.addAnnotation(annotation)
      }
    }
    return true
  }
}

// MARK: - Action

extension TruckVC {
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
  
  @objc private func onTapViewlist() {
    viewModel.action.send(.viewList)
  }
  
  @objc private func onTapCaculatorRoute() {
    viewModel.action.send(.caculatorRoute)
  }
}

// MARK: - UITableView
extension TruckVC: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.searchSuggestions.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(HomeSearchCell.self, for: indexPath)
    cell.backgroundColor = .white
    cell.selectionStyle = .none
    
    let data = viewModel.searchSuggestions[indexPath.row]
    cell.configData(data: data)
    tableView.snp.updateConstraints { make in
      make.top.equalTo(searchView.snp.bottom).offset(8)
      make.left.equalToSuperview().offset(20)
      make.centerX.equalToSuperview()
      if viewModel.searchSuggestions.count >= 4 {
        make.height.equalTo(288)
      } else {
        make.height.equalTo(60 * viewModel.searchSuggestions.count)
      }
    }
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard indexPath.row < viewModel.searchSuggestions.count else { return }
    let dataSuggestion = viewModel.searchSuggestions[indexPath.row]
    searchTextField.text = dataSuggestion.title
    searchTextField.resignFirstResponder()
    tableView.isHidden = true
    
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = dataSuggestion.title
    let search = MKLocalSearch(request: request)
    search.start { [weak self] response, error in
      guard let self = self,
            let coordinate = response?.mapItems.first?.placemark.coordinate else { return }
      DispatchQueue.main.async {
        let region = MKCoordinateRegion(
          center: coordinate,
          latitudinalMeters: 200,
          longitudinalMeters: 200
        )
        self.mapView.setRegion(region, animated: true)
        
        let annotation = CustomAnnotation(coordinate: coordinate, title: dataSuggestion.title , subtitle: dataSuggestion.subtitle, type: "", id:  dataSuggestion.title)
        self.mapView.addAnnotation(annotation)
      }
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
  }
}

extension TruckVC: MKLocalSearchCompleterDelegate {
  func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
    if completer.results.isEmpty {
      tableView.isHidden = true
    } else {
      viewModel.searchSuggestions = completer.results
    }
    tableView.reloadData()
  }
  
  func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
    LogManager.show("Completer error: \(error.localizedDescription)")
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
    let item = ServiceType.allCases[indexPath.row]
    self.searchNearby(with: item.name, type: item.title)
    self.currentQuery = item.name
    self.currentType = item.title
    viewModel.action.send(.getIndex(int: indexPath.row))
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
    PlaceManager.shared.addLocationToArray(place)
    
    if PlaceManager.shared.isExistLocation(place) {
      annotationView.configureButton(title: "Remove Stop", icon: .icTrash)
    } else {
      annotationView.configureButton(title: "Add Stop", icon: .icPlus)
    }
  }
}
