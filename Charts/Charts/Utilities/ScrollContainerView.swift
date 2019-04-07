//
//  ScrollContainerView.swift
//  Charts
//
//  Created by Oleksii Andriushchenko on 3/24/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import UIKit

final class ScrollContainerView: UIScrollView {
  private let contentView: UIView

  init(contentView: UIView) {
    self.contentView = contentView
    super.init(frame: .zero)
    setupUI()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupUI() {
    bounces = false
    addSubview(contentView, withEdgeInsets: .zero)
    NSLayoutConstraint.activate([
      widthAnchor.constraint(equalTo: contentView.widthAnchor)
    ])
  }
}

