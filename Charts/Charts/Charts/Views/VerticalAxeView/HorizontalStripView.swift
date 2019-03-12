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

  init(frame: CGRect, number: String) {
    super.init(frame: frame)
    setup(number: number)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup(number: String) {
    // configure number label
    numberLabel.font = UIFont.systemFont(ofSize: 11)
    numberLabel.textColor = .gray
    numberLabel.text = number
    addSubview(numberLabel, constraints: [
      numberLabel.topAnchor.constraint(equalTo: topAnchor),
      numberLabel.leadingAnchor.constraint(equalTo: leadingAnchor)
    ])

    // configure line view
    lineView.backgroundColor = .gray
    addSubview(lineView, constraints: [
      lineView.topAnchor.constraint(equalTo: numberLabel.bottomAnchor, constant: 4),
      lineView.leadingAnchor.constraint(equalTo: leadingAnchor),
      lineView.trailingAnchor.constraint(equalTo: trailingAnchor),
      lineView.bottomAnchor.constraint(equalTo: bottomAnchor),
      lineView.heightAnchor.constraint(equalToConstant: 1)
    ])
  }
}
