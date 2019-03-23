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
  }

  private let squareView = UIView()
  private let titleLabel = UILabel()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    selectionStyle = .none

    squareView.layer.cornerRadius = 5
    squareView.clipsToBounds = true
    addSubview(squareView, constraints: [
      squareView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
      squareView.centerYAnchor.constraint(equalTo: centerYAnchor),
      squareView.heightAnchor.constraint(equalToConstant: 20),
      squareView.widthAnchor.constraint(equalTo: squareView.heightAnchor)
    ])

    titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
    addSubview(titleLabel, constraints: [
      titleLabel.leadingAnchor.constraint(equalTo: squareView.trailingAnchor, constant: 16),
      titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
    ])
  }

  func render(props: Props) {
    squareView.backgroundColor = props.color
    titleLabel.text = props.title
    accessoryType = props.isChecked ? .checkmark : .none
  }
}
