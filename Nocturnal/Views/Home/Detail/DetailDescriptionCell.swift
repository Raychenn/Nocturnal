//
//  DetailDescriptionCell.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/16.
//

import UIKit

protocol DetailDescriptionCellDelegate: AnyObject {
    func animateDescriptionLabel(cell: DetailDescriptionCell)
}

class DetailDescriptionCell: UITableViewCell {
    
    weak var delegate: DetailDescriptionCellDelegate?
    
    private let descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 25, weight: .bold)
        label.numberOfLines = 0
        label.text = "About"
        return label
    }()
    
    lazy var decriptionContentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.numberOfLines = 0
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapDescriptionLabel))
        label.addGestureRecognizer(tap)
        label.isUserInteractionEnabled = true
        label.lineBreakMode = .byTruncatingTail
//        label.backgroundColor = .red
        label.text = "loading"
        return label
    }()
    
     lazy var readMoreLabel: UILabel = {
        let label = UILabel()
         label.text = "Read More"
         label.font = .systemFont(ofSize: 15, weight: .semibold)
         return label
    }()
    
//    var discriptionLabelHeightConst: NSLayoutConstraint!
            
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupCellUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

    }
    
    // MARK: - Selector
    
    @objc func didTapDescriptionLabel() {
        delegate?.animateDescriptionLabel(cell: self)
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
//        discriptionLabelHeightConst = decriptionContentLabel.heightAnchor.constraint(equalToConstant: 50)
//        discriptionLabelHeightConst.isActive = true
//        descriptionLabelHeightConst = decriptionContentLabel.heightAnchor.constraint(equalToConstant: 100)
//        descriptionLabelHeightConst.isActive = true
//        decriptionContentLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
//        contentView.addSubview(readMoreLabel)
//        readMoreLabel.anchor(top: decriptionContentLabel.bottomAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, paddingTop: 8, paddingBottom: 20, paddingRight: 8)
    }
    
    func configureCell(with event: Event) {
        decriptionContentLabel.text = event.description
    }

}
