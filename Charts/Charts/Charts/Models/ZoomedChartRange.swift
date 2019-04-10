//
//  ZoomedChartRange.swift
//  Charts
//
//  Created by Alik Vovkotrub on 4/11/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import struct Foundation.Date

class ZoomedChartRange {
  init(chart: ZoomedChart, index: Int, choosenRange: ClosedRange<Date>, fullChart: ChartRange) {
    self.chart = chart
    self.index = index
    self.choosenRange = choosenRange
    self.fullChart = fullChart
  }

  var chart: ZoomedChart
  var index: Int
  var choosenRange: ClosedRange<Date>

  var fullChart: ChartRange
}
