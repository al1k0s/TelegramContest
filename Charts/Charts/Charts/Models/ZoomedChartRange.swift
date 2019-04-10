//
//  ZoomedChartRange.swift
//  Charts
//
//  Created by Alik Vovkotrub on 4/11/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import struct Foundation.Date

class ZoomedChartRange {
  init(chart: ZoomedChart, index: Int, date: Date, fullChart: ChartRange) {
    self.chart = chart
    self.index = index
    self.date = date
    self.fullChart = fullChart
  }

  var chart: ZoomedChart
  let index: Int
  private let date: Date

  var range: ClosedRange<Date> {
    return date.addingTimeInterval(-60 * 60 * 24 * Double(chosenRange.lowerBound))...date.addingTimeInterval(60 * 60 * 24 * Double(chosenRange.upperBound))
  }
  private var chosenRange: ClosedRange<Int> = 0...0

  let fullChart: ChartRange

  func moveLeftBound(by moveLeftCount: Int = 1) {
    let newLowerBound = chosenRange.lowerBound - moveLeftCount
    guard newLowerBound > -3, chosenRange.count < 3 else { return }
    self.chosenRange = ClosedRange<Int>(uncheckedBounds: (lower: newLowerBound, upper: chosenRange.upperBound))
  }

  func moveRightBound(by moveRightCount: Int = 1) {
    let newUpperBound = chosenRange.upperBound + moveRightCount
    guard newUpperBound < 3, chosenRange.count < 3 else { return }
    self.chosenRange = ClosedRange<Int>(uncheckedBounds: (lower: chosenRange.lowerBound, upper: newUpperBound))
  }

  func moveWholeRangeLeft(by moveCount: Int = 1) {
    let newUpperBound = chosenRange.upperBound - moveCount
    let newLowerBound = chosenRange.lowerBound - moveCount
    guard newUpperBound < 3, newLowerBound > -3 else { return }
    self.chosenRange = newLowerBound...newUpperBound
  }

  func moveWholeRangeRight(by moveCount: Int = 1) {
    let newUpperBound = chosenRange.upperBound + moveCount
    let newLowerBound = chosenRange.lowerBound + moveCount
    guard newUpperBound < 3, newLowerBound > -3 else { return }
    self.chosenRange = newLowerBound...newUpperBound
  }
}
