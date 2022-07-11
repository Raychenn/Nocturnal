//
//  LoginController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/18.
//

import UIKit
import CryptoKit
import AuthenticationServices
import FirebaseAuth
import AVKit
import AVFAudio

class LoginController: UIViewController {
    // MARK: - Properties
    
    private lazy var videoPlayerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private let appNameLabel: UILabel = {
       let label = UILabel()
        label.font = .satisfyRegular(size: 35)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "Nocturnal Human"
        return label
    }()
    
    private lazy var emailContainerView: InputContainerView = {
       let containerView = InputContainerView(image: UIImage(named: "mail")!, textField: emailTextField)
        
        return containerView
    }()
     
    private lazy var passwordContainerView: InputContainerView = {
       let containerView = InputContainerView(image: UIImage(named: "lock")!, textField: passwordTextField)

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
    
    private lazy var loginButton: AuthButton = {
        let button = AuthButton(type: .system)
        button.setHeight(50)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.title = "Log In"
        button.addTarget(self, action: #selector(handleLogIn), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var signinWithAppleButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .black)
        button.setDimensions(height: 50, width: 12)
        button.addTarget(self, action: #selector(handleLoginWithApple), for: .touchUpInside)
        return button
    }()
    
    private lazy var dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
            
        button.attributedTitle(for: "Don't have an account?  ", secondPart: "Sign Up")
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()
    
    private let agreementLabel: UILabel = {
       let label = UILabel()
        label.text = "By signing in, you agree to our privacy policy and EULA"
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    private lazy var privacyButton: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("privay policy", for: .normal)
        button.setTitleColor(UIColor.lightBlue, for: .normal)
        button.addTarget(self, action: #selector(didTapPrivacy), for: .touchUpInside)
        return button
    }()
    
    private lazy var eulaButton: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("EULA", for: .normal)
        button.setTitleColor(UIColor.lightBlue, for: .normal)
        button.addTarget(self, action: #selector(didTapEULA), for: .touchUpInside)
        return button
    }()
    
    let popupVC = PopupAlertController()
    
    var currentNonce: String?
    
    var player: AVQueuePlayer?
    
    var audioPlayer: AVAudioPlayer?
    
    var playerLooper: AVPlayerLooper?
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureNavBar()
        playVideo()
        playSound()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetLoginScreenInitialState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateLogin()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        player = nil
        videoPlayerView.layer.sublayers?.removeAll()
        audioPlayer = nil
    }
    
    // MARK: - selectors
    
    @objc func didTapPrivacy() {
        let privacyVC = PrivacyPolicyController()
        
        self.present(privacyVC, animated: true)
    }
    
    @objc func didTapEULA() {
        let eulaVC = EULAController()
        
        self.present(eulaVC, animated: true)
    }
    
    @objc func handleShowSignUp() {
        let controller = RegistrationController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleLogIn() {
        guard let email = emailTextField.text, let password = passwordTextField.text, !email.isEmpty, !password.isEmpty else {
            popupVC.modalTransitionStyle = .crossDissolve
            popupVC.modalPresentationStyle = .overCurrentContext
            popupVC.delegate = self
            loginButton.buzz()
            present(self.popupVC, animated: true)
            return
        }
            loginButton.configuration?.showsActivityIndicator = true
            presentLoadingView(shouldPresent: true)
            AuthService.shared.logUserIn(with: email, password: password) { [weak self]  _, error in
                guard let self = self else { return }
                if let error = error {
                    self.presentLoadingView(shouldPresent: false)
                    self.presentErrorAlert(title: "Error", message: "\(String(describing: error.localizedDescription))", completion: nil)
                    return
                } else {
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
                    self.presentLoadingView(shouldPresent: false)
                    tab.authenticateUserAndConfigureUI()
                    self.loginButton.configuration?.showsActivityIndicator = false
                    print("successfully logged user in")
                    self.dismiss(animated: true)
                }
            }
    }
    
    @objc func handleLoginWithApple() {
        print("log in apple")
        startSignInWithAppleFlow()
    }
    
    // MARK: - helpers
    
    private func resetLoginScreenInitialState() {
        self.videoPlayerView.alpha = 0.7
        self.appNameLabel.alpha = 0
        self.emailContainerView.alpha = 0
        self.passwordContainerView.alpha = 0
        self.loginButton.alpha = 0
        self.signinWithAppleButton.alpha = 0
        self.dontHaveAccountButton.alpha = 0
    }
    
    private func animateLogin() {
        UIView.animate(withDuration: 1) {
            self.videoPlayerView.alpha = 1
        } completion: { _ in
            self.showTitle()
        }
    }
    
    private func showTitle() {
        UIView.animate(withDuration: 1) {
            self.appNameLabel.alpha = 1
        } completion: { _ in
            self.showTextFields()
        }
    }
    
    private func showTextFields() {
        UIView.animate(withDuration: 1) {
            self.emailContainerView.alpha = 1
            self.passwordContainerView.alpha = 1
        } completion: { _ in
            self.showLoginButtons()
        }
    }
    
    private func showLoginButtons() {
        UIView.animate(withDuration: 1) {
            self.loginButton.alpha = 1
            self.signinWithAppleButton.alpha = 1
            self.dontHaveAccountButton.alpha = 1
        }
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        navigationController?.navigationBar.barStyle = .black
        
        view.addSubview(videoPlayerView)
        videoPlayerView.fillSuperview()
        
        view.addSubview(appNameLabel)
        appNameLabel.centerX(inView: view)
        appNameLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView, passwordContainerView, loginButton, signinWithAppleButton])
        stack.axis = .vertical
        stack.spacing = 15
        stack.distribution = .fillEqually
        
        view.addSubview(stack)
        stack.anchor(top: appNameLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.centerX(inView: view)
        dontHaveAccountButton.anchor(top: stack.bottomAnchor, paddingTop: 15)
        
        view.addSubview(agreementLabel)
        agreementLabel.anchor(left: stack.leftAnchor,
                              right: stack.rightAnchor)
        
        view.addSubview(privacyButton)
        NSLayoutConstraint.activate([
            privacyButton.centerXAnchor.constraint(equalTo: agreementLabel.centerXAnchor, constant: -80)
        ])
        privacyButton.anchor(top: agreementLabel.bottomAnchor,
                             bottom: view.safeAreaLayoutGuide.bottomAnchor,
                             paddingTop: 8)
        
        view.addSubview(eulaButton)
        NSLayoutConstraint.activate([
            eulaButton.centerXAnchor.constraint(equalTo: agreementLabel.centerXAnchor, constant: 80)
        ])
        eulaButton.anchor(top: agreementLabel.bottomAnchor,
                          bottom: view.safeAreaLayoutGuide.bottomAnchor,
                          paddingTop: 8)
        
    }
    private func configureNavBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
    
    private func playVideo() {
        guard let path = Bundle.main.path(forResource: "intro", ofType: "mp4") else {
            print("no intro resouce")
            return
        }
        self.player = AVQueuePlayer()
        guard let player = player else { return }
        let playerItem = AVPlayerItem(url: URL(fileURLWithPath: path))
        playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        playerLayer.videoGravity = .resizeAspectFill
        self.videoPlayerView.layer.addSublayer(playerLayer)
        player.play()
    }
    
    private func playSound() {
        guard let url = Bundle.main.url(forResource: "enigma", withExtension: "mp3") else {
            print("can not find music resource in log in")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            audioPlayer = try AVAudioPlayer(contentsOf: url)

            guard let audioPlayer = audioPlayer else { return }

            audioPlayer.play()

        } catch let error {
            self.presentErrorAlert(message: "\(error.localizedDescription)")
            print("Fail to play music \(error)")
        }
    }
    
    // MARK: - Apple sign in
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    func startSignInWithAppleFlow() {
      let nonce = randomNonceString()
      currentNonce = nonce
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
      request.nonce = sha256(nonce)

      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = self
      authorizationController.performRequests()
    }
}

// MARK: - Apple Login
extension LoginController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
          guard let nonce = currentNonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
          }
          guard let appleIDToken = appleIDCredential.identityToken else {
            print("Unable to fetch identity token")
            return
          }
          guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
            return
          }
            
