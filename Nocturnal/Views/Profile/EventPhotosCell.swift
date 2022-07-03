//
//  EventPhotosCell.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/22.
//

import UIKit
import Kingfisher

class EventPhotosCell: UICollectionViewCell {
    
    private lazy var eventPhotoImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
//        imageView.isUserInteractionEnabled = true
//        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapImageView))
//        imageView.addGestureRecognizer(tap)
        imageView.backgroundColor = .lightBlue
        return imageView
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(eventPhotoImageView)
        eventPhotoImageView.fillSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configurePhotoCell(imageURL: String) {
        guard let url = URL(string: imageURL) else { return }
        eventPhotoImageView.kf.setImage(with: url)
        eventPhotoImageView.layer.cornerRadius = 10
    }
    
//    @objc func didTapImageView() {
//        print("tapp")
//    }
}
