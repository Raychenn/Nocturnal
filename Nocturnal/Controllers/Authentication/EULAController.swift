//
//  EULAController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/7/7.
//

import UIKit
import WebKit

class EULAController: UIViewController {
    
    // MARK: - Properties
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        
        return webView
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(webView)
        webView.fillSuperview()
        guard let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") else {
            print("no eula url")
            return 
        }
        webView.load(URLRequest(url: url))
    }

}
