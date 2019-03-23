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
      $0.dateFormat = "MMM dd"
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

  var containerLeftConstraint: NSLayoutConstraint?
  let container = with(UIView()) {
    $0.layer.cornerRadius = 4
    $0.backgroundColor = UIColor(red: 245/255, green: 250/255, blue: 245/255, alpha: 1)
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

  var lineLeftConstraint: NSLayoutConstraint?
  let line = with(UIView()) {
    $0.backgroundColor = UIColor(red: 245/255, green: 250/255, blue: 245/255, alpha: 1)
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
      drawTheme()
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(gestureOccured(sender:)))
    self.addGestureRecognizer(tapRecognizer)

    let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(gestureOccured(sender:)))
    self.addGestureRecognizer(panRecognizer)
    tapRecognizer.require(toFail: panRecognizer)

    containerLeftConstraint = container.leadingAnchor.constraint(equalTo: self.leadingAnchor)
    self.addSubview(container, constraints: [
      container.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
      containerLeftConstraint!
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

    lineLeftConstraint = line.leadingAnchor.constraint(equalTo: self.leadingAnchor)
    self.addSubview(line, constraints: [
      line.widthAnchor.constraint(equalToConstant: 1),
      line.topAnchor.constraint(equalTo: container.bottomAnchor),
      line.bottomAnchor.constraint(equalTo: self.bottomAnchor),
      lineLeftConstraint!
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
    containerLeftConstraint?.constant = min(max((data.charts[0].location.x * self.bounds.width) - container.bounds.width / 2, 0), self.bounds.width - container.bounds.width)
    lineLeftConstraint?.constant = data.charts[0].location.x * self.bounds.width
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
                                              $0.backgroundColor = isLight ?
                                                UIColor(red: 245/255, green: 250/255, blue: 245/255, alpha: 1) :
                                               UIColor(red: 27/255, green: 40/255, blue: 54/255, alpha: 1)
      }
      self.addSubview(circle)
      circles.append(circle)
    }

    drawTheme()
    subviews.forEach({ $0.alpha = 1 })
  }

  private func drawTheme() {
    circles.forEach { circle in
      circle.backgroundColor = isLight ? .white : UIColor(red: 34 / 255,
                                                          green: 47 / 255,
                                                          blue: 62 / 255,
                                                          alpha: 1.0)
      let color = isLight ? UIColor(red: 245/255, green: 250/255, blue: 245/255, alpha: 1) :
        UIColor(red: 27/255, green: 40/255, blue: 54/255, alpha: 1)
      container.backgroundColor = color
      line.backgroundColor = color
      [dayMonthLabel, yearLabel].forEach {
        $0.textColor = isLight ? .black : .white
      }
    }
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
