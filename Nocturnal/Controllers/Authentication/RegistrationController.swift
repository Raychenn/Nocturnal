//
//  RegistrationController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/18.
//
import UIKit
import FirebaseFirestore
 
protocol RegistrationControllerDelegate: AnyObject {
    func didPopController()
}

class RegistrationController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: RegistrationControllerDelegate?
    
    private var profileImage: UIImage?
    
    let popupVC = PopupAlertController()
    
    private lazy var plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "plus_photo"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(didTapplusPhotoButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var emailContainerView: InputContainerView = {
       let containerView = InputContainerView(image: UIImage(named: "mail")!, textField: emailTextField)
        
        return containerView
    }()
     
    private lazy var passwordContainerView: InputContainerView = {
       let containerView = InputContainerView(image: UIImage(named: "lock")!, textField: passwordTextField)
        
        return containerView
    }()
    
    private lazy var fullnameContainerView: InputContainerView = {
       let containerView = InputContainerView(image: UIImage(named: "person")!, textField: fullNameTextField)

        return containerView
    }()
    
    private let emailTextField: CustomTextField = {
       let textField = CustomTextField(placeholder: "Email")
        return textField
    }()
    private let passwordTextField: CustomTextField = {
       let textField = CustomTextField(placeholder: "Password")
        textField.isSecureTextEntry = true
        
        return textField
    }()
    
    private let fullNameTextField: UITextField = CustomTextField(placeholder: "Full Name")
        
    private lazy var signUpButton: AuthButton = {
        let button = AuthButton(type: .system)
        button.title = "Sign Up"
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
    private lazy var alreadyHasAcouuntButton: UIButton = {
        let button = UIButton(type: .system)
        button.attributedTitle(for: "Already has an account? ", secondPart: "Log In")
        button.addTarget(self, action: #selector(handleShowLogIn), for: .touchUpInside)
        return button
    }()
    
    private let backgroundImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "registerBg")
        return imageView
    }()
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        confiureUI()
    }
    
    // MARK: - selectors
    
    @objc func handleShowLogIn() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapplusPhotoButton() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    @objc func handleSignUp() {
        
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              let fullName = fullNameTextField.text,
              let profileImage = self.profileImage,
              !email.isEmpty, !password.isEmpty, !fullName.isEmpty else {
            
            popupVC.modalTransitionStyle = .crossDissolve
            popupVC.modalPresentationStyle = .overCurrentContext
            popupVC.delegate = self
            signUpButton.buzz()
            self.present(popupVC, animated: true)
            return
        }
        
        signUpButton.configuration?.showsActivityIndicator = true
        presentLoadingView(shouldPresent: true)
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
                            blockedUsersId: [],
                            requestedEventsId: [])
            
            AuthService.shared.registerUser(withUser: user, password: password) { [weak self] error in
                guard let self = self else { return }
                guard error == nil else {
                    self.presentLoadingView(shouldPresent: false)
                    self.presentErrorAlert(title: "Error", message: error!.localizedDescription, completion: nil)
                    return
                }
                var keyWindow: UIWindow? {
                    // Get connected scenes
                    return UIApplication.shared.connectedScenes
                        // Keep only active scenes, onscreen and visible to the user
                        .filter { $0.activationState == .foregroundActive }
                        // Keep only the first `UIWindowScene`
                        .first(where: { $0 is UIWindowScene })
                        // Get its associated windows
                        .flatMap({ $0 as? UIWindowScene })?.windows
                        // Finally, keep only the key window
                        .first(where: \.isKeyWindow)
                }

                guard let tab = keyWindow?.rootViewController as? MainTabBarController else {
                    print("no tab bar controller")
                    return
                }

                print("successfully register user with firestore")
                self.presentLoadingView(shouldPresent: false)
                tab.authenticateUserAndConfigureUI()
                self.signUpButton.configuration?.showsActivityIndicator = false
                self.dismiss(animated: true)
            }
        }
    }
    
    // MARK: - helpers
    
    private func confiureUI() {
        self.navigationController?.delegate = self
//        configureGradientLayer()
        
        view.addSubview(backgroundImageView)
        backgroundImageView.alpha = 1
        backgroundImageView.fillSuperview()
        
        let blurView = CustomBlurEffectView()
        blurView.frame = view.bounds
        view.addSubview(blurView)
        
        view.addSubview(plusPhotoButton)
        plusPhotoButton.centerX(inView: view)
        plusPhotoButton.setDimensions(height: 140, width: 140)
        plusPhotoButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView, passwordContainerView, fullnameContainerView, signUpButton])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 15
        
        view.addSubview(stack)
        stack.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(alreadyHasAcouuntButton)
        alreadyHasAcouuntButton.centerX(inView: view)
        alreadyHasAcouuntButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
        
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

extension RegistrationController: PopupAlertControllerDelegate {
    
    func handleDismissal() {
        popupVC.dismiss(animated: true)
    }
}

extension RegistrationController {
    
    override func willMove(toParent parent: UIViewController?) {
   
        /*You can detect here when the viewcontroller is being popped*/
        delegate?.didPopController()
    }
    
}
