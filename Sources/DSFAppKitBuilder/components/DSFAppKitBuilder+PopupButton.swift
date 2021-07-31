//
//  DSFAppKitBuilder+PopupButton.swift
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

import AppKit.NSPopUpButton

/// Wrapper for NSPopupButton
public class PopupButton: Control {

	public convenience init(
		pullsDown: Bool = false,
		@MenuBuilder builder: () -> [MenuItem]
	) {
		self.init(
			pullsDown: pullsDown,
			content: builder()
		)
	}

	// Private

	override var nsView: NSView { return self.popupButton }
	private let popupButton = NSPopUpButton()
	private let content: [MenuItem]

	private lazy var selectionBinder = Bindable<Int>()
	private var selectionChangeBlock: ((Int) -> Void)?

	internal init(
		pullsDown: Bool = false,
		content: [MenuItem]
	) {
		self.content = content
		super.init()

		self.popupButton.pullsDown = pullsDown
		let menu = NSMenu()
		content.forEach {
			$0.menuItem.target = self
			$0.menuItem.action = #selector(selectionChanged(_:))
			menu.addItem($0.menuItem)
		}
		self.popupButton.menu = menu
	}
}

// MARK: - Modifiers

public extension PopupButton {
	/// Set the initially selected popup item
	func selectItem(at index: Int) -> Self {
		self.popupButton.selectItem(at: index)
		return self
	}
}

// MARK: - Action

public extension PopupButton {
	/// Set the block to be called when the selection changes
	func onChange(_ block: @escaping (Int) -> Void) -> Self {
		self.selectionChangeBlock = block
		return self
	}
}

// MARK: - Binding

public extension PopupButton {
	/// Bind the selection to a keypath
	func bindSelection<TYPE>(_ object: NSObject, keyPath: ReferenceWritableKeyPath<TYPE, Int>) -> Self {
		self.selectionBinder.bind(object, keyPath: keyPath, onChange: { [weak self] newValue in
			self?.popupButton.selectItem(at: newValue)
		})
		return self
	}
}

// MARK: Private

private extension PopupButton {

	var selectedIndex: Int {
		return self.popupButton.indexOfSelectedItem
	}

	@objc private func selectionChanged(_: Any) {
		self.selectionChangeBlock?(self.selectedIndex)

		// Tell the binder to update
		self.selectionBinder.setValue(self.selectedIndex)
	}
}
