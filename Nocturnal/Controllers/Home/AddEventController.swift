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
import FirebaseAuth
import SwiftUI
import CoreLocation
import Lottie

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
    
    var eventVideoURLString: String?
    
    let loadingAnimationView: AnimationView = {
        let view = AnimationView(name: "cheers")
        view.loopMode = .loop
        view.contentMode = .scaleAspectFill
        view.animationSpeed = 1
        view.backgroundColor = .clear
        view.play()
        return view
    }()
    
    lazy var imagePickerController: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.modalPresentationStyle = .popover
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        return imagePicker
    }()
    
    lazy var popupView: CustomPopupView = {
        let view = CustomPopupView()
        view.delegate = self
        view.layer.cornerRadius = 5
        return view
    }()
    
    let visualEffectView: UIVisualEffectView = {
        let blureEffect = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: blureEffect)
        
        return view
    }()
        
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - Helpers
    
    private func setupUI() {
        setupNavigationBar()
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         left: view.leftAnchor,
                         bottom: view.safeAreaLayoutGuide.bottomAnchor,
                         right: view.rightAnchor, paddingTop: 0)
    }
    
    private func setupNavigationBar() {
        title = "Add Event"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .white
        //        tableView.contentInsetAdjustmentBehavior = .never
        //        tableView.setContentOffset(.init(x: 0, y: -2), animated: false)
    }
    
    private func configureAnimationView() {
        view.addSubview(loadingAnimationView)
        loadingAnimationView.centerY(inView: view)
        loadingAnimationView.centerX(inView: view)
        loadingAnimationView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        loadingAnimationView.heightAnchor.constraint(equalTo: loadingAnimationView.widthAnchor).isActive = true
    }
    
    private func stopAnimationView() {
        loadingAnimationView.stop()
        loadingAnimationView.alpha = 0
        loadingAnimationView.removeFromSuperview()
    }
    
    private func configurePopupView() {
        view.addSubview(visualEffectView)
        visualEffectView.fillSuperview()
        visualEffectView.alpha = 0
        
        view.addSubview(popupView)
        popupView.centerX(inView: view)
        popupView.centerY(inView: view, constant: 35)
        popupView.setDimensions(height: view.frame.width - 30, width: view.frame.width - 50)
        
        popupView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        popupView.alpha = 0
        
        UIView.animate(withDuration: 0.5) {
            self.visualEffectView.alpha = 1
            self.popupView.alpha = 1
            self.popupView.transform = .identity
        }
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
        return UITableView.automaticDimension
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
        
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            // Do something with the URL
        
            presentLoadingView(shouldPresent: true)
            StorageUploader.shared.uploadEventVideo(videoUrl: videoUrl) { [weak self] downloadedUrl in
                guard let self = self, let videoURL = URL(string: downloadedUrl) else { return }
                if let header = self.tableView.headerView(forSection: 0) as? AddEventHeader {
                    self.eventVideoURLString = downloadedUrl
                    header.setupVideoPlayerView(videoURL: videoURL)
                    header.newVideoButton.isHidden = true
                    self.presentLoadingView(shouldPresent: false)
                    self.dismiss(animated: true)
                }
            }
        } else if let selectedProfileImage = info[.editedImage] as? UIImage {
            // upload an image
            self.selectedEventImage = selectedProfileImage
            if let header = tableView.headerView(forSection: 0) as? AddEventHeader {
                header.newEventImageView.image = self.selectedEventImage
                header.newPhotoButton.isHidden = true
                dismiss(animated: true)
            }
        }
    }
}

// MARK: - AddEventHeaderDelegate
extension AddEventController: AddEventHeaderDelegate {

    func uploadNewEventImageView(header: AddEventHeader) {
        imagePickerController.mediaTypes = ["public.image"]
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func uploadNewEventVideoView(header: AddEventHeader) {
        
        if UserDefaults.standard.bool(forKey: UserDefaultConstant.hasSeenUploadVideoPopup) == true {
            self.imagePickerController.mediaTypes = ["public.movie"]
            self.present(self.imagePickerController, animated: true)
        } else {
            configurePopupView()
        }
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
              let selectedEventImage = self.selectedEventImage
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
            // upload video
            let geoCoder = CLGeocoder()
            configureAnimationView()
            self.view.isUserInteractionEnabled = false
            geoCoder.geocodeAddressString(userInputData.eventAddress) { [weak self] (placemarks, error) in
                guard let self = self else { return }
                print("geo coding")
                if let error = error {
                    self.presentLoadingView(shouldPresent: false)
                    self.presentErrorAlert(title: "Error", message: "error converting address \(error.localizedDescription))", completion: nil)
                    return
                }
                guard let placemarks = placemarks, let location = placemarks[0].location else {
                    // handle no location found
                    print("Present Alert to show no location found")
                    return
                }
                // get location
                let destinationLocation = GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                
                StorageUploader.shared.uploadEventImage(with: selectedEventImage) { downloadedImageURL in
            
                    StorageUploader.shared.uploadEventMusic(with: musicUrlData) { downloadedMusicURL in
                        
                        guard let uid = Auth.auth().currentUser?.uid else {
                            print("current user nil in add EventVC")
                            return
                        }
            
                        let newEvent = Event(title: userInputData.eventName,
                                             createTime: Timestamp(date: Date()),
                                             hostID: uid,
                                             description: userInputData.eventDescription,
                                             startingDate: Timestamp(date: userInputData.eventTime),
                                             destinationLocation: destinationLocation,
                                             fee: Double(userInputData.eventFee) ?? 0,
                                             style: userInputData.eventStyle,
                                             eventImageURL: downloadedImageURL,
                                             eventMusicURL: downloadedMusicURL,
                                             eventVideoURL: self.eventVideoURLString,
                                             participants: [],
                                             deniedUsersId: [],
                                             pendingUsersId: [])
            
                        EventService.shared.postNewEvent(event: newEvent) { [weak self] error in
                            guard let self = self else { return }
                            print("start uploading event")
                            guard error == nil else {
                                self.presentLoadingView(shouldPresent: false)
                                self.presentErrorAlert(title: "Error", message: "Fail to upload event: \(error!.localizedDescription)", completion: nil)
                                print("Fail to upload event \(String(describing: error))")
                                return
                            }
            
                            self.stopAnimationView()
                            self.view.isUserInteractionEnabled = true
                            print("Scussfully uploaded event")
                            self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
}
 // MARK: - CustomPopupViewDelegate

extension AddEventController: CustomPopupViewDelegate {
    
    func handleDismissal() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut) {
            self.visualEffectView.alpha = 0
            self.popupView.alpha = 0
            self.popupView.transform = .init(scaleX: 1.3, y: 1.3)
        } completion: { _ in
            self.popupView.removeFromSuperview()
            self.imagePickerController.mediaTypes = ["public.movie"]
            self.present(self.imagePickerController, animated: true)
            UserDefaults.standard.set(true, forKey: UserDefaultConstant.hasSeenUploadVideoPopup)
        }
    }
    
}
