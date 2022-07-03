//
//  AddEventHeader.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/30.
//

import UIKit

protocol AddEventHeaderDelegate: AnyObject {
    func uploadNewEventImageView(header: AddEventHeader)
}

class AddEventHeader: UITableViewHeaderFooterView {
    
    static let identifier = "AddEventHeader"
    
    weak var delegate: AddEventHeaderDelegate?
    
     lazy var newEventImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.setDimensions(height: 150, width: 150)
        imageView.image = UIImage(systemName: "plus")
        imageView.tintColor = .black
        imageView.backgroundColor = .lightGray
        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapEventImageView))
        imageView.addGestureRecognizer(tap)
        
        return imageView
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        addSubview(newEventImageView)
        newEventImageView.centerX(inView: self)
        newEventImageView.centerY(inView: self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        newEventImageView.layer.cornerRadius = 150/2
        newEventImageView.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didTapEventImageView() {
        delegate?.uploadNewEventImageView(header: self)
    }
}
