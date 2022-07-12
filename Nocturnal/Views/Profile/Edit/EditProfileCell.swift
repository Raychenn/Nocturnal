//
//  EditProfileCell.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/23.
//

import UIKit
import FirebaseFirestore

protocol EditProfileCellDelegate: AnyObject {
    func didTapSave(cell: EditProfileCell, editedData: EditProfileCellModel)
}

struct EditProfileCellModel {
    var firstname: String
    var familyname: String
    var email: String
    var country: String
    var birthday: Timestamp
    var gender: String
    var bio: String
}

class EditProfileCell: UITableViewCell {
    
    // MARK: - Properties
    
    weak var delegate: EditProfileCellDelegate?
    
    lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .inline
        picker.datePickerMode = .date
        picker.addTarget(self, action: #selector(didChangeDate), for: .valueChanged)
        return picker
    }()
    
    private lazy var countryPicker: UIPickerView = {
       let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        return picker
    }()
    
    private let firstnameField = UITextField().makeEditProfileTextField(placeholder: "Name")
    
    private let familynameField: UITextField = UITextField().makeEditProfileTextField(placeholder: "Family Name")
    
    private let emailField: UITextField = UITextField().makeEditProfileTextField(placeholder: "Email")
    
    private let countryField: UITextField = UITextField().makeEditProfileTextField(placeholder: "Country")
    
    private let birthdayField: UITextField = UITextField().makeEditProfileTextField(placeholder: "birthday")
    
    private let genderField: UITextField = UITextField().makeEditProfileTextField(placeholder: "Gender")
    
    private let bioInputTextView: InputTextView = {
       let textView = InputTextView()
        textView.placeholderText = "Bio"
        textView.font = .systemFont(ofSize: 18)
        textView.textColor = .white
        textView.backgroundColor = .darkGray
        return textView
    }()
    
    let genders: [Gender] = [.male, .female]
    
    let countries: [Country] = [ .taiwan, .china, .france, .germany, .india, .italy, .japan, .korea, .australia, .usa, .spain]
    
    private lazy var saveButton: UIButton = {
       let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .primaryBlue
        button.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        return button
    }()
    
    var selectedBirthday: Date?
    
    var data = EditProfileCellModel(firstname: "",
                                    familyname: "",
                                    email: "",
                                    country: "",
                                    birthday: Timestamp(date: Date()),
                                    gender: "",
                                    bio: "")
    
    var currentUser: User?
    
    // MARK: - Life Cycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupTextFields()
        setupCellUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selector
    
    @objc func didChangeDate(picker: UIDatePicker) {
        selectedBirthday = picker.date
        birthdayField.text = Date.dateFormatter.string(from: picker.date)
    }
    
    @objc func didTapSaveButton() {
       passData()
    }
    
    // MARK: - Helpers
    func configureCell(with user: User) {
        
        let firstname = String(user.name.split(separator: " ")[0])
        let familyname = String(user.name.split(separator: " ")[1])
        firstnameField.text = firstname
        familynameField.text = familyname
        emailField.text = user.email
        countryField.text = user.country
        let gender = Gender(rawValue: user.gender) ?? .unspecified
        
        switch gender {
        case .male:
            genderField.text = gender.getDescription
        case .female:
            genderField.text = gender.getDescription
            
        case .unspecified:
            genderField.text = gender.getDescription
        }
        
        datePicker.date = user.birthday.dateValue()
        bioInputTextView.text = user.bio
        
        if !bioInputTextView.text.isEmpty {
            bioInputTextView.placeholderText = nil
        }
    }
    
    func setupTextFields() {
        [firstnameField, familynameField, emailField, countryField, birthdayField, genderField].forEach { textField in
            textField.setHeight(50)
            textField.layer.cornerRadius = 6
            textField.delegate = self
        }
        
        bioInputTextView.delegate = self
        countryField.inputView = countryPicker
    }
    
