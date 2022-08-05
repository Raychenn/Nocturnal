//
//  JoinedEventCollectionViewCell.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/22.
//
import UIKit

protocol JoinedEventCellDelegate: AnyObject {
    func didTapSelectedEvent(cell: JoinedEventCell, event: Event)
}

class JoinedEventCell: UICollectionViewCell {
    
    weak var delegate: JoinedEventCellDelegate?
    
    private let joinedEventsTitleLabel = UILabel().makeBasicSemiboldLabel(fontSize: 22, text: "Joined Events")
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 30
        layout.sectionInset = .init(top: 0, left: 10, bottom: 0, right: 0)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(EventPhotosCell.self, forCellWithReuseIdentifier: EventPhotosCell.identifier)
        collectionView.backgroundColor = .darkGray
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    private let noJoinedEventsLabel: UILabel = {
        let label = UILabel()
        label.text = "No Joined Events"
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    let collectionViewStack = UIStackView()
    
    private var joinedEventsURL: [String] = [] {
        didSet {
            if joinedEventsURL.count == 0 {
                noJoinedEventsLabel.isHidden = false
            } else {
                noJoinedEventsLabel.isHidden = true
            }
            collectionView.reloadData()
        }
    }
    
    var joinedEvents: [Event] = []
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCellUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    func setupCellUI() {
        layer.cornerRadius = 20
        collectionView.layer.cornerRadius = 20
        contentView.addSubview(joinedEventsTitleLabel)
        joinedEventsTitleLabel.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, paddingTop: 10, paddingLeft: 10)
        
        contentView.addSubview(collectionView)
        collectionView.anchor(top: joinedEventsTitleLabel.bottomAnchor, left: joinedEventsTitleLabel.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, paddingTop: 10, paddingBottom: 10)
    }
    
    func configureCell(joinedEventsURL: [String]) {
        self.joinedEventsURL = joinedEventsURL
    }
    
}
// MARK: - UICollectionViewDataSource
extension JoinedEventCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return joinedEventsURL.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let photoCell = collectionView.dequeueReusableCell(withReuseIdentifier: EventPhotosCell.identifier, for: indexPath) as? EventPhotosCell else { return UICollectionViewCell() }
        
        let eventImageURL = joinedEventsURL[indexPath.item]
        photoCell.configurePhotoCell(imageURL: eventImageURL)
        
        return photoCell
    }
}

// MARK: - UICollectionViewDelegate
extension JoinedEventCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedEvent = joinedEvents[indexPath.item]
        delegate?.didTapSelectedEvent(cell: self, event: selectedEvent)
    }
}

extension JoinedEventCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size.height * 0.8

        return CGSize(width: size, height: size)
    }
}
