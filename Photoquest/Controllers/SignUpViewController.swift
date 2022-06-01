//
//  SignUpViewController.swift
//  Photoquest
//
//  Created by Nolin McFarland on 4/25/22.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var firstPageStack: UIStackView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailStatusIcon: UIImageView!
    @IBOutlet weak var emailErrorLabel: UILabel!
    
    @IBOutlet weak var secondPageStack: UIStackView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordStatusIcon: UIImageView!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordStatusIcon: UIImageView!
    @IBOutlet weak var confirmPasswordErrorLabel: UILabel!
    
    @IBOutlet weak var actionStack: UIStackView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    
    @IBOutlet weak var showPasswordButton: UIButton!
    var passwordHidden = true
    
    enum TextFieldStatusType {
        case none
        case error
        case success
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
        presentPage(firstPage: true, animated: false)
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        setActionLoading(true)
        guard let emailText = emailTextField.text, InputValidationService.validateEmail(email: emailText) else {
            updateStatus(emailStatusIcon, emailErrorLabel, status: .error, error: "Email address is not valid.")
            setActionLoading(false)
            return
        }
        
        AuthService.shared.accountExists(emailAddress: emailText) { exists in
            if exists {
                self.updateStatus(self.emailStatusIcon, self.emailErrorLabel, status: .error, error: "An account with this email address already exists.")
                self.setActionLoading(false)
            } else {
                self.presentPage(firstPage: false)
            }
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        presentPage(firstPage: true)
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        setActionLoading(true)
        guard InputValidationService.validatePassword(password: passwordTextField.text) else {
            updateStatus(passwordStatusIcon, passwordErrorLabel, status: .error, error: "Password must be at least 12 characters.")
            setActionLoading(false)
            return
        }
        guard confirmPasswordTextField.text == passwordTextField.text else {
            updateStatus(confirmPasswordStatusIcon, confirmPasswordErrorLabel, status: .error, error: "Passwords don't match.")
            setActionLoading(false)
            return
        }
        
        let emailText = emailTextField.text!
        let passwordText = passwordTextField.text!
        AuthService.shared.createUser(emailAddress: emailText, password: passwordText) { error in
            guard error == nil else {
                self.setActionLoading(false)
                self.updateStatus(self.confirmPasswordStatusIcon, self.confirmPasswordErrorLabel, status: .error, error: "Something went wrong. Please try again.")
                return
            }
            self.signUpSuccessful()
        }
    }
    
    func signUpSuccessful() {
        performSegue(withIdentifier: "segueToOnboarding", sender: self)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    @IBAction func showPasswordButtonTapped(_ sender: UIButton) {
        passwordHidden.toggle()
        showPasswordButton.setImage(
            UIImage(systemName: passwordHidden ? "eye.fill" : "eye.slash"),
            for: .normal
        )
        passwordTextField.isSecureTextEntry = passwordHidden
        confirmPasswordTextField.isSecureTextEntry = passwordHidden
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    func setActionLoading(_ loading: Bool) {
        if loading {
            setTextFieldsEnabled(false)
            actionStack.isHidden = true
            activitySpinner.startAnimating()
        } else {
            setTextFieldsEnabled(true)
            actionStack.isHidden = false
            activitySpinner.stopAnimating()
        }
    }
}

// MARK: - UI Animation Methods
extension SignUpViewController {
    
    func presentPage(firstPage: Bool, animated: Bool = true) {
        setActionLoading(true)
        headerLabel.alpha = .zero
        headerLabel.text = firstPage ? "Let's start with your email." : "Great! Let's make a password."
        
        let duration = animated ? 0.625 : 0
        let translation = CGAffineTransform(
            translationX: firstPage ? view.frame.width : -view.frame.width,
            y: 0
        )
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 4) {
            self.firstPageStack.transform = firstPage ? .identity : translation
            self.secondPageStack.transform = firstPage ? translation : .identity
        } completion: { complete in
            self.nextButton.isHidden = firstPage ? false : true
            self.doneButton.isHidden = firstPage ? true : false
            self.backButton.isHidden = firstPage ? true : false
            self.setActionLoading(false)
        }
        
        UIView.animate(withDuration: duration * 0.2, delay: duration * 0.8) {
            self.headerLabel.alpha = 1
        }
    }
    
    func animateStatusIcon(_ icon: UIImageView) {
        UIView.animate(withDuration: 0.125) {
            icon.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
        }
        UIView.animate(withDuration: 0.4, delay: 0.125, usingSpringWithDamping: 0.65, initialSpringVelocity: 5, options: .curveEaseOut) {
            icon.transform = .identity
        }
    }
    
    func animateErrorLabel(_ label: UILabel) {
        UIView.animate(withDuration: 0.075, delay: 0) {
            label.transform = CGAffineTransform(translationX: 10, y: 0)
        }
        UIView.animate(withDuration: 0.35, delay: 0.075, usingSpringWithDamping: 0.5, initialSpringVelocity: 10) {
            label.transform = .identity
        }
    }
}

// MARK: - UITextField Methods
extension SignUpViewController: UITextFieldDelegate {
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setupTextFields() {
        emailTextField.delegate = self
        emailTextField.addTarget(self, action: #selector(emailTextFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.delegate = self
        passwordTextField.addTarget(self, action: #selector(passwordTextFieldDidChange(_:)), for: .editingChanged)
        confirmPasswordTextField.delegate = self
        confirmPasswordTextField.addTarget(self, action: #selector(confirmPasswordTextFieldDidChange(_:)), for: .editingChanged)
        view.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        )
    }
    
    func setTextFieldsEnabled(_ enabled: Bool) {
        emailTextField.isEnabled = enabled
        passwordTextField.isEnabled = enabled
        confirmPasswordTextField.isEnabled = enabled
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return false
    }
    
    // Revalidate input if textField is auto-filled or pasted into
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard string.count > 1 else { return true }
        if textField == emailTextField {
            updateStatus(emailStatusIcon, emailErrorLabel, status: .none)
            emailTextFieldDidChange(textField)
        } else if textField == passwordTextField {
            updateStatus(passwordStatusIcon, passwordErrorLabel, status: .none)
            passwordTextFieldDidChange(textField)
        } else if textField == confirmPasswordTextField {
            updateStatus(confirmPasswordStatusIcon, confirmPasswordErrorLabel, status: .none)
            confirmPasswordTextFieldDidChange(textField)
        }
        return true
    }
    
    @objc func emailTextFieldDidChange(_ textField: UITextField) {
        guard InputValidationService.validateEmail(email: textField.text) else {
            updateStatus(emailStatusIcon, emailErrorLabel, status: .none)
            return
        }
        if emailStatusIcon.isHidden {
            updateStatus(emailStatusIcon, emailErrorLabel, status: .success)
        }
    }
    
    @objc func passwordTextFieldDidChange(_ textField: UITextField) {
        guard InputValidationService.validatePassword(password: textField.text) else {
            updateStatus(passwordStatusIcon, passwordErrorLabel, status: .none)
            return
        }
        if passwordStatusIcon.isHidden {
            updateStatus(passwordStatusIcon, passwordErrorLabel, status: .success)
        }
    }
    
    @objc func confirmPasswordTextFieldDidChange(_ textField: UITextField) {
        guard confirmPasswordTextField.text == passwordTextField.text else {
            updateStatus(confirmPasswordStatusIcon, confirmPasswordErrorLabel, status: .none)
            return
        }
        if confirmPasswordStatusIcon.isHidden {
            updateStatus(confirmPasswordStatusIcon, confirmPasswordErrorLabel, status: .success)
        }
    }
    
    func updateStatus(_ icon: UIImageView, _ label: UILabel, status: TextFieldStatusType, error: String? = nil) {
        switch status {
        case .none:
            icon.isHidden = true
            label.text = " "
            return
        case .error:
            icon.image = UIImage(systemName: "xmark.circle.fill")
            icon.tintColor = .red
            label.text = error ?? " "
            animateErrorLabel(label)
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .success:
            icon.image = UIImage(systemName: "checkmark.circle.fill")
            icon.tintColor = UIColor(named: "CustomTint")
            label.text = " "
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
        icon.isHidden = false
        animateStatusIcon(icon)
    }
}
