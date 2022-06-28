//
//  HomeEventCell.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/25.
//

import UIKit
import Kingfisher
import FirebaseFirestore

class HomeEventCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    private let eventImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .lightGray
        
        return imageView
    }()
    
    private let eventNameLabel: UILabel = {
       let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 22, weight: .bold)
        
        return label
    }()
   
    private let dateImageview: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "calendar")
        imageView.tintColor = .lightGray
        return imageView
    }()
    
    private let dateLabel: UILabel = {
       let label = UILabel()
        label.text = "Loading date"
        label.textColor = .lightGray
        return label
    }()
    
    private let feeImageview: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "ticket")
        imageView.tintColor = .lightGray
        return imageView
    }()
    
    private let feeLabel: UILabel = {
       let label = UILabel()
        label.text = "Loading fee"
        label.textColor = .lightGray
        return label
    }()
    
    private let profileImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let hostNameLabel: UILabel = {
        let label = UILabel()
         label.text = "Loading host"
         label.textColor = .white
         return label
    }()
    
    private let bottomBackgroundView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.hexStringToUIColor(hex: "#1C242F")
        return view
    }()

    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        profileImageView.layer.cornerRadius = 25/2
        profileImageView.layer.masksToBounds = true
    }
    
    // MARK: - Heleprs
    
    func configureCell(event: Event, host: User) {
        guard let url = URL(string: event.eventImageURL) else { return }
        guard let profileUrl = URL(string: host.profileImageURL) else { return }
        eventImageView.kf.setImage(with: url)
        dateLabel.text = Date.dateFormatter.string(from: event.startingDate.dateValue())
        eventNameLabel.text = event.title
        feeLabel.text = "$\(event.fee)"
        profileImageView.kf.setImage(with: profileUrl)
        hostNameLabel.text = host.name
    }
    
    func setupCellUI() {
        layer.cornerRadius = 20
        layer.masksToBounds = true
        backgroundColor = .black
        contentView.addSubview(eventImageView)
        eventImageView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, height: 210)
        
        contentView.addSubview(bottomBackgroundView)
        bottomBackgroundView.anchor(top: eventImageView.bottomAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor)
        
        bottomBackgroundView.addSubview(eventNameLabel)
        eventNameLabel.anchor(top: bottomBackgroundView.topAnchor,
                              left: bottomBackgroundView.leftAnchor,
                              right: bottomBackgroundView.rightAnchor,
                              paddingTop: 12, paddingLeft: 12, paddingRight: 12)
        
        bottomBackgroundView.addSubview(dateImageview)
        dateImageview.setDimensions(height: 15, width: 15)
        dateImageview.anchor(top: eventNameLabel.bottomAnchor,
                             left: eventNameLabel.leftAnchor,
                             paddingTop: 8)
        
        bottomBackgroundView.addSubview(dateLabel)
        dateLabel.centerY(inView: dateImageview)
        dateLabel.anchor(left: dateImageview.rightAnchor, paddingLeft: 6)
        
        bottomBackgroundView.addSubview(feeImageview)
        feeImageview.centerY(inView: dateImageview)
        feeImageview.setDimensions(height: 15, width: 15)
        feeImageview.anchor(left: dateLabel.rightAnchor, paddingLeft: 15)
        
        bottomBackgroundView.addSubview(feeLabel)
        feeLabel.centerY(inView: dateImageview)
        feeLabel.anchor(left: feeImageview.rightAnchor, paddingLeft: 6)
        
        bottomBackgroundView.addSubview(profileImageView)
        profileImageView.setDimensions(height: 25, width: 25)
        profileImageView.anchor(top: dateImageview.bottomAnchor,
                                left: dateImageview.leftAnchor,
                                paddingTop: 12)
        
        bottomBackgroundView.addSubview(hostNameLabel)
        hostNameLabel.centerY(inView: profileImageView)
        hostNameLabel.anchor(left: profileImageView.rightAnchor, paddingLeft: 8)
    }
    
}
