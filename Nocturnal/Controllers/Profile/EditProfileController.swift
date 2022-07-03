//
//  EditProfileController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/22.
//

import UIKit
import FirebaseFirestore
import Kingfisher
import Lottie

class EditProfileController: UIViewController {
    
    // MARK: - Properties
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.dataSource = self
        table.delegate = self
        table.backgroundColor = .black
        table.register(EditProfileCell.self, forCellReuseIdentifier: EditProfileCell.identifier)
        table.register(EditProfileHeader.self, forHeaderFooterViewReuseIdentifier: EditProfileHeader.identifier)
        table.contentInsetAdjustmentBehavior = .never
        let footerView = UIView()
        footerView.backgroundColor = .white
        table.tableFooterView = footerView
        return table
    }()
    
    private lazy var backButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        return button
    }()

    private var currentUser: User
    
    var currentImage: UIImage?
    
    var updatedImage: UIImage?
    
    let gradient = CAGradientLayer()
    
    let loadingAnimationView: AnimationView = {
       let view = AnimationView(name: "cheers")
        view.loopMode = .loop
        view.contentMode = .scaleAspectFill
        view.animationSpeed = 1
        view.backgroundColor = .clear
        view.play()
        return view
    }()
    
    // MARK: - Life
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    init(user: User) {
        self.currentUser = user
        super.init(nibName: nil, bundle: nil)
        fetchCurrentProfileImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    private func configureAnimationView() {
        view.addSubview(loadingAnimationView)
        loadingAnimationView.centerY(inView: view)
        loadingAnimationView.centerX(inView: view)
        loadingAnimationView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        loadingAnimationView.heightAnchor.constraint(equalTo: loadingAnimationView.widthAnchor).isActive = true
    }
    
    private func stopAnimationView() {
        loadingAnimationView.stop()
        loadingAnimationView.alpha = 0
        loadingAnimationView.removeFromSuperview()
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.fillSuperview()
        view.addSubview(backButton)
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                          left: view.leftAnchor, paddingTop: 8, paddingLeft: 10)
    }
    
    private func fetchCurrentProfileImage() {
        guard let url = URL(string: currentUser.profileImageURL) else { return }
        
        do {
            let imageData = try Data(contentsOf: url)
            self.currentImage = UIImage(data: imageData)
        } catch {
            print("Fail to load current image data \(error)")
        }
    }
    
    // MARK: - Selector
    
    @objc func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
}
// MARK: - UITableViewDataSource
extension EditProfileController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let editCell = tableView.dequeueReusableCell(withIdentifier: EditProfileCell.identifier, for: indexPath) as? EditProfileCell else { return UITableViewCell() }
        editCell.delegate = self
        editCell.currentUser = currentUser
        editCell.configureCell(with: currentUser)
        return editCell
    }
    
}
// MARK: - UITableViewDelegate
extension EditProfileController: UITableViewDelegate {
 
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let editHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: EditProfileHeader.identifier) as? EditProfileHeader else { return UIView() }
        
        editHeader.configureHeader(imageURL: currentUser.profileImageURL)
        editHeader.delegate = self
        gradient.removeFromSuperlayer()
        let gradientView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 350))
        gradient.frame = gradientView.frame
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradient.locations = [0.0, 1.3]
        gradientView.layer.insertSublayer(gradient, at: 0)
        editHeader.profileImageView.addSubview(gradientView)
        editHeader.bringSubviewToFront(gradientView)
        return editHeader
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        350
    }
}
 
extension EditProfileController: EditProfileCellDelegate {
    
    func didTapSave(cell: EditProfileCell, editedData: EditProfileCellModel) {
        let currentImage = self.currentImage ?? UIImage()
         
        // update user data in firestore
        let genderString = editedData.gender
        var gender: Gender = .unspecified
        switch genderString {
        case "Male":
            gender = Gender(rawValue: 0) ?? .unspecified
        case "Female":
            gender = Gender(rawValue: 1) ?? .unspecified
        case "Unspecified":
            gender = Gender(rawValue: 2) ?? .unspecified
        default:
            break
        }
    
        let imageToUpload = updatedImage == nil ? currentImage: updatedImage ?? UIImage()
        configureAnimationView()
        self.view.isUserInteractionEnabled = false
        StorageUploader.shared.uploadProfileImage(with: imageToUpload) { [weak self] downloadedImageURL in
            guard let self = self else { return }
            let user = User(name: "\(editedData.firstname) \(editedData.familyname)",
                            email: editedData.email,
                            country: editedData.country,
                            profileImageURL: downloadedImageURL,
                            birthday: editedData.birthday,
                            gender: gender.rawValue,
                            numberOfHostedEvents: self.currentUser.numberOfHostedEvents,
                            bio: editedData.bio,
                            joinedEventsId: self.currentUser.joinedEventsId,
                            blockedUsersId: self.currentUser.blockedUsersId,
                            requestedEventsId: self.currentUser.requestedEventsId)

            UserService.shared.updateUserProfile(newUserData: user) { error in
                guard error == nil else {
                    print("Fail to update edit user \(String(describing: error))")
                    return
                }
                // Fetch new new user and reload
                UserService.shared.fetchUser(uid: uid) { result in
                    switch result {
                    case .success(let updatedUser):
                        self.currentUser = updatedUser
                        self.tableView.reloadData()
                        self.stopAnimationView()
                        self.view.isUserInteractionEnabled = true
                        self.navigationController?.popViewController(animated: true)
                    case .failure(let error):
                        print("Fail to fetch user \(error)")
                    }
                }
            }
        }
    }
}

// MARK: - EditProfileHeaderDelegate
extension EditProfileController: EditProfileHeaderDelegate {
    
    func updateProfileImage(header: EditProfileHeader) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension EditProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        guard let selectedPhoto = info[.editedImage] as? UIImage else {
            return
        }
        guard let editHeader = tableView.headerView(forSection: 0) as? EditProfileHeader else {
            print("editHeader nil")
            return
        }
        editHeader.profileImageView.image = selectedPhoto
        self.updatedImage = selectedPhoto
        picker.dismiss(animated: true)
    }
}
