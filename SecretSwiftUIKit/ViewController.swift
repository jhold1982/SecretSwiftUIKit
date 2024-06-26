//
//  ViewController.swift
//  Project28
//
//  Created by TwoStraws on 19/08/2016.
//  Copyright © 2016 Paul Hudson. All rights reserved.
//

import LocalAuthentication
import UIKit

class ViewController: UIViewController {
	@IBOutlet var secretText: UITextView!

	override func viewDidLoad() {
		super.viewDidLoad()

		title = "Nothing to see here"

		let notificationCenter = NotificationCenter.default
		notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
		notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
		notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)
	}

	@objc func adjustForKeyboard(notification: Notification) {
		let userInfo = notification.userInfo!

		let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
		let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

		if notification.name == UIResponder.keyboardWillHideNotification {
			secretText.contentInset = UIEdgeInsets.zero
		} else {
			secretText.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
		}

		secretText.scrollIndicatorInsets = secretText.contentInset

		let selectedRange = secretText.selectedRange
		secretText.scrollRangeToVisible(selectedRange)
	}

	@IBAction func authenticateTapped(_ sender: AnyObject) {
		let context = LAContext()
		var error: NSError?

		if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
			let reason = "Identify yourself!"

			context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
				[unowned self] (success, authenticationError) in

				DispatchQueue.main.async {
					if success {
						self.unlockSecretMessage()
					} else {
						let ac = UIAlertController(title: "Authentication failed", message: "You could not be verified; please try again.", preferredStyle: .alert)
						ac.addAction(UIAlertAction(title: "OK", style: .default))
						self.present(ac, animated: true)
					}
				}
			}
		} else {
			let ac = UIAlertController(title: "Biometry unavailable", message: "Your device is not configured for biometric authentication.", preferredStyle: .alert)
			ac.addAction(UIAlertAction(title: "OK", style: .default))
			self.present(ac, animated: true)
		}
	}

	func unlockSecretMessage() {
		secretText.isHidden = false
		title = "Secret stuff!"

		if let text = KeychainWrapper.standard.string(forKey: "SecretMessage") {
			secretText.text = text
		}
	}

	@objc func saveSecretMessage() {
		if !secretText.isHidden {
			KeychainWrapper.standard.set(secretText.text, forKey: "SecretMessage")
			secretText.resignFirstResponder()
			secretText.isHidden = true
			title = "Nothing to see here"
		}
	}
}
