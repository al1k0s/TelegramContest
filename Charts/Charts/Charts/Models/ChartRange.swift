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

  private(set) var activeYAxes: [YAxis]

  var allYAxes: [YAxis] {
    return chart.yAxes
  }

  var yAxesNames: Set<String> {
    return Set(chart.yAxes.map({ $0.name }))
  }

  var xCoordinates: [Date] {
    return chart.x.coordinates
  }

  func updateYAxes(_ names: Set<String>) {
    self.activeYAxes = chart.yAxes.filter({ names.contains($0.name) })
  }

  init(chart: Chart, chosenRange: ClosedRange<Float>) {
    self.chosenRange = chosenRange
    self.chart = chart
    self.activeYAxes = chart.yAxes
  }

  var range: ClosedRange<Date> {
    let coordinates = chart.x.coordinates
    let difference = coordinates.last!.timeIntervalSince1970 - coordinates.first!.timeIntervalSince1970
    let lowerBound = coordinates.first!.timeIntervalSince1970 + difference * Double(chosenRange.lowerBound)
    let upperBound = coordinates.first!.timeIntervalSince1970 + difference * Double(chosenRange.upperBound)
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
    return activeYAxes.map({ $0.coordinates[indicies].max()! }).max()!
  }

  var allMax: Double {
    return activeYAxes.map({ $0.coordinates.max()! }).max()!
  }

  var min: Double {
    return activeYAxes.map({ $0.coordinates[indicies].min()! }).min()!
  }

  var allMin: Double {
    return activeYAxes.map({ $0.coordinates.min()! }).min()!
  }
}
