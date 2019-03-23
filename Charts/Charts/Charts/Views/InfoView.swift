//
//  InfoView.swift
//  Charts
//
//  Created by Alik Vovkotrub on 3/23/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import UIKit

struct InfoViewModel {
  struct Chart {
    var color: UIColor
    var value: String
    var location: CGPoint
  }

  var dayMonth: String
  var year: String
  var charts: [Chart]

  init(date: Date, charts: [(color: UIColor, value: Int, location: CGPoint)]) {
    self.dayMonth = with(DateFormatter()) {
      $0.dateFormat = "dd MMM"
    }.string(from: date)
    self.year = with(DateFormatter()) {
      $0.dateFormat = "yyyy"
    }.string(from: date)
    self.charts = charts.map { .init(color: $0.color, value: String($0.value), location: $0.location) }
  }
}

class InfoView: UIView {

  let dayMonthLabel = with(UILabel()) {
    $0.font = UIFont.systemFont(ofSize: 12)
  }
  let yearLabel = with(UILabel()) {
    $0.font = UIFont.systemFont(ofSize: 12, weight: .light)
  }

  let container = with(UIView()) {
    $0.layer.cornerRadius = 4
    $0.backgroundColor = .gray
  }

  let dateStackView = with(UIStackView()) {
    $0.axis = .vertical
    $0.alignment = .center
    $0.distribution = . fill
    $0.spacing = 4
  }

  let coordinatesStackView = with(UIStackView()) {
    $0.axis = .vertical
    $0.alignment = .center
    $0.distribution = . fill
    $0.spacing = 4
  }

  let stackView = with(UIStackView()) {
    $0.axis = .horizontal
    $0.alignment = .center
    $0.distribution = . fill
    $0.spacing = 4
  }

  let line = with(UIView()) {
    $0.backgroundColor = .gray
  }

  var tapOccured: (CGFloat) -> InfoViewModel = { _ in
    return InfoViewModel(date: .init(), charts: [
      (color: .red, value: 123, location: CGPoint(x: 0.3, y: 0.3)),
      (color: .green, value: 12, location: CGPoint(x: 0.5, y: 0.5))
    ])
  }

  var circles: [UIView] = []

  var lastViewModel: InfoViewModel?

  var isLight = true {
    didSet {
      lastViewModel.map(render)
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(gestureOccured(sender:)))
    self.addGestureRecognizer(tapRecognizer)

    let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(gestureOccured(sender:)))
    self.addGestureRecognizer(panRecognizer)
    tapRecognizer.require(toFail: panRecognizer)

    self.addSubview(container, constraints: [
      container.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
      container.centerXAnchor.constraint(equalTo: self.centerXAnchor)
    ])

    dateStackView.addArrangedSubview(dayMonthLabel)
    dateStackView.addArrangedSubview(yearLabel)

    stackView.addArrangedSubview(dateStackView)
    stackView.addArrangedSubview(coordinatesStackView)

    container.addSubview(stackView, constraints: [
      stackView.topAnchor.constraint(equalTo: container.topAnchor, constant: 4),
      stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 4),
      stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4),
      stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -4)
    ])

    self.addSubview(line, constraints: [
      line.widthAnchor.constraint(equalToConstant: 1),
      line.topAnchor.constraint(equalTo: container.bottomAnchor),
      line.bottomAnchor.constraint(equalTo: self.bottomAnchor),
      line.centerXAnchor.constraint(equalTo: container.centerXAnchor)
    ])
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc private func gestureOccured(sender: UIGestureRecognizer) {
    let location = sender.location(in: self)
    logTap(at: location)
  }

  private func logTap(at location: CGPoint) {
    resetCircles()
    let relative = location.x / bounds.width
    let data = tapOccured(relative)
    lastViewModel = data
    self.render(the: data)
  }

  private func render(the data: InfoViewModel) {
    resetCircles()
    dayMonthLabel.text = data.dayMonth
    yearLabel.text = data.year
    coordinatesStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
    for chart in data.charts {
      coordinatesStackView.addArrangedSubview(with(UILabel()) { label in
        label.textColor = chart.color
        label.text = chart.value
        label.font = UIFont.systemFont(ofSize: 12)
      })

      let locationInBounds = CGPoint(x: (chart.location.x * self.bounds.width) - 5,
                                     y: ((1 - chart.location.y) * self.bounds.height) - 5)
      let circle = with(UIView(frame: CGRect(origin: locationInBounds,
                                             size: CGSize(width: 10, height: 10)))) {
                                              $0.layer.cornerRadius = 5
                                              $0.layer.borderWidth = 2
                                              $0.layer.borderColor = chart.color.cgColor
                                              $0.backgroundColor = isLight ? .white : UIColor(red: 239.0 / 255,
                                                                                              green: 239.0 / 255,
                                                                                              blue: 244.0 / 255,
                                                                                              alpha: 1.0)
      }
      self.addSubview(circle)
      circles.append(circle)
    }

    subviews.forEach({ $0.alpha = 1 })
  }

  private func resetCircles() {
    circles.forEach({ $0.removeFromSuperview() })
    circles = []
  }

  func rangeChanged() {
    subviews.forEach({ $0.alpha = 0 })
    resetCircles()
    lastViewModel = nil
  }
}
