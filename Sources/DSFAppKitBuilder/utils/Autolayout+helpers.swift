//
//  Autolayout+helpers.swift
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

import AppKit

extension NSView {
	// Pin 'self' within 'other' view
	internal func pinEdges(to other: NSView, offset: CGFloat = 0, animate: Bool = false) {
		let target = animate ? animator() : self
		target.leadingAnchor.constraint(equalTo: other.leadingAnchor, constant: offset).isActive = true
		target.trailingAnchor.constraint(equalTo: other.trailingAnchor, constant: -offset).isActive = true
		target.topAnchor.constraint(equalTo: other.topAnchor, constant: offset).isActive = true
		target.bottomAnchor.constraint(equalTo: other.bottomAnchor, constant: -offset).isActive = true
	}

	// Center 'self' within 'other' view
	@discardableResult
	internal func center(in other: NSView) -> [NSLayoutConstraint] {
		let constraints = [
			NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: other, attribute: .leading, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: self, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: other, attribute: .top, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: other, attribute: .trailing, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: other, attribute: .bottom, multiplier: 1, constant: 0),

			NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: other, attribute: .centerX, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: other, attribute: .centerY, multiplier: 1, constant: 0)
		]

		other.addConstraints(constraints)
		return constraints
	}

}
