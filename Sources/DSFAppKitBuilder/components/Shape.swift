//
//  Shape.swift
//
//  Copyright © 2023 Darren Ford. All rights reserved.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

import AppKit
import DSFValueBinders

public class Shape: Element {
	let path: CGPath
	public init(path: CGPath) {
		self.path = path
		self.content.path = path
		super.init()

		self.receiveThemeNotifications = true

		let bounds = path.boundingBoxOfPath
		self.size(width: bounds.width, height: bounds.height)
	}

	override public func view() -> NSView { return self.content }
	private let content = ShapeView()

	private var _fillColor: NSColor = .textBackgroundColor
	private var _strokeColor: NSColor = .textColor
}

public extension Shape {
	/// Convenience for creating an ellipse shape
	@inlinable static func Ellipse(width: CGFloat, height: CGFloat) -> Shape {
		Shape.init(path: CGPath(ellipseIn: CGRect(x: 0, y: 0, width: width, height: height), transform: nil))
	}
	/// Convenience for creating a circle shape
	@inlinable static func Circle(_ dimension: CGFloat) -> Shape {
		Self.Ellipse(width: dimension, height: dimension)
	}
	/// Convenience for creating a round rect shape
	@inlinable static func RoundedRect(width: CGFloat, height: CGFloat, cornerRadius: CGFloat) -> Shape {
		let pth = CGPath(
			roundedRect: CGRect(x: 0, y: 0, width: width, height: height),
			cornerWidth: min(width / 2, cornerRadius),
			cornerHeight: min(height / 2, cornerRadius),
			transform: nil)
		return Shape(path: pth)
	}
}

public extension Shape {
	/// The fill color
	@discardableResult func fillColor(_ color: NSColor, _ fillRule: CAShapeLayerFillRule = .nonZero) -> Self {
		self._fillColor = color
		self.content.shape.fillRule = fillRule
		self.syncColors()
		return self
	}

	/// The fill color
	@discardableResult func fillColor(_ color: CGColor, _ fillRule: CAShapeLayerFillRule = .nonZero) -> Self {
		self.fillColor(NSColor(cgColor: color) ?? .textBackgroundColor, fillRule)
	}

	/// The stroke color
	@discardableResult func strokeColor(_ color: NSColor) -> Self {
		self._strokeColor = color
		self.syncColors()
		return self
	}

	/// The stroke color
	@discardableResult func strokeColor(_ color: CGColor) -> Self {
		self.strokeColor(NSColor(cgColor: color) ?? .textColor)
	}

	/// The line width
	@discardableResult func lineWidth(_ width: CGFloat) -> Self {
		self.content.shape.lineWidth = width
		return self
	}

	/// A drop shadow for the path
	@discardableResult override func shadow(
		radius: CGFloat = 3,
		offset: CGSize = CGSize(width: 0, height: -3),
		color: NSColor = .shadowColor,
		opacity: CGFloat = 0.5
	) -> Self {
		self.content.layer?.masksToBounds = false
		using(self.content.shape) {
			$0.shadowRadius = radius
			$0.shadowOffset = offset
			$0.shadowColor = color.cgColor
			$0.shadowOpacity = Float(opacity)
			$0.masksToBounds = false
		}
		return self
	}

	override func onThemeChange() {
		super.onThemeChange()
		self.syncColors()
	}
}

public extension Shape {
	/// Fallback 'all formatting' access
	func format(_ formatBlock: (CAShapeLayer) -> Void) -> Self {
		formatBlock(self.content.shape)
		return self
	}
}

private extension Shape {

	private func syncColors() {
		self.content.shape.fillColor = _fillColor.cgColor
		self.content.shape.strokeColor = _strokeColor.cgColor
	}

	class ShapeView: NSView {
		let shape = CAShapeLayer()
		var path: CGPath? {
			didSet {
				self.shape.path = self.path
			}
		}

		init() {
			super.init(frame: .zero)
			self.translatesAutoresizingMaskIntoConstraints = false
			self.wantsLayer = true
			self.layer!.addSublayer(self.shape)
		}

		@available(*, unavailable)
		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}

		override func layout() {
			super.layout()
			self.shape.frame = self.bounds
		}
	}
}
