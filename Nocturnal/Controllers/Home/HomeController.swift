//
//  HomeController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/14.
//

import UIKit
import FirebaseAuth
import Kingfisher
import AVKit
import Lottie

class HomeController: UIViewController {
    
    // MARK: - Properties
    
    let refreshControl = UIRefreshControl()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .black
        collectionView.refreshControl = refreshControl
        collectionView.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.register(HomeEventCell.self, forCellWithReuseIdentifier: HomeEventCell.identifier)
        collectionView.register(HomeProfileCell.self, forCellWithReuseIdentifier: HomeProfileCell.identifier)
        return collectionView
    }()
    
    private let addEventButtonBackgroundView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.primaryBlue
        view.setDimensions(height: 60, width: 60)
        return view
    }()
    
    private lazy var addEventButton: UIButton = {
        let button = UIButton()
        button.accessibilityIdentifier = "add"
        button.setDimensions(height: 60, width: 60)
        button.setImage(UIImage(systemName: "plus")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.primaryBlue
        button.addTarget(self, action: #selector(didTapShowEventButton), for: .touchUpInside)
        return button
    }()
    
    private let emptyAnimationView = LottieManager.shared.createLottieView(name: "empty-box", mode: .loop)
    
    private let emptyWarningLabel = UILabel().makeSatisfyLabel(text: "No Events yet, click the + button to add new event",
                                                               size: 25,
                                                               textAlighment: .center)
    
    private let currentUserNameLabel = UILabel().makeSatisfyLabel(text: "Loading Name", size: 18)
    
    private let currentUserProfileImageView = UIImageView().createBasicImageView(backgroundColor: .lightGray, tintColor: .black)
    
    private let profileView: UIView = {
       let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        return view
    }()
    
    let viewModel: HomeViewModel
    
    var homeEventCellViewModels: [HomeEventCellViewModel] = []
            
    // MARK: - Life Cycle
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindingViewModel()
        setupUI()
        
//        navigationItem.titleView = topImage
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        currentUserProfileImageView.layer.cornerRadius = 35/2
        setupPulsingLayer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        
        viewModel.fetchCurrentUser { [weak self] in
            guard let self = self else { return }
            self.viewModel.fetchAllEvents()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cleanupLayers()
        cleanupEmptyViews()
    }
    
    // MARK: - Selectors
    @objc func refreshData() {
        viewModel.fetchAllEvents()
    }
    
    @objc func didTapShowEventButton() {
        if Auth.auth().currentUser == nil {
            presentLoginVC()
        } else {
            let addEventVC = AddEventController()
            navigationController?.pushViewController(addEventVC, animated: true)
        }
    }
    
    // MARK: - Helpers
    
    private func bindingViewModel() {
        viewModel.firestoreError.bind { [weak self] error in
            guard let self = self else { return }
            self.presentErrorAlert(message: "\(String(describing: error?.localizedDescription))")
        }
        
        viewModel.shouldPresentLoadingView.bind { [weak self] shouldPresent in
            guard let self = self else { return }
            
            self.presentLoadingView(shouldPresent: shouldPresent)
        }
        
        viewModel.shouldPresentRefreshControl.bind { [weak self] shouldPresent in
            guard let self = self else { return }
            
            if shouldPresent { self.refreshControl.beginRefreshing() }
        }
        
        viewModel.shouldPresentEmptyView.bind { [weak self] shouldPresent in
            guard let self = self else { return }
            
            self.presentEmptyView(shouldPresent: shouldPresent)
        }
        
        viewModel.shouldEndRefreshing.bind { [weak self] shouldEnd in
            guard let self = self else { return }
            
            if shouldEnd { self.endRefreshing() }
        }
        
        viewModel.currentUser.bind { [weak self] currentUser in
            guard let self = self else { return }
            self.setupProfileView(currentUser: currentUser)
        }
    }
    
    private func setupProfileView(currentUser: User) {
        self.currentUserNameLabel.text = currentUser.name
        if let profileURL = URL(string: currentUser.profileImageURL) {
            self.currentUserProfileImageView.kf.setImage(with: profileURL)
        } else {
            self.currentUserProfileImageView.image = UIImage(systemName: "person")
        }
    }
    
    private func setupPulsingLayer() {
        let pulseLayer = PulsingLayer(numberOfPulses: .infinity, radius: 50, view: addEventButtonBackgroundView)
        self.addEventButtonBackgroundView.layer.addSublayer(pulseLayer)
    }
    
    private func presentEmptyView(shouldPresent: Bool) {
        if shouldPresent {
            configureEmptyAnimationView()
            configureEmptyWarningLabel()
            collectionView.isHidden = true
        } else {
            stopAnimationView()
            emptyWarningLabel.removeFromSuperview()
            collectionView.isHidden = false
        }
    }
    
    private func configureEmptyAnimationView() {
        view.addSubview(emptyAnimationView)
        emptyAnimationView.centerY(inView: view)
        emptyAnimationView.centerX(inView: view)
        emptyAnimationView.widthAnchor.constraint(equalToConstant: view.frame.size.width - 20).isActive = true
        emptyAnimationView.heightAnchor.constraint(equalTo: emptyAnimationView.widthAnchor).isActive = true
        emptyAnimationView.play()
    }
    
    private func stopAnimationView() {
        emptyAnimationView.stop()
        emptyAnimationView.alpha = 0
        emptyAnimationView.removeFromSuperview()
    }
    
    private func configureEmptyWarningLabel() {
        view.addSubview(emptyWarningLabel)
        emptyWarningLabel.centerX(inView: emptyAnimationView)
        emptyWarningLabel.anchor(top: emptyAnimationView.bottomAnchor, paddingTop: 15)
    }
    
    private func endRefreshing() {
        refreshControl.endRefreshing()
        collectionView.reloadData()
        presentLoadingView(shouldPresent: false)
    }
    
    private func removePulsingLayer() {
        self.addEventButtonBackgroundView.layer.sublayers?.forEach({ layer in
            if layer is PulsingLayer {
                layer.removeFromSuperlayer()
            }
        })
    }
    
    private func releaseVideoPlayer() {
        collectionView.visibleCells.forEach { cell in
            if let homeCell = cell as? HomeEventCell {
                homeCell.player?.removeAllItems()
                homeCell.player = nil
            }
        }
    }
    
    private func presentLoginVC() {
        let loginController = LoginController()
        let nav = UINavigationController(rootViewController: loginController)
        self.present(nav, animated: true, completion: nil)
    }
    
    private func cleanupLayers() {
        removePulsingLayer()
        releaseVideoPlayer()
    }
    
    private func cleanupEmptyViews() {
        emptyAnimationView.stop()
        emptyWarningLabel.removeFromSuperview()
    }
    
    private func animateProfileView(scrollView: UIScrollView, yOffset: CGFloat, duration: TimeInterval) {
        if scrollView.contentOffset.y >= yOffset && profileView.alpha != 1 {
            profileView.isHidden = false
            profileView.alpha = 0
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: 0, animations: {
                self.profileView.alpha = 1
            })
        } else if scrollView.contentOffset.y < yOffset && profileView.alpha == 1 {
            profileView.alpha = 1
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: 0, animations: {
                self.profileView.alpha = 0
            })
        }
    }
    
    func setupUI() {
        view.addSubview(profileView)
        profileView.isHidden = true
        profileView.alpha = 0
        profileView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
                           right: view.rightAnchor, height: 55)
        
        profileView.addSubview(currentUserProfileImageView)
        currentUserProfileImageView.centerY(inView: profileView)
        currentUserProfileImageView.anchor(left: profileView.leftAnchor, paddingLeft: 20)
        currentUserProfileImageView.setDimensions(height: 35, width: 35)
        
        profileView.addSubview(currentUserNameLabel)
        currentUserNameLabel.centerY(inView: currentUserProfileImageView)
        currentUserNameLabel.anchor(left: currentUserProfileImageView.rightAnchor, paddingLeft: 10)
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: profileView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.addSubview(addEventButtonBackgroundView)
        addEventButtonBackgroundView.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                            right: view.rightAnchor,
                                            paddingBottom: 10,
                                            paddingRight: 8)
        addEventButtonBackgroundView.layer.cornerRadius = 60/2
        
        view.addSubview(addEventButton)
        addEventButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor,
                              right: view.rightAnchor,
                              paddingBottom: 10,
                              paddingRight: 8)
        addEventButton.layer.cornerRadius = 60/2
    }
}

