//
//  AddEventController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/15.
//

import UIKit
import Photos
import PhotosUI
import FirebaseFirestore
import SwiftUI

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
    
    var userInputData: AddEventUserInputCellModel?
    
    var eventImageURLString: String?
    
    var eventMusicURLString: String?
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 750
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
        self.userInputData = data
        
        // update button to be enable
        cell.doneButton.isEnabled = true
        
        // upload data to firebase and pop this VC
        
    }
    
    func uploadEvent(cell: UploadEventInfoCell) {
        
        guard let userInputData = userInputData else { return }
        
        guard !userInputData.eventName.isEmpty,
              !userInputData.eventAddress.isEmpty,
              !userInputData.eventFee.isEmpty,
              !userInputData.eventMusicString.isEmpty,
              !userInputData.eventTime.description.isEmpty,
              !userInputData.eventDescription.isEmpty,
              let selectedEventImage = selectedEventImage
        else {
            print("incomplete input data")
            return
        }
        
        guard let musicUrl = Bundle.main.url(forResource: userInputData.eventMusicString, withExtension: "mp3") else {
            print("musicUrl nil")
            return
        }
        guard let musicUrlData = try? Data(contentsOf: musicUrl) else {
            print("musicUrlData nil")
            return
        }
        
        StorageUploader.shared.uploadEventImage(with: selectedEventImage) { downloadedImageURL in
            
            StorageUploader.shared.uploadEventMusic(with: musicUrlData) { downloadedMusicURL in
               
                let fakeHostID = UUID().uuidString
                let fakeLocation = GeoPoint(latitude: 0.18918, longitude: 0.94185)
                
                let newEvent = Event(title: userInputData.eventName,
                                     hostID: fakeHostID,
                                     description: userInputData.eventDescription,
                                     startingDate: Timestamp(date: userInputData.eventTime),
                                     destinationLocation: fakeLocation,
                                     fee: Double(userInputData.eventFee) ?? 0,
                                     style: userInputData.eventStyle,
                                     eventImageURL: downloadedImageURL,
                                     eventMusicURL: downloadedMusicURL,
                                     participants: [])

                EventService.shared.postNewEvent(event: newEvent) { error in
                    print("start uploading event")
                    guard error == nil else {
                        print("Fail to upload event \(String(describing: error))")
                        return
                    }

                    print("Scussfully uploaded event")
                }
            }
        }
    }
}
