//
//  File.swift
//  File
//
//  Created by Darren Ford on 27/7/21.
//

import AppKit.NSTextField

public class Label: Control {
	let label = NSTextField()
	public override var nsView: NSView { return self.label }

	public init(tag: Int? = nil, _ label: String? = nil) {
		super.init(tag: tag)
		self.label.isEditable = false
		self.label.drawsBackground = false
		self.label.isBezeled = false
		if let l = label { self.label.stringValue = l }
	}

	/// The text to display in the label
	public func label(_ label: String) -> Self {
		self.label.stringValue = label
		return self
	}

	/// Bind the label to a keypath
	public func bindLabel<TYPE>(_ object: NSObject, keyPath: ReferenceWritableKeyPath<TYPE, String>) -> Self {
		self.labelBinder.bind(object, keyPath: keyPath, onChange: { [weak self] newValue in
			self?.label.stringValue = newValue
		})
		self.labelBinder.setValue(object.value(forKeyPath: NSExpression(forKeyPath: keyPath).keyPath))
		return self
	}

	/// The font used to draw text in the receiver’s cell.
	public func font(_ font: NSFont? = nil) -> Self {
		self.label.font = font
		return self
	}

	// MARK: - Text Color

	/// The color of the text field’s content.
	public func textColor(_ textColor: NSColor? = nil) -> Self {
		self.label.textColor = textColor
		return self
	}

	/// Bind the text color of the text to a keypath
	public func bindTextColor<TYPE>(
		_ object: NSObject,
		keyPath: ReferenceWritableKeyPath<TYPE, NSColor>,
		animated: Bool = false) -> Self {
		self.textColorBinder.bind(object, keyPath: keyPath, onChange: { [weak self] newValue in
			guard let `self` = self else { return }
			if animated {
				self.textColorAnimator.animate(from: self.label.textColor ?? .clear, to: newValue) { [weak self] color in
					self?.label.textColor = color
				}
			}
			else {
				self.label.textColor = newValue
			}
		})
		return self
	}

	/// A Boolean value that determines whether the user can select the content of the text field.
	public func isSelectable(_ s: Bool) -> Self {
		self.label.isSelectable = s
		return self
	}

	/// A Boolean value that controls whether the text field draws a solid black border around its contents.
	public func isBordered(_ s: Bool) -> Self {
		self.label.isBordered = s
		return self
	}

	/// A Boolean value that controls whether the text field draws a bezeled background around its contents.
	public func isBezeled(_ s: Bool) -> Self {
		self.label.isBezeled = s
		return self
	}

	/// A Boolean value that controls whether the text field’s cell draws a background color behind the text.
	public func drawsBackground(_ s: Bool) -> Self {
		self.label.drawsBackground = s
		return self
	}

	/// The alignment mode of the text in the receiver’s cell.
	public func alignment(_ alignment: NSTextAlignment) -> Self {
		self.label.alignment = alignment
		return self
	}

	/// The line break mode to use when drawing text in the cell.
	public func lineBreakMode(_ mode: NSLineBreakMode) -> Self {
		self.label.cell?.lineBreakMode = mode
		return self
	}

	/// A Boolean value that controls whether single-line text fields tighten intercharacter spacing before truncating the text.
	public func allowsDefaultTighteningForTruncation(_ allow: Bool) -> Self {
		self.label.allowsDefaultTighteningForTruncation = allow
		return self
	}

	// Privates

	private lazy var labelBinder = Bindable<String>()
	private lazy var textColorAnimator = NSColor.Animator()
	private lazy var textColorBinder = Bindable<NSColor>()

}
