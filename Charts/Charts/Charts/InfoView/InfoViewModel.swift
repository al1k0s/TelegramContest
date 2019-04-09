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
    var name: String
    var color: UIColor
    var intValue: Int
    var location: CGPoint

    var value: String {
      return formatNumber(intValue)
    }
  }

  var date: Date
  var dayMonth: String {
    return with(DateFormatter()) {
      $0.dateFormat = "MMM dd"
    }.string(from: date)
  }
  var year: String {
    return with(DateFormatter()) {
      $0.dateFormat = "yyyy"
    }.string(from: date)
  }
  var fullDate: String {
    return with(DateFormatter()) {
      $0.dateFormat = "E, d MMM yyyy"
    }.string(from: date)
  }
  var charts: [Chart]
  var xCount: Int

  init(date: Date,
       xCount: Int,
       charts: [(name: String, color: UIColor, value: Int, location: CGPoint)]) {
    self.date = date
    self.xCount = xCount
    self.charts = charts.map { .init(name: $0.name, color: $0.color, intValue: $0.value, location: $0.location) }
  }
}
