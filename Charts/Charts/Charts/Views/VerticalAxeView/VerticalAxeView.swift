//
//  VerticalAxeView.swift
//  Charts
//
//  Created by Oleksii Andriushchenko on 3/10/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import UIKit

final class VerticalAxeView: UIView {

  private var stripViews: [HorizontalStripView] = []
  private let viewWidth: CGFloat

  init(width: CGFloat) {
    self.viewWidth = width
    super.init(frame: .zero)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    let stripHeight = Constants.stripHeight
    for iter in 0..<Constants.numberOfStrips {
      let stripView = HorizontalStripView(
        frame: CGRect(x: 0, y: CGFloat(iter) * stripHeight, width: viewWidth, height: 18.5)
      )
      stripViews.append(stripView)
      addSubview(stripView)
    }
  }

  enum Constants {
    static let numberOfStrips = 6
    static let topPadding: CGFloat = 25
    static let stripHeight: CGFloat = 40
  }
}
