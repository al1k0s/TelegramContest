//
//  HorizontalStripView.swift
//  Charts
//
//  Created by Oleksii Andriushchenko on 3/11/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import UIKit

final class HorizontalStripView: UIView {

  private var leftNumberLabel = UILabel()
  private var rightNumberLabel = UILabel()
  private let lineView = UIView()

  init(frame: CGRect, isLight: Bool) {
    super.init(frame: frame)
    setup(isLight: isLight)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func toggleMode(isLight: Bool) {
    let lightLine = UIColor(red: 248.0 / 255, green: 248.0 / 255, blue: 248.0 / 255, alpha: 1.0)
    let darkLine = UIColor(red: 30.0 / 255, green: 42.0 / 255, blue: 55.0 / 255, alpha: 1.0)
    lineView.backgroundColor = isLight ? lightLine : darkLine
  }

  private func setup(isLight: Bool) {

    leftNumberLabel.alpha = 0.8
    rightNumberLabel.alpha = 0.8

    // configure line view
    let lightLine = UIColor(red: 248.0 / 255, green: 248.0 / 255, blue: 248.0 / 255, alpha: 1.0)
    let darkLine = UIColor(red: 30.0 / 255, green: 42.0 / 255, blue: 55.0 / 255, alpha: 1.0)
    lineView.backgroundColor = isLight ? lightLine : darkLine
    lineView.alpha = 0.3
    addSubview(lineView, constraints: [
      lineView.leadingAnchor.constraint(equalTo: leadingAnchor),
      lineView.trailingAnchor.constraint(equalTo: trailingAnchor),
      lineView.bottomAnchor.constraint(equalTo: bottomAnchor),
      lineView.heightAnchor.constraint(equalToConstant: 1)
    ])
  }

  func setLeftNumber(_ text: String) {
    leftNumberLabel.text = text
  }

  func setRightNumber(_ text: String) {
    rightNumberLabel.text = text
  }

  func updateLabel(
    isLeft: Bool,
    isTopDirection: Bool,
    newText: String,
    color: UIColor,
    completion: @escaping () -> ()
  ) {
    let label = isLeft ? leftNumberLabel : rightNumberLabel
    guard label.text != newText else {
      completion()
      return
    }
    let newLabel = createNewLabel(isLeft: isLeft, text: newText, color: color)
    let dy: CGFloat = isTopDirection ? 15 : -15
    newLabel.frame.origin.y -= dy
    UIView.animate(withDuration: 0.2, animations: {
      label.frame.origin.y += dy
      newLabel.frame.origin.y += dy
      label.alpha = 0
      newLabel.alpha = 1
    }, completion: { [weak self] isInterrupted in
      if isLeft {
        self?.leftNumberLabel = newLabel
      } else {
        self?.rightNumberLabel = newLabel
      }
      label.removeFromSuperview()
      completion()
    })
  }

  private func createNewLabel(isLeft: Bool, text: String, color: UIColor) -> UILabel {
    let size = calculateLength(of: text)
    let x = isLeft ? 0 : bounds.width - size.width
    let y = bounds.height - 6 - size.height
    let label = UILabel(frame: CGRect(origin: CGPoint(x: x, y: y), size: size))
    label.font = UIFont.systemFont(ofSize: 11)
    label.textColor = color
    label.text = text
    label.alpha = 0.0
    addSubview(label)
    return label
  }

  private func calculateLength(of text: String) -> CGSize {
    let size = (text as NSString).size(
      withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11)]
    )
    return size
  }
}
