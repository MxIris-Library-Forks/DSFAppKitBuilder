//
//  DSFAppKitBuilder+Button.swift
//
//  Created by Darren Ford on 27/7/21
//
//  MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import AppKit.NSButton

public class Button: Control {

	public init(
		tag: Int? = nil,
		type: NSButton.ButtonType = .momentaryLight,
		bezelStyle: NSButton.BezelStyle = .rounded,
		allowMixedState: Bool = false,
		title: String
	) {
		super.init(tag: tag)
		self.button.title = title
		self.button.bezelStyle = bezelStyle
		self.button.setButtonType(type)
		self.button.allowsMixedState = allowMixedState
	}

	public init(
		tag: Int? = nil,
		type: NSButton.ButtonType = .momentaryLight,
		bezelStyle: NSButton.BezelStyle = .rounded,
		allowMixedState: Bool = false,
		title: String,
		action: @escaping ((NSButton) -> Void)
	) {
		super.init(tag: tag)
		self.button.title = title
		self.button.bezelStyle = bezelStyle
		self.button.setButtonType(type)
		self.button.allowsMixedState = allowMixedState

		self.setAction(action)
	}

	public init(
		tag: Int? = nil,
		type: NSButton.ButtonType = .momentaryLight,
		bezelStyle: NSButton.BezelStyle = .rounded,
		title: String,
		target: AnyObject,
		action: Selector
	) {
		super.init(tag: tag)
		self.button.setButtonType(type)
		self.button.bezelStyle = bezelStyle
		self.button.title = title
		self.button.isEnabled = true

		self.setAction(target, action: action)
	}

	// MARK: Title

	/// Set the button's title
	public func title(_ title: String) -> Self {
		self.button.stringValue = title
		return self
	}

	/// Bind the title to a keypath
	public func bindTitle<TYPE>(_ object: NSObject, keyPath: ReferenceWritableKeyPath<TYPE, String>) -> Self {
		self.titleBinder.bind(object, keyPath: keyPath, onChange: { [weak self] newValue in
			self?.button.title = newValue
		})
		self.titleBinder.setValue(object.value(forKeyPath: NSExpression(forKeyPath: keyPath).keyPath))
		return self
	}

	// MARK: Alternate Title

	/// The title that the button displays when the button is in an on state.
	public func alternateTitle(_ title: String) -> Self {
		self.button.alternateTitle = title
		return self
	}

	/// Bind the alternatetitle to a keypath
	public func bindAlternateTitle<TYPE>(_ object: NSObject, keyPath: ReferenceWritableKeyPath<TYPE, String>) -> Self {
		self.alternateTitleBinder.bind(object, keyPath: keyPath, onChange: { [weak self] newValue in
			self?.button.alternateTitle = newValue
		})
		self.alternateTitleBinder.setValue(object.value(forKeyPath: NSExpression(forKeyPath: keyPath).keyPath))
		return self
	}

	// MARK: Image

	/// Set the image that appears on the button when it’s in an off state
	public func image(
		_ image: NSImage,
		imagePosition: NSControl.ImagePosition = .imageLeading,
		imageScaling: NSImageScaling? = nil,
		imageHugsTitle: Bool? = nil) -> Self
	{
		self.button.image = image
		self.button.imagePosition = imagePosition
		if let i = imageHugsTitle { self.button.imageHugsTitle = i }
		if let i = imageScaling { self.button.imageScaling = i }
		return self
	}

	/// Set the image that appears on the button when it’s in an on state
	public func alternateImage(_ image: NSImage) -> Self{
		self.button.alternateImage = image
		return self
	}

	// A Boolean value that determines whether the button has a border.
	public func isBordered(_ isBordered: Bool) -> Self {
		self.button.isBordered = isBordered
		return self
	}

	// MARK: State

	/// Set the button's initial state
	public func state(_ state: NSControl.StateValue) -> Self {
		self.button.state = state
		return self
	}

	/// Bind the state to a keypath
	public func bindState<TYPE>(_ object: NSObject, keyPath: ReferenceWritableKeyPath<TYPE, NSControl.StateValue>) -> Self {
		self.stateBinder.bind(object, keyPath: keyPath, onChange: { [weak self] newValue in
			self?.button.state = newValue
		})
		self.stateBinder.setValue(object.value(forKeyPath: NSExpression(forKeyPath: keyPath).keyPath))
		return self
	}

	// MARK: Actions

	/// Set the action callback via a selector
	public func action(_ target: AnyObject, action: Selector) -> Self {
		self.setAction(target, action: action)
		return self
	}

	/// Set the action callback via a block
	public func action(_ action: @escaping ((NSButton) -> Void)) -> Self {
		self.setAction(action)
		return self
	}

	private func setAction(_: AnyObject, action: Selector) {
		self.action = nil
		self.button.target = self
		self.button.action = action
	}

	private func setAction(_ action: @escaping ((NSButton) -> Void)) {
		self.action = action
		self.button.target = self
		self.button.action = #selector(self.performAction(_:))
	}

	@objc internal func performAction(_ item: NSButton) {
		self.action?(item)
	}

	// Privates

	fileprivate let button = NSButton()
	public override var nsView: NSView { return self.button }
	private var action: ((NSButton) -> Void)?

	private lazy var stateBinder = Bindable<NSControl.StateValue>()
	private lazy var titleBinder = Bindable<String>()
	private lazy var alternateTitleBinder = Bindable<String>()
}
