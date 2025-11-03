import UIKit
import SafariServices
import MessageUI
import StoreKit
import SnapKit

class SettingsVC: BaseViewController {
  private lazy var titleVC: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Settings"
    label.textColor = UIColor(rgb: 0x1A1A1A)
    label.font = AppFont.font(.boldText, size: 28)
    return label
  }()
  
  private lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumLineSpacing = 24
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.showsVerticalScrollIndicator = false
    collectionView.isScrollEnabled = true
    return collectionView
  }()
  
  private lazy var icPremium: UIImageView = {
    let image = UIImageView()
    image.translatesAutoresizingMaskIntoConstraints = false
//    image.image = .icPremium
    image.isUserInteractionEnabled = true
    image.isHidden = true
    return image
  }()
  
  private lazy var bannerView: UIView = {
    let view = UIView()
    return view
  }()
  
  
  private let viewModel = SettingsViewModel()
    
  private var isLoadFaildNativeAd: Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    setupBanner()
    AppManager.shared.setStateShouldShowOpenAds(true)
  }
  
  override func binding() {
    AppManager.shared.$hasSub
      .receive(on: DispatchQueue.main)
      .sink { [weak self] hasSub in
        guard let self else {
          return
        }
        icPremium.isHidden = hasSub
      }.store(in: &subscriptions)
  }
  
  override func setProperties() {
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.register(cell: SettingCell.self)
  }
  
  override func addComponents() {
    self.view.addSubviews(titleVC)
    self.view.addSubviews(collectionView)
    self.view.addSubviews(icPremium)
    self.view.addSubviews(bannerView)
  }
  
  override func setConstraints() {
    titleVC.snp.makeConstraints { make in
      make.top.equalTo(self.view.snp.topMargin).inset(16)
      make.leading.equalToSuperview().inset(20)
      make.height.equalTo(33)
    }
    
    icPremium.snp.makeConstraints { make in
      make.centerY.equalTo(self.titleVC.snp.centerY)
      make.trailing.equalToSuperview().inset(20)
      make.height.width.equalTo(44)
    }
    
    collectionView.snp.makeConstraints { make in
      make.top.equalTo(self.titleVC.snp.bottom).inset(-28)
      make.leading.trailing.equalToSuperview().inset(20)
    }
    
    bannerView.snp.makeConstraints { make in
      make.top.lessThanOrEqualTo(self.collectionView.snp.bottom).inset(-16)
      make.left.right.equalToSuperview()
      make.height.equalTo(250)
      make.bottom.equalToSuperview().inset(110)
    }
  }
  
  private func setupBanner() {
    AdMobManager.shared.addAdBanner(unitId: AdUnitID(rawValue: SampleAdUnitID.adFormatFixedBannerID2),
                                    rootVC: self,
                                    view: bannerView, height: 250)
  }
  
  // MARK: Action
  override func setupAction() {
    icPremium.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapPremium)))
  }
  
  @objc private func onTapPremium() {
    viewModel.action.send(.iap)
  }
}

extension SettingsVC: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    switch viewModel.listItem.value[indexPath.row] {
      
    case .tutorial, .rate, .feedback, .termOfUse, .privacy:
      return CGSize(width: self.collectionView.frame.width, height: 28)
    case .moreApp:
      if AppManager.shared.displaySub == 0 {
        return CGSize(width: self.collectionView.frame.width, height: 0)
      } else {
        return CGSize(width: self.collectionView.frame.width, height: 28)
      }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int
  ) -> UIEdgeInsets {
    return UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 0)
  }
}

extension SettingsVC: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    switch viewModel.listItem.value[indexPath.row] {
    case .tutorial:
      viewModel.action.send(.tutorial)
    case .rate:
      StoreReviewHelper.rateApp(appId: AppText.appID)
    case .feedback:
      sendEmail()
    case .privacy:
      openURL(AppText.policy)
    case .termOfUse:
      openURL(AppText.term)
    case .moreApp:
      openURL(AppText.moreapp)
    }
  }
}

extension SettingsVC: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.listItem.value.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SettingCell", for: indexPath) as! SettingCell
    let item = viewModel.listItem.value[indexPath.row]
    cell.biding(item)
    return cell
  }
}

extension SettingsVC : MFMailComposeViewControllerDelegate {
  func sendEmail() {
    let nameApp = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
    let subject = "[FEEDBACK] \(nameApp)"
    let body = "<p>You're so awesome!</p>"
    
    if let emailUrl = createEmailUrl(to: AppText.mail,
                                     subject: subject, body: body) {
      print("xxx \(emailUrl)")
      self.openURL(emailUrl.absoluteString)
    } else {
      showMailError()
    }
  }
  
  private func createEmailUrl(to: String, subject: String, body: String) -> URL? {
    let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    
    let gmailUrl = URL(string: "googlegmail://co?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
    let outlookUrl = URL(string: "ms-outlook://compose?to=\(to)&subject=\(subjectEncoded)")
    let yahooMail = URL(string: "ymail://mail/compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
    let sparkUrl = URL(string: "readdle-spark://compose?recipient=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
    let defaultUrl = URL(string: "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)")
    
    if let gmailUrl = gmailUrl, UIApplication.shared.canOpenURL(gmailUrl) {
      return gmailUrl
    } else if let outlookUrl = outlookUrl, UIApplication.shared.canOpenURL(outlookUrl) {
      return outlookUrl
    } else if let yahooMail = yahooMail, UIApplication.shared.canOpenURL(yahooMail) {
      return yahooMail
    } else if let sparkUrl = sparkUrl, UIApplication.shared.canOpenURL(sparkUrl) {
      return sparkUrl
    }
    
    return defaultUrl
  }
  
  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    controller.dismiss(animated: true)
  }
  
  func showMailError() {
    let sendMailErrorAlert = UIAlertController(title: "Error", message: "Your device could not send email", preferredStyle: .alert)
    let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
    sendMailErrorAlert.addAction(dismiss)
    self.present(sendMailErrorAlert, animated: true, completion: nil)
  }
  
  func openURL(_ urlLink: String) {
    if let url = URL(string: urlLink) {
      UIApplication.shared.open(url)
    }
  }
}


struct StoreReviewHelper {
  
  static func requestReview() {
    if #available(iOS 14.0, *) {
      if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
        SKStoreReviewController.requestReview(in: scene)
      }
    } else if #available(iOS 10.3, *) {
      SKStoreReviewController.requestReview()
    } else {
      // Fallback on earlier versions
      // Try any other 3rd party or manual method here.
      rateApp(appId: AppText.appID)
    }
  }
  
  static func rateApp(appId: String) {
    StoreReviewHelper().openUrl("itms-apps://itunes.apple.com/app/id" + appId + "?mt=8&action=write-review")
  }
  
  fileprivate func openUrl(_ urlString:String) {
    let url = URL(string: urlString)!
    if #available(iOS 10.0, *) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    } else {
      UIApplication.shared.openURL(url)
    }
  }
}
