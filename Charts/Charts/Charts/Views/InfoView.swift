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
  }

  var dayMonth: String
  var year: String
  var charts: [Chart]

  init(date: Date, charts: [(color: UIColor, value: Int)]) {
    #warning("not implemented")
    self.dayMonth = "23 Fabruary"
    self.year = "2019"
    self.charts = charts.map { .init(color: $0.color, value: String($0.value)) }
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
      (color: .red, value: 123),
      (color: .green, value: 12)
    ])
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOccured(sender:)))
    self.addGestureRecognizer(tapRecognizer)

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

    subviews.forEach({ $0.alpha = 0 })
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc private func tapOccured(sender: UITapGestureRecognizer) {
    let location = sender.location(ofTouch: 0, in: self)
    let relative = self.bounds.width / location.x
    let data = tapOccured(relative)
    self.render(the: data)
  }

  private func render(the data: InfoViewModel) {
    dayMonthLabel.text = data.dayMonth
    yearLabel.text = data.year
    coordinatesStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
    for chart in data.charts {
      coordinatesStackView.addArrangedSubview(with(UILabel()) { label in
        label.textColor = chart.color
        label.text = chart.value
        label.font = UIFont.systemFont(ofSize: 12)
      })
    }

    subviews.forEach({ $0.alpha = 1 })
  }

  func rangeChanged() {
    self.subviews.forEach({ $0.alpha = 0 })
  }
}
