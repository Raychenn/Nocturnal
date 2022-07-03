//
//  PopupAlertController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/7/1.
//
import UIKit

protocol PopupAlertControllerDelegate: AnyObject {
    func handleDismissal()
}

class PopupAlertController: UIViewController {
    
    weak var delegate: PopupAlertControllerDelegate?
    
    private let parentView: UIView = {
       let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let oopsLabel: UILabel = {
        let label = UILabel()
         label.text = "Oops! "
         label.numberOfLines = 0
         label.font = .systemFont(ofSize: 40, weight: .bold)
         label.textColor = .black
         return label
     }()
    
    var titleLabel: UILabel = {
       let label = UILabel()
        label.text = "It appears some fields are still empty"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    var subtitleLabel: UILabel = {
       let label = UILabel()
        label.text = "Please make sure to fill all fields"
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let errorImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "warning")
        return imageView
    }()
    
    lazy var okButton: UIButton = {
       let button = UIButton()
        button.backgroundColor = UIColor.primaryBlue
        button.setTitle("OK", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let blureEffect = UIBlurEffect(style: .dark)
        let blureEffectView = UIVisualEffectView(effect: blureEffect)
        blureEffectView.frame = view.bounds
        view.addSubview(blureEffectView)
        
        view.addSubview(parentView)
        parentView.centerX(inView: view)
        parentView.centerY(inView: view)
        parentView.setDimensions(height: view.frame.width, width: view.frame.width - 40)
        parentView.layer.cornerRadius = 10
        
        parentView.addSubview(oopsLabel)
        oopsLabel.centerX(inView: parentView)
        oopsLabel.anchor(top: parentView.topAnchor, paddingTop: 25)
            
        parentView.addSubview(errorImageView)
        errorImageView.centerX(inView: parentView)
        errorImageView.anchor(top: oopsLabel.bottomAnchor, paddingTop: 20)
        errorImageView.setDimensions(height: 100, width: 100)
        
        parentView.addSubview(titleLabel)
        titleLabel.anchor(top: errorImageView.bottomAnchor, left: parentView.leftAnchor, right: parentView.rightAnchor, paddingTop: 25, paddingLeft: 25, paddingRight: 25)
        
        parentView.addSubview(subtitleLabel)
        subtitleLabel.centerX(inView: parentView)
        subtitleLabel.anchor(top: titleLabel.bottomAnchor, paddingTop: 10)
        
        parentView.addSubview(okButton)
        okButton.centerX(inView: parentView)
        okButton.anchor(bottom: parentView.bottomAnchor, paddingBottom: 15)
        okButton.setDimensions(height: 40, width: 200)
        okButton.layer.cornerRadius = 8
    }
    
    @objc func handleDismissal() {
        delegate?.handleDismissal()
    }
    
}
