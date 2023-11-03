//
//  DBManager.swift
//  falling
//
//  Created by Evhen Lukhtan on 03.11.2023.
//

import UIKit
import Firebase
import FirebaseDatabase

class DBManager {
    
    static let shared = DBManager()
    private(set) var preloadedData: [String: String] = [:]
    var ref: DatabaseReference!
    
    func preloadData(completion: @escaping () -> Void) {
        let group = DispatchGroup()
        
        let keys = [R.GameResult.winner, R.GameResult.loser]
        for key in keys {
            group.enter()
            DBManager.shared.getInfo(for: key) { infoDB in
                self.preloadedData[key] = infoDB
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
    func getInfo(for key: String, completion: @escaping (String?) -> Void) {
        ref = Database.database().reference()
        ref.child(key).getData(completion: { error, snapshot in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            let info = snapshot?.value as? String ?? "Unknown"
            completion(info)
        })
    }
}
