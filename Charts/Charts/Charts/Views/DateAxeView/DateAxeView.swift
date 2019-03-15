//
//  DateAxeView.swift
//  Charts
//
//  Created by Oleksii Andriushchenko on 3/15/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import UIKit

final class DateAxeView: UIView {

  private var labels: [UILabel] = []
  private var date: [Date] = []

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  private func setup() {

  }

  func updateDateAxe(chartRange: ChartRange) {
    if labels.count == 0 {
      addLabels(chartRange: chartRange)
    } else {
      updateLabels(chartRange: chartRange)
    }
  }

  private func addLabels(chartRange: ChartRange) {
    let width = Double(bounds.width)
    var visibleDates = chartRange.chart.x.coordinates.filter(chartRange.range.contains)
    let doubleCount = Double(visibleDates.count)
    var xCoordinates = (0..<visibleDates.count).map(Double.init).map { $0 / doubleCount * width }
    guard let interval = findInterval(xCoord: xCoordinates) else {
      return
    }
    guard let first = xCoordinates.firstIndex(where: { $0 > 23.0 }) else {
      return
    }
    xCoordinates = xCoordinates.enumerated().filter { ($0.0 - first) % interval == 0 }.map { $0.1 }
    visibleDates = visibleDates.enumerated().filter { ($0.0 - first) % interval == 0 }.map { $0.1 }
    labels = zip(visibleDates, xCoordinates).map { date, xCoord in
      return createLabel(xCoord: xCoord, date: date)
    }
    dates = visibleDates
  }

  private func findInterval(xCoord: [Double]) -> Int? {
    guard xCoord.count > 0 else { return nil }
    var interval = 1
    while xCoord.indices.contains(interval) && xCoord[interval] - xCoord[0] < Constants.labelMinDistance {
      interval *= 2
    }
    return xCoord.indices.contains(interval) ? interval : nil
  }

  private func updateLabels(chartRange: ChartRange) {
    
  }

  private func createLabel(xCoord: Double, date: Date) -> UILabel {
    let label = UILabel(frame: CGRect(x: xCoord - 23.0, y: 0.0, width: 46.0, height: Double(bounds.height)))
    label.font = UIFont.systemFont(ofSize: 13)
    label.textColor = .blue
    label.text = makeText(from: date)
    addSubview(label)
    return label
  }

  private func makeText(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM dd"
    return formatter.string(from: date)
  }

  enum Constants {
    static let labelMinDistance: Double = 40.0
  }
}
