//
//  StoreManager.swift
//  BaseSubscription
//
//  Created by HaiTu on 6/1/25.
//

import StoreKit
import UIKit

enum RegisteredPurchase: String {
  case weekly = "weekly1"
  case yearly = "yearly1"
  case monthly = "monthly1"
}

extension Notification.Name{
  static let offSub = Notification.Name("offSub")
  static let subscriptionExpired = Notification.Name("subscriptionExpired")
  static let subscriptionStatusChanged = Notification.Name("subscriptionStatusChanged")
}

class StoreManager: UIViewController {
  static let share = StoreManager()
  
  private(set) var products: [Product] = []
  private(set) var purchasedProductIDs = Set<String>()
  let appBundleId = Bundle.main.bundleIdentifier!
  
  // timer loading purchase
  var appPurchaseTimer: Timer?
  var appPurchaseTimeInSeconds: Int = 0
  let maxAppPurchaseTimeInSeconds: Int = 15
  
  var currentExpirationDate: Date?
  
  // Real-time monitoring properties
  private var subscriptionMonitorTimer: Timer?
  private var transactionUpdateTask: Task<Void, Never>?
  private var isMonitoringActive = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    Task {
      do {
        try await fetchProducts()
        LogManager.show("Fetched products successfully!")
        startRealTimeMonitoring()
      } catch {
        LogManager.show("Failed to fetch products: \(error.localizedDescription)")
      }
    }
  }
  
  deinit {
    stopRealTimeMonitoring()
  }
  
  func fetchProducts() async throws {
    let fetchedProducts = try await Product.products(for: Set([
      self.appBundleId + "." + RegisteredPurchase.weekly.rawValue,
      self.appBundleId + "." + RegisteredPurchase.yearly.rawValue,
      self.appBundleId + "." + RegisteredPurchase.monthly.rawValue
    ]))
    
    // Fetch product
    self.products = fetchedProducts
    LogManager.show("\(self.products.map { $0.id})")
  }
  
  // MARK: - Real-time Monitoring
  
  func startRealTimeMonitoring() {
    guard !isMonitoringActive else { return }
    isMonitoringActive = true
    
    // Start monitoring transactions
    startTransactionObserver()
    
    // Start periodic subscription check (every 30 seconds)
    startPeriodicSubscriptionCheck()
    
    // Listen for app state changes
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(appDidBecomeActive),
      name: UIApplication.didBecomeActiveNotification,
      object: nil
    )
    
    LogManager.show("Real-time subscription monitoring started")
  }
  
  func stopRealTimeMonitoring() {
    isMonitoringActive = false
    
    // Stop timers and tasks
    subscriptionMonitorTimer?.invalidate()
    subscriptionMonitorTimer = nil
    
    transactionUpdateTask?.cancel()
    transactionUpdateTask = nil
    
    // Remove observers
    NotificationCenter.default.removeObserver(
      self,
      name: UIApplication.didBecomeActiveNotification,
      object: nil
    )
    
    LogManager.show("Real-time subscription monitoring stopped")
  }
  
  private func startTransactionObserver() {
    transactionUpdateTask = Task {
      for await result in Transaction.updates {
        await handleTransactionUpdate(result)
      }
    }
  }
  
  private func startPeriodicSubscriptionCheck() {
    subscriptionMonitorTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
      Task { @MainActor in
        await self?.checkAndUpdateSubscriptionStatus()
      }
    }
  }
  
  @objc private func appDidBecomeActive() {
    Task {
      await checkAndUpdateSubscriptionStatus()
    }
  }
  
  private func handleTransactionUpdate(_ result: VerificationResult<Transaction>) async {
    switch result {
    case .verified(let transaction):
      LogManager.show("Transaction update received: \(transaction.productID)")
      await transaction.finish()
      await updatePurchasedProducts()
    case .unverified(_, let error):
      LogManager.show("Unverified transaction update: \(error.localizedDescription)")
    }
  }
  
  private func checkAndUpdateSubscriptionStatus() async {
    let previousHasSub = AppManager.shared.hasSub
    var hasActiveSubscription = false
    var latestExpirationDate: Date?
    
    for await result in Transaction.currentEntitlements {
      switch result {
      case .verified(let transaction):
        if transaction.revocationDate == nil {
          if let expirationDate = transaction.expirationDate {
            if expirationDate > Date() {
              hasActiveSubscription = true
              if latestExpirationDate == nil || expirationDate > latestExpirationDate! {
                latestExpirationDate = expirationDate
              }
              LogManager.show("Active subscription: \(transaction.productID) until \(expirationDate)")
            } else {
              LogManager.show("Expired subscription: \(transaction.productID) on \(expirationDate)")
            }
          } else {
            // Non-subscription product (like lifetime)
            hasActiveSubscription = true
            LogManager.show("Active product: \(transaction.productID)")
          }
        }
      case .unverified(_, let error):
        LogManager.show("Failed to verify transaction: \(error.localizedDescription)")
      }
    }
    
    // Update current expiration date
    currentExpirationDate = latestExpirationDate
    
    // Update subscription status if changed
    if hasActiveSubscription != previousHasSub {
      await MainActor.run {
        if hasActiveSubscription {
          purchaseAndRestoreSuccess()
          LogManager.show("Subscription activated in real-time")
        } else {
          purchaseFailed()
          LogManager.show("Subscription expired in real-time")
          
          // Post notification for subscription expiration
          NotificationCenter.default.post(name: .subscriptionExpired, object: nil)
        }
        
        // Post general status change notification
        NotificationCenter.default.post(
          name: .subscriptionStatusChanged,
          object: nil,
          userInfo: ["hasActiveSubscription": hasActiveSubscription]
        )
      }
    }
  }
  
  // MARK: - Purchase Methods
  
  func purchaseProduct(type: RegisteredPurchase) {
    // Find object from `products`
    LogManager.show(self.products)
    guard let product = products.first(where: { $0.id == self.appBundleId + "." + type.rawValue }) else {
      LogManager.show("Product not exist!")
      return
    }
    
    self.activityStartAnimating()
    self.startPurchaseTimer()
    
    // Purchase processing
    Task {
      do {
        self.stopPurchaseTimer()
        var result: Product.PurchaseResult?
        if #available(iOS 18.2, *) {
          result = try await product.purchase(confirmIn: self)
        } else if #available(iOS 17.0, *) {
          let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
          if let scene {
            result = try await product.purchase(confirmIn: scene)
          }
        } else {
          // Fallback on earlier versions
          result = try await product.purchase()
        }
        
        switch result {
        case .success(let verification):
          switch verification {
          case .verified(let transaction):
            LogManager.show("Purchase success: \(transaction.productID)")
            await transaction.finish()
            await self.updatePurchasedProducts()
            
            self.showCustomAlert(CustomAlertPropeties(status: true, description: "Purchase success")) {
              self.offSub()
            }
          case .unverified(_, let error):
            LogManager.show("Verified failed: \(error.localizedDescription)")
            self.showCustomAlert(CustomAlertPropeties(status: false, description: "Verified failed: \(error.localizedDescription)")) {}
          }
        case .userCancelled:
          LogManager.show("User Cancelled")
        case .pending:
          LogManager.show("transaction pending")
          self.showCustomAlert(CustomAlertPropeties(status: false, description: "Transaction Pending")) {}
        case .none:
          LogManager.show("Unknow error")
          self.showCustomAlert(CustomAlertPropeties(status: false, description: "Unknow Error")) {}
        @unknown default:
          LogManager.show("Unknow error")
          self.showCustomAlert(CustomAlertPropeties(status: false, description: "Unknow Error")) {}
        }
        self.activityStopAnimating()
        self.stopPurchaseTimer()
      } catch {
        LogManager.show("Purchase failed: \(error.localizedDescription)")
        self.activityStopAnimating()
        self.stopPurchaseTimer()
        self.showCustomAlert(CustomAlertPropeties(status: false, description: "Purchase failed: \(error.localizedDescription)")) {}
      }
    }
  }
  
  // Restore
  func restorePurchases() async {
    self.activityStartAnimating()
    do {
      try await AppStore.sync()
      for await transaction in Transaction.currentEntitlements {
        switch transaction {
        case .verified(let verifiedTransaction):
          if verifiedTransaction.revocationDate == nil {
            LogManager.show("Restore successfuly: \(verifiedTransaction.productID)")
            await handleRestoredTransaction(verifiedTransaction)
            self.showCustomAlert(CustomAlertPropeties(status: true, description: "All purchases have been restored")) {
              self.offSub()
            }
          }
        case .unverified(_, let error):
          LogManager.show("Unverified: \(error.localizedDescription)")
          self.showCustomAlert(CustomAlertPropeties(status: true, description: "Receipt verification failed: \(error.localizedDescription)")) {}
        }
        self.activityStopAnimating()
        return
      }
    } catch {
      LogManager.show("Restore failed: \(error.localizedDescription)")
      self.activityStopAnimating()
      self.showCustomAlert(CustomAlertPropeties(status: false, description: "Restore failed")) {}
      return
    }
    activityStopAnimating()
    self.showCustomAlert(CustomAlertPropeties(status: false, description: "Nothing to restore")) {}
  }
  
  // Restore processing
  func handleRestoredTransaction(_ transaction: Transaction) async {
    // transaction finish
    await transaction.finish()
    
    // check if subscription is registered
    if let subscription = RegisteredPurchase(rawValue: transaction.productID) {
      // Success
      LogManager.show("Restored: \(subscription)")
      await updatePurchasedProducts()
    }
  }
  
  // listen transaction - Enhanced with real-time updates
  func observeTransactions() {
    // This is now handled by startTransactionObserver()
    // Keeping for backward compatibility
    Task {
      for await result in Transaction.updates {
        await handleTransactionUpdate(result)
      }
    }
  }
  
  // update transaction - Enhanced with real-time status check
  func updatePurchasedProducts() async {
    purchasedProductIDs.removeAll()
    
    for await result in Transaction.currentEntitlements {
      guard case .verified(let transaction) = result else {
        continue
      }
      
      if transaction.revocationDate == nil {
        self.purchasedProductIDs.insert(transaction.productID)
      }
    }
    
    // Trigger real-time status check
    await checkAndUpdateSubscriptionStatus()
  }
  
  // check subscription status - Enhanced version
  func checkSubscriptionStatus() async {
    await checkAndUpdateSubscriptionStatus()
  }
  
  // MARK: - verify
  
  /// Xác thực các giao dịch hiện tại, lọc theo tất cả ProductID trong RegisteredPurchase
  @discardableResult
  func verify() async -> Bool {
    var hasActiveSubscription = false
    var latestExpirationDate: Date?
    
    // Danh sách productID đầy đủ
    let validProductIDs = self.products.map { appBundleId + "." + $0.id }
    
    for await verificationResult in Transaction.currentEntitlements {
      switch verificationResult {
      case .verified(let transaction):
        // Chỉ xét productID hợp lệ
        if validProductIDs.contains(transaction.productID) {
          if transaction.revocationDate == nil {
            if let expirationDate = transaction.expirationDate {
              if expirationDate > Date() {
                hasActiveSubscription = true
                if latestExpirationDate == nil || expirationDate > latestExpirationDate! {
                  latestExpirationDate = expirationDate
                }
                LogManager.show("Active: \(transaction.productID) - expires \(expirationDate)")
                AppManager.shared.getStateSub(hasSub: true)
              } else {
                LogManager.show("Expired: \(transaction.productID) - expired \(expirationDate)")
                AppManager.shared.getStateSub(hasSub: true)
              }
            } else {
              // Non-subscription (lifetime)
              hasActiveSubscription = true
              LogManager.show("Lifetime product: \(transaction.productID)")
              AppManager.shared.getStateSub(hasSub: true)
            }
          }
        }
        await transaction.finish()
        
      case .unverified(_, let error):
        LogManager.show("Unverified transaction: \(error.localizedDescription)")
        AppManager.shared.getStateSub(hasSub: false)
      }
    }
    
    // Cập nhật ngày hết hạn
    currentExpirationDate = latestExpirationDate
    
    // Cập nhật trạng thái
    if hasActiveSubscription {
      purchaseAndRestoreSuccess()
    } else {
      purchaseFailed()
    }
    
    return hasActiveSubscription
  }
    
  // MARK: - Logic Handlers
  
  func purchaseAndRestoreSuccess() {
    AppManager.shared.getStateSub(hasSub: true)
    //    UserDefaults.standard.set(IAPDefault.appRemoveAds, forKey: IAPDefault.appRemoveAds)
    //    UserDefaults.standard.synchronize()
    //
    LogManager.show("Subscription status updated: ACTIVE")
  }
  
  func purchaseFailed() {
    AppManager.shared.getStateSub(hasSub: false)
    //    UserDefaults.standard.removeObject(forKey: IAPDefault.appRemoveAds)
    //    UserDefaults.standard.synchronize()
    //
    LogManager.show("Subscription status updated: INACTIVE")
  }
  
  func offSub() {
    //    AppManager.shared.getStateSub(hasSub: false)
    //    if UserDefaults.standard.value(forKey: IAPDefault.appIntro) == nil{
    //      UserDefaults.standard.set(IAPDefault.appIntro, forKey: IAPDefault.appIntro)
    //      let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    //      appDelegate.configRootViewController()
    //    } else {
    //      MainIntroVC.shared?.dismiss(animated: true, completion: nil)
    //    }
  }
  
  // MARK: - Timer Management
  
  func startPurchaseTimer() {
    appPurchaseTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
      guard let self = self else { return }
      
      self.appPurchaseTimeInSeconds += 1
      
      if self.appPurchaseTimeInSeconds >= self.maxAppPurchaseTimeInSeconds {
        self.activityStopAnimating()
        self.stopPurchaseTimer()
      }
    }
  }
  
  func stopPurchaseTimer() {
    appPurchaseTimer?.invalidate()
    appPurchaseTimer = nil
    appPurchaseTimeInSeconds = 0
  }
  
  // Setup Subscription Function - Enhanced
  func setupSubscription() {
    startRealTimeMonitoring()
    Task {
      await updatePurchasedProducts()
      await checkSubscriptionStatus()
    }
  }
  
  // MARK: - Public Methods for Manual Checks
  
  /// Force check subscription status manually
  func forceCheckSubscriptionStatus() {
    Task {
      await checkAndUpdateSubscriptionStatus()
    }
  }
  
  /// Get time until subscription expires
  func getTimeUntilExpiration() -> TimeInterval? {
    guard let expirationDate = currentExpirationDate else { return nil }
    return expirationDate.timeIntervalSinceNow
  }
  
  /// Check if subscription will expire soon (within 24 hours)
  func isSubscriptionExpiringSoon() -> Bool {
    guard let timeUntilExpiration = getTimeUntilExpiration() else { return false }
    return timeUntilExpiration > 0 && timeUntilExpiration <= 86400 // 24 hours
  }
}

