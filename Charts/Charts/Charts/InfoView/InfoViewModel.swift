//
//  InfoViewModel.swift
//  Charts
//
//  Created by Alik Vovkotrub on 4/8/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import UIKit.UIColor
import Foundation.NSDate

struct InfoViewModel {
  struct Chart {
    var color: UIColor
    var value: String
    var location: CGPoint
  }

  var dayMonth: String
  var year: String
  var charts: [Chart]
  var xCount: Int

  init(date: Date,
       xCount: Int,
       charts: [(color: UIColor, value: Int, location: CGPoint)]) {
    self.dayMonth = with(DateFormatter()) {
      $0.dateFormat = "MMM dd"
    }.string(from: date)
    self.year = with(DateFormatter()) {
      $0.dateFormat = "yyyy"
    }.string(from: date)
    self.xCount = xCount
    self.charts = charts.map { .init(color: $0.color, value: formatNumber($0.value), location: $0.location) }
  }
}
