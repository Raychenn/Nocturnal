//
//  InputTextView.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/15.
//
import UIKit

class InputTextView: UITextView {
    
    // MARK: - Porperties
        
    var placeholderText: String? {
        didSet {
            placeholderLabel.text = placeholderText
        }
    }
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        
        return label
    }()
        
    var placeholderShouldCenter = true {
        didSet {
            if placeholderShouldCenter {
                placeholderLabel.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 8)
            } else {
                placeholderLabel.anchor(top: topAnchor, left: leftAnchor, paddingTop: 6, paddingLeft: 8)
            }
        }
    }
        
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        addSubview(placeholderLabel)
        placeholderLabel.anchor(top: topAnchor, left: leftAnchor, paddingTop: 6, paddingLeft: 8)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextDidChange), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - selector
    
    @objc func handleTextDidChange(textView: UITextView) {
        placeholderLabel.isHidden = !text.isEmpty
    }
}
