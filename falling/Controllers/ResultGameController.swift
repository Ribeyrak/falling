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
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.setNavigationBarHidden(false, animated: false)
        setupWebView()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - Private func
    private func setupWebView() {
        let webConfiguration = WKWebViewConfiguration()
        wView = WKWebView(frame: .zero, configuration: webConfiguration)
        wView.uiDelegate = self
        wView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(wView)
        
        guard let urlString = link, let url = URL(string: urlString) else {
            print("Invalid URL string.")
            return
        }
        let request = URLRequest(url: url)
        wView.load(request)
        
        NSLayoutConstraint.activate([
            wView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            wView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            wView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            wView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        let restartButton = UIBarButtonItem(title: "Restart game", style: .plain, target: self, action: #selector(restartGame))
        self.navigationItem.leftBarButtonItem = restartButton
    }
    
    @objc private func restartGame() {
        delegate?.restartGame()
    }
}
