//
//  GameViewController.swift
//  falling
//
//  Created by Evhen Lukhtan on 01.11.2023.
//

import UIKit
import SpriteKit
import GameplayKit
import Lottie

class GameViewController: UIViewController {
    
    var preloadedData: String?
    
    // MARK: - UI
    private let bg: UIImageView = {
        let v = UIImageView()
        v.backgroundColor = .systemMint
        return v
    }()
    
    private let startBtn: UIButton = {
        let v = UIButton(type: .system)
        v.isHidden = true
        v.setBackgroundImage(UIImage(named: "startBtn"), for: .normal)
        return v
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        makeAnimationLoader()
        animationToScreen()
        navigationController?.isNavigationBarHidden = true
    }

    // MARK: - Private func
    private func setupUI() {
        view.addSubview(bg)
        bg.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bg.topAnchor.constraint(equalTo: view.topAnchor),
            bg.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bg.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bg.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        view.addSubview(startBtn)
        startBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            startBtn.heightAnchor.constraint(equalToConstant: 200),
            startBtn.widthAnchor.constraint(equalToConstant: 200),
            startBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startBtn.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        startBtn.addTarget(self, action: #selector(startGameAction), for: .touchUpInside)
    }
    
    // Animation
    private func makeAnimationLoader() {
        let animationView = LottieAnimationView(name: "loaderGif")
        bg.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: bg.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: bg.centerYAnchor)
        ])
        animationView.loopMode = .loop
        animationView.play()
    }
    
    private func animationToScreen() {
        DBManager.shared.preloadData {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.bg.isHidden = true
                self.startBtn.isHidden = false
            }
        }
    }
    
     @objc func startGameAction() {
        startBtn.isHidden = true
        if let view = self.view as? SKView {
            let transition = SKTransition.fade(withDuration: 1)
            
            if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
                scene.gameDelegate = self
                scene.scaleMode = .fill
                view.presentScene(scene, transition: transition)
            }
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: - Show result
extension GameViewController: GameSceneDelegate {
    func gameDidEnd(winner: Bool) {
        let resultIdentifier = winner ? R.GameResult.winner : R.GameResult.loser
        print(resultIdentifier)
        let result = DBManager.shared.preloadedData[resultIdentifier]
        DispatchQueue.main.async {
            if let navigationController = self.navigationController {
                let resultVC = ResultGameController()
                resultVC.delegate = self
                resultVC.link = result
                navigationController.pushViewController(resultVC, animated: true)
            }
        }
    }
}

// MARK: - Restart game from web
extension GameViewController: GameRestartDelegate {
    func restartGame() {
        if let navigationController = self.navigationController {
            navigationController.popToRootViewController(animated: true)
            let transitionDuration = navigationController.transitionCoordinator?.transitionDuration ?? 0
            DispatchQueue.main.asyncAfter(deadline: .now() + transitionDuration) {
                self.startGameAction()
            }
        }
    }

}
