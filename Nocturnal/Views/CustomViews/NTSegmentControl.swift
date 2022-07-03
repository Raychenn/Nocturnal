//
//  NTSegmentControl.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/21.
//

import UIKit

class NTSegmentedControl: UIControl {
    
    var buttons: [UIButton] = []
    
    var selectorView = UIView()
    
    var selectedButtonIndex = 0
    
    var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    var commaSeparatedButtonTitles: String = "" {
        didSet {
            updateView()
        }
    }
    
    var textColor: UIColor = UIColor.black {
        didSet {
            updateView()
        }
    }
    
    var selectorColor: UIColor = UIColor.black {
        didSet {
            updateView()
        }
    }
    
    var selectorTextColor: UIColor = UIColor.white {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        buttons.removeAll()
        subviews.forEach({ $0.removeFromSuperview() })
        
        // slice button title
        let buttonTitles = commaSeparatedButtonTitles.components(separatedBy: ",")
        for buttonTitle in buttonTitles {
            let button = UIButton(type: .system)
            button.setTitle(buttonTitle, for: .normal)
            button.setTitleColor(textColor, for: .normal)
            button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
            buttons.append(button)
        }
        
        buttons[0].setTitleColor(selectorTextColor, for: .normal)
        
        let selectorWidth = frame.width / CGFloat(buttons.count)
        selectorView = UIView(frame: CGRect(x: 0, y: 0, width: selectorWidth, height: frame.height))
        selectorView.layer.cornerRadius = frame.height/2
        selectorView.backgroundColor = selectorColor
        self.addSubview(selectorView)
        
        let stack = UIStackView(arrangedSubviews: buttons)
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    override func draw(_ rect: CGRect) {
        layer.cornerRadius = frame.height/2
  
        updateView()
    }
    
    @objc func buttonTapped(sender: UIButton) {
        
        for (index, button) in buttons.enumerated() {
            // reset all buttons
            button.setTitleColor(textColor, for: .normal)
            
            if button == sender {
                print("index is \(index)")
                selectedButtonIndex = index
                // set the selected button to selected state
                let selectorStartPosition = frame.width / CGFloat(buttons.count) * CGFloat(index)
                
                UIView.animate(withDuration: 0.3) {
                    self.selectorView.frame.origin.x = selectorStartPosition 
                }
                
                button.setTitleColor(selectorTextColor, for: .normal)
            }
        }
        sendActions(for: .valueChanged)
    }
    
}
