//
//  OAuth2Storage.swift
//  ImageFeed
//
//  Created by alexander on 20.12.2024.
//

import Foundation
import SwiftKeychainWrapper

protocol OAuth2StorageProtocol {
    var token: String? { get set }
}

final class OAuth2Storage: OAuth2StorageProtocol {
    static let shared = OAuth2Storage()
    private init() {}
    
    private enum Keys: String {
        case token
    }

    private let userDefaults = UserDefaults.standard

    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: Keys.token.rawValue)
        }
        set {
            guard let newValue else {
                assertionFailure("Value for token is invalid")
                return
            }
            KeychainWrapper.standard.set(newValue, forKey: Keys.token.rawValue)
        }
    }

    func clean() {
        KeychainWrapper.standard.removeAllKeys()
    }
}
