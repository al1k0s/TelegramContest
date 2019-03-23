//
//  HorizontalStripView.swift
//  Charts
//
//  Created by Oleksii Andriushchenko on 3/11/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import UIKit

final class HorizontalStripView: UIView {

  private let numberLabel = UILabel()
  private let lineView = UIView()

  var number: String {
    get {
      return numberLabel.text ?? ""
    } set {
      numberLabel.text = newValue
    }
  }

  init(frame: CGRect, number: String, isLight: Bool) {
    super.init(frame: frame)
    setup(number: number, isLight: isLight)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func toggleMode(isLight: Bool) {
    let lightNumber = UIColor(red: 173.0 / 255, green: 178.0 / 255, blue: 182.0 / 255, alpha: 1.0)
    let darkNumber = UIColor(red: 80.0 / 255, green: 95.0 / 255, blue: 111.0 / 255, alpha: 1.0)
    numberLabel.textColor = isLight ? lightNumber : darkNumber
    let lightLine = UIColor(red: 248.0 / 255, green: 248.0 / 255, blue: 248.0 / 255, alpha: 1.0)
    let darkLine = UIColor(red: 30.0 / 255, green: 42.0 / 255, blue: 55.0 / 255, alpha: 1.0)
    lineView.backgroundColor = isLight ? lightLine : darkLine
  }

  private func setup(number: String, isLight: Bool) {
    // configure number label
    numberLabel.font = UIFont.systemFont(ofSize: 11)
    let lightNumber = UIColor(red: 173.0 / 255, green: 178.0 / 255, blue: 182.0 / 255, alpha: 1.0)
    let darkNumber = UIColor(red: 80.0 / 255, green: 95.0 / 255, blue: 111.0 / 255, alpha: 1.0)
    numberLabel.textColor = isLight ? lightNumber : darkNumber
    numberLabel.text = number
    addSubview(numberLabel, constraints: [
      numberLabel.topAnchor.constraint(equalTo: topAnchor),
      numberLabel.leadingAnchor.constraint(equalTo: leadingAnchor)
    ])

    // configure line view
    let lightLine = UIColor(red: 248.0 / 255, green: 248.0 / 255, blue: 248.0 / 255, alpha: 1.0)
    let darkLine = UIColor(red: 30.0 / 255, green: 42.0 / 255, blue: 55.0 / 255, alpha: 1.0)
    lineView.backgroundColor = isLight ? lightLine : darkLine
    addSubview(lineView, constraints: [
      lineView.topAnchor.constraint(equalTo: numberLabel.bottomAnchor, constant: 4),
      lineView.leadingAnchor.constraint(equalTo: leadingAnchor),
      lineView.trailingAnchor.constraint(equalTo: trailingAnchor),
      lineView.bottomAnchor.constraint(equalTo: bottomAnchor),
      lineView.heightAnchor.constraint(equalToConstant: 1)
    ])
  }
}
