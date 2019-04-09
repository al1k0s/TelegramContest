//
//  Info1View.swift
//  Charts
//
//  Created by Alik Vovkotrub on 3/23/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import UIKit

class Chart1InfoView: UIView, InfoViewProtocol {

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

  var circles: [UIView] = []

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
    resetCircles()
    let relative = location.x / bounds.width
    let data = tapOccured(relative)
    lastViewModel = data
    self.render(the: data)
  }

  private func render(the data: InfoViewModel) {
    containerLeftConstraint?.constant = calculateContainerLeadingConstant(data: data)
    lineLeftConstraint?.constant = data.charts[0].location.x * self.bounds.width
    resetCircles()
    dateLabel.text = data.fullDate
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
      namesStackView.alignment = .fill

      valuesStackView.addArrangedSubview(with(UILabel()) { label in
        label.textColor = chart.color
        label.text = chart.value
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .right
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
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
      insertSubview(circle, aboveSubview: line)
      circles.append(circle)
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
    circles.forEach { circle in
      circle.backgroundColor = isLight ? .white : UIColor(red: 34 / 255,
                                                          green: 47 / 255,
                                                          blue: 62 / 255,
                                                          alpha: 1.0)
      let color = isLight ? UIColor(red: 245/255, green: 250/255, blue: 245/255, alpha: 1) :
        UIColor(red: 27/255, green: 40/255, blue: 54/255, alpha: 1)
      container.backgroundColor = color
      line.backgroundColor = color
      dateLabel.textColor = isLight ? .black : .white
      namesStackView.arrangedSubviews.forEach { ($0 as? UILabel)?.textColor = isLight ? .black : .white }
    }
  }

  private func resetCircles() {
    circles.forEach({ $0.removeFromSuperview() })
    circles = []
  }

  func hide() {
    UIView.animate(withDuration: 0.1) {
      self.subviews.forEach({ $0.alpha = 0 })
    }
    resetCircles()
    lastViewModel = nil
  }
}

func makeModelForInfoView1(chartRange: ChartRange) -> (CGFloat) -> InfoViewModel {
  return { point in
    let up = chartRange.range.upperBound.timeIntervalSince1970
    let down = chartRange.range.lowerBound.timeIntervalSince1970
    let diff = up - down
    let time = down + diff * Double(point)
    let (index, _) = chartRange.xCoordinates.map { $0.timeIntervalSince1970 }
      .map { abs($0 - time) }
      .enumerated()
      .min(by: { $0.1 < $1.1 })!
    let dateX = (chartRange.xCoordinates[index].timeIntervalSince1970 - down) / diff
    let max = chartRange.max
    let min = chartRange.min
    let charts = chartRange.activeYAxes.map { axe -> (String, UIColor, Int, CGPoint) in
      let value = Int(axe.coordinates[index])
      return (name: axe.name, color: UIColor(hexString: axe.color), value, CGPoint(x: dateX, y: (Double(value) - min) / (max - min)))
    }
    return InfoViewModel(date: chartRange.xCoordinates[index],
                         xCount: chartRange.indicies.count,
                         charts: charts)
  }
}

func makeModelForInfoView2(chartRange: ChartRange) -> (CGFloat) -> InfoViewModel {
  return { point in
    let up = chartRange.range.upperBound.timeIntervalSince1970
    let down = chartRange.range.lowerBound.timeIntervalSince1970
    let diff = up - down
    let time = down + diff * Double(point)
    let (index, _) = chartRange.xCoordinates.map { $0.timeIntervalSince1970 }
      .map { abs($0 - time) }
      .enumerated()
      .min(by: { $0.1 < $1.1 })!
    let dateX = (chartRange.xCoordinates[index].timeIntervalSince1970 - down) / diff
    let charts = chartRange.activeYAxes.map { axe -> (String, UIColor, Int, CGPoint) in
      let max = axe.coordinates[chartRange.indicies].max()!
      let min = axe.coordinates[chartRange.indicies].min()!
      let value = Int(axe.coordinates[index])
      return (name: axe.name, color: UIColor(hexString: axe.color), value, CGPoint(x: dateX, y: (Double(value) - min) / (max - min)))
    }
    return InfoViewModel(date: chartRange.xCoordinates[index],
                         xCount: chartRange.indicies.count,
                         charts: charts)
  }
}
