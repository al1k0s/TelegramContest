//
//  ZoomedChart.swift
//  Charts
//
//  Created by Alik Vovkotrub on 4/11/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import Foundation.NSJSONSerialization

struct ZoomedChart: Decodable {
  var x: XAxis
  var yAxes: [YAxis]

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

