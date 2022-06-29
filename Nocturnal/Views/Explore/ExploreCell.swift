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
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.text = "The beginng's Guide to create Animated"
        label.textColor = .white
        label.numberOfLines = 0
        
        return label
    }()
    
    private let eventTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .lightGray
        label.numberOfLines = 0
        label.text = "Jun 4 . 7:00 PM"
        return label

    }()
    
    private let bottonBackgroundView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.hexStringToUIColor(hex: "#1C242F")
        return view
    }()
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCellUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = 15
        layer.masksToBounds = true
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
        eventTimeLabel.text = Date.dateTimeFormatter.string(from: event.startingDate.dateValue())
    }
    
    private func setupCellUI() {
        addSubview(eventImageView)
        eventImageView.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor)
       
        addSubview(bottonBackgroundView)
        bottonBackgroundView.anchor(top: eventImageView.bottomAnchor,
                                    left: leftAnchor,
                                    bottom: bottomAnchor,
                                    right: rightAnchor,
                                    height: 60)
        
        bottonBackgroundView.addSubview(eventNameLabel)
        eventNameLabel.centerX(inView: bottonBackgroundView)

        bottonBackgroundView.addSubview(eventTimeLabel)
        eventTimeLabel.centerX(inView: bottonBackgroundView)
        eventTimeLabel.anchor(top: eventNameLabel.bottomAnchor,
                              bottom: bottonBackgroundView.bottomAnchor,
                              paddingTop: 1,
                              paddingBottom: 10)
    }
}