// MARK: - Extensions

extension StoreManager {
  struct CustomAlertPropeties {
    var status: Bool
    var description: String
  }
  
  func showCustomAlert(_ value: CustomAlertPropeties, handle: (() -> Void)?) {
    let vc = PopupVC()
    vc.configData(status: value.status, description: value.description, handle: { [weak self] in
      guard let self else { return }
      handle?()
    })
    vc.modalPresentationStyle = .overCurrentContext
    vc.modalTransitionStyle = .crossDissolve
    self.present(vc, animated: true)
  }
}

// MARK: - Usage Example for ViewControllers

/*
 // In your ViewControllers, you can listen for subscription changes:
 
 class YourViewController: UIViewController {
 
 override func viewDidLoad() {
 super.viewDidLoad()
 
 // Listen for subscription status changes
 NotificationCenter.default.addObserver(
 self,
 selector: #selector(subscriptionStatusChanged),
 name: .subscriptionStatusChanged,
 object: nil
 )
 
 // Listen for subscription expiration
 NotificationCenter.default.addObserver(
 self,
 selector: #selector(subscriptionExpired),
 name: .subscriptionExpired,
 object: nil
 )
 }
 
 @objc private func subscriptionStatusChanged(_ notification: Notification) {
 if let hasActiveSubscription = notification.userInfo?["hasActiveSubscription"] as? Bool {
 DispatchQueue.main.async {
 // Update UI based on subscription status
 self.updateUIForSubscription(isActive: hasActiveSubscription)
 }
 }
 }
 
 @objc private func subscriptionExpired() {
 DispatchQueue.main.async {
 // Handle subscription expiration
 self.showSubscriptionExpiredAlert()
 }
 }
 
 private func updateUIForSubscription(isActive: Bool) {
 // Update your UI elements here
 // For example: hide/show ads, enable/disable premium features
 }
 
 private func showSubscriptionExpiredAlert() {
 // Show alert to user about expired subscription
 }
 }
 
 // OR Check with "AppManager.shared.hasSub" variable
 */
