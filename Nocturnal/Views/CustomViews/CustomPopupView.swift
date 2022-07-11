//
//  CustomPopupView.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/7/5.
//

import UIKit

protocol CustomPopupViewDelegate: AnyObject {
    func handleDismissal()
}

class CustomPopupView: UIView {
    
    weak var delegate: CustomPopupViewDelegate?
    
    lazy var button: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.deepBlue
        button.setTitle("OK", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        return button
    }()
    
    let imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "owl")
//        label.font = .systemFont(ofSize: 96)
        imageView.tintColor = UIColor(red: 147/255, green: 227/255, blue: 105/255, alpha: 1)
        return imageView
    }()
    
    let notificationLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Avenir", size: 24)
        label.textColor = .darkGray
        label.text = "Notice!"
        return label
    }()
    
    let notificationSubtitleLabel: UILabel = {
       let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Avenir", size: 20)
        label.textAlignment = .center
        label.textColor = .darkGray
        label.text = "Once uploading an event video, home page will show event video instead of photo"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 96),
            imageView.heightAnchor.constraint(equalToConstant: 96),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 20)
        ])
        
        addSubview(notificationLabel)
        NSLayoutConstraint.activate([
            notificationLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            notificationLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8)
        ])
        
        addSubview(notificationSubtitleLabel)
        NSLayoutConstraint.activate([
            notificationSubtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            notificationSubtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            notificationSubtitleLabel.topAnchor.constraint(equalTo: notificationLabel.bottomAnchor, constant: 8)
        ])
        
        addSubview(button)
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 50),
            button.topAnchor.constraint(equalTo: notificationSubtitleLabel.bottomAnchor, constant: 12),
            button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
        ])
        
        button.layer.cornerRadius = 12
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleDismissal() {
        delegate?.handleDismissal()
    }
}
