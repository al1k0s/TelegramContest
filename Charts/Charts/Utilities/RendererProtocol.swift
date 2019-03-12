//
//  RendererProtocol.swift
//  Charts
//
//  Created by Oleksii Andriushchenko on 3/12/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import CoreGraphics

extension CGContext {
  func drawLine(from startingPoint: CGPoint, to endPoint: CGPoint, color: CGColor, lineWidth: CGFloat) {
    setLineWidth(lineWidth)
    setStrokeColor(color)
    move(to: startingPoint)
    addLine(to: endPoint)
    strokePath()
  }

  func drawCircle(at point: CGPoint, radius: CGFloat, color: CGColor, lineWidth: CGFloat) {
    setLineWidth(lineWidth)
    setStrokeColor(color)
    move(to: point)
    addArc(center: point,
           radius: radius,
           startAngle: .zero,
           endAngle: .pi,
           clockwise: true)
    strokePath()
  }
}
