//
//  PrivacyPolicyController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/7/7.
//

import UIKit
import WebKit

class PrivacyPolicyController: UIViewController {

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
        guard let url = URL(string: "https://www.privacypolicies.com/live/e61b85e0-b103-4cb4-8000-46b6e018924d") else {
            print("no privacy policy url")
            return 
        }
        webView.load(URLRequest(url: url))
    }

}
