//
//  ControlsComponents.swift
//  Charts
//
//  Created by Oleksii Andriushchenko on 4/7/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import UIKit

final class SideView: UIView {

  private let visibleView = UIView()
  private let imageView = UIImageView()
  private let isLeft: Bool

  init(isLeft: Bool) {
    self.isLeft = isLeft
    super.init(frame: .zero)
    setup(isLeft: isLeft)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    setCornerRadius(isLeft: isLeft)
  }

  private func setup(isLeft: Bool) {

    visibleView.backgroundColor = Constants.lightBackground
    let leftInset: CGFloat = isLeft ? 13 : 0
    let rightInset: CGFloat = isLeft ? 0 : 13
    addSubview(visibleView, withEdgeInsets: .init(top: 0, left: leftInset, bottom: 0, right: rightInset))

    let centerOffset: CGFloat = isLeft ? 6.5 : -6.5
    addSubview(imageView, constraints: [
      imageView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: centerOffset),
      imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
      imageView.widthAnchor.constraint(equalToConstant: 5),
      imageView.heightAnchor.constraint(equalToConstant: 10)
    ])
  }

  func setBackgroundColor(_ color: UIColor) {
    visibleView.backgroundColor = color
  }

  func setImage(_ image: UIImage) {
    imageView.image = image
  }

  private func setCornerRadius(isLeft: Bool) {
    if isLeft {
      visibleView.roundCorners(corners: [.topLeft, .bottomLeft], radius: Constants.controlViewRadius)
    } else {
      visibleView.roundCorners(corners: [.topRight, .bottomRight], radius: Constants.controlViewRadius)
    }
  }
}

final class CenterView: UIView {

  let topLine = UIView()
  let bottomLine = UIView()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  private func setup() {
    topLine.backgroundColor = Constants.lightBackground
    addSubview(topLine, constraints: [
      topLine.topAnchor.constraint(equalTo: topAnchor),
      topLine.leadingAnchor.constraint(equalTo: leadingAnchor),
      topLine.trailingAnchor.constraint(equalTo: trailingAnchor),
      topLine.heightAnchor.constraint(equalToConstant: 1)
    ])

    bottomLine.backgroundColor = Constants.lightBackground
    addSubview(bottomLine, constraints: [
      bottomLine.leadingAnchor.constraint(equalTo: leadingAnchor),
      bottomLine.trailingAnchor.constraint(equalTo: trailingAnchor),
      bottomLine.bottomAnchor.constraint(equalTo: bottomAnchor),
      bottomLine.heightAnchor.constraint(equalToConstant: 1)
    ])
  }

  func setLinesColor(_ color: UIColor) {
    topLine.backgroundColor = color
    bottomLine.backgroundColor = color
  }
}

private enum Constants {
  static let unvisibleControlViewWidth: CGFloat = 13
  static let controlViewRadius: CGFloat = 6
  static let lightBackground = UIColor(red: 190.0 / 255, green: 205.0 / 255, blue: 220.0 / 255, alpha: 1.0)
  static let darkBackground = UIColor(red: 86.0 / 255, green: 98.0 / 255, blue: 108.0 / 255, alpha: 1.0)
}
