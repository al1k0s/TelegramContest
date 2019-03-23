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
  private var dates: [Date] = []
  private var labelsToBeRemoved: [UILabel] = []
  private var datesForRemovedLabels: [Date] = []
  private var interval = 1

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
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
    var visibleDates = chartRange.xCoordinates.filter(chartRange.range.contains)
    let doubleCount = Double(visibleDates.count)
    var xCoordinates = (0..<visibleDates.count).map(Double.init).map { $0 / doubleCount * width }
    guard let datesInterval = findInterval(xCoord: xCoordinates) else {
      return
    }
    interval = datesInterval
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
    for iter in 0..<labels.count {
      let normalizedXCoord = findNormalizedXCoordinates(date: dates[iter], range: chartRange.range)
      let newXCoord = CGFloat(normalizedXCoord) * bounds.width
      labels[iter].frame.origin.x = newXCoord - 23.0
    }
    for iter in 0..<labelsToBeRemoved.count {
      let normalizedXCoord = findNormalizedXCoordinates(date: datesForRemovedLabels[iter], range: chartRange.range)
      let newXCoord = CGFloat(normalizedXCoord) * bounds.width
      labelsToBeRemoved[iter].frame.origin.x = newXCoord - 23.0
    }
    removeInvisibleLabels()
    addNewLabelsOnLeftIfNeeded(chartRange: chartRange)
    addNewLabelsOnRightIfNeeded(chartRange: chartRange)
    decreaseDateIntervalIdNeeded(chartRange: chartRange)
    increaseDateIntervalIdNeeded()
  }

  private func findNormalizedXCoordinates(date: Date, range: ClosedRange<Date>) -> Double {
    let interval = range.upperBound.timeIntervalSince1970 - range.lowerBound.timeIntervalSince1970
    let offset = date.timeIntervalSince1970 - range.lowerBound.timeIntervalSince1970
    return offset / interval
  }

  private func removeInvisibleLabels() {
    var iter = 0
    while iter < labels.count {
      let xCoord = (labels[iter].frame.minX + labels[iter].frame.maxX) / 2
      if xCoord < 0.0 || xCoord > bounds.width {
        removeLabel(label: labels[iter], date: dates[iter])
        labels.remove(at: iter)
        dates.remove(at: iter)
      } else {
        iter += 1
      }
    }
  }

  private func addNewLabelsOnLeftIfNeeded(chartRange: ChartRange) {
    let chartDates = chartRange.xCoordinates
    guard let index = findIndexOf(date: dates.first, in: chartDates) else {
      return
    }

    let newIndex = index - interval
    guard newIndex >= 0 else { return }
    let newDate = chartDates[newIndex]
    let normalizedCoordinates = findNormalizedXCoordinates(date: newDate, range: chartRange.range)
    let newXCoord = normalizedCoordinates * Double(bounds.width)
    if newXCoord > 0.0 {
      let label = createLabel(xCoord: newXCoord, date: newDate)
      addSubview(label)
      labels.insert(label, at: 0)
      dates.insert(newDate, at: 0)
    }
  }

  private func addNewLabelsOnRightIfNeeded(chartRange: ChartRange) {
    let chartDates = chartRange.xCoordinates
    guard let index = findIndexOf(date: dates.last, in: chartDates) else {
        return
    }

    let newIndex = index + interval
    guard newIndex < chartDates.count else { return }
    let newDate = chartDates[newIndex]
    let normalizedCoordinates = findNormalizedXCoordinates(date: newDate, range: chartRange.range)
    let newXCoord = normalizedCoordinates * Double(bounds.width)
    if newXCoord < Double(bounds.width) {
      let label = createLabel(xCoord: newXCoord, date: newDate)
      addSubview(label)
      labels.append(label)
      dates.append(newDate)
    }
  }

  private func decreaseDateIntervalIdNeeded(chartRange: ChartRange) {
    guard labels.count > 1 else { return }
    let difference = labels[1].frame.minX - labels[0].frame.minX
    if difference > 95 {
      let chartDates = chartRange.xCoordinates
      guard let index = findIndexOf(date: dates[0], in: chartDates) else { return }
      interval /= 2
      var iter = index - interval < 0 ? index : index - interval
      var normalizedCoord = findNormalizedXCoordinates(date: chartDates[iter], range: chartRange.range)
      var xCoord = normalizedCoord * Double(bounds.width)
      repeat {
        if xCoord >= 0.0 {
          let label = createLabel(xCoord: xCoord, date: chartDates[iter])
          addSubview(label)
          labels.append(label)
          dates.append(chartDates[iter])
        }
        iter += interval * 2
        if iter >= chartDates.count {
          break
        }
        normalizedCoord = findNormalizedXCoordinates(date: chartDates[iter], range: chartRange.range)
        xCoord = normalizedCoord * Double(bounds.width)
      } while xCoord < Double(bounds.width)
    }
    labels.sort(by: { $0.frame.minX < $1.frame.minX })
    dates.sort(by: { $0 < $1 })
  }

  private func increaseDateIntervalIdNeeded() {
    guard labels.count > 1 else { return }
    let difference = labels[1].frame.minX - labels[0].frame.minX
    if difference < 50 {
      interval *= 2
      let needToRemove = labels.enumerated().filter { $0.0 % 2 == 1 }.map { $0.1 }
      let datesForRemoved = dates.enumerated().filter { $0.0 % 2 == 1 }.map { $0.1 }
      labels = labels.enumerated().filter { $0.0 % 2 == 0 }.map { $0.1 }
      zip(needToRemove, datesForRemoved).forEach { removeLabel(label: $0, date: $1) }
      dates = dates.enumerated().filter { $0.0 % 2 == 0 }.map { $0.1 }
    }
  }

  private func findIndexOf(date: Date?, in dates: [Date]) -> Int? {
    guard let date = date else { return nil }
    return dates.firstIndex(where: { $0 == date })
  }

  private func createLabel(xCoord: Double, date: Date) -> UILabel {
    let label = UILabel(frame: CGRect(x: xCoord - 23.0, y: 0.0, width: 46.0, height: Double(bounds.height)))
    label.font = UIFont.systemFont(ofSize: 13)
    label.textColor = .gray
    label.text = makeText(from: date)
    label.alpha = 0.0
    addSubview(label)
    UIView.animate(withDuration: 0.2, animations: {
      label.alpha = 1.0
    })
    return label
  }

  private func removeLabel(label: UILabel, date: Date) {
    labelsToBeRemoved.append(label)
    datesForRemovedLabels.append(date)
    UIView.animate(withDuration: 0.2, animations: {
      label.alpha = 0
    }) { [weak self] _ in
      if let index = self?.labelsToBeRemoved.firstIndex(of: label) {
        self?.labelsToBeRemoved.remove(at: index)
        self?.datesForRemovedLabels.remove(at: index)
      }
      label.removeFromSuperview()
    }
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
