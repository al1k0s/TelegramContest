//
//  ZoomedChartRange.swift
//  Charts
//
//  Created by Alik Vovkotrub on 4/11/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import Foundation.NSDate
import UIKit.NSDataAsset

private let maxLenght = 3

class ZoomedChartRange {
  let fullChart: ChartRange
  private var charts: [Chart]

  var selectedCharts: [Chart] {
    return Array(charts[(chosenRange.lowerBound + 2)...(chosenRange.upperBound + 2)])
  }

  let index: Int
  private let date: Date
  private var chosenRange = 0...0

  init(index: Int, date: Date, fullChart: ChartRange) {
    self.charts = zoom(fullChart: fullChart, index: index, date)
    self.index = index
    self.date = date
    self.fullChart = fullChart
  }

  var range: ClosedRange<Date> {
    let day = 60 * 60 * 24.0
    return date.addingTimeInterval(-day * Double(chosenRange.lowerBound))...date.addingTimeInterval(day * Double(chosenRange.upperBound))
  }
}

private func zoom(fullChart: ChartRange,
                  index: Int,
                  _ date: Date) -> [Chart] {
  precondition(index != 5)

  return [date.dayBefore.dayBefore,
          date.dayBefore,
          date,
          date.dayAfter,
          date.dayAfter.dayAfter].compactMap { date in
            let formattedDate = with(DateFormatter()) { formatter in
              formatter.dateFormat = "yyyy-M/dd"
              }.string(from: date)
            let name = "\(index)/\(formattedDate)"
            guard let dataset = NSDataAsset(name: name) else { return nil }
            let chart = try! JSONDecoder().decode(Chart.self, from: dataset.data)
            return chart
  }
}

extension Date {
  var noon: Date {
    return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
  }

  var dayAfter: Date {
    return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
  }

  var dayBefore: Date {
    return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
  }
}
