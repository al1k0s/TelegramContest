//
//  ChartRange.swift
//  Charts
//
//  Created by Alik Vovkotrub on 3/15/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import struct Foundation.Date

class ChartRange {
  private var chart: Chart
  var chosenRange: ClosedRange<Float>

  var isTwoYAxes: Bool {
    return chart.isTwoYAxes
  }

  var isPercentageYValues: Bool {
    return chart.isPercentageYValues
  }

  var activeYAxes: [YAxis] {
    return allYAxes.filter { selectedYAxes.contains($0) }
  }

  var allYAxes: [YAxis] {
    return chart.yAxes
  }

  private var selectedYAxes = Set<YAxis>()

  var xCoordinates: [Date] {
    return chart.x.coordinates
  }

  func updateYAxes(_ index: Int) {
    guard !isTwoYAxes else { return }
    let yAxis = allYAxes[index]
    if selectedYAxes.contains(yAxis) && selectedYAxes.count > 1 {
      selectedYAxes.remove(yAxis)
    } else if !selectedYAxes.contains(yAxis) {
      selectedYAxes.insert(yAxis)
    }
  }

  init(chart: Chart, chosenRange: ClosedRange<Float>) {
    self.chosenRange = chosenRange
    self.chart = chart
    self.selectedYAxes = Set(chart.yAxes)
  }

  var range: ClosedRange<Date> {
    let coordinates = chart.x.coordinates
    let difference = coordinates.last!.timeIntervalSince1970 - coordinates.first!.timeIntervalSince1970 + 2.0 * 86400.0
    let lowerBound = (coordinates.first!.timeIntervalSince1970 - 86400.0) + difference * Double(chosenRange.lowerBound)
    let upperBound = (coordinates.first!.timeIntervalSince1970 - 86400.0) + difference * Double(chosenRange.upperBound)
    return Date(timeIntervalSince1970: lowerBound)...Date(timeIntervalSince1970: upperBound)
  }

  var indicies: ClosedRange<Int> {
    let coordinates = chart.x.coordinates
    let difference = coordinates.last!.timeIntervalSince1970 - coordinates.first!.timeIntervalSince1970
    let lowerBound = coordinates.first!.timeIntervalSince1970 + difference * Double(chosenRange.lowerBound)
    let upperBound = coordinates.first!.timeIntervalSince1970 + difference * Double(chosenRange.upperBound)
    let lowerIndex = coordinates.firstIndex(where: { $0.timeIntervalSince1970 > lowerBound })!
    let upperIndex = coordinates.lastIndex(where: { $0.timeIntervalSince1970 < upperBound })!
    return lowerIndex...upperIndex
  }

  var max: Double {
    let max = activeYAxes.map({ $0.coordinates[indicies].max()! }).max()!
    return max
  }

  var allMax: Double {
    let max = activeYAxes.map({ $0.coordinates.max()! }).max()!
    return max
  }

  var min: Double {
    return activeYAxes.map({ $0.coordinates[indicies].min()! }).min()!
  }

  var allMin: Double {
    return activeYAxes.map({ $0.coordinates.min()! }).min()!
  }

  func leftIndex() -> Int {
    let lowerBound = range.lowerBound.timeIntervalSince1970
    return xCoordinates.lastIndex(where: { lowerBound > $0.timeIntervalSince1970 }) ?? 0
  }

  func rightIndex() -> Int {
    let upperBound = range.upperBound.timeIntervalSince1970
    return xCoordinates.firstIndex(where: { $0.timeIntervalSince1970 > upperBound }) ?? xCoordinates.count - 1
  }

  func extremum() -> Extremum {
    if isTwoYAxes {
      return .init(
        topLeft: allYAxes[0].coordinates[indicies].max()!,
        bottomLeft: allYAxes[0].coordinates[indicies].min()!,
        topRight: allYAxes[1].coordinates[indicies].max()!,
        bottomRight: allYAxes[1].coordinates[indicies].min()!
      )
    } else if isPercentageYValues {
      return .init(topLeft: 110, bottomLeft: 0, topRight: nil, bottomRight: nil)
    } else if chart.isStacked {
      return .init(topLeft: max, bottomLeft: 0, topRight: nil, bottomRight: nil)
    } else {
      return .init(topLeft: max, bottomLeft: min, topRight: nil, bottomRight: nil)
    }
  }
}
