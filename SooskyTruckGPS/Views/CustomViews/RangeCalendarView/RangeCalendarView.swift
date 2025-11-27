//
//  CalendarView.swift
//  SooskyBabyTracker
//
//  Created by VuongDV on 10/4/25.
//

import UIKit
import FSCalendar
import SnapKit
import Toast

class RangeCalendarView: BaseView {
  
  @IBOutlet var contentView: UIView!
  @IBOutlet weak var calendarView: UIView!
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var saveLabel: UILabel!
  
  var handlerDateRange: ((Date, Date) -> Void)?
  var handlerActionShowIAPVC: Handler?
  
  private var initialDate: Date?
  private var startDate: Date?
  private var endDate: Date?
  private var countOfSave: Int = 0
  
  // MARK: - UI Components
  private var calendar: FSCalendar!
  
  private lazy var monthLabel: UILabel = {
    let label = UILabel()
    label.font = AppFont.font(.semiBoldText, size: 17)
    label.textColor = UIColor(rgb: 0x2E1F88)
    return label
  }()
  
  private lazy var previousButton: UIButton = {
    let button = UIButton()
    button.setImage(.iconPrevious, for: .normal)
    button.addTarget(self, action: #selector(previousMonth), for: .touchUpInside)
    return button
  }()
  
  private lazy var nextButton: UIButton = {
    let button = UIButton()
    button.setImage(.iconNext, for: .normal)
    button.addTarget(self, action: #selector(nextMonth), for: .touchUpInside)
    return button
  }()
  
  private lazy var nextYearButton: UIButton = {
    let button = UIButton()
    button.setImage(.iconNextYear, for: .normal)
    button.addTarget(self, action: #selector(nextYear), for: .touchUpInside)
    return button
  }()
  
  private lazy var stackViewOfButtons: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 28
    stackView.alignment = .center
    return stackView
  }()
  
  private lazy var stackViewForYear: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 4
    stackView.alignment = .center
    return stackView
  }()
  
  private lazy var headerView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    return view
  }()
  
  private var selectionMode: CalendarSelectionMode = .single
  
  // MARK: - Lifecycle
  override func addComponents() {
    loadNibNamed()
    addSubview(contentView)
    setupCalendar()
    setupHeaderView()
    setupTapGesture()
  }
  
  override func setConstraints() {
    contentView.frame = bounds
    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    setupCalendarConstraints()
  }
  
  override func setProperties() {
    containerView.layer.cornerRadius = 24
    containerView.clipsToBounds = true
    
    saveLabel.font = AppFont.font(.boldText, size: 20)
  }
  
  // MARK: - Setup
  private func setupCalendar() {
    calendar = FSCalendar()
    calendar.delegate = self
    calendar.dataSource = self
    calendar.register(CustomRangeCalendarCVC.self, forCellReuseIdentifier: "CustomRangeCalendarCVC")
    calendarView.addSubview(calendar)
    
    // Appearance
    calendar.appearance.headerMinimumDissolvedAlpha = 0.0
    calendar.appearance.headerDateFormat = ""
    calendar.headerHeight = 0
    calendar.appearance.weekdayTextColor = UIColor(rgb: 0xBEBEBE)
    calendar.appearance.titleDefaultColor = UIColor(rgb: 0x2E1F88)
    
    calendar.appearance.todayColor = .clear
    calendar.appearance.titleTodayColor = UIColor(rgb: 0xFF6C9E)
    
    calendar.appearance.titleFont = AppFont.font(.regularText, size: 20)
    calendar.appearance.weekdayFont = AppFont.font(.semiBoldText, size: 13)
    calendar.appearance.caseOptions = [.weekdayUsesUpperCase]
    calendar.appearance.weekdayTextColor = UIColor(rgb: 0xBEBEBE)
    calendar.weekdayHeight = 32
    
    calendar.appearance.selectionColor = .clear
    calendar.appearance.titleSelectionColor = UIColor(rgb: 0xFF6C9E)
    
    // Selection
    calendar.allowsMultipleSelection = false
    calendar.select(Date())
    
    // Layout
    calendar.placeholderType = .none
    calendar.backgroundColor = .white
  }
  
  private func setupHeaderView() {
    calendarView.addSubview(headerView)
    headerView.addSubview(stackViewOfButtons)
    headerView.addSubview(stackViewForYear)
    
    stackViewOfButtons.addArrangedSubview(previousButton)
    stackViewOfButtons.addArrangedSubview(nextButton)
    stackViewForYear.addArrangedSubview(monthLabel)
    // stackViewForYear.addArrangedSubview(nextYearButton)
    updateMonthLabel()
  }
  
  private func setupCalendarConstraints() {
    // Header View
    headerView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
      make.height.equalTo(44)
    }
    
