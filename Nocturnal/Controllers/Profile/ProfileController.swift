//
//  ProfileController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/14.
//

import UIKit

class ProfileController: UIViewController {

    // MARK: - Properties
    
    private lazy var collectionView: UICollectionView = {
           let layout = UICollectionViewFlowLayout()
            layout.sectionInset = .init(top: 10, left: 0, bottom: 0, right: 0)
            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: ProfileCell.identifier)
            collectionView.register(BioCell.self, forCellWithReuseIdentifier: BioCell.identifier)
            collectionView.register(JoinedEventCell.self, forCellWithReuseIdentifier: JoinedEventCell.identifier)
            collectionView.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileHeader.identifier)
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.allowsSelection = false
            collectionView.backgroundColor = .black
            collectionView.showsVerticalScrollIndicator = false
            collectionView.contentInsetAdjustmentBehavior = .never
            return collectionView
        }()
    
    private var currentUser: User
        
    private var joinedEventURLs: [String] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    let gradient = CAGradientLayer()
    
    // MARK: - Life Cycle
    
    init(user: User) {
        self.currentUser = user
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchJoinEvents()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUser()
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        gradient.removeFromSuperlayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - API

    private func fetchJoinEvents() {
        EventService.shared.fetchEvents(fromEventIds: currentUser.joinedEventsId) { result in
            switch result {
            case .success(let events):
                events.forEach({ self.joinedEventURLs.append($0.eventImageURL) })
            case .failure(let error):
                print("Fail to fetch events \(error)")
            }
        }
    }
    
    private func fetchUser() {
        UserService.shared.fetchUser(uid: currentUser.id ?? "") { result in
            switch result {
            case .success(let user):
                print("current user name in profile \(user.name)")
                self.currentUser = user
                self.collectionView.reloadData()
            case .failure(let error):
                print("Fail to fetch user \(error)")
            }
        }
    }
    
    // MARK: - Helpers
    func setupUI() {
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
        view.addSubview(collectionView)
        collectionView.fillSuperview()
    }
}

// MARK: - UICollectionViewDataSource
extension ProfileController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let profileCell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileCell.identifier, for: indexPath) as? ProfileCell else { return UICollectionViewCell()}
        
        guard let bioCell = collectionView.dequeueReusableCell(withReuseIdentifier: BioCell.identifier, for: indexPath) as? BioCell else { return UICollectionViewCell() }
        
        guard let joinedEventCell = collectionView.dequeueReusableCell(withReuseIdentifier: JoinedEventCell.identifier, for: indexPath) as? JoinedEventCell else { return UICollectionViewCell() }
        
        if indexPath.item == 0 {
            profileCell.user = currentUser
            profileCell.delegate = self
            profileCell.configureCell(with: currentUser)
            return profileCell
        } else if indexPath.item == 1 {
            bioCell.configureCell(bioText: currentUser.bio)
            return bioCell
        } else {
            joinedEventCell.user = currentUser
            joinedEventCell.configureCell(joinedEventsURL: joinedEventURLs)
            joinedEventCell.delegate = self
            joinedEventCell.isHidden = joinedEventURLs.count == 0 ? true: false
            return joinedEventCell
        }
    }
}

// MARK: - UICollectionViewDelegate

extension ProfileController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let profileHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ProfileHeader.identifier, for: indexPath) as? ProfileHeader else { return UICollectionReusableView() }
        
        profileHeader.configureHeader(user: currentUser)
        let gradientView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 400))
        gradient.frame = gradientView.frame
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradient.locations = [0.0, 1.3]
        gradientView.layer.insertSublayer(gradient, at: 0)
        profileHeader.profileImageView.addSubview(gradientView)
        profileHeader.bringSubviewToFront(gradientView)
        
        return profileHeader
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 400)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ProfileController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let estimatedSizeCell = BioCell(frame: frame)
        estimatedSizeCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = estimatedSizeCell.systemLayoutSizeFitting(targetSize)
        
        if indexPath.item == 1 {
            return .init(width: view.frame.width - 20, height: estimatedSize.height)
        } else {
            return CGSize(width: view.frame.width - 20, height: 200)
        }
    }
}

// MARK: - ProfileCellDelegate
extension ProfileController: ProfileCellDelegate {
    func didTapEditProfile(cell: ProfileCell) {
        let editProfileVC = EditProfileController(user: currentUser)
        navigationController?.pushViewController(editProfileVC, animated: true)
    }
    
    func didTapOpenConversation(cell: ProfileCell) {
        let conversationVC = ConversationsController()
        let nav = UINavigationController(rootViewController: conversationVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    func didTapSetting(cell: ProfileCell) {
        let settingVC = SettingsController()
        navigationController?.pushViewController(settingVC, animated: true)
    }
}
// MARK: - JoinedEventCellDelegate
extension ProfileController: JoinedEventCellDelegate {
    
    func didTapSelectedEvent(cell: JoinedEventCell, event: Event) {
        let detailController = EventDetailController(event: event)
        detailController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailController, animated: true)

    }
}
