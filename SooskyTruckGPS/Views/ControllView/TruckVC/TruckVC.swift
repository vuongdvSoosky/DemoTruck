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
  
  private lazy var searchTextField: UITextField = {
    let textField = UITextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.placeholder = "Search here"
    return textField
  }()
  // gas station, bank, car wash, supermarket, pharmacy, fast food
  private var address: String = ""
  
  private var currentQuery = "fast food"
  private var searchDelayTimer: Timer?
  private var currentCalloutView: CustomAnnotationCalloutView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupMap()
  }
  
  override func setProperties() {
    searchTextField.delegate = self
    searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
  }
  
  private func setupMap() {
    MapManager.shared.attachMap(to: mapView)
    mapView.delegate = self
    // Lấy vị trí hiện tại và hiển thị dịch vụ xung quanh
    //    MapManager.shared.requestUserLocation { [weak self] location in
    //      guard let self = self, let location = location else { return }
    //      MapManager.shared.centerMap(on: location, zoom: 0.05)
    //      // self.searchNearby()
    //    }
  }
  
  private func searchNearby() {
    MapManager.shared.searchServiceAroundVisibleRegion(currentQuery) { items in
      LogManager.show("Tìm thấy \(items.count) kết quả cho \(self.currentQuery)")
    }
  }
  
  override func addComponents() {
    self.view.addSubviews(mapView, searchView)
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
  }
}

// MARK: - MapView Delegate
extension TruckVC: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    // debounce tránh spam search khi người dùng kéo bản đồ liên tục
    //    searchDelayTimer?.invalidate()
    //    searchDelayTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
    //      // self?.searchNearby()
    //    }
    
    guard let superview = mapView.superview else { return }
    
    superview.subviews
      .filter { $0 is CustomAnnotationCalloutView }
      .forEach { view in
        UIView.animate(withDuration: 0.2, animations: {
          view.alpha = 0
        }) { _ in
          view.removeFromSuperview()
        }
      }
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
    return view
  }
  
  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    guard let annotation = view.annotation else { return }
    
    // Xoá popup cũ
    mapView.superview?.subviews
      .filter { $0 is CustomAnnotationCalloutView }
      .forEach { $0.removeFromSuperview() }
    
    // Tạo popup mới
    let popup = CustomAnnotationCalloutView(frame: CGRect(x: 0, y: 0, width: 220, height: 100))
    let address = self.address.shortAddress
    popup.configure(title: address)
    
    popup.onButtonTapped = {
      LogManager.show("Add Stop tapped cho \(address)")
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
      guard let self else {
        return
      }
      let point = mapView.convert(annotation.coordinate, toPointTo: mapView.superview)
      popup.center = CGPoint(x: point.x, y: point.y - view.frame.height - 60)
      
      mapView.superview?.addSubview(popup)
      
      popup.alpha = 1
      popup.transform = CGAffineTransform(translationX: 0, y: 10)
      UIView.animate(withDuration: 0.25) {
        popup.alpha = 1
        popup.transform = .identity
      }
    }
  }
  
  func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
    UIView.animate(withDuration: 0, animations: {
      mapView.subviews.filter { $0 is CustomAnnotationCalloutView }.forEach {
        $0.alpha = 0
      }
    }) { _ in
      mapView.subviews.filter { $0 is CustomAnnotationCalloutView }.forEach { $0.removeFromSuperview() }
    }
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
    guard let text = textField.text else { return true }
    
    
    MapManager.shared.showPin(for: text, type: "parking")
    return true
  }
}
