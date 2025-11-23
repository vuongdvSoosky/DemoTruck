//
//  SaveRouteDetailVC.swift
//  SooskyTruckGPS
//
//  Created by VuongDv on 21/11/25.
//

import UIKit
import SnapKit
import MapKit

class SaveRouteDetailVC: BaseViewController {
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
  
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 4
    
    [iconButtonView, titleButtonView].forEach({stackView.addArrangedSubview($0)})
    
    view.addSubviews(stackView)
    
    stackView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    
    return view
  }()
  
  private lazy var iconButtonView: UIImageView = {
    let icon = UIImageView()
    icon.contentMode = .scaleAspectFit
    icon.image = .icCaculatoRoute
    icon.isHidden = true
    return icon
  }()
  
  private lazy var titleButtonView: UILabel = {
    let label = UILabel()
    label.text = "GO"
    label.textColor = UIColor(rgb: 0xFFFFFF)
    label.font = AppFont.font(.boldText, size: 20)
    return label
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
  
  private var viewModel: SaveRouteDetailVM!
  
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
       searchNearby()
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
        LogManager.show(self.arrayPlaces.count)
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
        self.updateAnnotations(for:  places.places)
      }.store(in: &subscriptions)
    
    viewModel.index
      .receive(on: DispatchQueue.main)
      .sink { [weak self] index in
        guard let self else {
          return
        }
        collectionView.reloadData()
      }.store(in: &subscriptions)
    
    viewModel.actionEditLocation
      .receive(on: DispatchQueue.main)
      .sink { [weak self]  in
        guard let self else {
          return
        }
        titleButtonView.text = "Calculate Best Route"
        iconButtonView.isHidden = false
      }.store(in: &subscriptions)
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
      let isInPlaceGroup = PlaceManager.shared.isExistLocation(place)
      
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
  
  private func searchNearby(with nameService: String = "", type: String = "") {
    MapManager.shared.searchServiceAroundVisibleRegion(nameService, type: type) { items in
//      LogManager.show("Tìm thấy \(items.count) kết quả cho \(self.currentQuery)")
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
      make.bottom.equalToSuperview().inset(20)
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
    if PlaceManager.shared.isExistLocation(place) {
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
    if PlaceManager.shared.isExistLocation(place) {
      annotationView.configureButton(title: "Remove Stop", icon: .icTrash)
    } else {
      annotationView.configureButton(title: "Add Stop", icon: .icPlus)
    }
  }
}

// MARK: - MapView Delegate
extension SaveRouteDetailVC: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    // debounce tránh spam search khi người dùng kéo bản đồ liên tục
    searchDelayTimer?.invalidate()
    searchDelayTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
       self?.searchNearby(with: self?.currentQuery ?? "", type: self?.currentType ?? "")
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

// MARK: UITextFieldDelegate
extension SaveRouteDetailVC: UITextFieldDelegate {
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
          
          let annotation = CustomAnnotation(coordinate: coordinate, title: title, subtitle: subtitle, type: "parking", id: keyword)
          self.mapView.addAnnotation(annotation)
  
          // Hiển thị tooltip sau khi tìm kiếm
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.showTooltipForAnnotation(annotation)
          }
        }
      }
      return true
    }
}

// MARK: - Action

extension SaveRouteDetailVC {
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
    if viewModel.isEditLocation {
      viewModel.action.send(.caculatorRoute)
    } else {
      viewModel.action.send(.go)
    }
  }
}

// MARK: - UITableView
extension SaveRouteDetailVC: UITableViewDelegate, UITableViewDataSource {
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
        
        // Hiển thị tooltip sau khi chọn trong tableView
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
          self.showTooltipForAnnotation(annotation)
        }
      }
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
  }
}

extension SaveRouteDetailVC: MKLocalSearchCompleterDelegate {
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

extension SaveRouteDetailVC {
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

extension SaveRouteDetailVC: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let item = ServiceType.allCases[indexPath.row]
    self.searchNearby(with: item.name, type: item.title)
    self.currentQuery = item.name
    self.currentType = item.title
    viewModel.action.send(.getIndex(int: indexPath.row))
  }
}

extension SaveRouteDetailVC: UICollectionViewDataSource {
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

extension SaveRouteDetailVC: CustomAnnotationViewDelagate {
  func customAnnotationView(_ annotationView: CustomAnnotationView, place: Place?) {
    guard let place = place else { return }
    let wasInPlaceGroup = PlaceManager.shared.isExistLocation(place)
    PlaceManager.shared.addLocationToArray(place)
    viewModel.action.send(.actionEditLocation)
    let isInPlaceGroup = PlaceManager.shared.isExistLocation(place)
    
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

extension SaveRouteDetailVC {
  func setViewModel(_ viewModel: SaveRouteDetailVM) {
    self.viewModel = viewModel
  }
}
