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
        case service
        case delete
        case blockedList
        case signout
        
        var description: String {
            switch self {
            case .privacy:
                return "Privacy policy"
            case .service:
                return "Terms of serivce"
            case .delete:
                return "Delete account"
            case .blockedList:
                return "Blocked users"
            case .signout:
                return "Sign out"
            }
        }
    }
    
    let settings: [SettingType] = [.privacy, .service, .delete, .blockedList, .signout]
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 20
        layout.sectionInset = .init(top: 20, left: 0, bottom: 20, right: 0)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(SettingCell.self, forCellWithReuseIdentifier: SettingCell.id)
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
        SettingType.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let settingCell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingCell.id, for: indexPath) as? SettingCell else { return UICollectionViewCell() }
        
        let setting = settings[indexPath.item].description
        
        settingCell.configureCell(title: setting)
        return settingCell
    }
}

extension SettingsController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedSetting = settings[indexPath.item]
        
      
    }
}

extension SettingsController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width - 40, height: 100)
    }
}
