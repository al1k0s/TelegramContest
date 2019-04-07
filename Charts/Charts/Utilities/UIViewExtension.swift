//
//  UIViewExtension.swift
//  Charts
//
//  Created by Oleksii Andriushchenko on 3/10/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import UIKit

extension UIView {
  func addSubview(_ otherView: UIView, constraints: [NSLayoutConstraint]) {
    addSubview(otherView)
    otherView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate(constraints)
  }

  func addSubview(_ otherView: UIView, withEdgeInsets insets: UIEdgeInsets) {
    addSubview(otherView, constraints: [
      otherView.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
      otherView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
      otherView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.right),
      otherView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom)
      ])
  }

  func roundCorners(corners: UIRectCorner, radius: CGFloat) {
    let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
    let mask = CAShapeLayer()
    mask.path = path.cgPath
    layer.mask = mask
  }
}
