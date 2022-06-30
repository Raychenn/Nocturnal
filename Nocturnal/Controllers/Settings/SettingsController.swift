//
//  SettingsController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/28.
//
import UIKit

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
    
    private lazy var backButton
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
        
    private func setupUI() {
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.fillSuperview()
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
                break
            case .rate:
                break
            case .feedback:
                break
            case .eula:
                break
            case .blockedList:
                let blockedListVC = BlockedUsersController()
                navigationController?.pushViewController(blockedListVC, animated: true)
            case .signout:
                break
            }
        } else {
            
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SettingHeader.identifier) as? SettingHeader else { return UIView() }
            
            return header
        }
        
        return UIView()
    }
   
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 270: 15
    }
}
