//
//  FilterButtonCell.swift
//  Charts
//
//  Created by Oleksii Andriushchenko on 4/7/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import UIKit

final class FilterButtonCell: UICollectionViewCell {

  struct Props: Equatable {
    let color: UIColor
    let text: String
    let isChecked: Bool
  }

  private let tickImage = UIImageView()
  private let textLabel = UILabel()
  private var labelTrailingConstraint: NSLayoutConstraint!
  private var labelCenterXConstraint: NSLayoutConstraint!

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  private func setup() {
    layer.borderWidth = 1
    layer.cornerRadius = 6
    clipsToBounds = true

    // configure image
    tickImage.image = #imageLiteral(resourceName: "tick")
    addSubview(tickImage, constraints: [
      tickImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 11),
      tickImage.centerYAnchor.constraint(equalTo: centerYAnchor),
      tickImage.widthAnchor.constraint(equalToConstant: 12),
      tickImage.heightAnchor.constraint(equalToConstant: 10)
    ])

    // configure label
    textLabel.font = UIFont.systemFont(ofSize: 13)
    labelTrailingConstraint = textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
    labelCenterXConstraint = textLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
    addSubview(textLabel, constraints: [
      textLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
      labelTrailingConstraint
    ])
  }

  func render(props: Props) {
    backgroundColor = props.isChecked ? props.color : .clear
    layer.borderColor = props.color.cgColor
    textLabel.text = props.text
    textLabel.textColor = props.isChecked ? .white : props.color
    tickImage.isHidden = !props.isChecked
    labelTrailingConstraint.isActive = props.isChecked
    labelCenterXConstraint.isActive = !props.isChecked
  }
}
