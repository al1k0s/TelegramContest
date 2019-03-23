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

  private(set) var yAxes: Set<YAxis>

  var yAxesNames: [String] {
    return chart.yAxes.map({ $0.name })
  }

  var xCoordinates: [Date] {
    return chart.x.coordinates
  }

  func addYAxis(_ name: String) {
    let axis = chart.yAxes.first(where: { $0.name == name })!
    yAxes.insert(axis)
  }

  func removeAxis(_ name: String) {
    let axis = chart.yAxes.first(where: { $0.name == name })!
    yAxes.remove(axis)
  }

  init(chart: Chart, chosenRange: ClosedRange<Float>) {
    self.chosenRange = chosenRange
    self.chart = chart
    self.yAxes = Set(chart.yAxes)
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
    let lowerBound = coordinates.indices.first(where: { Float($0) / Float(coordinates.count) > chosenRange.lowerBound })!
    let upperBound = coordinates.indices.last(where: { Float($0) / Float(coordinates.count) < chosenRange.upperBound })!
    return lowerBound...upperBound
  }

  var max: Double {
    return chart.yAxes.map({ $0.coordinates[indicies].max()! }).max()!
  }
}
