//
//  BlockedUserListCell.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/28.
//
import UIKit

class BlockedUserListCell: UICollectionViewCell {
    
    private let blockedUserListLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.text = "Blocked users"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCellUI() {
        backgroundColor = .clear
        layer.masksToBounds = false
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 5, height: 5)
        layer.shadowColor = UIColor.white.cgColor
        contentView.backgroundColor = .black
        contentView.layer.cornerRadius = 8
        
        addSubview(blockedUserListLabel)
        blockedUserListLabel.centerY(inView: self)
        blockedUserListLabel.centerX(inView: self)
    }
}
