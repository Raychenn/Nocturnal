//
//  SettingsController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/28.
//

import UIKit

class SettingsController: UIViewController {
    
    enum SettingType: CaseIterable {
        case privacy
        case rate
        case feedback
        case eula
        case delete
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
            case .delete:
                return "Delete account"
            case .blockedList:
                return "Blocked users"
            case .signout:
                return "Sign out"
            }
        }
    }
    
    let settings: [SettingType] = [.privacy, .rate, .feedback, .eula, .delete, .blockedList, .signout]
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 20
        layout.sectionInset = .init(top: 20, left: 0, bottom: 20, right: 0)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(SettingCell.self, forCellWithReuseIdentifier: SettingCell.identifier)
        collectionView.register(SettingProfileCell.self, forCellWithReuseIdentifier: SettingProfileCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        navigationController?.navigationBar.isHidden = false
        view.backgroundColor = .white
        view.addSubview(collectionView)
        navigationItem.title = "Settings"
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
}

extension SettingsController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        SettingType.allCases.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let profileCell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingProfileCell.identifier, for: indexPath) as? SettingCell else { return UICollectionViewCell() }

        return profileCell
        
//        if indexPath.item == 0 {
//            guard let profileCell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingProfileCell.identifier, for: indexPath) as? SettingCell else { return UICollectionViewCell() }
//
//            return profileCell
//        } else {
//            guard let settingCell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingCell.identifier, for: indexPath) as? SettingCell else { return UICollectionViewCell() }
//            
//            let setting = settings[indexPath.item].description
//            settingCell.configureCell(title: setting)
//            return settingCell
//        }
    }
}

extension SettingsController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension SettingsController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == 0 {
            return CGSize(width: view.frame.size.width - 40, height: 100)
        } else {
            return CGSize(width: view.frame.size.width - 40, height: 50)
        }        
    }
}
