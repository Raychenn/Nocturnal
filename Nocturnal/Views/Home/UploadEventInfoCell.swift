//
//  UploadEventCell.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/15.
//

import UIKit

struct AddEventUserInputCellModel {
    
    let eventName: String
    
    let eventAddress: String
    
    let eventFee: String
    
    let eventMusicString: String
    
    let eventTime: Date
}

protocol UploadEventInfoCellDelegate: AnyObject {
    func didChangeUserData(
        _ cell: UploadEventInfoCell,
        data: AddEventUserInputCellModel
    )
}

class UploadEventInfoCell: UITableViewCell {
    
    weak var delegate: UploadEventInfoCellDelegate?
    
    var musicSamples: [MusicSample] = [.allthat, .betterdays, .creativeminds, .dreams, .relaxing, .slowmotion]
    
    private let eventNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.text = "Event Name"
        return label
    }()
    
    private lazy var eventNameTextField = UITextField().makeAddEventTextField()
    
    private let eventAddressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.text = "Event Address"
        return label
    }()
    
    private lazy var eventAddressTextField = UITextField().makeAddEventTextField()
    
    private let eventFeeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.text = "Event Fee"
        return label
    }()
    
    private lazy var eventFeeTextField = UITextField().makeAddEventTextField()
    
    private let eventMusicLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.text = "Event Music URL"
        return label
    }()
    
    private lazy var eventMusicTextField: UITextField = {
        let textfield = UITextField()
        textfield.layer.borderWidth = 1.3
        textfield.layer.borderColor = UIColor.lightGray.cgColor
        textfield.layer.cornerRadius = 5
        textfield.setHeight(50)
        textfield.setLeftPaddingPoints(amount: 8)
        
        let musicPicker = UIPickerView()
        musicPicker.dataSource = self
        musicPicker.delegate = self
        textfield.inputView = musicPicker
        
        return textfield
    }()
    
    private let eventDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.text = "Pick Event Date"
        return label
    }()
    
    lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.addTarget(self, action: #selector(didChangeDate), for: .valueChanged)
        return picker
    }()
    
    lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Done", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.isEnabled = false
        button.setBackgroundColor(color: .clear, forState: .disabled)
        button.setBackgroundColor(color: .deepBlue, forState: .normal)
        button.layer.borderColor = UIColor.deepBlue.cgColor
        button.layer.borderWidth = 1.3
        button.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        return button
    }()
    
    private var selectedDate: Date?
    private var selectedMusic: String?
    
    // MARK: - Life Cycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupCellUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selector
    
    @objc func didTapDoneButton() {
      
        passData()
    }
    
    @objc func didChangeDate(sender: UIDatePicker) {
        print("didChangeDate")
        selectedDate = sender.date
        passData()
    }
    
    // MARK: - Helpers
    
    private func setupCellUI() {
        backgroundColor = UIColor.lightBlue
        eventNameTextField.delegate = self
        eventAddressTextField.delegate = self
        eventFeeTextField.delegate = self
        eventMusicTextField.delegate = self
        
        layer.cornerRadius = 20
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        let vStack = UIStackView(arrangedSubviews: [eventNameLabel,
                                                    eventNameTextField,
                                                    eventAddressLabel,
                                                    eventAddressTextField,
                                                    eventFeeLabel,
                                                    eventFeeTextField,
                                                    eventMusicLabel,
                                                    eventMusicTextField,
                                                    eventDateLabel,
                                                    datePicker])
        vStack.axis = .vertical
        vStack.distribution = .fill
        vStack.spacing = 8
        contentView.addSubview(vStack)
        contentView.addSubview(doneButton)
        
        vStack.anchor(top: topAnchor,
                      left: leftAnchor,
                      right: rightAnchor,
                      paddingTop: 16,
                      paddingLeft: 16,
                      paddingBottom: 16,
                      paddingRight: 16)
        
        doneButton.anchor(top: vStack.bottomAnchor,
                          left: leftAnchor,
                          bottom: bottomAnchor,
                          right: rightAnchor,
                          paddingTop: 16,
                          paddingLeft: 16,
                          paddingBottom: 16,
                          paddingRight: 16,
                          height: 50)
        
        doneButton.layer.cornerRadius = 10
        doneButton.layer.masksToBounds = true
    }
    
    private func passData() {
        guard let selectedDate = selectedDate else { return }
        
        guard
            let eventName = eventNameTextField.text,
            let eventAddress = eventAddressTextField.text,
            let eventFee = eventFeeTextField.text,
            let eventMusic = selectedMusic else
        {
            return
        }
        
        let data = AddEventUserInputCellModel(eventName: eventName,
                                              eventAddress: eventAddress,
                                              eventFee: eventFee,
                                              eventMusicString: eventMusic,
                                              eventTime: selectedDate)
        
        delegate?.didChangeUserData(self, data: data)
    }
}

// MARK: - UITextFieldDelegate

extension UploadEventInfoCell: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("pass data")
        passData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == eventNameTextField {
            textField.resignFirstResponder()
            eventAddressTextField.becomeFirstResponder()
        } else if textField == eventAddressTextField {
            textField.resignFirstResponder()
            eventFeeTextField.becomeFirstResponder()
        } else if textField == eventFeeTextField {
            textField.resignFirstResponder()
            eventMusicTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
}

// MARK: - UIPickerViewDataSource, UIPickerViewDelegate
extension UploadEventInfoCell: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        musicSamples.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return musicSamples[row].description
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        eventMusicTextField.text = musicSamples[row].description
        selectedMusic = musicSamples[row].rawValue
    }
}
