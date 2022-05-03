//
//  SignInViewController.swift
//  Photoquest
//
//  Created by Nolin McFarland on 4/25/22.
//

import UIKit

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordStatusIcon: UIImageView!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    
    @IBOutlet weak var showPasswordButton: UIButton!
    var passwordHidden = true
    
    enum TextFieldStatusType {
        case none
        case error
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
    }
    
    func setActionLoading(_ loading: Bool) {
        if loading {
            setTextFieldsEnabled(false)
            signInButton.isHidden = true
            activitySpinner.startAnimating()
        } else {
            setTextFieldsEnabled(true)
            signInButton.isHidden = false
            activitySpinner.stopAnimating()
        }
    }
    
    @IBAction func showPasswordButtonTapped(_ sender: Any) {
        passwordHidden.toggle()
        showPasswordButton.setImage(
            UIImage(systemName: passwordHidden ? "eye.fill" : "eye.slash"),
            for: .normal
        )
        passwordTextField.isSecureTextEntry = passwordHidden
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        setActionLoading(true)
        
        // Validate email address format before attempting sign in
        guard let emailText = emailTextField.text, InputValidationService.validateEmail(email: emailText) else {
            setActionLoading(false)
            updateStatus(passwordStatusIcon, passwordErrorLabel, status: .error, error: "Invalid email address or password.")
            return
        }
        
        //Validate password is not empty before attempting sign in
        guard let passwordText = passwordTextField.text, !passwordText.isEmpty else {
            setActionLoading(false)
            updateStatus(passwordStatusIcon, passwordErrorLabel, status: .error, error: "Invalid email address or password.")
            return
        }
        
        // Attempt sign in
        AuthService.shared.signIn(emailAddress: emailText, password: passwordText) { error in
            guard error == nil else {
                self.setActionLoading(false)
                self.updateStatus(self.passwordStatusIcon, self.passwordErrorLabel, status: .error, error: "Invalid email address or password.")
                return
            }
            self.signInSuccessful()
        }
    }
    
    func signInSuccessful() {
        view.window?.rootViewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "rootTabViewController")
        view.window?.makeKeyAndVisible()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

// MARK: UI Animation Methods
extension SignInViewController {

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
extension SignInViewController: UITextFieldDelegate {
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setupTextFields() {
        emailTextField.delegate = self
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.delegate = self
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        view.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        )
    }
    
    func setTextFieldsEnabled(_ enabled: Bool) {
        emailTextField.isEnabled = enabled
        passwordTextField.isEnabled = enabled
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return false
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        updateStatus(passwordStatusIcon, passwordErrorLabel, status: .none)
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
        }
        icon.isHidden = false
        animateStatusIcon(icon)
    }
}
