//
//  DetailHeader.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/16.
//

import UIKit

class DetailHeader: UITableViewHeaderFooterView {
    
    static let identifier = "DetailHeader"
    
     let imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "cat")
        
        return imageView
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        let view = UIView()
        view.backgroundColor = .blue
//        view.addSubview(imageView)
//        imageView.fillSuperview()
        contentView.addSubview(view)
        view.fillSuperview()
//        addSubview(imageView)
//        imageView.fillSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
