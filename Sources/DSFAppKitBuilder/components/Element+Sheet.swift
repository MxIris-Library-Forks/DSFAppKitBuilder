//
//  Element+Sheet.swift
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

import Foundation
import AppKit.NSView
import DSFValueBinders

// MARK: - Presenting sheet

extension Element {
	/// Attach a sheet to this element
	/// - Parameters:
	///   - isVisible: A ValueBinder to indicate whether the sheet is visible or not
	///   - builder: A builder for creating the sheet content
	/// - Returns: self
	public func sheet(isVisible: ValueBinder<Bool>, _ builder: @escaping () -> Element) -> Self {
		let sheetInstance = SheetInstance(parent: self, isVisible: isVisible, builder)
		self.attachedObjects.append(sheetInstance)
		return self
	}
}

// MARK: Sheet instance wrapper

private class SheetInstance {
	init(parent: Element, isVisible: ValueBinder<Bool>, _ builder: @escaping () -> Element) {
		self.parent = parent
		self.viewController = DSFAppKitBuilderAssignableViewController(builder)
		self.isVisible = isVisible

		isVisible.register(self) { [weak self] state in
			guard let `self` = self else { return }
			if state == true {
				self.presentSheet()
			}
			else {
				self.dismissSheet()
			}
		}
	}

	deinit {
		self.isVisible.deregister(self)
		if DSFAppKitBuilderShowDebuggingOutput {
			Swift.print("\(self.self): deinit")
		}
	}

	private func presentSheet() {
		// Attach the sheet to the window that contains this element
		guard let parentWindow = self.parent?.view().window else { return }

		let window = KeyableWindow(
			contentRect: .zero,
			styleMask: [.resizable],
			backing: .buffered,
			defer: true
		)

		window.title = "something"
		window.isReleasedWhenClosed = true
		window.isMovableByWindowBackground = false
		window.autorecalculatesKeyViewLoop = true

		let content = NSView()
		content.autoresizingMask = [.width, .height]

		viewController.reloadBody()
		content.addSubview(viewController.view)
		viewController.view.pinEdges(to: content)

		window.contentView = content

		window.recalculateKeyViewLoop()

		parentWindow.beginSheet(window)
	}

	private func dismissSheet() {
		guard
			let parentWindow = self.parent?.view().window,
			let sheetWindow = self.viewController.view.window
		else {
			return
		}
		parentWindow.endSheet(sheetWindow)

		viewController.reset()
	}

	weak var parent: Element?
	let viewController: DSFAppKitBuilderAssignableViewController
	let isVisible: ValueBinder<Bool>

	class KeyableWindow: NSWindow {
		override var canBecomeKey: Bool { true }
	}
}
