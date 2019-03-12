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
}
