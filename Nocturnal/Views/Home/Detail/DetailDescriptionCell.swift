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
        label.textColor = .label
        label.font = .systemFont(ofSize: 25, weight: .bold)
        label.numberOfLines = 0
        label.text = "About"
        return label
    }()
    
    lazy var decriptionContentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.numberOfLines = 4
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapDescriptionLabel))
        label.addGestureRecognizer(tap)
        label.isUserInteractionEnabled = true
        label.lineBreakMode = .byTruncatingTail
        label.text = "loading"
        return label
    }()
                    
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
        backgroundColor = UIColor.hexStringToUIColor(hex: "#161616")
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

}
