//
//  ChartRange.swift
//  Charts
//
//  Created by Alik Vovkotrub on 3/15/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import struct Foundation.Date

class ChartRange {
  var chart: Chart
  var chosenRange: ClosedRange<Float>

  init(chart: Chart, chosenRange: ClosedRange<Float>) {
    self.chosenRange = chosenRange
    self.chart = chart
  }

  var range: ClosedRange<Date> {
    let coordinates = chart.x.coordinates
//    let lowerBound = coordinates.indices.first(where: { Float($0) / Float(coordinates.count) > chosenRange.lowerBound })!
//    let upperBound = coordinates.indices.last(where: { Float($0) / Float(coordinates.count) < chosenRange.upperBound })!
    let difference = coordinates.last!.timeIntervalSince1970 - coordinates.first!.timeIntervalSince1970
    let lowerBound = coordinates.first!.timeIntervalSince1970 + difference * Double(chosenRange.lowerBound)
    let upperBound = coordinates.first!.timeIntervalSince1970 + difference * Double(chosenRange.upperBound)
    return Date(timeIntervalSince1970: lowerBound)...Date(timeIntervalSince1970: upperBound)
  }
}
