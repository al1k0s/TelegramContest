//
//  ZoomedChartRange.swift
//  Charts
//
//  Created by Alik Vovkotrub on 4/11/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import struct Foundation.Date

private let maxLenght = 3

class ZoomedChartRange {
  let fullChart: ChartRange
  var chart: ZoomedChart
  let index: Int
  private let date: Date
  private var chosenRange = 0...0

  init(chart: ZoomedChart, index: Int, date: Date, fullChart: ChartRange) {
    self.chart = chart
    self.index = index
    self.date = date
    self.fullChart = fullChart
  }

  var range: ClosedRange<Date> {
    let day = 60 * 60 * 24.0
    return date.addingTimeInterval(-day * Double(chosenRange.lowerBound))...date.addingTimeInterval(day * Double(chosenRange.upperBound))
  }

  func moveLeftBound(by moveLeftCount: Int = 1) {
    let newLowerBound = chosenRange.lowerBound - moveLeftCount
    guard newLowerBound > -maxLenght, chosenRange.count < maxLenght else { return }
    self.chosenRange = newLowerBound...chosenRange.upperBound
  }

  func moveRightBound(by moveRightCount: Int = 1) {
    let newUpperBound = chosenRange.upperBound + moveRightCount
    guard newUpperBound < maxLenght, chosenRange.count < maxLenght else { return }
    self.chosenRange = chosenRange.lowerBound...newUpperBound
  }

  func moveWholeRangeLeft(by moveCount: Int = 1) {
    let newUpperBound = chosenRange.upperBound - moveCount
    let newLowerBound = chosenRange.lowerBound - moveCount
    guard newUpperBound < maxLenght, newLowerBound > -maxLenght else { return }
    self.chosenRange = newLowerBound...newUpperBound
  }

  func moveWholeRangeRight(by moveCount: Int = 1) {
    let newUpperBound = chosenRange.upperBound + moveCount
    let newLowerBound = chosenRange.lowerBound + moveCount
    guard newUpperBound < maxLenght, newLowerBound > -maxLenght else { return }
    self.chosenRange = newLowerBound...newUpperBound
  }
}