    func setupCellUI() {
        
        backgroundColor = .black
        let nameStack = UIStackView(arrangedSubviews: [firstnameField, familynameField])
        contentView.addSubview(nameStack)
        nameStack.axis = .horizontal
        nameStack.spacing = 10
        nameStack.distribution = .fillEqually
        contentView.addSubview(nameStack)
        nameStack.anchor(top: contentView.topAnchor,
                         left: contentView.leftAnchor,
                         right: contentView.rightAnchor, paddingTop: 8, paddingLeft: 15, paddingRight: 15)
        
        let descriptionStack = UIStackView(arrangedSubviews: [emailField, countryField, birthdayField, genderField])
        contentView.addSubview(descriptionStack)
        descriptionStack.axis = .vertical
        descriptionStack.distribution = .fill
        descriptionStack.spacing = 10
        contentView.addSubview(descriptionStack)
        
        birthdayField.inputView = datePicker
        let genderPicker = UIPickerView()
        genderPicker.dataSource = self
        genderPicker.delegate = self
        genderField.inputView = genderPicker
        
        descriptionStack.anchor(top: nameStack.bottomAnchor,
                                left: contentView.leftAnchor,
                                right: contentView.rightAnchor,
                                paddingTop: 10,
                                paddingLeft: 15,
                                paddingRight: 15)
        
        contentView.addSubview(bioInputTextView)
        bioInputTextView.anchor(top: descriptionStack.bottomAnchor,
                                left: contentView.leftAnchor,
                                right: contentView.rightAnchor,
                                paddingTop: 10,
                                paddingLeft: 15,
                                paddingRight: 15,
                                height: 100)
        bioInputTextView.layer.cornerRadius = 6
        
        contentView.addSubview(saveButton)
        saveButton.anchor(top: bioInputTextView.bottomAnchor,
                          left: contentView.leftAnchor,
                          bottom: contentView.bottomAnchor,
                          right: contentView.rightAnchor,
                          paddingTop: 10,
                          paddingLeft: 15,
                          paddingBottom: 10,
                          paddingRight: 15,
                          height: 50)
        saveButton.layer.cornerRadius = 8
    }
    
    private func passData() {
        guard let currentUser = currentUser else {
            print("currentUser nil")
            return
        }
        let currentGender = Gender(rawValue: currentUser.gender) ?? .unspecified
        let inputName = "\(firstnameField.text ?? currentUser.name) \(familynameField.text ?? currentUser.name)"
        let firstname = String(inputName.split(separator: " ")[0])
        let familyname = String(inputName.split(separator: " ")[1])
        self.data.firstname = firstname
        self.data.familyname = familyname
        self.data.email = emailField.text ?? currentUser.email
        self.data.country = countryField.text ?? currentUser.country
        self.data.birthday = Timestamp(date: selectedBirthday ?? Date())
        self.data.gender = genderField.text ?? currentGender.getDescription
        self.data.bio = bioInputTextView.text ?? currentUser.bio
        
        delegate?.didTapSave(cell: self, editedData: data)
    }
}

// MARK: - UIPickerViewDataSource, UIPickerViewDelegate
extension EditProfileCell: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        countryField.isFirstResponder ? countries.count: genders.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countryField.isFirstResponder ? countries[row].rawValue: genders[row].getDescription
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if countryField.isFirstResponder {
            countryField.text = countries[row].rawValue
        } else {
            genderField.text = "\(genders[row].getDescription)"
        }
    }
}
// MARK: - UITextFieldDelegate
extension EditProfileCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == firstnameField {
            textField.resignFirstResponder()
            familynameField.becomeFirstResponder()
        } else if textField == familynameField {
            textField.resignFirstResponder()
            emailField.becomeFirstResponder()
        } else if textField == emailField {
            textField.resignFirstResponder()
            countryField.becomeFirstResponder()
        } else if textField == countryField {
            textField.resignFirstResponder()
            birthdayField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
}
// MARK: - UITextViewDelegate
extension EditProfileCell: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
}
