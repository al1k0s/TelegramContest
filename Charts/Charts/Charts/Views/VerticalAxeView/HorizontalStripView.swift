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

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    // configure number label
    numberLabel.font = UIFont.systemFont(ofSize: 11)
    numberLabel.textColor = .gray
    numberLabel.text = "31"
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
