//
//  StretchyTableHeaderview.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/16.
//

import UIKit
import Kingfisher

protocol StretchyTableHeaderViewDelegate: AnyObject {
    func didTapBackButton(header: StretchyTableHeaderView)
}

final class StretchyTableHeaderView: UIView {
    
    weak var delegate: StretchyTableHeaderViewDelegate?
    
    public let imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 30)
        button.setImage(UIImage(systemName: "chevron.backward.circle.fill", withConfiguration: config), for: .normal)
        button.tintColor = .darkGray
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        return button
    }()
    
    private var imageViewHeightConst = NSLayoutConstraint()
    private var imageViewBottonConst = NSLayoutConstraint()
    private var containerView = UIView()
    private var containerViewHeightConst = NSLayoutConstraint()
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createViews()
        setViewConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selector
    
    @objc func didTapBackButton() {
        delegate?.didTapBackButton(header: self)
    }
    
    // MARK: - Helpers
    
    func configureHeader(with url: URL) {
        imageView.kf.setImage(with: url)
    }
    
    private func createViews() {
        addSubview(containerView)
        containerView.addSubview(imageView)
    }
    
    private func setViewConstraints() {
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalTo: containerView.widthAnchor),
            centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            heightAnchor.constraint(equalTo: containerView.heightAnchor)
        ])
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.widthAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        containerViewHeightConst = containerView.heightAnchor.constraint(equalTo: self.heightAnchor)
        containerViewHeightConst.isActive = true
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageViewBottonConst = imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        imageViewBottonConst.isActive = true
        imageViewHeightConst = imageView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        imageViewHeightConst.isActive = true
        
        addSubview(backButton)
        backButton.anchor(top: topAnchor, left: leftAnchor, paddingTop: 35, paddingLeft: 15)
        backButton.setDimensions(height: 30, width: 30)
    }
    
    // Notify view of scroll view
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        containerViewHeightConst.constant = scrollView.contentInset.top
        let offsetY = -(scrollView.contentOffset.y + scrollView.contentInset.top)
        containerView.clipsToBounds = offsetY <= 0
        imageViewBottonConst.constant = offsetY >= 0 ? 0 : -offsetY / 2
        imageViewHeightConst.constant = max(offsetY + scrollView.contentInset.top, scrollView.contentInset.top)
    }
}