    // Month Label
    stackViewForYear.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(20)
      make.top.equalToSuperview().offset(16)
    }
    
    stackViewOfButtons.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(16)
      make.trailing.equalToSuperview().offset(-16)
    }
    
    // Calendar
    calendar.snp.makeConstraints { make in
      make.top.equalTo(headerView.snp.bottom).offset(5)
      make.leading.equalToSuperview().offset(14)
      make.trailing.equalToSuperview().offset(-4)
      make.bottom.equalToSuperview().offset(-7)
    }
  }
  
  private func setupTapGesture() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapClose))
    tapGesture.delegate = self
    self.addGestureRecognizer(tapGesture)
  }
  
  // MARK: - Actions
  
  @objc private func previousMonth() {
    calendar.setCurrentPage(getPreviousMonth(), animated: true)
    updateMonthLabel()
  }
  
  @objc private func nextMonth() {
    calendar.setCurrentPage(getNextMonth(), animated: true)
    updateMonthLabel()
  }
  
  @objc private func nextYear() {
    calendar.setCurrentPage(getNextYear(), animated: true)
  }
  
  @objc private func onTapClose() {
    self.dismissSlideView()
  }
  
  @IBAction func onTapSave(_ sender: Any) {
    handlerDateRange?(startDate ?? Date(), endDate ?? startDate ?? Date())
    self.dismissSlideView()
  }
  
  // MARK: - Helpers
  private func updateMonthLabel() {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    monthLabel.text = formatter.string(from: calendar.currentPage)
  }
  
  private func getPreviousMonth() -> Date {
    return Calendar.current.date(byAdding: .month, value: -1, to: calendar.currentPage)!
  }
  
  private func getNextMonth() -> Date {
    return Calendar.current.date(byAdding: .month, value: 1, to: calendar.currentPage)!
  }
  
  private func getNextYear() -> Date {
    return Calendar.current.date(byAdding: .year, value: 1, to: calendar.currentPage)!
  }
}

// MARK: - FSCalendarDelegate, FSCalendarDataSource
extension RangeCalendarView: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
  func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
    handleRangeSelection(for: date)
  }
  
  func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
    updateMonthLabel()
  }
  
  func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
    let cell = calendar.dequeueReusableCell(withIdentifier: "CustomRangeCalendarCVC", for: date, at: position) as! CustomRangeCalendarCVC
    let isInRange = isDateInRange(date)
    let isStart = Calendar.current.isDate(date, inSameDayAs: startDate ?? Date.distantPast)
    let isEnd = Calendar.current.isDate(date, inSameDayAs: endDate ?? Date.distantPast)
    
    cell.configure(with: date, isInRange: isInRange, isStart: isStart, isEnd: isEnd)
    return cell
  }
  
  func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
    return date <= Date()
  }
  
  func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
    if date > Date() {
      return UIColor.lightGray
    } else {
      return UIColor(rgb: 0x2E1F88)
    }
  }
  
  private func isDateInRange(_ date: Date) -> Bool {
    guard let start = startDate else { return false }
    guard let end = endDate else { return Calendar.current.isDate(date, inSameDayAs: start) }
    return date >= start && date <= end
  }
}

extension RangeCalendarView {
  func setRangeDate(_ startDate: Date, endDate: Date) {
    self.startDate = startDate
    self.endDate = endDate
    // Cuộn đến tháng chứa startDate
    calendar.setCurrentPage(startDate, animated: true)
    
    // Deselect tất cả để tránh xung đột hiển thị cũ
    deselectAllDates()
    
    // Select lại các ngày trong khoảng
    selectDates(from: startDate, to: endDate)
  }
}

extension RangeCalendarView: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    // Nếu touch là trong calendarView, không xử lý tap
    if let touchedView = touch.view, touchedView.isDescendant(of: calendarView) {
      return false
    }
    return true
  }
  
  private func handleRangeSelection(for date: Date) {
    if startDate == nil {
      startDate = date
      calendar.select(date)
    } else if let start = startDate, endDate == nil {
      let numberOfDays = Calendar.current.dateComponents([.day], from: start, to: date).day ?? 0
      if numberOfDays < 0 {
        deselectAllDates()
        startDate = date
        endDate = nil
        calendar.select(date)
      } else if numberOfDays <= 365 {
        endDate = date
        selectDates(from: start, to: date)
        if let startDate = startDate, let endDate = endDate {
          self.startDate = startDate
          self.endDate = endDate
          calendar.reloadData()
        }
      } else {
        self.makeToast("Only up to 15 consecutive days can be selected.")
      }
    } else {
      deselectAllDates()
      startDate = date
      endDate = nil
      calendar.select(date)
    }
  }
  
  private func selectDates(from start: Date, to end: Date) {
    var date = start
    while date <= end {
      calendar.select(date)
      guard let next = Calendar.current.date(byAdding: .day, value: 1, to: date) else { break }
      date = next
    }
  }
  
  private func deselectAllDates() {
    calendar.selectedDates.forEach { calendar.deselect($0) }
    calendar.reloadData()
  }
}

extension RangeCalendarView {
  func setStateSelectionMode(with mode: CalendarSelectionMode) {
    self.selectionMode = mode
    calendar.allowsMultipleSelection = true
  }
}
