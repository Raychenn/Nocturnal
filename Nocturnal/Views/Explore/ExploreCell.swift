//
//  ExploreCell.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/21.
//

import UIKit
import Kingfisher

class ExploreCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    private let eventImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .lightGray
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let eventNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.text = "The beginng's Guide to create Animated"
        label.textColor = .white
        label.numberOfLines = 0
        
        return label
    }()
    
    private let eventTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .lightGray
        label.numberOfLines = 0
        label.text = "Jun 4 . 7:00 PM"
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
    
    // MARK: - Helpers
    
    func configureCell(with event: Event) {
        guard let eventUrl = URL(string: event.eventImageURL) else {
            print("eventUrl nil")
            return
        }
        
        eventImageView.kf.setImage(with: eventUrl)
        eventNameLabel.text = event.title
        eventTimeLabel.text = Date.dateFormatter.string(from: event.startingDate.dateValue())
    }
    
    private func setupCellUI() {
        addSubview(eventImageView)
        eventImageView.fillSuperview()
        eventImageView.layer.cornerRadius = 15
        
        eventImageView.addSubview(eventNameLabel)
        eventNameLabel.centerX(inView: eventImageView)
        eventNameLabel.anchor(bottom: eventImageView.bottomAnchor,
                              right: eventImageView.rightAnchor,
                              paddingBottom: 25, paddingRight: 8)
        
        eventImageView.addSubview(eventTimeLabel)
        eventTimeLabel.centerX(inView: eventImageView)
        eventTimeLabel.anchor(bottom: eventImageView.bottomAnchor, paddingBottom: 10)
    }
}
