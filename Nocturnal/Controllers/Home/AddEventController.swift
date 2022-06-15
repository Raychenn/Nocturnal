//
//  AddEventController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/15.
//

import UIKit
import Photos
import PhotosUI

class AddEventController: UIViewController {

    // MARK: - Properties
    
    private var selectedEventImage: UIImage?
    private var selectedDate: Date?
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.delegate = self
        table.dataSource = self
//        table.register(UploadEventImageCell.self, forCellReuseIdentifier: UploadEventImageCell.identifier)
        table.register(UploadEventInfoCell.self, forCellReuseIdentifier: UploadEventInfoCell.identifier)
        table.tableFooterView = UIView()
        return table
    }()
    
    private lazy var newEventImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.setDimensions(height: 150, width: 150)
        imageView.image = UIImage(systemName: "plus")
        imageView.tintColor = .black
        imageView.backgroundColor = .lightGray
        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapEventImageView))
        imageView.addGestureRecognizer(tap)
        
        return imageView
    }()
    

    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        newEventImageView.layer.cornerRadius = 150/2
        newEventImageView.layer.masksToBounds = true
    }
    
    // MARK: - Selectors
    @objc func didTapEventImageView() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.modalPresentationStyle = .popover
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: - Helpers
    
    private func setupUI() {
        setupNavigationBar()
        view.backgroundColor = .white
        view.addSubview(newEventImageView)
        view.addSubview(tableView)
        
        newEventImageView.centerX(inView: view)
        newEventImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                 paddingTop: 0)
        
        tableView.anchor(top: newEventImageView.bottomAnchor,
                         left: view.leftAnchor,
                         bottom: view.safeAreaLayoutGuide.bottomAnchor,
                         right: view.rightAnchor, paddingTop: 8)
    }
    
    private func setupNavigationBar() {
        title = "Add Event"
        navigationController?.navigationBar.prefersLargeTitles = true
//        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(tappedDone))
        navigationController?.navigationBar.tintColor = .black
//        tableView.contentInsetAdjustmentBehavior = .never
//        tableView.setContentOffset(.init(x: 0, y: -2), animated: false)
    }
}

// MARK: - UITableViewDataSource
extension AddEventController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let infoCell = tableView.dequeueReusableCell(withIdentifier: UploadEventInfoCell.identifier) as? UploadEventInfoCell else {
            return UITableViewCell()
        }
        
        infoCell.delegate = self
//        infoCell.backgroundColor = .red
        return infoCell
    }
}

// MARK: - UITableViewDelegate
extension AddEventController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 500
        } else {
            return 100
        }
    }
}

// MARK: - PHPickerViewControllerDelegate
extension AddEventController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        guard let selectedProfileImage = info[.editedImage] as? UIImage else { return }
        self.selectedEventImage = selectedProfileImage
        newEventImageView.image = self.selectedEventImage
        dismiss(animated: true)
    }
}

extension AddEventController: UploadEventInfoCellDelegate {
    
    func didChangeUserData(_ cell: UploadEventInfoCell, data: AddEventUserInputCellModel) {
        guard !data.eventName.isEmpty,
              !data.eventAddress.isEmpty,
              !data.eventFee.isEmpty,
              !data.eventMusicString.isEmpty,
              !data.eventTime.description.isEmpty,
              selectedEventImage != nil
        else {
            print("incomplete input data")
            return
        }
        
        // update button to be enable
        cell.doneButton.isEnabled = true
        // upload data to firebase and pop this VC
        print("selected result \(data)")
    }
    
}