          // Initialize a Firebase credential.
          let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                    idToken: idTokenString,
                                                    rawNonce: nonce)
            presentLoadingView(shouldPresent: true)
          // Sign in with Firebase.
          Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
              guard let self = self else { return }
              if error != nil {
              // Error. If error.code == .MissingOrInvalidNonce, make sure
              // you're sending the SHA256-hashed nonce as a hex string with
              // your request to Apple.
             self.presentLoadingView(shouldPresent: false)
             self.presentErrorAlert(title: "Error", message: "Fail to log in with Apple: \(String(describing: error!.localizedDescription))", completion: nil)
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
              
              let uid = authResult?.user.uid ?? ""

              UserService.shared.checkIfUserExist(uid: uid) { [weak self] result in
                  guard let self = self else { return }
                  switch result {
                  case .success(let isExisted):
                      if isExisted {
                          // go to main tab bar controller and fetch user data
                          tab.authenticateUserAndConfigureUI()
                          self.presentLoadingView(shouldPresent: false)
                          self.dismiss(animated: true)
                      } else {
                        // Create new user
                          let firstname = appleIDCredential.fullName?.givenName ?? "Unkown"
                          let familyname = appleIDCredential.fullName?.familyName ?? "Unkown family name"
                          let username = "\(firstname) \(familyname)"
                            let email = authResult?.user.email ?? ""
                          AuthService.shared.uploadNewUser(withId: uid, name: username, email: email) { error in
                              guard error == nil else {
                                  self.presentErrorAlert(message: "\(error!.localizedDescription)")
                                  self.presentLoadingView(shouldPresent: false)
                                  print("Fail to upload new user \(String(describing: error))")
                                  return
                              }
                              print("did Sign in appleeee")
                              tab.authenticateUserAndConfigureUI()
                              self.presentLoadingView(shouldPresent: false)
                              self.dismiss(animated: true)
                          }
                      }
                  case .failure(let error):
                      self.presentErrorAlert(message: "\(error.localizedDescription)")
                      self.presentLoadingView(shouldPresent: false)
                      print("Fail to if check user is existed \(error)")
                  }
              }
          }
        }
      }
      func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
          
          switch error {
          case ASAuthorizationError.canceled:
              break
          case ASAuthorizationError.failed:
              break
          case ASAuthorizationError.invalidResponse:
              break
          case ASAuthorizationError.notHandled:
              break
          case ASAuthorizationError.unknown:
              break
          default:
              break
          }
                      
          print("didCompleteWithError: \(error.localizedDescription)")
      }
}

extension LoginController: PopupAlertControllerDelegate {
    
    func handleDismissal() {
        popupVC.dismiss(animated: true)
    }

}
