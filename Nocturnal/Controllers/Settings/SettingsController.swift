//
//  SettingsController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/28.
//
import UIKit
import FirebaseAuth
import FirebaseFirestore

class SettingsController: UIViewController {
    
    // MARK: - Properties
    
    enum SettingType: CaseIterable {
        case privacy
        case rate
        case feedback
        case eula
        case blockedList
        case signout
        
        var description: String {
            switch self {
            case .privacy:
                return "Privacy policy"
            case .rate:
                return "Rate Our App"
            case .feedback:
                return "Send us feedback"
            case .eula:
                return "EULA"
            case .blockedList:
                return "Blocked users"
            case .signout:
                return "Sign out"
            }
        }
        
        var iconName: String {
            switch self {
            case .privacy:
                return "checkerboard.shield"   
            case .rate:
                return "star.fill"
            case .feedback:
                return "square.and.pencil"
            case .eula:
                return "pentagon.lefthalf.filled"
            case .blockedList:
                return "eye.slash"
            case .signout:
                return "rectangle.portrait.and.arrow.right"
            }
        }
    }
    
    let settings: [SettingType] = [.privacy, .rate, .feedback, .eula, .blockedList, .signout]
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.contentInsetAdjustmentBehavior = .never
        table.register(SettingCell.self, forCellReuseIdentifier: SettingCell.identifier)
        table.register(DeleteAccountCell.self, forCellReuseIdentifier: DeleteAccountCell.identifier)
        table.register(SettingHeader.self, forHeaderFooterViewReuseIdentifier: SettingHeader.identifier)
        table.dataSource = self
        table.delegate = self
        table.backgroundColor = UIColor.hexStringToUIColor(hex: "#3F4E4F")
        return table
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage( UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        return button
    }()
    
    private let user: User
    
    // MARK: - Life Cycle
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - API
    
    private func handleLogout() {
        do {
            try Auth.auth().signOut()
            print("successfully sign out")
        } catch {
            print("Fail to log out \(error)")
        }
       
       checkIfUserIsLoggedIn()
    }
    
    private func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let loginController = LoginController()
                let nav = UINavigationController(rootViewController: loginController)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        }
    }
        
    // MARK: - Helpers
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.fillSuperview()
        view.addSubview(backButton)
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 8, paddingLeft: 8)
    }
    
    private func presentLogoutController() {
        let alert = UIAlertController(title: "Are you sure to log out?", message: "", preferredStyle: .actionSheet)
        
        let noAction = UIAlertAction(title: "NO", style: .default, handler: nil)
        let yesAction = UIAlertAction(title: "YES", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.handleLogout()
        }
        
        alert.addAction(noAction)
        alert.addAction(yesAction)
        self.present(alert, animated: true)
    }
    
    private func presentFeedBackAlert() {
        let alert = UIAlertController(title: "Please send any suggestion or feedback to the developer at r0975929562@gmail.com", message: "Hope you have a nice experience using this App", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    // MARK: - Selectors
    
    @objc func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension SettingsController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? settings.count: 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            guard let settingCell = tableView.dequeueReusableCell(withIdentifier: SettingCell.identifier, for: indexPath) as? SettingCell else { return UITableViewCell() }
            
            let setting = settings[indexPath.row]
            settingCell.configureCell(title: setting.description, symbolName: setting.iconName)
            settingCell.accessoryType = .disclosureIndicator

            return settingCell
            
        } else {
            guard let deleteCell = tableView.dequeueReusableCell(withIdentifier: DeleteAccountCell.identifier, for: indexPath) as? DeleteAccountCell else { return UITableViewCell() }
            
            return deleteCell
        }
    }
    
}
// MARK: - UITableViewDelegate
extension SettingsController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            let selectedSetting = settings[indexPath.row]
            
            switch selectedSetting {
            case .privacy:
                let privacyVC = PrivacyPolicyController()
                self.present(privacyVC, animated: true)
            case .rate:
                break
            case .feedback:
                presentFeedBackAlert()
            case .eula:
                let eulaVC = EULAController()
                self.present(eulaVC, animated: true)
            case .blockedList:
                let blockedListVC = BlockedUsersController()
                navigationController?.pushViewController(blockedListVC, animated: true)
            case .signout:
                presentLogoutController()
            }
        } else {
            let alert = UIAlertController(title: "Are you sure you want to delete this account?", message: "", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "YES", style: .destructive, handler: { [weak self] _ in
                guard let self = self else { return }
                // delete account
                print("start deleting account")
                self.presentLoadingView(shouldPresent: true)
                guard let currentUser = Auth.auth().currentUser else {
                    self.presentErrorAlert(message: "Can not find current user")
                    print("current user is nil in setting")
                    return
                }
            // MARK: - TODO:
                currentUser.delete { [weak self] error in
                    guard let self = self else { return }
                    if let error = error {
                        self.presentErrorAlert(message: "\(error.localizedDescription)")
                        self.presentLoadingView(shouldPresent: false)
                        return
                    }
            
                    StorageUploader.shared.uploadProfileImage(with: UIImage(systemName: "person")!) { downloadedUrl in
                        let emptyUser = User(name: "Unknown User",
                                             email: "",
                                             country: "",
                                             profileImageURL: downloadedUrl,
                                             birthday: Timestamp(date: Date()),
                                             gender: 2,
                                             numberOfHostedEvents: 0,
                                             bio: "This account has been deleted",
                                             joinedEventsId: [],
                                             blockedUsersId: [],
                                             requestedEventsId: [])
                        
                        UserService.shared.updateUserProfileForDeletion(deledtedUserId: currentUser.uid, emptyUser: emptyUser) { error in
                            if let error = error {
                                self.presentErrorAlert(message: "\(error.localizedDescription)")
                                self.presentLoadingView(shouldPresent: false)
                                return
                            }
                            
                            NotificationService.shared.updateCancelNotification(deletedUserId: currentUser.uid) { error in
                                if let error = error {
                                    self.presentErrorAlert(message: "\(error.localizedDescription)")
                                    self.presentLoadingView(shouldPresent: false)
                                    return
                                }
                                self.presentLoadingView(shouldPresent: false)
                                // remember to present login full screen
                                print("Successfully deleted user")
                                self.handleLogout()
                            }
                        }
                    }
                }
            }))
            self.present(alert, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SettingHeader.identifier) as? SettingHeader else { return UIView() }
            header.configureHeader(user: user)
            return header
        }
        
        return UIView()
    }
   
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 270: 15
    }
}
