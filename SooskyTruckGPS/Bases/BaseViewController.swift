//
//  BaseViewController.swift
//  SooskyBabyTracker
//
//  Created by VuongDV on 9/4/25.
//

import UIKit
import Combine
import SnapKit
import MapKit

class BaseViewController: UIViewController, ViewProtocol {
  private var taskLoadingView = TaskLoadingView()
  var subscriptions = Set<AnyCancellable>()
  var diaperValidationSubscription: AnyCancellable?
  private var didSetInitialRegion = false
  
  private lazy var notiView: NotiView = {
    let view = NotiView()
    
    return view
  }()
  
  private var didShowNoInternet: Bool = false
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    addComponents()
    setConstraints()
    setProperties()
    binding()
    setupAction()
    setupNotiView()
    hideButtonItem()
    self.bindingInternet()
    DispatchQueue.main.async { [weak self] in
      guard let self else {
        return
      }
      setColor()
    }
  }
  
  deinit {
    removeSubs()
    // Force cleanup any remaining subscriptions
    diaperValidationSubscription?.cancel()
    diaperValidationSubscription = nil
    LogManager.show("\(String(describing: type(of: self))) deallocated")
    resetData()
  }
  
  func addComponents() {}
  
  func setConstraints() {}
  
  func setProperties() {}
  
  func setColor() {}
  
  func binding() {}
  
  func setupAction() {}
  
  func resetData() {}
  
  func hideButtonItem() {
    self.navigationItem.leftBarButtonItem = nil
    self.navigationItem.hidesBackButton = true
  }
  
  //  func showCurrentLocation(_ mapView: MKMapView) {
  //    LocationService.shared.checkAndRequestAuthorization { [weak self] status in
  //      guard let self = self else { return }
  //
  //      switch status {
  //      case .authorizedWhenInUse, .authorizedAlways:
  //        LocationService.shared.requestCurrentLocation { location in
  //          let coordinate = location.coordinate
  //
  //          DispatchQueue.main.async {
  //            let region = MKCoordinateRegion(center: coordinate,
  //                                            latitudinalMeters: 1000,
  //                                            longitudinalMeters: 1000)
  //
  //            mapView.setRegion(region, animated: true)
  //          }
  //        }
  //        UserDefaultsManager.shared.set(true, key: .requestLocation)
  //
  //      case .denied, .restricted:
  //        DispatchQueue.main.async {
  //          LocationService.shared.showSettingsAlert(from: self)
  //        }
  //        UserDefaultsManager.shared.set(false, key: .requestLocation)
  //
  //      case .notDetermined:
  //        break
  //
  //      @unknown default:
  //        break
  //      }
  //    }
  //  }
  
  func showCurrentLocation(_ mapView: MKMapView) {
    LocationService.shared.checkAndRequestAuthorization { [weak self] status in
      guard let self else { return }
      
      switch status {
      case .authorizedWhenInUse, .authorizedAlways:
        LocationService.shared.requestCurrentLocation { [weak self] location in
          guard let self else { return }
          let coordinate = location.coordinate
          
          DispatchQueue.main.async {
            if !self.didSetInitialRegion {
              self.didSetInitialRegion = true
              
              let region = MKCoordinateRegion(center: coordinate,
                                              latitudinalMeters: 1500,
                                              longitudinalMeters: 1500)
              mapView.setRegion(region, animated: true)
              mapView.setUserTrackingMode(.follow, animated: true)
            } else {
              mapView.setCenter(coordinate, animated: true)
            }
          }
        }
        UserDefaultsManager.shared.set(true, key: .requestLocation)
      case .denied, .restricted:
        LocationService.shared.showSettingsAlert(from: self)
        UserDefaultsManager.shared.set(false, key: .requestLocation)
        
      case .notDetermined: break
      @unknown default: break
      }
    }
  }
  
  func removeSubs() {
    subscriptions.forEach { $0.cancel() }
    subscriptions.removeAll()
  }
  
  func showLoading(at view: UIView, alpha: Double = 0.6) {
    taskLoadingView.showView(view: view)
    taskLoadingView.setAlpha(alpha: alpha)
  }
  
  func removeLoading() {
    taskLoadingView.removeFromSuperview()
  }
  
  func setupNotiView() {
    view.addSubview(notiView)
    notiView.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-200)
      make.leading.equalToSuperview().offset(20)
      make.trailing.equalToSuperview().offset(-20)
      make.height.equalTo(100)
    }
    
    DispatchQueue.main.async {[weak self] in
      guard let self else {
        return
      }
      
      notiView.addShadow(color: UIColor(rgb: 0x7A7A7A))
      notiView.addCornerRadius(radius: 12)
    }
  }
  
  func bindingInternet() {
    NetworkMonitor.shared.$isConnected
      .receive(on: DispatchQueue.main)
      .sink { [weak self] value in
        guard let self = self else {
          return
        }
        if value == false {
          self.showNoConnectionView()
        }
      }.store(in: &subscriptions)
  }
  
  private func showNoConnectionView() {}
  
  func showAlertRemoveSession(_ completionHandler: (() -> Void)? = nil) {
    let alert = UIAlertController(title: "Delete This Session?",
                                  message: "Are you sure you would like delete this session?",
                                  preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
      completionHandler?()
    })
    
    present(alert, animated: true)
  }
}

extension BaseViewController {
  func showNotiView() {
    notiView.snp.remakeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
      make.leading.equalToSuperview().offset(20)
      make.trailing.equalToSuperview().offset(-20)
      make.height.equalTo(100)
    }
    
    UIView.animate(withDuration: 0.4) {
      self.view.layoutIfNeeded()
    }
  }
  
  func closeNotiView() {
    notiView.snp.remakeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-200)
      make.leading.equalToSuperview().offset(20)
      make.trailing.equalToSuperview().offset(-20)
      make.height.equalTo(100)
    }
    
    UIView.animate(withDuration: 0.4) {
      self.view.layoutIfNeeded()
    }
  }
}
