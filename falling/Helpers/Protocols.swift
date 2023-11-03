//
//  Protocols.swift
//  falling
//
//  Created by Evhen Lukhtan on 03.11.2023.
//

import Foundation

protocol GameSceneDelegate: AnyObject {
    func gameDidEnd(winner: Bool)
}

protocol GameRestartDelegate: AnyObject {
    func restartGame()
}
