//
//  LoginController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/18.
//

import UIKit

class LoginController: UIViewController {
    // MARK: - Properties
            
    private let iconImageView: UIImageView = {
       let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.image = UIImage(named: "Instagram_logo_white")
        
        return img
    }()
    
    private let emailTextField: UITextField = {
       let textField = CustomTextField(placeholder: "Email")

        return textField
    }()
    
    private let passwordTextField: UITextField = {
       let textField = CustomTextField(placeholder: "Password")
        
        textField.isSecureTextEntry = true
        
        return textField
    }()
    
    private lazy var loginButton: UIButton = {
        let button = AuthButton(type: .system)
        button.title = "Log In"
        button.addTarget(self, action: #selector(handleLogIn), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.attributedTitle(for: "Forgot your password? ", secondPart: "Get help here")
        button.addTarget(self, action: #selector(forgotPasswordButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
            
        button.attributedTitle(for: "Don't have an account?  ", secondPart: "Sign Up")
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureNotificationObserver()
    }
    
    // MARK: - selectors
    
    @objc func handleShowSignUp() {
        let controller = RegistrationController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func textDidChange(_ sender: UITextField) {
        if sender == emailTextField {
            
        } else {
            
        }
    }
    
    @objc func handleLogIn() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        loginButton.configuration?.showsActivityIndicator = true
        
        AuthService.shared.logUserIn(with: email, password: password) { _, error in
            if let error = error {
                print("Failed to log user in with error \(error)")
                return
            }
            
            self.loginButton.configuration?.showsActivityIndicator = false
            print("successfully logged user in")
            self.dismiss(animated: true)
        }
    }
    
    @objc func forgotPasswordButtonTapped() {
        let controller = ResetPasswordController()
        controller.email = emailTextField.text
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - helpers
    private func configureUI() {
        view.backgroundColor = .white
        navigationController?.navigationBar.barStyle = .black
        configureGradientLayer()
        view.addSubview(iconImageView)
        iconImageView.centerX(inView: view)
        iconImageView.setDimensions(height: 80, width: 120)
        iconImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        
        let stack = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton, forgotPasswordButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.distribution = .fillEqually
        
        view.addSubview(stack)
        stack.anchor(top: iconImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.centerX(inView: view)
        dontHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
    }
    
    private func configureNotificationObserver() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
}
