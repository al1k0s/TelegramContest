//
//  ButtonCell.swift
//  Charts
//
//  Created by Oleksii Andriushchenko on 3/23/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import UIKit

final class ButtonCell: UITableViewCell {

  struct Props {
    let title: String
    let color: UIColor
    let isChecked: Bool
    let isLight: Bool
    let isLast: Bool
  }

  private let squareView = UIView()
  private let titleLabel = UILabel()
  private let lineView = UIView()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    backgroundColor = .clear
    selectionStyle = .none

    squareView.layer.cornerRadius = 5
    squareView.clipsToBounds = true
    addSubview(squareView, constraints: [
      squareView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
      squareView.centerYAnchor.constraint(equalTo: centerYAnchor),
      squareView.heightAnchor.constraint(equalToConstant: 20),
      squareView.widthAnchor.constraint(equalTo: squareView.heightAnchor)
    ])

    titleLabel.textColor = UIColor(red: 34.0 / 255, green: 34.0 / 255, blue: 34.0 / 255, alpha: 1.0)
    titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
    addSubview(titleLabel, constraints: [
      titleLabel.leadingAnchor.constraint(equalTo: squareView.trailingAnchor, constant: 16),
      titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
    ])

    lineView.backgroundColor = .white
    addSubview(lineView, constraints: [
      lineView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
      lineView.trailingAnchor.constraint(equalTo: trailingAnchor),
      lineView.bottomAnchor.constraint(equalTo: bottomAnchor),
      lineView.heightAnchor.constraint(equalToConstant: 1)
    ])
  }

  func render(props: Props) {
    squareView.backgroundColor = props.color
    titleLabel.text = props.title
    let light = UIColor(red: 34.0 / 255, green: 34.0 / 255, blue: 34.0 / 255, alpha: 1.0)
    let dark = UIColor(red: 225.0 / 255, green: 225.0 / 255, blue: 225.0 / 255, alpha: 1.0)
    titleLabel.textColor = props.isLight ? light : dark
    accessoryType = props.isChecked ? .checkmark : .none
    let lightLine = UIColor(red: 244.0 / 255, green: 244.0 / 255, blue: 245.0 / 255, alpha: 1.0)
    let darkLine = UIColor(red: 31.0 / 255, green: 43.0 / 255, blue: 57.0 / 255, alpha: 1.0)
    lineView.backgroundColor = props.isLight ? lightLine : darkLine
    lineView.isHidden = props.isLast
  }
}
