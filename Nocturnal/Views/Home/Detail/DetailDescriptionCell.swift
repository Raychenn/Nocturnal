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
        label.font = .systemFont(ofSize: 25, weight: .semibold)
        label.numberOfLines = 0
        label.text = "Event Description"
        return label
    }()
    
    let decriptionContentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.numberOfLines = 5
        label.lineBreakMode = .byTruncatingTail
        label.text = "loading"
        return label
    }()
    
    var descriptionLabelHeightConst: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupCellUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    private func setupCellUI() {
        contentView.addSubview(descriptionTitleLabel)
        descriptionTitleLabel.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, paddingTop: 8, paddingLeft: 8)
        
        contentView.addSubview(decriptionContentLabel)
        decriptionContentLabel.anchor(top: descriptionTitleLabel.bottomAnchor,
                                      left: contentView.leftAnchor,
                                      bottom: contentView.bottomAnchor,
                                      right: contentView.rightAnchor,
                                      paddingTop: 8,
                                      paddingLeft: 8,
                                      paddingBottom: 8,
                                      paddingRight: 8)
    }
    
    func configureCell(with event: Event) {
        decriptionContentLabel.text = event.description
    }
    
    func animateDescriptionLabel(shouldShow: Bool) {
        print("animateDescriptionLabel called")

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            
            self.layoutIfNeeded()
        }, completion: nil)
    }
}
