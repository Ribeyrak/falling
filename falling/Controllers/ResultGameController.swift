//
//  ResultGameController.swift
//  falling
//
//  Created by Evhen Lukhtan on 02.11.2023.
//

import UIKit
import WebKit

class ResultGameController: UIViewController, WKUIDelegate {

    var wView: WKWebView!
    var link: String!
    weak var delegate: GameRestartDelegate?
    
    // MARK: - Lifecycle
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        wView = WKWebView(frame: .zero, configuration: webConfiguration)
        wView.uiDelegate = self
        wView.allowsBackForwardNavigationGestures = true
        view = wView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let myURL = URL(string: link)
        let myRequest = URLRequest(url: myURL!)
        wView.load(myRequest)
        navigationController?.setNavigationBarHidden(false, animated: false)
        setupNavigationBar()
    }

    // MARK: - Setup navigation
    private func setupNavigationBar() {
        let restartButton = UIBarButtonItem(title: "Restart game", style: .plain, target: self, action: #selector(restartGame))
        self.navigationItem.leftBarButtonItem = restartButton
    }
    
    @objc private func restartGame() {
        delegate?.restartGame()
    }
}
