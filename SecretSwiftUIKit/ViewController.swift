//
//  ViewController.swift
//  SecretSwiftUIKit
//
//  Created by Justin Hold on 3/20/24.
//

import UIKit

class ViewController: UIViewController {

	// MARK: - @IBOUTLET
	@IBOutlet var secretText: UITextView!
	
	
	// MARK: - VIEWDIDLOAD
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		let notificationCenter = NotificationCenter.default
		
		notificationCenter.addObserver(
			self,
			selector: #selector(adjustForKeyboard),
			name: UIResponder.keyboardWillHideNotification,
			object: nil
		)
		
		notificationCenter.addObserver(
			self,
			selector: #selector(adjustForKeyboard),
			name: UIResponder.keyboardWillChangeFrameNotification,
			object: nil
		)
	}

	// MARK: - @IBACTION
	@IBAction func authenticateTapped(_ sender: Any) {
		
	}
	
	// MARK: - @OBJC FUNCTIONS
	@objc func adjustForKeyboard(notification: Notification) {
		guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
		
		let keyboardScreenEnd = keyboardValue.cgRectValue
		let keyboardViewEndFrame = view.convert(keyboardScreenEnd, from: view.window)
		
		if notification.name == UIResponder.keyboardWillHideNotification {
			secretText.contentInset = .zero
		} else {
			secretText.contentInset = UIEdgeInsets(
				top: 0,
				left: 0,
				bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom,
				right: 0
			)
		}
		
		secretText.scrollIndicatorInsets = secretText.contentInset
		let selectedRange = secretText.selectedRange
		secretText.scrollRangeToVisible(selectedRange)
	}
	
}

