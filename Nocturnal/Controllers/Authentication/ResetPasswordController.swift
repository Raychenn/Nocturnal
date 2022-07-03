//
//  ResetPasswordController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/18.
//

import UIKit

class ResetPasswordController: UIViewController {
    
    // MARK: - properties
    var email: String?
        
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        
        return button
    }()
    
    private let iconImageView: UIImageView = {
       let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.image = UIImage(named: "Instagram_logo_white")
        
        return img
    }()
    
    let emailTextField = CustomTextField(placeholder: "email")
    
    private lazy var resetPasswordButton: UIButton = {
        let button = AuthButton(type: .system)
        button.title = "Reset Password"
        button.addTarget(self, action: #selector(handleResetPassword), for: .touchUpInside)
       
        return button
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    // MARK: - Actions
    
    @objc func handleResetPassword() {
        print("reset password")
//        guard let email = emailTextField.text else { return }
//
//        AuthService.resetPasswrod(withEamil: email) { error in
//            self.showLoader(false)
//            if let error = error {
//
//                self.showAlert(withTitle: "Error", message: error.localizedDescription)
//                return
//            }
//
//            self.delegate?.didSendResetPassword(self)
//        }
    }
    
    @objc func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func textDidChanged(sender: UITextField) {
        
        if sender == emailTextField {
            
        }
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        navigationController?.setNavigationBarHidden(true, animated: true)
        emailTextField.text = email
        configureGradientLayer()
        
        view.addSubview(backButton)
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 16, paddingLeft: 16)
        
        view.addSubview(iconImageView)
        iconImageView.centerX(inView: view)
        iconImageView.setDimensions(height: 80, width: 120)
        iconImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        
        let stack = UIStackView(arrangedSubviews: [emailTextField, resetPasswordButton])
        stack.axis = .vertical
        stack.spacing = 5
        stack.distribution = .fillEqually
        view.addSubview(stack)
        stack.anchor(top: iconImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32)
        
        emailTextField.addTarget(self, action: #selector(textDidChanged), for: .editingChanged)
    }
}
