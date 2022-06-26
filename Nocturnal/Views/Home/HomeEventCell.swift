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
    
    private let eventTimeLabel: UILabel = {
       let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 16)
        
        return label
    }()
    
    private let eventNameLabel: UILabel = {
       let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .bold)
        
        return label
    }()
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Heleprs
    
    func configureCell(event: Event) {
        guard let url = URL(string: event.eventImageURL) else { return }
        
        eventImageView.kf.setImage(with: url)
        eventTimeLabel.text = Date.dateFormatter.string(from: event.startingDate.dateValue())
        eventNameLabel.text = event.title
    }
    
    func setupCellUI() {
        layer.cornerRadius = 20
        layer.masksToBounds = true
        backgroundColor = .black
        contentView.addSubview(eventImageView)
        eventImageView.fillSuperview()
        
        contentView.addSubview(eventTimeLabel)
        eventTimeLabel.anchor(left: contentView.leftAnchor,
                              right: contentView.rightAnchor,
                              paddingLeft: 16, paddingRight: 16)
        
        contentView.addSubview(eventNameLabel)
        eventNameLabel.anchor(top: eventTimeLabel.bottomAnchor,
                              left: contentView.leftAnchor,
                              bottom: contentView.bottomAnchor,
                              right: contentView.rightAnchor,
                              paddingTop: 8,
                              paddingLeft: 16, paddingBottom: 16, paddingRight: 16)
    }
    
}
