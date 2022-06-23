//
//  DetailDescriptionCell.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/16.
//

import UIKit

class DetailDescriptionCell: UITableViewCell {
    
    private let descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 25, weight: .bold)
        label.numberOfLines = 0
        label.text = "About"
        return label
    }()
    
    let decriptionContentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.numberOfLines = 4
        label.lineBreakMode = .byWordWrapping
        label.text = "loading"
        return label
    }()
    
//    private lazy var readBoreButton: UIButton = {
//        
//    }()
    
    var descriptionLabelHeightConst: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupCellUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        DispatchQueue.main.async {
//            self.decriptionContentLabel.addTrailing(with: "... ", moreText: "ReadMore", moreTextFont: .systemFont(ofSize: 20, weight: .semibold), moreTextColor: .lightBlue)
//        }
    }
    
    // MARK: - Helpers
    
    private func setupCellUI() {
        contentView.addSubview(descriptionTitleLabel)
        descriptionTitleLabel.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, paddingTop: 8, paddingLeft: 8)

        contentView.addSubview(decriptionContentLabel)
        decriptionContentLabel.anchor(top: descriptionTitleLabel.bottomAnchor,
                                      left: contentView.leftAnchor,
                                      right: contentView.rightAnchor,
                                      paddingTop: 8,
                                      paddingLeft: 8,
                                      paddingRight: 8)
        
        descriptionLabelHeightConst = decriptionContentLabel.heightAnchor.constraint(equalToConstant: 50)
        descriptionLabelHeightConst.isActive = true
        
        decriptionContentLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: 8).isActive = true
    }
    
    func configureCell(with event: Event) {
        decriptionContentLabel.text = event.description
    }
    
    func animateDescriptionLabel() {
        decriptionContentLabel.numberOfLines = 0
        decriptionContentLabel.lineBreakMode = .byWordWrapping
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.descriptionLabelHeightConst.isActive = false
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    func getLabelHeight(text: String, width: CGFloat, font: UIFont) -> CGFloat {
        let lbl = UILabel(frame: .zero)
        lbl.frame.size.width = width
        lbl.font = font
        lbl.numberOfLines = 0
        lbl.text = text
        lbl.sizeToFit()

        return lbl.frame.size.height
    }
}
