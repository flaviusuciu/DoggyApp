//
//  PetsPersistencyManager.swift
//  DoggyApp
//
//  Created by Flaviu Adrian Suciu on 06.11.2022.
//

import Foundation
import RxSwift

class PersistanceManager {

    // MARK: - Properties

    static let shared = PersistanceManager()

    var apiKey: String
    var apiSecret: String
    private let bearerKey = "Bearer"
    lazy var currentToken : decodedToken? = nil
    private lazy var disposeBag = DisposeBag()
    private lazy var dateFormatter = DateFormatter(dateFormat: GlobalConstants.localPetsDateFormat)

    // Initialization

    private init() {
        guard let filePath = Bundle.main.path(forResource: "PetFinderAccess", ofType: "plist") else {
            fatalError("Couldn't find file 'PetFinderAccess.plist'.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let keyValue = plist?.object(forKey: "API_key") as? String, let keySecret = plist?.object(forKey: "API_secret") as? String else {
            fatalError("Couldn't find key 'API_key' in 'PetFinderAccess.plist'.")
        }
        self.apiKey = keyValue
        self.apiSecret = keySecret
    }
    
    func fetchTokenFromWebServiceAndSave() {
        PetService().fetchToken(apiKey: self.apiKey, apiSecret: self.apiSecret).subscribe(onNext: { token in
            self.saveToken(decodedToken: token)
        }, onError: { error in
            print(error)
        }).disposed(by: disposeBag)
    }

    func saveToken(decodedToken: decodedToken) {
        let tokenDateString = self.dateFormatter.string(from: Date().addingTimeInterval(Double(decodedToken.token.expires_in)))
//        let tokenDate = Date().addingTimeInterval(Double(decodedToken.token.expires_in))
//        let attributes: [String: Any] = [
//                kSecValueData as String: Data(decodedToken.token.access_token.utf8),
//                kSecClass as String: kSecClassGenericPassword,
//                kSecAttrCreationDate as String: Data(tokenDate.timeIntervalSince1970), //Will be used as expiration date instead
//                kSecAttrService as String: "DogFinder",
//                kSecAttrAccount as String: "DoggyApp"
//            ]
        var status = KeyChain.save(key: "token", data: Data(decodedToken.token.access_token.utf8))
            if status == errSecSuccess {
                print("token saved successfully in the keychain")
            } else {
                print("Something went wrong trying to save the token in the keychain: \(status)")
            }
        status = KeyChain.save(key: "expiration", data: Data(tokenDateString.utf8))
            if status == errSecSuccess {
                print("Token expiration saved successfully in the keychain")
            } else {
                print("Something went wrong trying to save the token expiration in the keychain: \(status)")
            }
    }
    
    func checkTokenValidityAndRefetchIfNeeded() {
        guard let existingToken = KeyChain.load(key: "token"), let expirationDateStringData = KeyChain.load(key: "expiration") else {
            fetchTokenFromWebServiceAndSave()
            return
        }
        if let dateFromTokenExpirationString = String(data: expirationDateStringData, encoding: .utf8),
           let accessToken = String(data: existingToken, encoding: .utf8),
           let expirationDate = self.dateFormatter.date(from: dateFromTokenExpirationString){
            if Date.now < expirationDate {
                self.currentToken = decodedToken(token: token(token_type: self.bearerKey,
                                                              expires_in: Int(expirationDate - Date.now),
                                                              access_token: accessToken), isExpired: false)
            } else {
                fetchTokenFromWebServiceAndSave()
                return
            }
        } else {
            fetchTokenFromWebServiceAndSave()
            return
        }
    }
    
    private func fetchAPITokenAndExpiration() -> decodedToken? {
        
        // Set query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecValueData as String: kSecMatchLimitOne,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true,
        ]
        
        var item: CFTypeRef?

        // Check if user exists in the keychain
        if SecItemCopyMatching(query as CFDictionary, &item) == noErr {
            // Extract result
            if let existingItem = item as? [String: Any],
               let date = existingItem[kSecAttrCreationDate as String] as? String,
               let tokenData = existingItem[kSecValueData as String] as? Data,
               let tokenPassword = String(data: tokenData, encoding: .utf8)
            {
                print(date)
                print(tokenPassword)
                
                guard let expirationDate = self.dateFormatter.date(from: date) else {
                    return decodedToken(token: token(token_type: self.bearerKey,
                                                 expires_in: 0,
                                                 access_token: tokenPassword),
                                    isExpired: true)
                    
                }
                if expirationDate < Date() {
                    return decodedToken(token: token(token_type: self.bearerKey,
                                                 expires_in: Int(expirationDate.timeIntervalSince(Date())),
                                                 access_token: tokenPassword),
                                    isExpired: true)
                    
                } else {
                    return decodedToken(token: token(token_type: "Bearer",
                                                     expires_in: 0,
                                                     access_token: tokenPassword),
                                        isExpired: true)
                }
                
            }
        } else {
            print("Something went wrong trying to find the user in the keychain")
            return nil
        }
    
        return nil
    }
}

// MARK - Date Extensions

extension DateFormatter {
    convenience init(dateFormat: String) {
       self.init()
       self.dateFormat = dateFormat
    }
}

extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}
