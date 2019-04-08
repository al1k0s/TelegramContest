//
//  Charts.swift
//  TelegramContest
//
//  Created by Alik Vovkotrub on 3/12/19.
//  Copyright © 2019 Alik Vovkotrub. All rights reserved.
//

import struct Foundation.Date
import class Foundation.DateFormatter

public struct XAxis {
  public var coordinates: [Date]
}

struct YAxis: Hashable {
  var id: String
  var coordinates: [Double]
  var color: String
  var name: String
  var type: AxisType

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  enum AxisType: String, Hashable {
    case line
    case area
    case bar
    // x axis values for each of the charts at the corresponding positions
    case x
  }
}

struct Chart: Decodable {
  var x: XAxis
  var yAxes: [YAxis]
  var isTwoYAxes: Bool
  var isStacked: Bool
  var isPercentageYValues: Bool

  private struct Either<One: Decodable, Other: Decodable>: Decodable {
    init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      if let one = try? container.decode(One.self) {
        self.one = one
        self.other = nil
      } else {
        let other = try container.decode(Other.self)
        self.other = other
        self.one = nil
      }
    }

    var one: One?
    var other: Other?
  }

  enum CodingKeys: String, CodingKey {
    case columns
    case names
    case colors
    case types
    case percentage
    case stacked
    case yScaled = "y_scaled"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    isTwoYAxes = try container.decodeIfPresent(Bool.self, forKey: .yScaled) ?? false
    isStacked = try container.decodeIfPresent(Bool.self, forKey: .stacked) ?? false
    isPercentageYValues = try container.decodeIfPresent(Bool.self, forKey: .percentage) ?? false

    let columns = try container.decode([[Either<String, Double>]].self, forKey: .columns)

    let colors = try container.decode([String: String].self, forKey: .colors)
    let names = try container.decode([String: String].self, forKey: .names)
    let types = try container.decode([String: String].self, forKey: .types)

    let xColumn = columns[0]
    let rest = Array(columns.dropFirst())

    let coordinates = xColumn
      .dropFirst()
      .map({ $0.other! / 1000 })
      .map(Date.init(timeIntervalSince1970:))

    self.x = XAxis(coordinates: Array(coordinates))

    self.yAxes = rest.enumerated().map({ index, column in
      let id = column[0].one!
      let coordinates = Array(column.dropFirst().map({ $0.other! }))
      let color = colors[id]!
      let name = names[id]!
      let type = YAxis.AxisType(rawValue: types[id]!)!
      return YAxis(id: id, coordinates: coordinates, color: color, name: name, type: type)
    })
  }
}
