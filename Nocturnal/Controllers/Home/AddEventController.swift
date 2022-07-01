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
import CoreLocation

class AddEventController: UIViewController {
    
    // MARK: - Properties
    
    private var selectedEventImage: UIImage?
    private var selectedDate: Date?
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.delegate = self
        table.dataSource = self
        table.register(UploadEventInfoCell.self, forCellReuseIdentifier: UploadEventInfoCell.identifier)
        table.register(AddEventHeader.self, forHeaderFooterViewReuseIdentifier: AddEventHeader.identifier)
        table.tableFooterView = UIView()
        return table
    }()
    
    var userInputData: AddEventUserInputCellModel?
    
    var eventImageURLString: String?
    
    var eventMusicURLString: String?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - Helpers
    
    private func setupUI() {
        setupNavigationBar()
        view.backgroundColor = .white
//        view.addSubview(newEventImageView)
        view.addSubview(tableView)
        
//        newEventImageView.centerX(inView: view)
//        newEventImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
//                                 paddingTop: 0)
        
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         left: view.leftAnchor,
                         bottom: view.safeAreaLayoutGuide.bottomAnchor,
                         right: view.rightAnchor, paddingTop: 0)
    }
    
    private func setupNavigationBar() {
        title = "Add Event"
        navigationController?.navigationBar.prefersLargeTitles = true
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: AddEventHeader.identifier) as? AddEventHeader else { return UIView() }
        
        header.delegate = self
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        150
    }
    
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
        if let header = tableView.headerView(forSection: 0) as? AddEventHeader {
            header.newEventImageView.image = self.selectedEventImage
            dismiss(animated: true)
        }
    }
}

// MARK: - AddEventHeaderDelegate
extension AddEventController: AddEventHeaderDelegate {
    
    func uploadNewEventImageView(header: AddEventHeader) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.modalPresentationStyle = .popover
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
    }
}

// MARK: - UploadEventInfoCellDelegate
extension AddEventController: UploadEventInfoCellDelegate {
    
    func didChangeUserData(_ cell: UploadEventInfoCell, data: AddEventUserInputCellModel) {
        self.userInputData = data
        
        // update button to be enable
        cell.doneButton.isEnabled = true
        
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
        print("event address \(userInputData.eventAddress)")
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(userInputData.eventAddress) { (placemarks, error) in
            print("geo coding")
            if let error = error {
                print("error converting address \(error)")
                return
            }
            guard let placemarks = placemarks, let location = placemarks[0].location else {
                // handle no location found
                print("Present Alert to show no location found")
                return
            }
            
            // get location
            let fakeLocation = GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            print("new GeoPoint \(fakeLocation)")
            StorageUploader.shared.uploadEventImage(with: selectedEventImage) { downloadedImageURL in
                
                StorageUploader.shared.uploadEventMusic(with: musicUrlData) { downloadedMusicURL in
                    
                    let newEvent = Event(title: userInputData.eventName,
                                         hostID: uid,
                                         description: userInputData.eventDescription,
                                         startingDate: Timestamp(date: userInputData.eventTime),
                                         destinationLocation: fakeLocation,
                                         fee: Double(userInputData.eventFee) ?? 0,
                                         style: userInputData.eventStyle,
                                         eventImageURL: downloadedImageURL,
                                         eventMusicURL: downloadedMusicURL,
                                         participants: [],
                                         deniedUsersId: [],
                                         pendingUsersId: [])
                    
                    EventService.shared.postNewEvent(event: newEvent) { [weak self] error in
                        print("start uploading event")
                        guard error == nil else {
                            print("Fail to upload event \(String(describing: error))")
                            return
                        }
                        
                        print("Scussfully uploaded event")
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
}