// MARK: - UICollectionViewDataSource

extension HomeController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 1: viewModel.events.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            
            guard let profileCell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeProfileCell.identifier, for: indexPath) as? HomeProfileCell else { return UICollectionViewCell() }
            
            profileCell.configureCell(user: viewModel.currentUser.value)
            
            return profileCell
            
        } else {
            guard let eventCell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeEventCell.identifier, for: indexPath) as? HomeEventCell else { return UICollectionViewCell() }
            
            let event = viewModel.events[indexPath.item]
            let eventCellViewModel: HomeEventCellViewModel
            
            if viewModel.eventHosts == nil {
                eventCellViewModel = HomeEventCellViewModel.init(event: event, host: nil)
            } else {
                let host = viewModel.eventHosts?[event.hostID] ?? User()
                
                eventCellViewModel = HomeEventCellViewModel.init(event: event, host: host)
            }
            
            eventCell.delegate = self
            eventCell.bindCell(with: eventCellViewModel)
            eventCell.configureCell(with: eventCellViewModel)
        
            return eventCell
        }
    }
}

// MARK: - UICollectionViewDelegate

extension HomeController: UICollectionViewDelegate {
        
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if Auth.auth().currentUser == nil {
            presentLoginVC()
        } else {
            if indexPath.section == 1 {
                let selectedEvent = viewModel.events[indexPath.item]
                let detailVC = EventDetailController(event: selectedEvent)
                detailVC.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HomeController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        
        return section == 0 ? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0): UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return indexPath.section == 0 ? CGSize(width: view.frame.width, height: 60) : CGSize(width: view.frame.size.width - 40, height: 350)
    }
}

// MARK: - UIScrollViewDelegate
extension HomeController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        animateProfileView(scrollView: scrollView, yOffset: 110, duration: 0.3)
    }
}

// MARK: - HomeEventCellDelegate
extension HomeController: HomeEventCellDelegate {
    
    func didTapReportButton(cell: HomeEventCell) {
        
        showReportAlert()
    }
}
