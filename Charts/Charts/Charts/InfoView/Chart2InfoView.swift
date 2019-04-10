//
//  Chart2InfoView.swift
//  Charts
//
//  Created by Oleksii Andriushchenko on 4/9/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import UIKit

class Chart5InfoView: UIView, InfoViewProtocol {

  let dateLabel = with(UILabel()) {
    $0.font = UIFont.systemFont(ofSize: 12)
  }

  let rightArrowImageView = with(UIImageView()) {
    $0.image = #imageLiteral(resourceName: "rightArrowIcon")
  }

  var containerLeftConstraint: NSLayoutConstraint?
  let container = with(UIView()) {
    $0.layer.cornerRadius = 4
    $0.backgroundColor = UIColor(red: 245/255, green: 250/255, blue: 245/255, alpha: 1)
  }

  let percentStackView = with(UIStackView()) {
    $0.axis = .vertical
    $0.alignment = .trailing
    $0.distribution = .fill
    $0.spacing = 4
    $0.setContentHuggingPriority(.required, for: .horizontal)
  }

  let namesStackView = with(UIStackView()) {
    $0.axis = .vertical
    $0.alignment = .fill
    $0.distribution = .fill
    $0.spacing = 4
  }

  let valuesStackView = with(UIStackView()) {
    $0.axis = .vertical
    $0.alignment = .trailing
    $0.distribution = .fill
    $0.spacing = 4
    $0.setContentHuggingPriority(.required, for: .horizontal)
  }

  let stackView = with(UIStackView()) {
    $0.axis = .horizontal
    $0.alignment = .center
    $0.distribution = .fill
    $0.spacing = 4
  }

  var lineLeftConstraint: NSLayoutConstraint?
  let line = with(UIView()) {
    $0.backgroundColor = UIColor(red: 245/255, green: 250/255, blue: 245/255, alpha: 1)
  }

  var tapOccured: (CGFloat) -> InfoViewModel = { _ in
    return InfoViewModel(
      date: .init(),
      xCount: 1, charts: [
        (name: "Name1", color: .red, value: 123, location: CGPoint(x: 0.3, y: 0.3)),
        (name: "Name1", color: .green, value: 12, location: CGPoint(x: 0.5, y: 0.5))
      ])
  }

  var lastViewModel: InfoViewModel?

  var onZoom: (() -> Void)?

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

    stackView.addArrangedSubview(percentStackView)
    stackView.addArrangedSubview(namesStackView)
    stackView.addArrangedSubview(valuesStackView)

    container.addSubview(dateLabel, constraints: [
      dateLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 4),
      dateLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 4)
      ])

    container.addSubview(rightArrowImageView, constraints: [
      rightArrowImageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
      rightArrowImageView.leadingAnchor.constraint(greaterThanOrEqualTo: dateLabel.trailingAnchor, constant: 12),
      rightArrowImageView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -11),
      rightArrowImageView.widthAnchor.constraint(equalToConstant: 6),
      rightArrowImageView.heightAnchor.constraint(equalToConstant: 10)
      ])

    container.addSubview(stackView, constraints: [
      stackView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
      stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 4),
      stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4),
      stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -4)
      ])

    lineLeftConstraint = line.leadingAnchor.constraint(equalTo: self.leadingAnchor)
    self.addSubview(line, constraints: [
      line.widthAnchor.constraint(equalToConstant: 1),
      line.topAnchor.constraint(equalTo: self.topAnchor),
      line.bottomAnchor.constraint(equalTo: self.bottomAnchor),
      lineLeftConstraint!
      ])
    sendSubviewToBack(line)

    let clickGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(zoomed))
    container.addGestureRecognizer(clickGestureRecognizer)
  }

  @objc private func zoomed() {
    onZoom?()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc private func gestureOccured(sender: UIGestureRecognizer) {
    let location = sender.location(in: self)
    guard bounds.contains(location) else { return }
    logTap(at: location)
  }

  private func logTap(at location: CGPoint) {
    let relative = location.x / bounds.width
    let data = tapOccured(relative)
    lastViewModel = data
    self.render(the: data)
  }

  private func render(the data: InfoViewModel) {
    containerLeftConstraint?.constant = calculateContainerLeadingConstant(data: data)
    lineLeftConstraint?.constant = data.charts[0].location.x * self.bounds.width
    dateLabel.text = data.fullDate
    percentStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
    valuesStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
    namesStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
    for chart in data.charts {
      namesStackView.addArrangedSubview(with(UILabel()) { label in
        label.textColor = isLight ? .black : .white
        label.text = chart.name
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
      })

      valuesStackView.addArrangedSubview(with(UILabel()) { label in
        label.textColor = chart.color
        label.text = chart.value
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .right
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
      })

      let max = data.charts.map { $0.intValue }.reduce(0, +)
      //var overall = 100
      percentStackView.addArrangedSubview(with(UILabel()) { label in
        label.textColor = isLight ? .black : .white
        let percent = Double(chart.intValue) / Double(max) * 100
        label.text = "\(Int(percent)).\((Int(percent * 100) % 100))%"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .right
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
      })
    }

    drawTheme()
    subviews.forEach({ $0.alpha = 1 })
  }

  private func calculateContainerLeadingConstant(data: InfoViewModel) -> CGFloat {
    if data.charts[0].location.x < 0.5 {
      return data.charts[0].location.x * self.bounds.width + 10
    } else {
      return data.charts[0].location.x * self.bounds.width - 10 - container.bounds.width
    }
  }

  private func drawTheme() {
    let color = isLight
      ? UIColor(red: 245/255, green: 250/255, blue: 245/255, alpha: 1)
      : UIColor(red: 27/255, green: 40/255, blue: 54/255, alpha: 1)
    container.backgroundColor = color
    line.backgroundColor = color
    dateLabel.textColor = isLight ? .black : .white
    namesStackView.arrangedSubviews.forEach { ($0 as? UILabel)?.textColor = isLight ? .black : .white }
    percentStackView.arrangedSubviews.forEach { ($0 as? UILabel)?.textColor = isLight ? .black : .white }
  }

  func hide() {
    UIView.animate(withDuration: 0.1) {
      self.subviews.forEach({ $0.alpha = 0 })
    }
    lastViewModel = nil
  }
}
