//
//  RegistrationController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/18.
//
import UIKit
import FirebaseFirestore

class RegistrationController: UIViewController {
    
    // MARK: - Properties
    
    private var profileImage: UIImage?
    
    private lazy var plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(didTapplusPhotoButton), for: .touchUpInside)
        return button
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
    
    private let fullNameTextField: UITextField = CustomTextField(placeholder: "Full Name")
        
    private lazy var signUpButton: UIButton = {
        let button = AuthButton(type: .system)
        button.title = "Sign Up"
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
    private lazy var alreadyHasAcouuntButton: UIButton = {
        let button = UIButton(type: .system)
        button.attributedTitle(for: "Already has an account? ", secondPart: "Log In")
        button.addTarget(self, action: #selector(handleShowLogIn), for: .touchUpInside)
        return button
    }()
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        confiureUI()
        configureNotificationObserver()
    }
    
    // MARK: - selectors
    
    @objc func handleShowLogIn() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func textDidChange(_ sender: UITextField) {
        if sender == emailTextField {
            
        } else if sender == passwordTextField {
            
        } else if sender == fullNameTextField {
            
        } else {
            
        }
    }
    
    @objc func didTapplusPhotoButton() {
        print("present photo library and let user select")
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    @objc func handleSignUp() {
        
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let fullName = fullNameTextField.text else { return }
        guard let profileImage = self.profileImage else { return }
        
        signUpButton.configuration?.showsActivityIndicator = true
        
        StorageUploader.shared.uploadProfileImage(with: profileImage) { downloadedImgURL in
            
            let defaultGender = Gender.unspecified.rawValue
            
            let user = User(name: fullName,
                            email: email,
                            country: "",
                            profileImageURL: downloadedImgURL,
                            birthday: Timestamp(date: Date()),
                            gender: defaultGender,
                            numberOfHostedEvents: 0,
                            bio: "",
                            joinedEventsId: [],
                            blockedUsersId: [])
            
            AuthService.shared.registerUser(withUser: user, password: password) { [weak self] error in
                guard let self = self else { return }
                guard error == nil else {
                    print("Error signing user up \(String(describing: error))")
                    return
                }
                
                self.signUpButton.configuration?.showsActivityIndicator = false
                self.dismiss(animated: true)
                print("successfully register user with firestore")
            }
        }
    }
    
    // MARK: - helpers
    
    private func confiureUI() {
        configureGradientLayer()
        
        view.addSubview(plusPhotoButton)
        plusPhotoButton.centerX(inView: view)
        plusPhotoButton.setDimensions(height: 140, width: 140)
        plusPhotoButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        
        let stack = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, fullNameTextField, signUpButton])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 20
        
        view.addSubview(stack)
        stack.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(alreadyHasAcouuntButton)
        alreadyHasAcouuntButton.centerX(inView: view)
        alreadyHasAcouuntButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
        
    }
    
    private func configureNotificationObserver() {
        
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        fullNameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension RegistrationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        guard let selectedPhoto = info[.editedImage] as? UIImage else {
            return
        }
        plusPhotoButton.layer.cornerRadius =  plusPhotoButton.frame.width/2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.white.cgColor
        plusPhotoButton.layer.borderWidth = 2
        plusPhotoButton.setImage(selectedPhoto.withRenderingMode(.alwaysOriginal), for: .normal)
        
        profileImage = selectedPhoto
        self.dismiss(animated: true, completion: nil)
    }
}
