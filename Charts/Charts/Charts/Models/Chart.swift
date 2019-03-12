//
//  Chart.swift
//  Charts
//
//  Created by Oleksii Andriushchenko on 3/11/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import Foundation

enum ChartDecodingError: String, Error {
  case notFoundXColumn = "Can't find column with x label"
}

struct Chart: Decodable {

  let dateScale: [Date]
  let plots: [Column]

  enum CodingKeys: String, CodingKey {
    case columns
    case names
    case colors
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    let columns = try values.decode([[IntOrString]].self, forKey: .columns)
    var columnsDictionary = [String: [Int]]()
    var dates: [Date] = []
    for column in columns {
      switch column.first?.text {
      case "x":
        dates = column.compactMap { $0.number }.map { Date(timeIntervalSince1970: Double($0)) }
      case .some(let text):
        columnsDictionary[text] = column.compactMap { $0.number }
      default:
        break
      }
    }
    dateScale = dates
    let names = try values.decode([String: String].self, forKey: .names)
    let colors = try values.decode([String: String].self, forKey: .colors)
    // create columns
    plots = columnsDictionary.map({ (key, value) -> Column? in
      return Column(
        name: names[key],
        color: colors[key],
        values: value
      )
    }).compactMap { $0 }
  }
}

struct Column {
  let name: String
  let color: String
  let values: [Int]

  init?(name: String?, color: String?, values: [Int]) {
    guard let _name = name, let _color = color else {
      print("Can't initilize Column object, some value is nil!")
      print("Name: \(String(describing: name))")
      print("color: \(String(describing: color))")
      return nil
    }
    self.name = _name
    self.color = _color
    self.values = values
  }
}

enum IntOrString: Decodable {
  case integer(Int)
  case string(String)

  var text: String? {
    switch self {
    case .integer:
      return nil
    case .string(let text):
      return text
    }
  }

  var number: Int? {
    switch self {
    case .integer(let num):
      return num
    case .string:
      return nil
    }
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let x = try? container.decode(Int.self) {
      self = .integer(x)
      return
    }
    if let x = try? container.decode(String.self) {
      self = .string(x)
      return
    }
    throw DecodingError.typeMismatch(
      IntOrString.self,
      DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "Wrong type for IntOrString"
      )
    )
  }
}
